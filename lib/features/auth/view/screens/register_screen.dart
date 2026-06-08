import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/auth/cubit/auth_state.dart';
import '../../../../core/shared/theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final int role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _agreed = false;
  // int _selectedRole = 1; // 0=Patient, 1=Practitioner

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final List<String> _specialties = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Dermatology',
    'Pediatrics',
    'Oncology',
    'Psychiatry',
    'General Practice',
    'Surgery',
    'Radiology',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the Terms & Conditions.',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    context.read<SignUpCubit>().signUp(
          role: widget.role == 1 ? 'Doctor' : 'Patient',
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(listener: (context, state) {
      if (state is SignUpSuccess) {
        // Doctors go to the second step; patients go directly to home
        if (widget.role == 1) {
          Navigator.pushReplacementNamed(context, Routes.medicalStaffProfile);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home,
              arguments: {
                "role": "patient",
                "userId": context.read<SignUpCubit>().signedUpUserId,
              });
        }
      } else if (state is SignUpError) {
        print("error in cubit $state");
        print(state.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${state.error}',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }, builder: (context, state) {
      final signUpCubit = context.read<SignUpCubit>();
      final isLoading = state is SignUpLoading;
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
                children: [
                  // Header on dark bg
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment_outlined,
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
                          ],
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.teal,
                              height: 1.2,
                            ),
                            children: const [
                              TextSpan(
                                  text:
                                      'Join the next\ngeneration of clinical\nexcellence.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Secure, efficient, and designed for practitioners who prioritize patient outcomes above all else.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.55),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White form card
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Role toggle
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _RoleTab(
                                        label: 'Patient',
                                        isSelected: widget.role == 0,
                                        onTap: () =>
                                            Navigator.pushReplacementNamed(
                                                context, Routes.register,
                                                arguments: 0),
                                      ),
                                      _RoleTab(
                                        label: 'Doctor',
                                        isSelected: widget.role == 1,
                                        onTap: () =>
                                            Navigator.pushReplacementNamed(
                                                context, Routes.register,
                                                arguments: 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                _Label('Full Name'),
                                const SizedBox(height: 6),
                                _buildField(
                                  controller: signUpCubit.nameCtrl,
                                  hint: 'Dr. Julian Vane',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 14),

                                _Label('Email Address'),
                                const SizedBox(height: 6),
                                _buildField(
                                  controller: signUpCubit.emailCtrl,
                                  hint: 'julian.vane@clinic.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 14),

                                _Label('Phone Number'),
                                const SizedBox(height: 6),
                                _buildField(
                                  controller: signUpCubit.phoneCtrl,
                                  hint: '+1 (555) 000-0000',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 14),

                                // if (widget.role == 1) ...[
                                //   _Label('Medical License Number'),
                                //   const SizedBox(height: 6),
                                //   _buildField(
                                //     controller: signUpCubit.licenseCtrl,
                                //     hint: 'MED-992384-LX',
                                //     icon: Icons.badge_outlined,
                                //     validator: (v) => v == null || v.isEmpty
                                //         ? 'Required'
                                //         : null,
                                //   ),
                                //   const SizedBox(height: 14),
                                // _Label('Medical Specialty'),
                                // const SizedBox(height: 6),
                                //   DropdownButtonFormField<String>(
                                //     value: signUpCubit.selectedSpecialty,
                                //     hint: Text(
                                //       'Select your specialty',
                                //       style: GoogleFonts.dmSans(
                                //         color: AppColors.textLight,
                                //         fontSize: 14,
                                //       ),
                                //     ),
                                //     items: _specialties
                                //         .map((s) => DropdownMenuItem(
                                //               value: s,
                                //               child: Text(s,
                                //                   style: GoogleFonts.dmSans(
                                //                       fontSize: 14)),
                                //             ))
                                //         .toList(),
                                //     onChanged: (v) =>
                                //         signUpCubit.selectedSpecialty = v,
                                //     validator: widget.role == 1
                                //         ? (v) => v == null ? 'Required' : null
                                //         : null,
                                //     decoration: _fieldDecoration(
                                //         hint: '',
                                //         icon: Icons.medical_services_outlined),
                                //     dropdownColor: Colors.white,
                                //     borderRadius: BorderRadius.circular(12),
                                //     icon: const Icon(
                                //       Icons.keyboard_arrow_down_rounded,
                                //       color: AppColors.textMedium,
                                //     ),
                                //   ),
                                //   const SizedBox(height: 14),
                                // ],

                                _Label('Security Password'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: signUpCubit.passCtrl,
                                  obscureText: _obscure,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Required';
                                    if (v.length < 12) {
                                      return 'Min 12 characters with one symbol';
                                    }
                                    return null;
                                  },
                                  decoration: _fieldDecoration(
                                    hint: '••••••••••••',
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: GestureDetector(
                                      onTap: () =>
                                          setState(() => _obscure = !_obscure),
                                      child: Icon(
                                        _obscure
                                            ? Icons.lock_outline_rounded
                                            : Icons.lock_open_outlined,
                                        color: AppColors.textLight,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Minimum 12 characters including one symbol.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Terms checkbox
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _agreed = !_agreed),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          color: _agreed
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: _agreed
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: _agreed
                                            ? const Icon(Icons.check,
                                                size: 12, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: AppColors.textMedium,
                                              height: 1.5,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms & Conditions',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const TextSpan(text: ' and the '),
                                              TextSpan(
                                                text:
                                                    'Clinical Data Privacy Policy',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const TextSpan(
                                                  text:
                                                      ' regarding patient information handling.'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Create account button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : Text(
                                            'Create Account',
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/login'),
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13.5,
                                            color: AppColors.textMedium),
                                        children: [
                                          const TextSpan(
                                              text:
                                                  'Already have a professional profile? '),
                                          TextSpan(
                                            text: 'Sign In',
                                            style: TextStyle(
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Security badges
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (i) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Icon(
                                        Icons.shield_outlined,
                                        color: AppColors.textLight,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
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
          ],
        ),
      );
    });
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textDark),
      decoration: _fieldDecoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 14),
      suffixIcon: Icon(icon, color: AppColors.textLight, size: 18),
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }
}
