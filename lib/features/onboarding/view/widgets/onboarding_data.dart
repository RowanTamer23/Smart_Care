import 'package:flutter/material.dart';
import 'package:smart_care/features/onboarding/view/widgets/dark_booking_card.dart';
import 'package:smart_care/features/onboarding/view/widgets/effecincy_section.dart';
import 'package:smart_care/features/onboarding/view/widgets/smart_search_card.dart';

class OnboardingData {
  final String? badge;
  final String headline;
  final String body;
  final bool isDark;

  OnboardingData({
    this.badge,
    required this.headline,
    required this.body,
    required this.isDark,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isDark) {
      return DarkBookingCard(data: data);
    } else if (data.badge != null) {
      return EfficiencySection(data: data);
    } else {
      return SmartSearchCard(data: data);
    }
  }
}