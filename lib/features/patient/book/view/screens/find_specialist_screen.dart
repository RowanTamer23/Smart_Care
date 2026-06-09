import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Doctor {
  final String name, specialty, distance, rating;
  final Color avatarBg;
  final bool hasFilter;
  final String? id;
  final Map<String, dynamic>? rawData;

  const _Doctor({
    required this.name,
    required this.specialty,
    required this.distance,
    required this.rating,
    required this.avatarBg,
    this.hasFilter = false,
    this.id,
    this.rawData,
  });
}

const _doctors = [
  _Doctor(
      name: 'Dr. Michael Park',
      specialty: 'General Practice',
      distance: '1.2 km away',
      rating: '4.9',
      avatarBg: Color(0xFFCCFBF1)),
  _Doctor(
      name: 'Dr. Sarah Chen',
      specialty: 'Cardiologist',
      distance: '2.4 km away',
      rating: '10.0',
      avatarBg: Color(0xFFFCE7F3)),
  _Doctor(
      name: 'Dr. David Lee',
      specialty: 'Dermatologist',
      distance: '0.8 km away',
      rating: '4.8',
      avatarBg: Color(0xFFDBEAFE)),
  _Doctor(
      name: 'Dr. Abigail Morgan',
      specialty: 'Orthopedic Surgeon',
      distance: '3.1 km away',
      rating: '4.9',
      avatarBg: Color(0xFFEDE9FE),
      hasFilter: true),
];

class FindSpecialistScreen extends StatefulWidget {
  const FindSpecialistScreen({super.key});

  @override
  State<FindSpecialistScreen> createState() => _FindSpecialistScreenState();
}

class _FindSpecialistScreenState extends State<FindSpecialistScreen> {
  int _tab = 0;
  final _tabs = ['General', 'Dental', 'Cardiology'];
  List<_Doctor> _displayDoctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final res = await Supabase.instance.client
          .from('medical_staff_profiles')
          .select('*, profiles(full_name), specialties(name)');

      final mapped = (res as List).map((item) {
        final profile = item['profiles'] as Map<String, dynamic>?;
        final specialty = item['specialties'] as Map<String, dynamic>?;
        final years = item['years_experience'];
        return _Doctor(
          id: item['id'] as String,
          name: profile?['full_name'] as String? ?? 'Unknown Doctor',
          specialty: specialty?['name'] as String? ?? 'Medical Specialist',
          distance: years != null ? '$years+ yrs exp' : '5+ yrs exp',
          rating: '4.9',
          avatarBg: const Color(0xFFCCFBF1),
          rawData: item,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _displayDoctors = mapped.isEmpty ? _doctors : mapped;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _displayDoctors = _doctors;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: Text('Find a Specialist',
            style: AppText.display(20, color: AppColors.primary)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                const CPSearchBar(hint: 'Search by specialty or name'),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        _tabs.length,
                        (i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CPChip(
                                  label: _tabs[i],
                                  active: i == _tab,
                                  onTap: () => setState(() => _tab = i)),
                            )),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayDoctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) =>
                        _DoctorCard(doctor: _displayDoctors[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final _Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: doctor.avatarBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: doctor.avatarBg.computeLuminance() > 0.5
                          ? AppColors.primary
                          : Colors.white,
                      size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(doctor.name,
                                  style: AppText.display(15))),
                          _RatingBadge(rating: doctor.rating),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(doctor.specialty,
                          style:
                              AppText.body(13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(doctor.distance,
                              style: AppText.label(color: AppColors.textMuted)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.doctorProfileScreen,
                                arguments: doctor.rawData ??
                                    {
                                      'id': doctor.id ??
                                          'f5a8703e-02ba-46a7-9215-163ef0c5a473',
                                      'profiles': {'full_name': doctor.name},
                                      'specialties': {'name': doctor.specialty},
                                      'years_experience': 15,
                                      'consultation_fee': 150.0,
                                      'bio':
                                          'Board-certified clinical specialist with years of medical experience.',
                                    },
                              );
                            },
                            child: Text('View Profile',
                                style: AppText.body(12,
                                    color: AppColors.primary,
                                    weight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.doctorProfileScreen,
                        arguments: doctor.rawData ??
                            {
                              'id': doctor.id ??
                                  'f5a8703e-02ba-46a7-9215-163ef0c5a473',
                              'profiles': {'full_name': doctor.name},
                              'specialties': {'name': doctor.specialty},
                              'years_experience': 15,
                              'consultation_fee': 150.0,
                              'bio':
                                  'Board-certified clinical specialist with years of medical experience.',
                            },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Book Visit',
                        style: AppText.body(14,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final String rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(rating, style: AppText.label(color: AppColors.accent, size: 12)),
        ],
      ),
    );
  }
}
