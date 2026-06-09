import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentApprovalScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentApprovalScreen({super.key, required this.appointment});

  @override
  State<AppointmentApprovalScreen> createState() => _AppointmentApprovalScreenState();
}

class _AppointmentApprovalScreenState extends State<AppointmentApprovalScreen> {
  bool _loading = true;
  bool _updating = false;
  String? _error;
  PatientProfile? _patientProfile;
  List<MedicalRecord> _medicalRecords = [];
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch patient profile
      final profileRes = await supabase
          .from('patient_profiles')
          .select()
          .eq('id', widget.appointment.patientProfileId)
          .maybeSingle();

      if (profileRes == null) {
        throw 'Patient profile not found.';
      }
      final profile = PatientProfile.fromMap(profileRes);

      // 2. Fetch medical records for this patient
      final recsRes = await supabase
          .from('medical_records')
          .select()
          .eq('patient_profile_id', widget.appointment.patientProfileId)
          .order('record_date', ascending: false);
      final records = (recsRes as List).map((e) => MedicalRecord.fromMap(e)).toList();

      // 3. Fetch appointments between this patient and doctor
      final appsRes = await supabase
          .from('appointments')
          .select()
          .eq('patient_profile_id', widget.appointment.patientProfileId)
          .eq('staff_profile_id', widget.appointment.staffProfileId)
          .order('appointment_date', ascending: false);
      final appointments = (appsRes as List).map((e) => Appointment.fromMap(e)).toList();

      if (mounted) {
        setState(() {
          _patientProfile = profile;
          _medicalRecords = records;
          _appointments = appointments;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _updateStatus(AppointmentStatus newStatus) {
    if (_updating) return;

    setState(() => _updating = true);

    context.read<AppointmentCubit>().updateAppointmentStatus(
      appointmentId: widget.appointment.id,
      status: newStatus,
      staffProfileId: widget.appointment.staffProfileId,
    ).then((_) {
      if (mounted) {
        final verb = newStatus == AppointmentStatus.confirmed ? 'accepted' : 'refused';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment $verb successfully!'),
            backgroundColor: newStatus == AppointmentStatus.confirmed ? AppColors.stable : AppColors.critical,
          ),
        );
        Navigator.pop(context);
      }
    }).catchError((err) {
      if (mounted) {
        setState(() => _updating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $err'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _patientProfile?.fullName ?? widget.appointment.patientName ?? 'Patient Details';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Approve Appointment', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: _buildBody(displayName),
      bottomNavigationBar: _loading || _error != null ? null : _buildBottomActions(),
    );
  }

  Widget _buildBody(String displayName) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.critical),
              const SizedBox(height: 12),
              Text('Failed to load patient profile', style: AppTextStyles.heading3),
              const SizedBox(height: 4),
              Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _fetchPatientData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final docPatient = DoctorPatient(
      profile: _patientProfile!,
      medicalRecords: _medicalRecords,
      appointments: _appointments,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(docPatient),
          const SizedBox(height: 16),
          _buildAppointmentsSummary(docPatient.appointments),
          const SizedBox(height: 16),
          _buildMedicalRecords(docPatient.medicalRecords),
        ],
      ),
    );
  }

