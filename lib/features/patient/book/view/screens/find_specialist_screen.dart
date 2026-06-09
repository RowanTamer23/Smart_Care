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
  List<String> _allSpecialties = [];
  String? _selectedSpecialtyFilter;
  List<_Doctor> _allDoctors = [];
  List<_Doctor> _displayDoctors = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final res = await Supabase.instance.client
          .from('medical_staff_profiles')
          .select('*, profiles(full_name, avatar_url), specialties(name)');

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

      List<String> allSpecialtiesList = [];
      try {
        final specialtiesRes =
            await Supabase.instance.client.from('specialties').select('name');
        allSpecialtiesList = (specialtiesRes as List)
            .map((item) => item['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      } catch (e) {
        debugPrint('Error loading specialties from table: $e');
        // Fallback to specialties from loaded doctors
        allSpecialtiesList = mapped.map((d) => d.specialty).toSet().toList()
          ..sort();
      }

      if (mounted) {
        setState(() {
          _allDoctors = mapped.isEmpty ? _doctors : mapped;
          _allSpecialties = allSpecialtiesList;
          _loading = false;
          _filterDoctors();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allDoctors = _doctors;
          _allSpecialties = _allDoctors.map((d) => d.specialty).toSet().toList()
            ..sort();
          _loading = false;
          _filterDoctors();
        });
      }
    }
  }

  bool _isSpecialtyMatch(String docSpec, String selSpec) {
    final cleanDoc =
        docSpec.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
    final cleanSel =
        selSpec.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

    if (cleanDoc == cleanSel) return true;
    if (cleanDoc.contains(cleanSel) || cleanSel.contains(cleanDoc)) return true;

    // Match roots (e.g. cardiology vs cardiologist, dentistry vs dentist)
    if (cleanDoc.length >= 5 && cleanSel.length >= 5) {
      final rootDoc = cleanDoc.substring(0, 5);
      final rootSel = cleanSel.substring(0, 5);
      if (rootDoc == rootSel) return true;
    }

    return false;
  }

  void _filterDoctors() {
    final query = _searchQuery.toLowerCase().trim();

    setState(() {
      _displayDoctors = _allDoctors.where((doctor) {
        // 1. Tab category filter
        if (_tab == 1) {
          // Dental filter
          final specLower = doctor.specialty.toLowerCase();
          final isDentist = specLower.contains('dent') ||
              specLower.contains('ortho') ||
              specLower.contains('oral') ||
              specLower.contains('periodont') ||
              specLower.contains('endodont') ||
              specLower.contains('prosthodont');
          if (!isDentist) return false;
        } else if (_tab == 2) {
          // Cardiology filter
          final specLower = doctor.specialty.toLowerCase();
          final isCardiologist =
              specLower.contains('cardio') || specLower.contains('heart');
          if (!isCardiologist) return false;
        }

        // 2. Specialty Bottom Sheet filter
        if (_selectedSpecialtyFilter != null &&
            !_isSpecialtyMatch(doctor.specialty, _selectedSpecialtyFilter!)) {
          return false;
        }

        // 3. Search query filter
        if (query.isNotEmpty) {
          final nameMatches = doctor.name.toLowerCase().contains(query);
          final specialtyMatches =
              doctor.specialty.toLowerCase().contains(query);
          if (!nameMatches && !specialtyMatches) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showSpecialtyFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SpecialtyFilterBottomSheet(
        specialties: _allSpecialties,
        initialSelected: _selectedSpecialtyFilter,
        onSelected: (val) {
          setState(() {
            _selectedSpecialtyFilter = val;
            _filterDoctors();
          });
        },
      ),
    );
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
                CPSearchBar(
                  hint: 'Search by specialty or name',
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterDoctors();
                  },
                  trailing: GestureDetector(
                    onTap: () => _showSpecialtyFilterBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedSpecialtyFilter != null
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedSpecialtyFilter != null
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: _selectedSpecialtyFilter != null
                                ? Colors.white
                                : AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedSpecialtyFilter != null
                                ? (_selectedSpecialtyFilter!.length > 12
                                    ? '${_selectedSpecialtyFilter!.substring(0, 10)}...'
                                    : _selectedSpecialtyFilter!)
                                : 'Filter',
                            style: AppText.label(
                              color: _selectedSpecialtyFilter != null
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 11,
                              weight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedSpecialtyFilter != null) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSpecialtyFilter = null;
                                  _filterDoctors();
                                });
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _displayDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded,
                                size: 48, color: AppColors.textMuted),
                            Text(
                              'No specialists found',
                              style: AppText.body(14,
                                  color: AppColors.textSecondary,
                                  weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (doctor.rawData?['profiles']?['avatar_url'] !=
                                null &&
                            (doctor.rawData?['profiles']?['avatar_url']
                                    as String)
                                .isNotEmpty)
                        ? Image.network(
                            doctor.rawData?['profiles']?['avatar_url']
                                as String,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person_rounded,
                              color: doctor.avatarBg.computeLuminance() > 0.5
                                  ? AppColors.primary
                                  : Colors.white,
                              size: 36,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: doctor.avatarBg.computeLuminance() > 0.5
                                ? AppColors.primary
                                : Colors.white,
                            size: 36,
                          ),
                  ),
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

class _SpecialtyFilterBottomSheet extends StatefulWidget {
  final List<String> specialties;
  final String? initialSelected;
  final ValueChanged<String?> onSelected;

  const _SpecialtyFilterBottomSheet({
    required this.specialties,
    required this.initialSelected,
    required this.onSelected,
  });

  @override
  State<_SpecialtyFilterBottomSheet> createState() =>
      _SpecialtyFilterBottomSheetState();
}

class _SpecialtyFilterBottomSheetState
    extends State<_SpecialtyFilterBottomSheet> {
  String _search = '';
  List<String> _filteredSpecialties = [];

  @override
  void initState() {
    super.initState();
    _filteredSpecialties = widget.specialties;
  }

  void _filter(String val) {
    setState(() {
      _search = val;
      _filteredSpecialties = widget.specialties
          .where((s) => s.toLowerCase().contains(val.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Specialty', style: AppText.display(18)),
                if (widget.initialSelected != null)
                  TextButton(
                    onPressed: () {
                      widget.onSelected(null);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear Filter',
                      style: AppText.body(13,
                          color: AppColors.red, weight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CPSearchBar(
              hint: 'Search specialties...',
              onChanged: _filter,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredSpecialties.length,
              itemBuilder: (context, index) {
                final specialty = _filteredSpecialties[index];
                final isSelected = specialty == widget.initialSelected;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    specialty,
                    style: AppText.body(
                      14,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    widget.onSelected(specialty);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
