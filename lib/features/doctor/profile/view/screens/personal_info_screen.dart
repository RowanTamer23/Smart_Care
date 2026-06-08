import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // Medical Staff Controllers
  late TextEditingController _yearsController;
  late TextEditingController _feeController;
  late TextEditingController _durationController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _languagesController;
  late TextEditingController _bioController;
  late TextEditingController _licenseController;

  String? _selectedSpecialtyId;
  late bool _supportsInPerson;
  late bool _supportsVideo;
  late bool _supportsHomeVisit;

  List<Map<String, dynamic>> _specialties = [];
  File? _pickedImage;
  bool _isSaving = false;
  bool _isLoadingSpecialties = true;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final doctor = context.read<ProfileCubit>().doctor;
    final medicalProfile =
        context.read<MedicalStaffCubit>().medicalStaffProfile;

    // Initialize profile fields
    _nameController = TextEditingController(text: doctor?.fullName ?? '');
    _phoneController = TextEditingController(text: doctor?.phone ?? '');

    // Initialize medical fields
    _yearsController = TextEditingController(
        text: medicalProfile?.yearsExperience?.toString() ?? '');
    _feeController = TextEditingController(
        text: medicalProfile?.consultationFee?.toString() ?? '');
    _durationController = TextEditingController(
        text: medicalProfile?.appointmentDurationMinutes?.toString() ?? '');
    _cityController = TextEditingController(text: medicalProfile?.city ?? '');
    _countryController =
        TextEditingController(text: medicalProfile?.country ?? '');
    _languagesController = TextEditingController(
        text: medicalProfile?.languages?.join(', ') ?? '');
    _bioController = TextEditingController(text: medicalProfile?.bio ?? '');
    _licenseController =
        TextEditingController(text: medicalProfile?.licenseNumber ?? '');

    _selectedSpecialtyId = medicalProfile?.specialtyId;
    _supportsInPerson = medicalProfile?.supportsInPerson ?? false;
    _supportsVideo = medicalProfile?.supportsVideo ?? false;
    _supportsHomeVisit = medicalProfile?.supportsHomeVisit ?? false;

    _loadSpecialties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _yearsController.dispose();
    _feeController.dispose();
    _durationController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _languagesController.dispose();
    _bioController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    try {
      final res = await Supabase.instance.client
          .from('specialties')
          .select('id, name')
          .order('name', ascending: true);
      if (mounted) {
        setState(() {
          _specialties = List<Map<String, dynamic>>.from(res);
          _isLoadingSpecialties = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching specialties: $e');
      if (mounted) {
        setState(() => _isLoadingSpecialties = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Source',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Camera',
                style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Gallery',
                style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final profileCubit = context.read<ProfileCubit>();
      final medicalCubit = context.read<MedicalStaffCubit>();
      final doctor = profileCubit.doctor;
      final medicalProfile = medicalCubit.medicalStaffProfile;

      if (doctor == null || medicalProfile == null) return;

      String? updatedAvatarUrl = doctor.avatarUrl;

      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        final fileName = _pickedImage!.path.split('/').last;
        final uploadResult = await profileCubit.uploadAvatar(
          doctor.id,
          fileName,
          bytes,
        );
        if (uploadResult != null) {
          updatedAvatarUrl = uploadResult;
        }
      }

      // 1. Update Profile in Supabase
      await profileCubit.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: updatedAvatarUrl,
      );

      // 2. Update Medical Staff Profile in Supabase
      final updatedMedical = medicalProfile.copyWith(
        specialtyId: _selectedSpecialtyId,
        yearsExperience: int.tryParse(_yearsController.text.trim()),
        bio: _bioController.text.trim(),
        consultationFee: double.tryParse(_feeController.text.trim()),
        appointmentDurationMinutes:
            int.tryParse(_durationController.text.trim()),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        languages: _languagesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        supportsInPerson: _supportsInPerson,
        supportsVideo: _supportsVideo,
        supportsHomeVisit: _supportsHomeVisit,
        licenseNumber: _licenseController.text.trim(),
      );

      await medicalCubit.updateMedicalData(updatedMedical);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All changes saved successfully!'),
          backgroundColor: AppColors.stable,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.critical,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = context.read<ProfileCubit>().doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Personal Information',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingSpecialties
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Avatar Section
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.white,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (doctor?.avatarUrl != null &&
                                        doctor!.avatarUrl!.isNotEmpty
                                    ? NetworkImage(doctor.avatarUrl!)
                                        as ImageProvider
                                    : null),
                            child: _pickedImage == null &&
                                    (doctor?.avatarUrl == null ||
                                        doctor!.avatarUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 64,
                                    color: AppColors.textMuted,
                                  )
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap the camera icon to upload a new profile picture.',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Profile Fields Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'General Profile Info',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name Input
                    _buildLabel('Full Name'),
                    TextFormField(
                      controller: _nameController,
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration('Enter your full name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Input
                    _buildLabel('Phone Number'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.body,
                      decoration:
                          _buildInputDecoration('Enter your phone number'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.trim().length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Read-only Email
                    _buildLabel('Email Address (Cannot be changed)'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            doctor?.email ?? 'No email configured',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: AppColors.border, thickness: 1),
                    const SizedBox(height: 24),

                    // Professional & Medical Info Fields Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Professional & Medical Info',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Specialty Dropdown
                    _buildLabel('Specialty / Department'),
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialtyId,
                      style: AppTextStyles.body,
                      decoration:
                          _buildInputDecoration('Select your specialty'),
                      items: _specialties.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'] as String,
                          child: Text(item['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSpecialtyId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Specialty is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Years of Experience Input
                    _buildLabel('Years of Experience'),
                    TextFormField(
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration('e.g. 5'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Years of experience is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // License Number Input
                    _buildLabel('License Number'),
                    TextFormField(
                      controller: _licenseController,
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration(
                          'Enter your medical license number'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'License number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Consultation Fee Input
                    _buildLabel('Consultation Fee (\$)'),
                    TextFormField(
                      controller: _feeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration('e.g. 150.00'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Fee is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Must be a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Consultation Duration Input
                    _buildLabel('Consultation Duration (minutes)'),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration('e.g. 30'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Duration is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Location - City & Country
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('City'),
                              TextFormField(
                                controller: _cityController,
                                style: AppTextStyles.body,
                                decoration:
                                    _buildInputDecoration('e.g. Berlin'),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'City is required'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Country'),
                              TextFormField(
                                controller: _countryController,
                                style: AppTextStyles.body,
                                decoration:
                                    _buildInputDecoration('e.g. Germany'),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Country is required'
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Languages Input
                    _buildLabel('Languages Spoken (comma separated)'),
                    TextFormField(
                      controller: _languagesController,
                      style: AppTextStyles.body,
                      decoration: _buildInputDecoration(
                          'e.g. English, German, Spanish'),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'At least one language is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Bio Input
                    _buildLabel('Short Biography'),
                    TextFormField(
                      controller: _bioController,
                      style: AppTextStyles.body,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                          'Tell us about your medical background and care approach...'),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Biography is required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Service Formats
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Supported Consultation Formats',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSwitchRow(
                      'In-Person Consultation',
                      'Allow patients to visit your office location',
                      _supportsInPerson,
                      (val) => setState(() => _supportsInPerson = val),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchRow(
                      'Video Call Consultation',
                      'Allow online video appointments',
                      _supportsVideo,
                      (val) => setState(() => _supportsVideo = val),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchRow(
                      'Home Visit Consultation',
                      'Allow traveling to the patient\'s home',
                      _supportsHomeVisit,
                      (val) => setState(() => _supportsHomeVisit = val),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          labelText,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSwitchRow(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
