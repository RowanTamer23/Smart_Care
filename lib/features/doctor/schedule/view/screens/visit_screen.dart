import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/patient/profile/data/model/lab_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitScreen extends StatefulWidget {
  final Appointment appointment;
  final PatientProfile patientProfile;
  final List<MedicalRecord> medicalRecords;
  final List<PatientLab> labs;

  const VisitScreen({
    super.key,
    required this.appointment,
    required this.patientProfile,
    required this.medicalRecords,
    required this.labs,
  });

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFinishing = false;
  late String _currentUserId;
  late String _otherUserId;
  List<MedicalRecord> _medicalRecords = [];
  List<PatientLab> _labs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _otherUserId =
        widget.appointment.patientAuthId ?? widget.appointment.patientProfileId;
    _medicalRecords = widget.medicalRecords;
    _labs = widget.labs;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Active Visit', style: AppTextStyles.heading3),
        centerTitle: true,
        actions: [
          if (_isFinishing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            TextButton.icon(
              onPressed: _finishAppointment,
              icon: const Icon(Icons.check_circle_outline,
                  color: AppColors.stable, size: 20),
              label: Text('Finish',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.stable, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Video call section
          _buildVideoSection(),
          // Tabs section
          _buildTabsSection(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientHistoryTab(),
                _buildLabsTab(),
                _buildAddRecordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finishAppointment() {
    if (_isFinishing) return;

    setState(() => _isFinishing = true);

    context
        .read<AppointmentCubit>()
        .updateAppointmentStatus(
          appointmentId: widget.appointment.id,
          status: AppointmentStatus.completed,
          staffProfileId: widget.appointment.staffProfileId,
        )
        .then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment completed successfully!'),
            backgroundColor: AppColors.stable,
          ),
        );
        Navigator.pop(context);
      }
    }).catchError((err) {
      print('Error completing appointment: $err');
      if (mounted) {
        setState(() => _isFinishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete appointment: $err'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    });
  }

  Widget _buildVideoSection() {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final appointments = context.read<AppointmentCubit>().appointments;
        final currentAppt = appointments.firstWhere(
          (a) => a.id == widget.appointment.id,
          orElse: () => widget.appointment,
        );

        final hasActiveCall = currentAppt.videoRoomUrl != null &&
            currentAppt.videoRoomUrl!.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!hasActiveCall)
                ElevatedButton.icon(
                  onPressed: () => _startVideoCall(currentAppt),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Start Video Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () => _joinVideoCall(currentAppt),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Join Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.stable,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _endVideoCall(currentAppt),
                  icon: const Icon(Icons.call_end_rounded, size: 20),
                  label: const Text('End Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.chatScreen,
                    arguments: {
                      'appointmentId': widget.appointment.id,
                      'currentUserId': _currentUserId,
                      'otherUserId': _otherUserId,
                      'otherUserName': widget.patientProfile.fullName,
                      'otherUserRole': 'Patient',
                      'otherUserAvatar': null,
                    },
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startVideoCall(Appointment appt) {
    context
        .read<AppointmentCubit>()
        .startVideoCall(
          appointmentId: appt.id,
          staffProfileId: appt.staffProfileId,
        )
        .then((_) {
      _joinVideoCall(appt);
    }).catchError((err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call: $err'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    });
  }

  void _joinVideoCall(Appointment appt) {
    final doctorName =
        context.read<ProfileCubit>().doctor?.fullName ?? 'Doctor';
    Navigator.pushNamed(
      context,
      Routes.videoCall,
      arguments: {
        'callId': appt.id,
        'userId': _currentUserId,
        'userName': doctorName,
      },
    );
  }

  void _endVideoCall(Appointment appt) {
    context
        .read<AppointmentCubit>()
        .endVideoCall(
          appointmentId: appt.id,
          staffProfileId: appt.staffProfileId,
        )
        .then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video call ended.'),
            backgroundColor: AppColors.stable,
          ),
        );
      }
    }).catchError((err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end call: $err'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    });
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body,
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'Labs'),
          Tab(text: 'Records'),
        ],
      ),
    );
  }

  Widget _buildPatientHistoryTab() {
    // Combine medical records and labs for patient history
    final allRecords = [
      ..._medicalRecords.map((r) => {'type': 'medical', 'data': r}),
      ..._labs.map((l) => {'type': 'lab', 'data': l}),
    ];
    // Sort by date
    allRecords.sort((a, b) {
      final dateA = a['type'] == 'medical'
          ? (a['data'] as MedicalRecord).recordDate
          : (a['data'] as PatientLab).createdAt;
      final dateB = b['type'] == 'medical'
          ? (b['data'] as MedicalRecord).recordDate
          : (b['data'] as PatientLab).createdAt;
      return dateB.compareTo(dateA);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient History', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          if (allRecords.isEmpty)
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
                  Icon(Icons.history_rounded,
                      size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No records found',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: allRecords.length,
                itemBuilder: (context, index) {
                  final item = allRecords[index];
                  if (item['type'] == 'medical') {
                    return _buildMedicalRecordCard(
                        item['data'] as MedicalRecord);
                  } else {
                    return _buildLabCard(item['data'] as PatientLab);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.recordType,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _formatDate(record.recordDate),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          if (record.symptoms != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Symptoms', record.symptoms!),
          ],
          if (record.diagnosis != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Diagnosis', record.diagnosis!),
          ],
          if (record.treatment != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Treatment', record.treatment!),
          ],
        ],
      ),
    );
  }

  Widget _buildLabsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lab Results', style: AppTextStyles.heading3),
              ElevatedButton.icon(
                onPressed: _showAddLabDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Lab'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_labs.isEmpty)
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
                  Icon(Icons.science_rounded,
                      size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No lab results',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _labs.length,
                itemBuilder: (context, index) {
                  final lab = _labs[index];
                  return _buildLabCard(lab);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddRecordTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medical Records', style: AppTextStyles.heading3),
              ElevatedButton.icon(
                onPressed: _showAddMedicalRecordDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                Icon(Icons.medical_information_outlined,
                    size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text('Add medical records for this patient visit',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(PatientLab lab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lab Result',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _formatDate(lab.createdAt),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          if (lab.note != null) ...[
            const SizedBox(height: 8),
            Text(lab.note!, style: AppTextStyles.bodySmall),
          ],
          if (lab.fileUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lab.fileUrls.map((url) {
                return Chip(
                  label: Text('File', style: AppTextStyles.label),
                  avatar: const Icon(Icons.attach_file_rounded, size: 16),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }

  void _showAddMedicalRecordDialog() {
    final _formKey = GlobalKey<FormState>();
    final _symptomsController = TextEditingController();
    final _diagnosisController = TextEditingController();
    final _treatmentController = TextEditingController();
    final _notesController = TextEditingController();
    late DateTime _selectedDate;
    late String _selectedType;
    bool isSaving = false;

    _selectedDate = DateTime.now();
    _selectedType = 'visit';

    InputDecoration _inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }

    String _formatDate(DateTime date) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Medical Record',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: _inputDecoration(
                                'Record Type', Icons.category_rounded),
                            items: const [
                              DropdownMenuItem(
                                  value: 'visit', child: Text('Doctor Visit')),
                              DropdownMenuItem(
                                  value: 'surgery', child: Text('Surgery')),
                              DropdownMenuItem(
                                  value: 'prescription',
                                  child: Text('Prescription')),
                            ],
                            onChanged: (val) => setDialogState(
                                () => _selectedType = val ?? 'visit'),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: widget.appointment.staffProfileId,
                            decoration: _inputDecoration(
                                'Doctor', Icons.person_pin_rounded),
                            items: [
                              DropdownMenuItem(
                                value: widget.appointment.staffProfileId,
                                child: Text('Current Doctor'),
                              ),
                            ],
                            onChanged: null,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() => _selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Record Date',
                                          style: AppTextStyles.caption),
                                      const SizedBox(height: 2),
                                      Text(_formatDate(_selectedDate),
                                          style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _symptomsController,
                            decoration: _inputDecoration(
                                'Symptoms', Icons.sick_rounded),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _diagnosisController,
                            decoration: _inputDecoration(
                                'Diagnosis / Condition Name',
                                Icons.healing_rounded),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'This field is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _treatmentController,
                            decoration: _inputDecoration(
                                'Treatment / Dose / Value',
                                Icons.medication_rounded),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'This field is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            decoration: _inputDecoration(
                                'Additional Notes', Icons.description_rounded),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setDialogState(() => isSaving = true);

                                  try {
                                    final medicalRecord = MedicalRecord(
                                      id: 'temp',
                                      patientProfileId:
                                          widget.patientProfile.id,
                                      staffProfileId:
                                          widget.appointment.staffProfileId,
                                      appointmentId: widget.appointment.id,
                                      symptoms: _symptomsController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _symptomsController.text.trim(),
                                      diagnosis: _diagnosisController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _diagnosisController.text.trim(),
                                      treatment: _treatmentController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _treatmentController.text.trim(),
                                      recordDate: _selectedDate,
                                      recordType: _selectedType,
                                      notes:
                                          _notesController.text.trim().isEmpty
                                              ? null
                                              : _notesController.text.trim(),
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    );

                                    // Use direct Supabase insert for medical record
                                    final supabase = Supabase.instance.client;
                                    final recordMap = medicalRecord.toMap();
                                    recordMap.remove(
                                        'id'); // Let Supabase auto-generate ID
                                    await supabase
                                        .from('medical_records')
                                        .insert(recordMap);

                                    // Fetch updated medical records from database
                                    final updatedRecordsRes = await supabase
                                        .from('medical_records')
                                        .select()
                                        .eq('patient_profile_id',
                                            widget.patientProfile.id)
                                        .order('record_date', ascending: false);
                                    final updatedRecords = (updatedRecordsRes
                                            as List)
                                        .map((e) => MedicalRecord.fromMap(e))
                                        .toList();

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Medical record added successfully!'),
                                          backgroundColor: AppColors.stable,
                                        ),
                                      );
                                      setState(() {
                                        _medicalRecords.clear();
                                        _medicalRecords.addAll(updatedRecords);
                                      });
                                    }
                                  } catch (e) {
                                    print('Error adding medical record: $e');
                                    setDialogState(() => isSaving = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to add medical record: $e'),
                                          backgroundColor: AppColors.critical,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Save',
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLabDialog() {
    final _formKey = GlobalKey<FormState>();
    final _noteController = TextEditingController();
    List<String> _selectedFiles = [];
    bool isSaving = false;

    InputDecoration _inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Lab Result',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _noteController,
                            decoration: _inputDecoration(
                                'Lab Note', Icons.description_rounded),
                            maxLines: 3,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'This field is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          // File upload section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.attach_file_rounded,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Attachments',
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_selectedFiles.isEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO: Implement file picker
                                      setDialogState(() {
                                        _selectedFiles.add(
                                            'sample_file_url_${DateTime.now().millisecondsSinceEpoch}');
                                      });
                                    },
                                    icon: const Icon(Icons.upload_rounded,
                                        size: 18),
                                    label: const Text('Upload File'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.tealLight,
                                      foregroundColor: AppColors.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ..._selectedFiles.map((file) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: AppColors.border),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .insert_drive_file_rounded,
                                                      size: 16,
                                                      color: AppColors.primary),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      file.split('/').last,
                                                      style: AppTextStyles
                                                          .bodySmall,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setDialogState(() {
                                                        _selectedFiles
                                                            .remove(file);
                                                      });
                                                    },
                                                    child: const Icon(
                                                        Icons.close_rounded,
                                                        size: 16,
                                                        color:
                                                            AppColors.critical),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement file picker
                                          setDialogState(() {
                                            _selectedFiles.add(
                                                'sample_file_url_${DateTime.now().millisecondsSinceEpoch}');
                                          });
                                        },
                                        icon: const Icon(Icons.add_rounded,
                                            size: 18),
                                        label: const Text('Add Another File'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.tealLight,
                                          foregroundColor: AppColors.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setDialogState(() => isSaving = true);

                                  try {
                                    // Use direct Supabase insert for lab
                                    final supabase = Supabase.instance.client;
                                    final labMap = {
                                      'patient_profile_id':
                                          widget.patientProfile.id,
                                      'appointment_id': widget.appointment.id,
                                      'staff_profile_id':
                                          widget.appointment.staffProfileId,
                                      'note': _noteController.text.trim(),
                                      'file_urls': _selectedFiles,
                                    };
                                    await supabase
                                        .from('patient_labs')
                                        .insert(labMap);

                                    // Fetch updated labs from database
                                    final updatedLabsRes = await supabase
                                        .from('patient_labs')
                                        .select()
                                        .eq('patient_profile_id',
                                            widget.patientProfile.id)
                                        .order('created_at', ascending: false);
                                    final updatedLabs = (updatedLabsRes as List)
                                        .map((e) => PatientLab.fromMap(e))
                                        .toList();

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Lab result added successfully!'),
                                          backgroundColor: AppColors.stable,
                                        ),
                                      );
                                      setState(() {
                                        _labs.clear();
                                        _labs.addAll(updatedLabs);
                                      });
                                    }
                                  } catch (e) {
                                    print('Error adding lab result: $e');
                                    setDialogState(() => isSaving = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to add lab result: $e'),
                                          backgroundColor: AppColors.critical,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealLight,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary))
                            : Text('Save',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
