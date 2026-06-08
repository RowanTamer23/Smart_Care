import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/document_preview.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/credentials_empty_state.dart';

// ─── CREDENTIALS SCREEN ──────────────────────────────────────────────────────
class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key, required this.id});
  final String id;

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  final List<MedicalStaffDocument> _credentials = [];
  bool _isLoading = true;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<DocumentCubit>().getDocuments(widget.id);
  }

  // ─── ADDING & DELETING DOCUMENTS ───────────────────────────────────────────
  void _addCredential(String documentType, String fileName, List<int> fileBytes) {
    context.read<DocumentCubit>().uploadDocument(
      staffProfileId: widget.id,
      documentType: documentType,
      fileName: fileName,
      fileBytes: fileBytes,
    );
  }

  void _deleteCredential(String id) {
    context.read<DocumentCubit>().deleteDocument(id);
  }

  // Helper to read picked file bytes
  Future<List<int>?> _readFileAsBytes(dynamic file) async {
    try {
      if (file is XFile) {
        return await file.readAsBytes();
      } else if (file is PlatformFile) {
        if (file.bytes != null) {
          return file.bytes;
        } else if (file.path != null) {
          return await File(file.path!).readAsBytes();
        }
      }
    } catch (e) {
      debugPrint('Error reading file bytes: $e');
    }
    return null;
  }

  // Show bottom sheet to fill out info and pick file
  void _showAddDocumentDialog() {
    final titleController = TextEditingController();
    String? selectedFileName;
    String? selectedFileType;
    List<int>? selectedFileBytes;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Add Document', style: AppTextStyles.heading2),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Document Title / Type',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Board Certification, MD Diploma',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Upload Document (Photo or PDF)',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Photo pick option
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    final source =
                                        await showDialog<ImageSource>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Choose Source'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, ImageSource.camera),
                                            child: const Text('Camera'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, ImageSource.gallery),
                                            child: const Text('Gallery'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (source == null) return;
                                    setModalState(() => isProcessing = true);
                                    final file =
                                        await _picker.pickImage(source: source);
                                    if (file != null) {
                                      final content =
                                          await _readFileAsBytes(file);
                                      setModalState(() {
                                        selectedFileName = file.name;
                                        selectedFileType = 'image';
                                        selectedFileBytes = content;
                                      });
                                    }
                                    setModalState(() => isProcessing = false);
                                  },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Pick Image'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // PDF pick option
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    setModalState(() => isProcessing = true);
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf', 'doc', 'docx'],
                                    );
                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      final file = result.files.first;
                                      final content =
                                          await _readFileAsBytes(file);
                                      setModalState(() {
                                        selectedFileName = file.name;
                                        selectedFileType = 'pdf';
                                        selectedFileBytes = content;
                                      });
                                    }
                                    setModalState(() => isProcessing = false);
                                  },
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Pick PDF'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedFileName != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedFileType == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: selectedFileType == 'pdf'
                                  ? AppColors.critical
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedFileName!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedFileName = null;
                                  selectedFileType = null;
                                  selectedFileBytes = null;
                                });
                              },
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.critical),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isProcessing ||
                                titleController.text.trim().isEmpty ||
                                selectedFileBytes == null)
                            ? null
                            : () {
                                _addCredential(
                                  titleController.text.trim(),
                                  selectedFileName ?? 'document',
                                  selectedFileBytes!,
                                );
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save & Upload',
                                style: AppTextStyles.heading3
                                    .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── PREVIEW MODAL ──────────────────────────────────────────────────────────
  void _showPreviewDialog(MedicalStaffDocument document) {
    showDialog(
      context: context,
      builder: (context) {
        final status = document.verificationStatus ?? 'pending';
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(document.documentType,
                              style: AppTextStyles.heading3,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: status.toLowerCase() == 'approved'
                                      ? AppColors.stable
                                      : AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status.toUpperCase(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: status.toLowerCase() == 'approved'
                                      ? AppColors.stable
                                      : AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Document Canvas
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: DocumentPreview(document: document),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // ─── MAIN BUILD ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is DocumentsLoaded) {
          setState(() {
            _credentials.clear();
            _credentials.addAll(state.documents);
            _isLoading = false;
          });
        } else if (state is DocumentUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${state.document.documentType}" uploaded successfully!'),
              backgroundColor: AppColors.stable,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DocumentDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully.'),
              backgroundColor: AppColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DocumentFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
            title: Text('Credentials & License', style: AppTextStyles.heading3),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Verification Documents',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your professional certifications, degrees, and licenses. These help verify your credentials for patients.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _credentials.isEmpty
                            ? const CredentialsEmptyState()
                            : ListView.separated(
                                itemCount: _credentials.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final cred = _credentials[index];
                                  final fileUrlLower = cred.fileUrl.toLowerCase();
                                  final isPdf = fileUrlLower.endsWith('.pdf') || fileUrlLower.endsWith('.doc') || fileUrlLower.endsWith('.docx');
                                  final fileName = cred.fileUrl.contains('_') 
                                      ? cred.fileUrl.split('_').last 
                                      : cred.fileUrl.contains('/')
                                          ? cred.fileUrl.split('/').last
                                          : cred.fileUrl;
                                  final status = cred.verificationStatus ?? 'pending';

                                  return Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _showPreviewDialog(cred),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: isPdf
                                                    ? AppColors.criticalLight
                                                    : AppColors.primary
                                                        .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                isPdf
                                                    ? Icons.picture_as_pdf
                                                    : Icons.image,
                                                color: isPdf
                                                    ? AppColors.critical
                                                    : AppColors.primary,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cred.documentType,
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    fileName,
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                            color: AppColors
                                                                .textSecondary),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: status.toLowerCase() ==
                                                                  'approved'
                                                              ? AppColors
                                                                  .stableLight
                                                              : AppColors
                                                                  .followUpLight,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Text(
                                                          status.toUpperCase(),
                                                          style: AppTextStyles
                                                              .label
                                                              .copyWith(
                                                            color: status.toLowerCase() ==
                                                                    'approved'
                                                                ? AppColors.stable
                                                                : AppColors
                                                                    .followUp,
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '${cred.createdAt.day}/${cred.createdAt.month}/${cred.createdAt.year}',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                                fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              onPressed: () =>
                                                  _deleteCredential(cred.id),
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddDocumentDialog,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Document',
                style: AppTextStyles.body
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

}