  Widget _buildProfileCard(DoctorPatient docPatient) {
    final profile = docPatient.profile;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  docPatient.displayName.isNotEmpty ? docPatient.displayName[0].toUpperCase() : 'P',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(docPatient.displayName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    _buildStatusBadge(docPatient.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _buildInfoGrid(profile, docPatient.age),
          if (profile.allergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildChipSection('Allergies', profile.allergies, color: AppColors.critical, bgColor: AppColors.criticalLight),
          ],
          if (profile.chronicDiseases.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildChipSection('Chronic Diseases', profile.chronicDiseases, color: AppColors.followUp, bgColor: AppColors.followUpLight),
          ],
          if (profile.address != null && profile.address!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(profile.address!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoGrid(PatientProfile profile, int? age) {
    final items = <(String, String)>[
      if (age != null) ('Age', '$age years'),
      if (profile.gender != null) ('Gender', _capitalize(profile.gender!.name)),
      if (profile.bloodType != null) ('Blood Type', profile.bloodType!.value),
      if (profile.insuranceCompany != null && profile.insuranceCompany!.isNotEmpty)
        ('Insurance', profile.insuranceCompany!),
      if (profile.insuranceNumber != null && profile.insuranceNumber!.isNotEmpty)
        ('Policy #', profile.insuranceNumber!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items.map((item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.$1, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            Text(item.$2, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChipSection(String title, List<String> items, {required Color color, required Color bgColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item, style: AppTextStyles.label.copyWith(color: color)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bg;
    switch (status) {
      case 'STABLE':
        color = AppColors.stable;
        bg = AppColors.stableLight;
        break;
      case 'FOLLOW-UP':
        color = AppColors.followUp;
        bg = AppColors.followUpLight;
        break;
      default:
        color = AppColors.textMuted;
        bg = AppColors.border;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: AppTextStyles.label.copyWith(color: color)),
    );
  }

  Widget _buildAppointmentsSummary(List<Appointment> appointments) {
    if (appointments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appointment History', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        ...appointments.map((a) => _buildAppointmentTile(a)),
      ],
    );
  }

  Widget _buildAppointmentTile(Appointment a) {
    final statusColors = {
      AppointmentStatus.completed: AppColors.stable,
      AppointmentStatus.confirmed: AppColors.primary,
      AppointmentStatus.pending: AppColors.followUp,
      AppointmentStatus.cancelled: AppColors.textMuted,
      AppointmentStatus.rejected: AppColors.critical,
    };
    final color = statusColors[a.status] ?? AppColors.textMuted;

    final dateStr = _formatDate(a.appointmentDate);
    final hour = a.appointmentTime.hourOfPeriod == 0 ? 12 : a.appointmentTime.hourOfPeriod;
    final minute = a.appointmentTime.minute.toString().padLeft(2, '0');
    final period = a.appointmentTime.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '$hour:$minute $period';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$dateStr · $timeStr', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(a.careType?.value ?? 'In-person', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _capitalize(a.status.name),
              style: AppTextStyles.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecords(List<MedicalRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medical Records', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.medical_information_outlined, size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text('No medical records yet', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text('Records will appear after visits are documented.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          )
        else
          ...records.map((r) => _buildRecordCard(r)),
      ],
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 18),
          ),
          title: Text(_capitalize(record.recordType), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(_formatDate(record.recordDate), style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          children: [
            if (record.symptoms != null) _recordRow('Symptoms', record.symptoms!),
            if (record.diagnosis != null) _recordRow('Diagnosis', record.diagnosis!),
            if (record.treatment != null) _recordRow('Treatment', record.treatment!),
            if (record.doctorNotes != null) _recordRow('Doctor Notes', record.doctorNotes!),
            if (record.notes != null) _recordRow('Notes', record.notes!),
          ],
        ),
      ),
    );
  }

  Widget _recordRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    // Show actions ONLY if the appointment is currently PENDING
    if (widget.appointment.status != AppointmentStatus.pending) {
      final statusColors = {
        AppointmentStatus.completed: AppColors.stable,
        AppointmentStatus.confirmed: AppColors.primary,
        AppointmentStatus.cancelled: AppColors.textMuted,
        AppointmentStatus.rejected: AppColors.critical,
      };
      final color = statusColors[widget.appointment.status] ?? AppColors.textMuted;
      
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                'This appointment is already ${_capitalize(widget.appointment.status.name)}',
                style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3)),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _updating ? null : () => _updateStatus(AppointmentStatus.rejected),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.critical.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _updating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.critical))
                  : Text('Refuse', style: AppTextStyles.heading3.copyWith(color: AppColors.critical, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ElevatedButton(
              onPressed: _updating ? null : () => _updateStatus(AppointmentStatus.confirmed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _updating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Accept', style: AppTextStyles.heading3.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
