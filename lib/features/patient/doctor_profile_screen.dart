import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedTimeSlot = 1; // 10:30 AM selected
  int _selectedDay = 1;      // Tuesday selected (index 1)

  static const _morningSlots = ['09:00 AM', '10:30 AM', '11:15 AM'];
  static const _afternoonSlots = ['01:00 PM', '03:30 PM', '04:45 PM'];
  static const _days = [
    ('Mon', '13'),
    ('Tue', '14'),
    ('Wed', '15'),
    ('Thu', '1A'),
  ];

  @override
  Widget build(BuildContext context) {
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
            // Hero image
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorInfo(),
                  const SizedBox(height: 20),
                  _buildAboutSection(),
                  const SizedBox(height: 20),
                  _buildReviews(),
                  const SizedBox(height: 20),
                  _buildBookingSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingBar(),
    );
  }

  Widget _buildHeroSection() {
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
              // Decorative circles
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
              // Doctor illustration
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
              // Rating badge
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
                      Text('4.9', style: AppText.body(13, color: Colors.white, weight: FontWeight.w800)),
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

  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dr. Elena Ross', style: AppText.display(24)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text('SENIOR NEUROSURGEON', style: AppText.label(color: AppColors.accent, size: 11)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _BadgePill(icon: Icons.workspace_premium_rounded, label: '15+ Years Exp.', color: AppColors.primary),
            const SizedBox(width: 10),
            _BadgePill(icon: Icons.verified_rounded, label: 'Board Certified', color: AppColors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StarRating(rating: 3.5),
            const SizedBox(width: 8),
            Text('(1.2k Reviews)', style: AppText.body(13, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
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
          Text('About Dr. Ross', style: AppText.display(16)),
          const SizedBox(height: 10),
          Text(
            'Dr. Elena Ross is a world-renowned neurosurgeon specializing in minimally invasive spinal procedures and cognitive neurological disorders. With over 15 years of experience at leading clinical institutions, she combines surgical precision with a compassionate, patient-centered approach.',
            style: AppText.body(13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: 'Education',
                  lines: const ['Johns Hopkins', 'University School', 'of Medicine'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  title: 'Expertise',
                  lines: const ['Neurosurgery,', 'Pain Management,', 'Spinal Therapy'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Patient Reviews', action: 'View All'),
        const SizedBox(height: 12),
        Container(
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
                        backgroundColor: AppColors.blueLight,
                        child: Text('M', style: AppText.body(14, color: AppColors.blue, weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Michael Pel S.', style: AppText.body(13, weight: FontWeight.w600)),
                          Text('Verified Patient', style: AppText.label(color: AppColors.green, size: 10)),
                        ],
                      ),
                    ],
                  ),
                  Text('2 days ago', style: AppText.label(color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"Dr. Ross explained the procedure with clinical precision. I felt completely at ease throughout the consultation. Highly recommended for complex cases."',
                style: AppText.body(13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Appointment', style: AppText.display(16)),
        const SizedBox(height: 16),
        // Month selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Date', style: AppText.body(14, weight: FontWeight.w600)),
            Text('October 2023', style: AppText.body(13, color: AppColors.textSecondary, weight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        // Day strip
        Row(
          children: List.generate(_days.length, (i) {
            final selected = i == _selectedDay;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
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
        const SizedBox(height: 20),
        // Morning slots
        Text('Morning Slots', style: AppText.body(14, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(_morningSlots.length, (i) {
            final sel = i == _selectedTimeSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.accent : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                ),
                child: Text(
                  _morningSlots[i],
                  style: AppText.body(13,
                      color: sel ? Colors.white : AppColors.textPrimary,
                      weight: sel ? FontWeight.w700 : FontWeight.w500),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Afternoon slots
        Text('Afternoon Slots', style: AppText.body(14, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(_afternoonSlots.length, (i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(_afternoonSlots[i],
                  style: AppText.body(13, color: AppColors.textPrimary, weight: FontWeight.w500)),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBookingBar() {
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
              Text('\$150.00', style: AppText.display(20, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
              label: const Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

// ── Supporting Widgets ──────────────────────────────────────────────────────

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
