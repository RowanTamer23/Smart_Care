import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/pill.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class ProfileSliverAppBar extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onEditPressed;

  const ProfileSliverAppBar({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final name = profile.fullName ?? 'Unknown Patient';
    final gender = profile.gender != null
        ? (profile.gender == PatientGender.male ? 'Male' : 'Female')
        : 'Gender N/A';
    final ageVal = _calculateAge(profile.dateOfBirth);
    final ageStr = ageVal != null ? '$ageVal yrs' : 'Age N/A';

    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: C.primary,
      leading: const SizedBox(),
      title: Row(
        children: [
          const SizedBox(width: 70),
          Text(name, style: hTextStyle(20, c: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
          onPressed: onEditPressed,
        ),
      ],
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // gradient bg
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16302B), Color(0xFF0A4040)],
                ),
              ),
            ),
            // decorative circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.teal.withOpacity(0.12),
                ),
              ),
            ),
            // content
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 80, 18, 16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [C.teal, Color(0xFF0A6B62)],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: C.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Pill(gender, C.teal, C.tealLight.withOpacity(0.2)),
                            const SizedBox(width: 6),
                            Pill(ageStr, C.amber, C.amberLight.withOpacity(0.2)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 13,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ID: #${profile.profileId.substring(0, 8).toUpperCase()}',
                              style: lblTextStyle(c: Colors.white54, s: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
