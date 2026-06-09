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
    final supportsInPerson = widget.doctorData?['supports_in_person'] as bool? ?? true;
    final supportsHomeVisit = widget.doctorData?['supports_home_visit'] as bool? ?? false;
    
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

  List<String> _generateTimeSlotsForDate(DateTime date, List<StaffAvailability> availabilities) {
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
    
    final duration = widget.doctorData?['appointment_duration_minutes'] as int? ?? 30;
    final slots = <String>[];
    
    var currentMinutes = availability.startTime.hour * 60 + availability.startTime.minute;
    final endMinutes = availability.endTime.hour * 60 + availability.endTime.minute;
    
    while (currentMinutes + duration <= endMinutes) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      
      final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
      final hourOfPeriod = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
      final hourStr = hourOfPeriod.toString().padLeft(2, '0');
      final minuteStr = timeOfDay.minute.toString().padLeft(2, '0');
      
      slots.add('$hourStr:$minuteStr $period');
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
        _selectedTimeText = slots[0];
        _isMorningSelected = slots[0].endsWith('AM');
      } else {
        _selectedTimeText = '';
      }
    });
  }

  List<String> _getEducation(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('cardio')) {
      return ['Harvard Medical School', 'Cardiology Fellowship', 'Mass General Hospital'];
    } else if (s.contains('dent')) {
      return ['NYU College of Dentistry', 'DDS Program', 'Clinical Residency'];
    } else if (s.contains('derm')) {
      return ['Stanford University', 'Dermatology Residency', 'Mayo Clinic'];
    } else if (s.contains('ortho')) {
      return ['Johns Hopkins Medicine', 'Orthopedic Surgery Residency', 'Cleveland Clinic'];
    } else if (s.contains('neuro')) {
      return ['Johns Hopkins University', 'Neurosurgery Fellowship', 'Mayo Clinic'];
    } else {
      return ['Stanford University', 'School of Medicine', 'Family Medicine Residency'];
    }
  }

  List<String> _getExpertise(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('cardio')) {
      return ['Cardiovascular Disease', 'Heart Failure', 'Interventional Cardiology'];
    } else if (s.contains('dent')) {
      return ['Cosmetic Dentistry', 'Oral Surgery', 'Orthodontics'];
    } else if (s.contains('derm')) {
      return ['Skin Cancer Screening', 'Acne Treatment', 'Laser Therapy'];
    } else if (s.contains('ortho')) {
      return ['Joint Replacement', 'Sports Medicine', 'Spine Surgery'];
    } else if (s.contains('neuro')) {
      return ['Brain Tumors', 'Spinal Disorders', 'Cognitive Neurology'];
    } else {
      return ['General Consultations', 'Diagnostic Medicine', 'Patient Wellness'];
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
        const SnackBar(content: Text('Patient profile is loading. Please try again.')),
      );
      return;
    }
    
    final patientProfileId = profileState.profile.id;
    final staffProfileId = widget.doctorData?['id'] as String? ?? 'f5a8703e-02ba-46a7-9215-163ef0c5a473';
    
    final date = _days[_selectedDay].$3;
    final time = _parseSlotTime(_selectedTimeText);
    
    final appointment = Appointment(
      id: 'temp',
      patientProfileId: patientProfileId,
      staffProfileId: staffProfileId,
      appointmentDate: date,
      appointmentTime: time,
      status: AppointmentStatus.pending,
      notes: 'Booked via smart care mobile app',
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
    final name = widget.doctorData?['profiles']?['full_name'] as String? ?? 'Dr. Elena Ross';
    final specialty = widget.doctorData?['specialties']?['name'] as String? ?? 'Senior Neurosurgeon';
    final experience = widget.doctorData?['years_experience'] != null
        ? '${widget.doctorData!['years_experience']}+ Years Exp.'
        : '15+ Years Exp.';
    final bio = widget.doctorData?['bio'] as String? ??
        'Dr. Elena Ross is a world-renowned neurosurgeon specializing in minimally invasive spinal procedures and cognitive neurological disorders. With over 15 years of experience at leading clinical institutions, she combines surgical precision with a compassionate, patient-centered approach.';
    final feeVal = widget.doctorData?['consultation_fee'] != null
        ? '\$${widget.doctorData!['consultation_fee']}.00'
        : '\$150.00';
    final rating = widget.doctorData?['rating']?.toString() ?? '4.9';
    final reviewsCount = widget.doctorData?['reviews_count']?.toString() ?? '1.2k';

    final edu = _getEducation(specialty);
    final exp = _getExpertise(specialty);

    final supportsVideo = widget.doctorData?['supports_video'] as bool? ?? true;
    final supportsInPerson = widget.doctorData?['supports_in_person'] as bool? ?? true;
    final supportsHomeVisit = widget.doctorData?['supports_home_visit'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Clinical\nPrecision', style: AppText.display(15)),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share_outlined, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined, size: 22), onPressed: () {}),
          Container(
            width: 32, height: 32, margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(rating),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorInfo(name, specialty, experience, rating, reviewsCount),
                  const SizedBox(height: 20),
                  _buildAboutSection(bio, edu, exp),
                  const SizedBox(height: 20),
                  _buildReviews(),
                  const SizedBox(height: 20),
                  _buildBookingSection(supportsVideo, supportsInPerson, supportsHomeVisit),
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

  Widget _buildHeroSection(String rating) {
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
                right: -30, top: -30,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                right: 40, bottom: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 140, height: 200,
                    margin: const EdgeInsets.only(right: 60),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_rounded, size: 80, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(rating, style: AppText.body(13, color: Colors.white, weight: FontWeight.w800)),
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

  Widget _buildDoctorInfo(String name, String specialty, String experience, String rating, String reviewsCount) {
    final ratingDouble = double.tryParse(rating) ?? 4.9;
    
    final city = widget.doctorData?['city'] as String?;
    final country = widget.doctorData?['country'] as String?;
    final location = (city != null && country != null && city.trim().isNotEmpty && country.trim().isNotEmpty)
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
            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(location, style: AppText.body(13, color: AppColors.textSecondary, weight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _BadgePill(icon: Icons.workspace_premium_rounded, label: experience, color: AppColors.primary),
            const SizedBox(width: 10),
            _BadgePill(icon: Icons.verified_rounded, label: 'Board Certified', color: AppColors.green),
          ],
        ),
        if (languagesStr != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.language_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Languages: $languagesStr', style: AppText.body(13, color: AppColors.textSecondary, weight: FontWeight.w500)),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            StarRating(rating: ratingDouble),
            const SizedBox(width: 8),
            Text('($reviewsCount Reviews)', style: AppText.body(13, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(String bio, List<String> education, List<String> expertise) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: 'Education',
                  lines: education,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  title: 'Expertise',
                  lines: expertise,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_MockReview> _getMockReviews(String specialty, String name) {
    final s = specialty.toLowerCase();
    if (s.contains('cardio') || s.contains('heart')) {
      return const [
        _MockReview(
          author: 'Michael Pel S.',
          date: '2 days ago',
          content: 'Explained the procedure with clinical precision. I felt completely at ease throughout the consultation. Highly recommended.',
          rating: 5.0,
          avatarLetter: 'M',
          avatarBg: AppColors.blueLight,
          avatarTextColor: AppColors.blue,
        ),
        _MockReview(
          author: 'Sarah G.',
          date: '1 week ago',
          content: 'Excellent cardiologist. Took the time to explain my test results thoroughly. Very compassionate and professional.',
          rating: 4.8,
          avatarLetter: 'S',
          avatarBg: AppColors.greenLight,
          avatarTextColor: AppColors.green,
        ),
      ];
    } else if (s.contains('dent') || s.contains('ortho')) {
      return const [
        _MockReview(
          author: 'David K.',
          date: '3 days ago',
          content: 'Fantastic experience. Very gentle and explained every step of the procedure. The clinic was spotless.',
          rating: 5.0,
          avatarLetter: 'D',
          avatarBg: AppColors.orangeLight,
          avatarTextColor: AppColors.orange,
        ),
        _MockReview(
          author: 'Emily L.',
          date: '2 weeks ago',
          content: 'Extremely professional team. They made me feel comfortable from start to finish. Highly recommend!',
          rating: 4.9,
          avatarLetter: 'E',
          avatarBg: AppColors.blueLight,
          avatarTextColor: AppColors.blue,
        ),
      ];
    } else {
      return const [
        _MockReview(
          author: 'Robert H.',
          date: '2 days ago',
          content: 'Very detailed assessment and extremely professional approach. Great bedside manner and clear communication.',
          rating: 5.0,
          avatarLetter: 'R',
          avatarBg: AppColors.blueLight,
          avatarTextColor: AppColors.blue,
        ),
        _MockReview(
          author: 'Jessica M.',
          date: '1 week ago',
          content: 'Caring, skilled, and took time to address all my concerns. The best specialist I have visited.',
          rating: 4.8,
          avatarLetter: 'J',
          avatarBg: AppColors.tealLight,
          avatarTextColor: AppColors.teal,
        ),
      ];
    }
  }

  Widget _buildReviews() {
    final name = widget.doctorData?['profiles']?['full_name'] as String? ?? 'Dr. Elena Ross';
    final specialty = widget.doctorData?['specialties']?['name'] as String? ?? 'Senior Neurosurgeon';
    final reviews = _getMockReviews(specialty, name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Patient Reviews', action: 'View All'),
        const SizedBox(height: 12),
        ...reviews.map((rev) => Container(
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
                        child: Text(rev.avatarLetter, style: AppText.body(14, color: rev.avatarTextColor, weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rev.author, style: AppText.body(13, weight: FontWeight.w600)),
                          Row(
                            children: [
                              Text('Verified Patient', style: AppText.label(color: AppColors.green, size: 10)),
                              const SizedBox(width: 6),
                              StarRating(rating: rev.rating, size: 10),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(rev.date, style: AppText.label(color: AppColors.textMuted)),
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

  Widget _buildBookingSection(bool supportsVideo, bool supportsInPerson, bool supportsHomeVisit) {
    return BlocConsumer<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
        if (state is AvailabilitySuccess) {
          final date = _days[_selectedDay].$3;
          final slots = _generateTimeSlotsForDate(date, state.availabilities);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                if (slots.isNotEmpty) {
                  _selectedTimeText = slots[0];
                  _isMorningSelected = slots[0].endsWith('AM');
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
                Text('Select Date', style: AppText.body(14, weight: FontWeight.w600)),
                Text('Dynamic Availability', style: AppText.body(13, color: AppColors.textSecondary, weight: FontWeight.w500)),
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
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(_days[i].$1,
                              style: AppText.label(
                                  color: selected ? Colors.white70 : AppColors.textMuted, size: 11)),
                          const SizedBox(height: 4),
                          Text(_days[i].$2,
                              style: AppText.display(16,
                                  color: selected ? Colors.white : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            _buildCareTypeSection(supportsVideo, supportsInPerson, supportsHomeVisit),
            const SizedBox(height: 20),
            if (slots.isEmpty) ...[
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
                    const Icon(Icons.calendar_today_rounded, size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      'No available time slots for this date.',
                      style: AppText.body(14, color: AppColors.textSecondary, weight: FontWeight.w600),
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
                Text('Morning Slots', style: AppText.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(morningSlots.length, (i) {
                    final isSelected = _isMorningSelected && _selectedTimeText == morningSlots[i];
                    return GestureDetector(
                      onTap: () => setState(() {
                        _isMorningSelected = true;
                        _selectedTimeText = morningSlots[i];
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                        ),
                        child: Text(
                          morningSlots[i],
                          style: AppText.body(13,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w500),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
              if (afternoonSlots.isNotEmpty) ...[
                Text('Afternoon Slots', style: AppText.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(afternoonSlots.length, (i) {
                    final isSelected = !_isMorningSelected && _selectedTimeText == afternoonSlots[i];
                    return GestureDetector(
                      onTap: () => setState(() {
                        _isMorningSelected = false;
                        _selectedTimeText = afternoonSlots[i];
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                        ),
                        child: Text(
                          afternoonSlots[i],
                          style: AppText.body(13,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w500),
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

  Widget _buildCareTypeSection(bool supportsVideo, bool supportsInPerson, bool supportsHomeVisit) {
    final availableTypes = <(AppointmentCareType, String, IconData)>[];
    if (supportsVideo) availableTypes.add((AppointmentCareType.video, 'Video', Icons.videocam_rounded));
    if (supportsInPerson) availableTypes.add((AppointmentCareType.inPerson, 'In-Person', Icons.location_on_rounded));
    if (supportsHomeVisit) availableTypes.add((AppointmentCareType.homeVisit, 'Home Visit', Icons.home_rounded));

    if (availableTypes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Select Consultation Type', style: AppText.body(14, weight: FontWeight.w600)),
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
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppText.body(13,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            weight: isSelected ? FontWeight.w700 : FontWeight.w500),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consultation Fee', style: AppText.body(14, color: AppColors.textSecondary)),
              Text(fee, style: AppText.display(20, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedTimeText.isEmpty ? null : _confirmBooking,
              icon: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
              label: const Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  const _BadgePill({required this.icon, required this.label, required this.color});

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
          Text(title, style: AppText.label(color: AppColors.textMuted, size: 10)),
          const SizedBox(height: 6),
          ...lines.map((l) => Text(l, style: AppText.body(12, weight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _MockReview {
  final String author;
  final String date;
  final String content;
  final double rating;
  final String avatarLetter;
  final Color avatarBg;
  final Color avatarTextColor;

  const _MockReview({
    required this.author,
    required this.date,
    required this.content,
    required this.rating,
    required this.avatarLetter,
    required this.avatarBg,
    required this.avatarTextColor,
  });
}
