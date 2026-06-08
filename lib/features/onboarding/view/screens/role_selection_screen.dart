import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/onboarding/view/widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        'Smart-Care',
                        style: primaryBody,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.textDark),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.tealLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child:
                              Text('ONBOARDING COMPLETE', style: primaryBody),
                        ),
                        const SizedBox(height: 18),

                        Text(
                          'Tailoring your\nexperience.',
                          style: textHeadline.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                            'To provide you with the most relevant tools and clinical data, please let us know your role in the Smart-Care ecosystem.',
                            style: lightTextBody),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                size: 16, color: AppColors.textMedium),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'HIPAA compliant and secure medical records access.',
                                style: lightTextBody,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Doctor card
                        RoleCard(
                          isDoctorSelected: true,
                          iconBg: AppColors.primary,
                          iconColor: Colors.white,
                          icon: Icons.medical_services_rounded,
                          backgroundIcon: Icons.medical_services_outlined,
                          title: 'I am a Doctor',
                          description:
                              'Access patient histories, manage schedules, and enter surgical notes with clinical precision.',
                          ctaText: 'Continue as Doctor',
                          ctaColor: AppColors.textDark,
                          onTap: () => Navigator.pushNamed(
                              context, Routes.register,
                              arguments: 1),
                          hasBorder: true,
                        ),
                        const SizedBox(height: 16),

                        // Patient card
                        RoleCard(
                          isDoctorSelected: false,
                          iconBg: AppColors.accent,
                          iconColor: AppColors.primary,
                          icon: Icons.person_outline_rounded,
                          backgroundIcon: Icons.person,
                          title: 'I am a Patient',
                          description:
                              'View your treatment plans, schedule upcoming visits, and track your health recovery trends.',
                          ctaText: 'Continue as Patient',
                          ctaColor: AppColors.accent,
                          onTap: () => Navigator.pushNamed(
                              context, Routes.register,
                              arguments: 0),
                          hasBorder: false,
                        ),
                        const SizedBox(height: 32),
                      ],
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
