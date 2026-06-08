import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';

class DocumentPreview extends StatelessWidget {
  final MedicalStaffDocument document;

  const DocumentPreview({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrlLower = document.fileUrl.toLowerCase();
    final isPdf = fileUrlLower.endsWith('.pdf') ||
        fileUrlLower.endsWith('.doc') ||
        fileUrlLower.endsWith('.docx');
    if (isPdf) {
      return _buildPdfDocumentMock(context);
    } else {
      return _buildImageDocument(document.fileUrl);
    }
  }

  Widget _buildImageDocument(String fileUrl) {
    final publicUrl =
        'https://hbnvbekhyyaclymabwwi.supabase.co/storage/v1/object/public/medical-documents/$fileUrl';
    return Image.network(
      publicUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('Unable to load image preview'),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfDocumentMock(BuildContext context) {
    final doctorName =
        context.read<ProfileCubit>().doctor?.fullName ?? 'Doctor';
    final title = document.documentType;
    final regNo = 'smart-care-lic-${document.id.substring(0, 8)}';
    final status = document.verificationStatus ?? 'pending';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber.shade700, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded,
                  color: Colors.amber.shade700, size: 36),
              const SizedBox(width: 8),
              Text(
                'BOARD OF MEDICINE',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          Divider(color: Colors.amber.shade700, thickness: 1.5, height: 24),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text('This is to certify that'),
          const SizedBox(height: 8),
          Text(
            'Dr. $doctorName',
            style: GoogleFonts.greatVibes(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'is fully registered and licensed to practice medicine.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REGISTRATION NO.', style: AppTextStyles.caption),
                  Text(regNo,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('STATUS', style: AppTextStyles.caption),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == 'approved'
                          ? AppColors.stableLight
                          : AppColors.followUpLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: status.toLowerCase() == 'approved'
                            ? AppColors.stable
                            : AppColors.followUp,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DATE APPROVED', style: AppTextStyles.caption),
                  Text(
                    '${document.createdAt.day}/${document.createdAt.month}/${document.createdAt.year}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Official Seal',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  const Text('_________________',
                      style: TextStyle(height: 0.5)),
                  Text('REGISTRAR SIGNATURE',
                      style: AppTextStyles.label
                          .copyWith(fontSize: 8, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
