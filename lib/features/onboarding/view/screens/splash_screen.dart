import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/onboarding/view/widgets/feature_tile.dart';
import 'package:smart_care/features/onboarding/view/widgets/medical_hero_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _currentDot = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Hero image
          Stack(
            children: [
              Container(
                height: 230,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFB8D8E0),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Abstract medical background
                    Center(
                      child: MedicalHeroImage(),
                    ),
                  ],
                ),
              ),
              // Nav bar overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Logo(dark: false),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, Routes.login),
                          child: Text('Skip', style: lightTextBody),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Headline
                      RichText(
                        text: TextSpan(
                          style: darkHeadline,
                          children: const [
                            TextSpan(text: 'Bridging the Gap in\n'),
                            TextSpan(
                              text: 'Modern ',
                              style: TextStyle(color: AppColors.accent),
                            ),
                            TextSpan(text: 'Healthcare'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Smart-Care connects practitioners and patients through a seamless, clinical-grade interface. Reduce cognitive load and prioritize patient outcomes with our surgical-precision workflow tools.',
                        style: splashBody,
                      ),
                      const SizedBox(height: 24),

                      // Feature tiles
                      FeatureTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.teal,
                        iconBg: AppColors.tealLight.withOpacity(0.4),
                        title: 'Instant Consultations',
                        subtitle:
                            'Secure, real-time messaging and video conferencing for urgent care.',
                      ),
                      const SizedBox(height: 12),
                      FeatureTile(
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.teal,
                        iconBg: AppColors.tealLight.withOpacity(0.4),
                        title: 'Data Driven Insights',
                        subtitle:
                            'Live vitals monitoring and automated trend analysis for better diagnostics.',
                      ),
                      const SizedBox(height: 32),

                      // CTA buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, Routes.onboarding),
                          icon: const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary),
                          label: Text(
                            'Get Started',
                            style: primaryBody,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Existing Partner Log-in',
                            style: darkTextBody,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Legal
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: darkTextBody,
                            children: [
                              const TextSpan(
                                text:
                                    'By continuing, you agree to the Smart-Care\n',
                              ),
                              TextSpan(
                                  text: 'Terms of Service',
                                  style: lightTextBody.copyWith(
                                    decoration: TextDecoration.underline,
                                  )),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Clinical Privacy Standards',
                                style: lightTextBody.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
