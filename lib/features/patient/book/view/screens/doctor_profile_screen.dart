import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/schedule/cubit/availability_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/availability_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/Availability_model.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? doctorData;
  const DoctorProfileScreen({super.key, this.doctorData});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedDay = 0;
  bool _isMorningSelected = true;
  String _selectedTimeText = '';
  AppointmentCareType? _selectedCareType;

  late List<(String, String, DateTime)> _days;

  List<_DoctorReview> _reviews = [];
  bool _isLoadingReviews = true;
  Set<String> _takenSlots = {};

  List<_DoctorCertificate> _certificates = [];
  bool _isLoadingCertificates = true;

  @override
  void initState() {
    super.initState();

    // Generate next 7 days starting today dynamically
    final now = DateTime.now();
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _days = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return (
        weekdayNames[date.weekday - 1],
        date.day.toString(),
        DateTime(date.year, date.month, date.day)
      );
    });

    final supportsVideo = widget.doctorData?['supports_video'] as bool? ?? true;
    final supportsInPerson =
        widget.doctorData?['supports_in_person'] as bool? ?? true;
    final supportsHomeVisit =
        widget.doctorData?['supports_home_visit'] as bool? ?? false;

    if (supportsVideo) {
      _selectedCareType = AppointmentCareType.video;
    } else if (supportsInPerson) {
      _selectedCareType = AppointmentCareType.inPerson;
    } else if (supportsHomeVisit) {
      _selectedCareType = AppointmentCareType.homeVisit;
    }

    // Fetch weekly availability for this doctor
    final staffId = widget.doctorData?['id'] as String?;
    if (staffId != null) {
      context.read<AvailabilityCubit>().getAvailability(staffId);
    }

    _loadDoctorAppointments();
    _loadDoctorReviews();
    _loadDoctorCertificates();
  }

  Future<void> _loadDoctorAppointments() async {
    final staffId = widget.doctorData?['id'] as String?;
    if (staffId == null) {
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('appointments')
          .select('appointment_date, appointment_time, status')
          .eq('staff_profile_id', staffId)
          .neq('status', 'cancelled')
          .neq('status', 'rejected');

      final taken = <String>{};
      for (final item in res as List) {
        final dateStr = item['appointment_date'] as String;
        final timeStr = item['appointment_time'] as String;
        final timeParts = timeStr.split(':');
        final normalizedTime = '${timeParts[0]}:${timeParts[1]}';
        taken.add('$dateStr $normalizedTime');
      }

      if (mounted) {
        setState(() {
          _takenSlots = taken;

          // Ensure selection is valid
          final availabilityState = context.read<AvailabilityCubit>().state;
          if (availabilityState is AvailabilitySuccess) {
            final date = _days[_selectedDay].$3;
            final slots = _generateTimeSlotsForDate(
                date, availabilityState.availabilities);
            if (slots.isNotEmpty) {
              if (_selectedTimeText.isEmpty ||
                  !_isSlotSelectable(_selectedTimeText, date)) {
                _selectFirstAvailableSlot(date, slots);
              }
            } else {
              _selectedTimeText = '';
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading doctor appointments: $e');
    }
  }

  Future<void> _loadDoctorReviews() async {
    final staffId = widget.doctorData?['id'] as String?;
    if (staffId == null) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingReviews = true;
      });
    }

    try {
      final res = await Supabase.instance.client
          .from('reviews')
          .select('*, patient:patient_profiles(*, profiles(full_name))')
          .eq('staff_profile_id', staffId);

      final loadedReviews = <_DoctorReview>[];
      final colorsBg = [
        AppColors.blueLight,
        AppColors.greenLight,
        AppColors.orangeLight,
        AppColors.tealLight
      ];
      final colorsText = [
        AppColors.blue,
        AppColors.green,
        AppColors.orange,
        AppColors.teal
      ];
      int colorIdx = 0;

      for (final item in res as List) {
        final id = item['id']?.toString() ?? '';
        final comment =
            item['comment']?.toString() ?? item['content']?.toString() ?? '';
        final ratingVal =
            double.tryParse(item['rating']?.toString() ?? '') ?? 5.0;
        final createdAtStr = item['created_at']?.toString();

        String dateStr = 'Recently';
        if (createdAtStr != null) {
          try {
            final dt = DateTime.parse(createdAtStr);
            final diff = DateTime.now().difference(dt);
            if (diff.inDays == 0) {
              dateStr = 'Today';
            } else if (diff.inDays == 1) {
              dateStr = '1 day ago';
            } else if (diff.inDays < 30) {
              dateStr = '${diff.inDays} days ago';
            } else {
              dateStr =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            }
          } catch (_) {}
        }

        String authorName = 'Anonymous';
        final patient = item['patient'];
        if (patient is Map) {
          final profiles = patient['profiles'];
          if (profiles is Map) {
            authorName = profiles['full_name']?.toString() ?? 'Anonymous';
          } else {
            authorName = patient['full_name']?.toString() ?? 'Anonymous';
          }
        }

        loadedReviews.add(_DoctorReview(
          id: id,
          author: authorName,
          date: dateStr,
          content: comment,
          rating: ratingVal,
          avatarLetter:
              authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
          avatarBg: colorsBg[colorIdx % colorsBg.length],
          avatarTextColor: colorsText[colorIdx % colorsText.length],
        ));
        colorIdx++;
      }

      if (mounted) {
        setState(() {
          _reviews = loadedReviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews (falling back to empty): $e');
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _loadDoctorCertificates() async {
    final staffId = widget.doctorData?['id'] as String?;
    if (staffId == null) {
      if (mounted) {
        setState(() {
          _isLoadingCertificates = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingCertificates = true;
      });
    }

    try {
      final res = await Supabase.instance.client
          .from('medical_staff_documents')
          .select()
          .eq('staff_profile_id', staffId);

      final certs = (res as List).map((item) {
        return _DoctorCertificate(
          id: item['id'] as String,
          type: item['document_type'] as String? ?? 'Certificate',
          fileUrl: item['file_url'] as String? ?? '',
          status: item['verification_status'] as String? ?? 'pending',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _certificates = certs;
          _isLoadingCertificates = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading doctor certificates: $e');
      if (mounted) {
        setState(() {
          _isLoadingCertificates = false;
        });
      }
    }
  }

  bool _isSlotSelectable(String slot, DateTime date) {
    if (slot.isEmpty) return false;
    final time = _parseSlotTime(slot);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final slotKey = '$dateStr $hourStr:$minuteStr';
    return !_takenSlots.contains(slotKey);
  }

  void _selectFirstAvailableSlot(DateTime date, List<String> slots) {
    String? firstAvailable;
    for (final s in slots) {
      if (_isSlotSelectable(s, date)) {
        firstAvailable = s;
        break;
      }
    }

    if (firstAvailable != null) {
      _selectedTimeText = firstAvailable;
      _isMorningSelected = firstAvailable.endsWith('AM');
    } else {
      _selectedTimeText = '';
    }
  }

  TimeOfDay _parseSlotTime(String slot) {
    final parts = slot.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPm = parts[1].toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> _generateTimeSlotsForDate(
      DateTime date, List<StaffAvailability> availabilities) {
    final weekdayIndex = date.weekday % 7;

    final availability = availabilities.firstWhere(
      (a) => a.weekday == weekdayIndex,
      orElse: () => StaffAvailability(
        id: '',
        staffProfileId: '',
        weekday: weekdayIndex,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        isActive: false,
        createdAt: DateTime.now(),
      ),
    );

    if (!availability.isActive) {
      return [];
    }

    final duration =
        widget.doctorData?['appointment_duration_minutes'] as int? ?? 30;
    final slots = <String>[];

    var currentMinutes =
        availability.startTime.hour * 60 + availability.startTime.minute;
    final endMinutes =
        availability.endTime.hour * 60 + availability.endTime.minute;

    while (currentMinutes + duration <= endMinutes) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);

      final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
      final hourOfPeriod =
          timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
      final hourStrOfPeriod = hourOfPeriod.toString().padLeft(2, '0');
      final minuteStrOfPeriod = timeOfDay.minute.toString().padLeft(2, '0');

      slots.add('$hourStrOfPeriod:$minuteStrOfPeriod $period');
      currentMinutes += duration;
    }

    return slots;
  }

  void _onDaySelected(int index, List<StaffAvailability> availabilities) {
    setState(() {
      _selectedDay = index;

      final date = _days[index].$3;
      final slots = _generateTimeSlotsForDate(date, availabilities);
      if (slots.isNotEmpty) {
        _selectFirstAvailableSlot(date, slots);
      } else {
        _selectedTimeText = '';
      }
    });
  }

  List<String> _getEducation(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('cardio')) {
      return [
        'Harvard Medical School',
        'Cardiology Fellowship',
        'Mass General Hospital'
      ];
    } else if (s.contains('dent')) {
      return ['NYU College of Dentistry', 'DDS Program', 'Clinical Residency'];
    } else if (s.contains('derm')) {
      return ['Stanford University', 'Dermatology Residency', 'Mayo Clinic'];
    } else if (s.contains('ortho')) {
      return [
        'Johns Hopkins Medicine',
        'Orthopedic Surgery Residency',
        'Cleveland Clinic'
      ];
    } else if (s.contains('neuro')) {
      return [
        'Johns Hopkins University',
        'Neurosurgery Fellowship',
        'Mayo Clinic'
      ];
    } else {
      return [
        'Stanford University',
        'School of Medicine',
        'Family Medicine Residency'
      ];
    }
  }

  List<String> _getExpertise(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('cardio')) {
      return [
        'Cardiovascular Disease',
        'Heart Failure',
        'Interventional Cardiology'
      ];
    } else if (s.contains('dent')) {
      return ['Cosmetic Dentistry', 'Oral Surgery', 'Orthodontics'];
    } else if (s.contains('derm')) {
      return ['Skin Cancer Screening', 'Acne Treatment', 'Laser Therapy'];
    } else if (s.contains('ortho')) {
      return ['Joint Replacement', 'Sports Medicine', 'Spine Surgery'];
    } else if (s.contains('neuro')) {
      return ['Brain Tumors', 'Spinal Disorders', 'Cognitive Neurology'];
    } else {
      return [
        'General Consultations',
        'Diagnostic Medicine',
        'Patient Wellness'
      ];
    }
  }

  void _confirmBooking() {
    if (_selectedTimeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available time slot.')),
      );
      return;
    }

    final profileState = context.read<PatientProfileCubit>().state;
    if (profileState is! PatientProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Patient profile is loading. Please try again.')),
      );
      return;
    }

    final patientProfileId = profileState.profile.id;
    final staffProfileId = widget.doctorData?['id'] as String? ??
        'f5a8703e-02ba-46a7-9215-163ef0c5a473';

    final date = _days[_selectedDay].$3;
    final time = _parseSlotTime(_selectedTimeText);

    final appointment = Appointment(
      id: 'temp',
      patientProfileId: patientProfileId,
      staffProfileId: staffProfileId,
      appointmentDate: date,
      appointmentTime: time,
      status: AppointmentStatus.pending,
      notes: const {'notes': 'Booked via smart care mobile app'},
      createdAt: DateTime.now(),
      careType: _selectedCareType ?? AppointmentCareType.video,
    );

    context.read<AppointmentCubit>().bookAppointment(appointment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
      Navigator.of(context).pop();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $err')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.doctorData?['profiles']?['full_name'] as String? ??
        'Dr. Elena Ross';
    final specialty = widget.doctorData?['specialties']?['name'] as String? ??
        'Senior Neurosurgeon';
    final experience = widget.doctorData?['years_experience'] != null
        ? '${widget.doctorData!['years_experience']}+ Years Exp.'
        : '15+ Years Exp.';
    final bio = widget.doctorData?['bio'] as String? ??
        'No bio available for this doctor.';
    final feeVal = widget.doctorData?['consultation_fee'] != null
        ? '\$${widget.doctorData!['consultation_fee']}.00'
        : '\$150.00';

    final hasReviews = _reviews.isNotEmpty;
    final ratingDouble = hasReviews
        ? _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            _reviews.length
        : 0.0;
    final rating = hasReviews ? ratingDouble.toStringAsFixed(1) : '0.0';
    final reviewsCount = _reviews.length.toString();

    final edu = _getEducation(specialty);
    final exp = _getExpertise(specialty);

    final supportsVideo = widget.doctorData?['supports_video'] as bool? ?? true;
    final supportsInPerson =
        widget.doctorData?['supports_in_person'] as bool? ?? true;
    final supportsHomeVisit =
        widget.doctorData?['supports_home_visit'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Clinical Precision'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(rating, hasReviews),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorInfo(name, specialty, experience, ratingDouble,
                      reviewsCount, hasReviews),
                  const SizedBox(height: 20),
                  _buildAboutSection(bio, edu, exp),
                  const SizedBox(height: 20),
                  _buildReviews(hasReviews),
                  const SizedBox(height: 20),
                  _buildBookingSection(
                      supportsVideo, supportsInPerson, supportsHomeVisit),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingBar(feeVal),
    );
  }

  Widget _buildHeroSection(String rating, bool hasReviews) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3C34), Color(0xFF2D5A4E)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 140,
                    height: 200,
                    margin: const EdgeInsets.only(right: 60),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                      child: (widget.doctorData?['profiles']?['avatar_url'] !=
                                  null &&
                              (widget.doctorData?['profiles']?['avatar_url']
                                      as String)
                                  .isNotEmpty)
                          ? Image.network(
                              widget.doctorData?['profiles']?['avatar_url']
                                  as String,
                              width: 140,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(Icons.person_rounded,
                                    size: 80, color: AppColors.primary),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person_rounded,
                                  size: 80, color: AppColors.primary),
                            ),
                    ),
                  ),
                ),
              ),
              if (hasReviews)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(rating,
                            style: AppText.body(13,
                                color: Colors.white, weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(String name, String specialty, String experience,
      double ratingDouble, String reviewsCount, bool hasReviews) {
    final city = widget.doctorData?['city'] as String?;
    final country = widget.doctorData?['country'] as String?;
    final location = (city != null &&
            country != null &&
            city.trim().isNotEmpty &&
            country.trim().isNotEmpty)
        ? '${city.trim()}, ${country.trim()}'
        : 'San Francisco, USA';

    final languagesList = widget.doctorData?['languages'] as List<dynamic>?;
    final languagesStr = languagesList != null && languagesList.isNotEmpty
        ? languagesList.map((e) => e.toString()).join(', ')
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: AppText.display(24)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(location,
                style: AppText.body(13,
                    color: AppColors.textSecondary, weight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _BadgePill(
                icon: Icons.workspace_premium_rounded,
                label: experience,
                color: AppColors.primary),
            const SizedBox(width: 10),
            _BadgePill(
                icon: Icons.verified_rounded,
                label: 'Board Certified',
                color: AppColors.green),
          ],
        ),
        if (languagesStr != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.language_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Languages: $languagesStr',
                  style: AppText.body(13,
                      color: AppColors.textSecondary, weight: FontWeight.w500)),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (hasReviews)
          Row(
            children: [
              StarRating(rating: ratingDouble),
              const SizedBox(width: 8),
              Text('($reviewsCount Reviews)',
                  style: AppText.body(13, color: AppColors.textSecondary)),
            ],
          )
        else
          Row(
            children: [
              const Icon(Icons.rate_review_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('No reviews yet',
                  style: AppText.body(13, color: AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }

  Widget _buildAboutSection(
      String bio, List<String> education, List<String> expertise) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Doctor', style: AppText.display(16)),
          const SizedBox(height: 10),
          Text(
            bio,
            style: AppText.body(13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (_isLoadingCertificates)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_certificates.isNotEmpty) ...[
            Text('Certificates', style: AppText.display(14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _certificates.map((cert) {
                final double width = _certificates.length == 1
                    ? (MediaQuery.of(context).size.width - 36 - 12)
                    : (MediaQuery.of(context).size.width - 36 - 12 - 12) / 2;
                return SizedBox(
                  width: width,
                  child: _CertificateBox(
                    title: cert.type,
                    imageUrl: cert.fileUrl,
                    status: cert.status,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviews(bool hasReviews) {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Patient Reviews',
          action: hasReviews ? 'View All' : null,
          onAction: () {},
        ),
        const SizedBox(height: 12),
        if (!hasReviews)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined,
                    size: 32, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text(
                  'No reviews yet for this doctor.',
                  style: AppText.body(13,
                      color: AppColors.textSecondary, weight: FontWeight.w500),
                ),
              ],
            ),
          )
        else
          ..._reviews.map((rev) => Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: rev.avatarBg,
                              child: Text(rev.avatarLetter,
                                  style: AppText.body(14,
                                      color: rev.avatarTextColor,
                                      weight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rev.author,
                                    style: AppText.body(13,
                                        weight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Text('Verified Patient',
                                        style: AppText.label(
                                            color: AppColors.green, size: 10)),
                                    const SizedBox(width: 6),
                                    StarRating(rating: rev.rating, size: 10),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(rev.date,
                            style: AppText.label(color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '"${rev.content}"',
                      style: AppText.body(13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildBookingSection(
      bool supportsVideo, bool supportsInPerson, bool supportsHomeVisit) {
    return BlocConsumer<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
        if (state is AvailabilitySuccess) {
          final date = _days[_selectedDay].$3;
          final slots = _generateTimeSlotsForDate(date, state.availabilities);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                if (slots.isNotEmpty) {
                  if (_selectedTimeText.isEmpty ||
                      !_isSlotSelectable(_selectedTimeText, date)) {
                    _selectFirstAvailableSlot(date, slots);
                  }
                } else {
                  _selectedTimeText = '';
                }
              });
            }
          });
        }
      },
      builder: (context, state) {
        if (state is AvailabilityLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        List<StaffAvailability> availabilities = [];
        if (state is AvailabilitySuccess) {
          availabilities = state.availabilities;
        }

        final date = _days[_selectedDay].$3;
        final slots = _generateTimeSlotsForDate(date, availabilities);
        final morningSlots = slots.where((s) => s.endsWith('AM')).toList();
        final afternoonSlots = slots.where((s) => s.endsWith('PM')).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Book Appointment', style: AppText.display(16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Date',
                    style: AppText.body(14, weight: FontWeight.w600)),
                Text('Dynamic Availability',
                    style: AppText.body(13,
                        color: AppColors.textSecondary,
                        weight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_days.length, (i) {
                final selected = i == _selectedDay;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDaySelected(i, availabilities),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(_days[i].$1,
                              style: AppText.label(
                                  color: selected
                                      ? Colors.white70
                                      : AppColors.textMuted,
                                  size: 11)),
                          const SizedBox(height: 4),
                          Text(_days[i].$2,
                              style: AppText.display(16,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            _buildCareTypeSection(
                supportsVideo, supportsInPerson, supportsHomeVisit),
            const SizedBox(height: 20),
            if (slots.isEmpty) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      'No available time slots for this date.',
                      style: AppText.body(14,
                          color: AppColors.textSecondary,
                          weight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please try selecting another date.',
                      style: AppText.label(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (morningSlots.isNotEmpty) ...[
                Text('Morning Slots',
                    style: AppText.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(morningSlots.length, (i) {
                    final isTaken = !_isSlotSelectable(morningSlots[i], date);
                    final isSelected = _isMorningSelected &&
                        _selectedTimeText == morningSlots[i];
                    return GestureDetector(
                      onTap: isTaken
                          ? null
                          : () => setState(() {
                                _isMorningSelected = true;
                                _selectedTimeText = morningSlots[i];
                              }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : (isTaken
                                  ? AppColors.border.withOpacity(0.3)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : (isTaken
                                      ? AppColors.border.withOpacity(0.3)
                                      : AppColors.border)),
                        ),
                        child: Text(
                          morningSlots[i],
                          style: AppText.body(13,
                              color: isSelected
                                  ? Colors.white
                                  : (isTaken
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary),
                              weight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
              if (afternoonSlots.isNotEmpty) ...[
                Text('Afternoon Slots',
                    style: AppText.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(afternoonSlots.length, (i) {
                    final isTaken = !_isSlotSelectable(afternoonSlots[i], date);
                    final isSelected = !_isMorningSelected &&
                        _selectedTimeText == afternoonSlots[i];
                    return GestureDetector(
                      onTap: isTaken
                          ? null
                          : () => setState(() {
                                _isMorningSelected = false;
                                _selectedTimeText = afternoonSlots[i];
                              }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : (isTaken
                                  ? AppColors.border.withOpacity(0.3)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : (isTaken
                                      ? AppColors.border.withOpacity(0.3)
                                      : AppColors.border)),
                        ),
                        child: Text(
                          afternoonSlots[i],
                          style: AppText.body(13,
                              color: isSelected
                                  ? Colors.white
                                  : (isTaken
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary),
                              weight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildCareTypeSection(
      bool supportsVideo, bool supportsInPerson, bool supportsHomeVisit) {
    final availableTypes = <(AppointmentCareType, String, IconData)>[];
    if (supportsVideo)
      availableTypes
          .add((AppointmentCareType.video, 'Video', Icons.videocam_rounded));
    if (supportsInPerson)
      availableTypes.add((
        AppointmentCareType.inPerson,
        'In-Person',
        Icons.location_on_rounded
      ));
    if (supportsHomeVisit)
      availableTypes.add(
          (AppointmentCareType.homeVisit, 'Home Visit', Icons.home_rounded));

    if (availableTypes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Select Consultation Type',
            style: AppText.body(14, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: availableTypes.map((typeTuple) {
            final type = typeTuple.$1;
            final label = typeTuple.$2;
            final icon = typeTuple.$3;
            final isSelected = _selectedCareType == type;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCareType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppText.body(13,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            weight:
                                isSelected ? FontWeight.w700 : FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingBar(String fee) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consultation Fee',
                  style: AppText.body(14, color: AppColors.textSecondary)),
              Text(fee, style: AppText.display(20, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedTimeText.isEmpty ? null : _confirmBooking,
              icon: const Icon(Icons.calendar_today_rounded,
                  size: 18, color: Colors.white),
              label: const Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: AppText.body(16, weight: FontWeight.w700),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Rescheduling is available up to 24 hours prior.',
              style: AppText.label(color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _BadgePill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppText.label(color: color, size: 11)),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _InfoBox({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppText.label(color: AppColors.textMuted, size: 10)),
          const SizedBox(height: 6),
          ...lines.map(
              (l) => Text(l, style: AppText.body(12, weight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _DoctorReview {
  final String id;
  final String author;
  final String date;
  final String content;
  final double rating;
  final String avatarLetter;
  final Color avatarBg;
  final Color avatarTextColor;

  const _DoctorReview({
    required this.id,
    required this.author,
    required this.date,
    required this.content,
    required this.rating,
    required this.avatarLetter,
    required this.avatarBg,
    required this.avatarTextColor,
  });
}

class _DoctorCertificate {
  final String id;
  final String type;
  final String fileUrl;
  final String status;

  const _DoctorCertificate({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.status,
  });
}

class _CertificateBox extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;

  const _CertificateBox({
    required this.title,
    required this.imageUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.workspace_premium_rounded;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('license')) {
      iconData = Icons.assignment_ind_rounded;
    } else if (lowerTitle.contains('degree') ||
        lowerTitle.contains('diploma')) {
      iconData = Icons.school_rounded;
    } else if (lowerTitle.contains('id') || lowerTitle.contains('passport')) {
      iconData = Icons.badge_rounded;
    }

    final isApproved = status.toLowerCase() == 'approved' ||
        status.toLowerCase() == 'verified';

    final publicUrl = imageUrl.startsWith('http')
        ? imageUrl
        : 'https://hbnvbekhyyaclymabwwi.supabase.co/storage/v1/object/public/medical-documents/$imageUrl';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCertificateDialog(context, publicUrl, title),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(),
                style: AppText.body(13, weight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isApproved ? AppColors.green : AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isApproved ? 'Verified' : 'Pending',
                    style: AppText.label(
                      color: isApproved ? AppColors.green : AppColors.orange,
                      size: 10,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_rounded,
                      size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'View Photo',
                    style: AppText.label(
                      color: AppColors.primary,
                      size: 11,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCertificateDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    title,
                    style: AppText.body(16,
                        color: Colors.white, weight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 250,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.broken_image_rounded,
                              size: 48, color: AppColors.orange),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load certificate image',
                            style: AppText.body(13,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
