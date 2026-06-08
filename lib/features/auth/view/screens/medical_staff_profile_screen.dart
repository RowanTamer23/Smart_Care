import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/auth/cubit/auth_state.dart';

// ─── Helper constants ────────────────────────────────────────────────────────

const _kGenders = ['Male', 'Female'];
const _kLanguages = [
  'Arabic',
  'English',
  'French',
  'Spanish',
  'German',
  'Italian',
  'Turkish',
  'Chinese',
  'Japanese',
  'Portuguese',
];
const _kDurations = [15, 20, 30, 45, 60, 90];

// ─── Screen ──────────────────────────────────────────────────────────────────

class MedicalStaffProfileScreen extends StatefulWidget {
  const MedicalStaffProfileScreen({super.key});

  @override
  State<MedicalStaffProfileScreen> createState() =>
      _MedicalStaffProfileScreenState();
}

class _MedicalStaffProfileScreenState extends State<MedicalStaffProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _yearsCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();

  // dropdown / toggle values
  String? _selectedGender;
  String? _selectedSpecialty;
  int _selectedDuration = 30;
  bool _supportsInPerson = true;
  bool _supportsVideo = false;
  bool _supportsHomeVisit = false;

  final Set<String> _selectedLanguages = {'English'};

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _licenseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    context.read<SignUpCubit>().loadSpecialties();
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _feeCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── submit ──────────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_supportsInPerson && !_supportsVideo && !_supportsHomeVisit) {
      _showSnack('Please select at least one consultation type.',
          isError: true);
      return;
    }
    if (_selectedLanguages.isEmpty) {
      _showSnack('Please select at least one language.', isError: true);
      return;
    }

    context.read<SignUpCubit>().saveMedicalStaffProfile(
          specialtyId: _selectedSpecialty,
          staffType: 'doctor',
          yearsExperience: int.tryParse(_yearsCtrl.text),
          gender: _selectedGender,
          country: _countryCtrl.text.isEmpty ? null : _countryCtrl.text,
          city: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
          bio: _bioCtrl.text.isEmpty ? null : _bioCtrl.text,
          consultationFee: double.tryParse(_feeCtrl.text),
          appointmentDurationMinutes: _selectedDuration,
          supportsInPerson: _supportsInPerson,
          supportsVideo: _supportsVideo,
          supportsHomeVisit: _supportsHomeVisit,
          languages: _selectedLanguages.toList(),
          licenseNumber: _licenseCtrl.text.isEmpty ? null : _licenseCtrl.text,
        );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: isError ? Colors.redAccent : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is MedicalProfileSuccess) {
          Navigator.pushReplacementNamed(context, Routes.home,
              arguments: {
                "role": "doctor",
                "userId": state.userId,
              });
        } else if (state is MedicalProfileError) {
          _showSnack('Error: ${state.error}', isError: true);
        }
      },
      builder: (context, state) {
        final isSaving = state is MedicalProfileSaving;
        return Scaffold(
          body: Stack(
            children: [
              // Dark gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A2220),
                      Color(0xFF0D3B38),
                      Color(0xFF142E2C),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment_outlined,
                                  color: AppColors.teal, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                'Smart-Care',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              // Step indicator
                              _StepPill(label: 'Step 2 of 2'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Your Practice\nProfile',
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.teal,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help patients understand your expertise and how you prefer to consult.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.55),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── White scrollable form ─────────────────────────────────
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Personal details ──────────────────────

                                    _SectionHeader(
                                        icon: Icons.person_outline_rounded,
                                        title: 'Personal Details'),
                                    const SizedBox(height: 16),

                                    _Row2(
                                      left: _FormField(
                                        label: 'Years of Experience',
                                        child: _TextField(
                                          controller: _yearsCtrl,
                                          hint: 'e.g. 8',
                                          icon:
                                              Icons.workspace_premium_outlined,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      right: _FormField(
                                        label: 'Gender',
                                        child: _DropdownField<String>(
                                          value: _selectedGender,
                                          hint: 'Select',
                                          icon: Icons.wc_outlined,
                                          items: _kGenders,
                                          onChanged: (v) => setState(
                                              () => _selectedGender = v),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    _Row2(
                                      left: _FormField(
                                        label: 'Country',
                                        child: _TextField(
                                          controller: _countryCtrl,
                                          hint: 'e.g. Egypt',
                                          icon: Icons.flag_outlined,
                                        ),
                                      ),
                                      right: _FormField(
                                        label: 'City',
                                        child: _TextField(
                                          controller: _cityCtrl,
                                          hint: 'e.g. Cairo',
                                          icon: Icons.location_city_outlined,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    _FormField(
                                      label: 'Professional Bio',
                                      child: TextFormField(
                                        controller: _bioCtrl,
                                        maxLines: 4,
                                        minLines: 3,
                                        decoration: _inputDec(
                                          hint:
                                              'Briefly describe your background, approach, and expertise...',
                                          icon: Icons.edit_note_rounded,
                                        ),
                                        style: GoogleFonts.dmSans(fontSize: 14),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    _SectionHeader(
                                        icon: Icons.medical_services_outlined,
                                        title: 'Medical Data'),
                                    const SizedBox(height: 12),

                                    _DropdownField(
                                      value: _selectedSpecialty,
                                      hint: 'Select Specialization',
                                      items: context
                                          .read<SignUpCubit>()
                                          .specialtiesList
                                          .map((e) => e['name'] as String)
                                          .toSet()
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSpecialty = value;
                                        });
                                      },
                                      icon: Icons.medical_services_outlined,
                                    ),
                                    const SizedBox(height: 12),

                                    _TextField(
                                      controller: _licenseCtrl,
                                      hint: 'Enter license number',
                                      icon: Icons.verified_user_outlined,
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                    ),

                                    const SizedBox(height: 28),

                                    // ── Consultation details ───────────────────

                                    const _SectionHeader(
                                        icon: Icons.monetization_on_outlined,
                                        title: 'Consultation Details'),
                                    const SizedBox(height: 16),

                                    _Row2(
                                      left: _FormField(
                                        label: 'Consultation Fee (\$)',
                                        child: _TextField(
                                          controller: _feeCtrl,
                                          hint: 'e.g. 80',
                                          icon: Icons.attach_money_rounded,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                        ),
                                      ),
                                      right: _FormField(
                                        label: 'Session Duration',
                                        child: _DropdownField<int>(
                                          value: _selectedDuration,
                                          hint: 'Mins',
                                          icon: Icons.timer_outlined,
                                          items: _kDurations,
                                          itemLabel: (v) => '$v min',
                                          onChanged: (v) => setState(() =>
                                              _selectedDuration = v ?? 30),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // ── Consultation types ─────────────────────

                                    _SectionHeader(
                                        icon: Icons.video_call_outlined,
                                        title: 'Consultation Types'),
                                    const SizedBox(height: 14),

                                    _ConsultTypeCard(
                                      icon: Icons.local_hospital_outlined,
                                      label: 'In-Person',
                                      subtitle: 'Patients visit your clinic',
                                      value: _supportsInPerson,
                                      onChanged: (v) =>
                                          setState(() => _supportsInPerson = v),
                                    ),
                                    const SizedBox(height: 10),
                                    _ConsultTypeCard(
                                      icon: Icons.videocam_outlined,
                                      label: 'Video Consultation',
                                      subtitle: 'Remote video sessions',
                                      value: _supportsVideo,
                                      onChanged: (v) =>
                                          setState(() => _supportsVideo = v),
                                    ),
                                    const SizedBox(height: 10),
                                    _ConsultTypeCard(
                                      icon: Icons.home_outlined,
                                      label: 'Home Visit',
                                      subtitle: 'You travel to the patient',
                                      value: _supportsHomeVisit,
                                      onChanged: (v) => setState(
                                          () => _supportsHomeVisit = v),
                                    ),

                                    const SizedBox(height: 22),

                                    const SizedBox(height: 28),
                                    Text(
                                      'Languages Spoken',
                                      style: GoogleFonts.dmSans(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _kLanguages.map((lang) {
                                        final selected =
                                            _selectedLanguages.contains(lang);
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (selected) {
                                                _selectedLanguages.remove(lang);
                                              } else {
                                                _selectedLanguages.add(lang);
                                              }
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.inputBg,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: selected
                                                    ? AppColors.primary
                                                    : AppColors.border,
                                              ),
                                            ),
                                            child: Text(
                                              lang,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: selected
                                                    ? Colors.white
                                                    : AppColors.textMedium,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 22),

                                    // ── Submit button ─────────────────────────

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: isSaving ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: isSaving
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : Text(
                                                'Complete Registration',
                                                style: GoogleFonts.dmSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Skip link
                                    Center(
                                      child: GestureDetector(
                                        onTap: isSaving
                                            ? null
                                            : () =>
                                                Navigator.pushReplacementNamed(
                                                    context, Routes.home,
                                                    arguments: {
                                                      "role": "doctor",
                                                      "userId": context.read<SignUpCubit>().signedUpUserId,
                                                    }),
                                        child: Text(
                                          'Skip for now — complete later',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: AppColors.textLight,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _StepPill extends StatelessWidget {
  final String label;
  const _StepPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: AppColors.teal,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

InputDecoration _inputDec({required String hint, required IconData icon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 13),
    prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
    filled: true,
    fillColor: AppColors.inputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _inputDec(hint: hint, icon: icon),
      style: GoogleFonts.dmSans(fontSize: 14),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<T> items;
  final String Function(T)? itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _inputDec(hint: hint, icon: icon),
      hint: Text(hint,
          style: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 13)),
      items: items
          .map((i) => DropdownMenuItem<T>(
                value: i,
                child: Text(itemLabel != null ? itemLabel!(i) : '$i',
                    style: GoogleFonts.dmSans(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textMedium),
    );
  }
}

class _ConsultTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsultTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              value ? AppColors.primary.withOpacity(0.06) : AppColors.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20,
                  color: value ? AppColors.primary : AppColors.textLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: value ? AppColors.textDark : AppColors.textMedium,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
