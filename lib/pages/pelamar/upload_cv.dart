import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/pelamar_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class UploadCv extends StatefulWidget {
  const UploadCv({super.key});

  @override
  State<UploadCv> createState() => _UploadCvState();
}

class _UploadCvState extends State<UploadCv> {
  String? selectedFileName;
  bool isUploading = false;
  File? CV;
  var user;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    try {
      var response = await meAPI().getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
        });
      }
    } catch (_) {}
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFileName = result.files.single.name;
          CV = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih file: $e")),
      );
    }
  }

  Future<void> uploadFile(int idpelamar, File cvFile) async {
    if (!cvFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File tidak ditemukan.")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      bool status =
          await Pelamarapi().updateCV(idpelamar: idpelamar, imagePath: cvFile);

      if (!mounted) return;
      setState(() {
        isUploading = false;
      });

      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV berhasil diunggah!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengunggah CV. Silakan coba lagi."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengunggah file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: blackColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Unggah CV",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Pilih File Curriculum Vitae (PDF)",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Pastikan berkas berformat PDF dengan data riwayat kerja dan keahlian terkini Anda.",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: isUploading ? null : pickFile,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedFileName != null
                          ? darkMaroon
                          : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: darkMaroon.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selectedFileName != null
                              ? Icons.picture_as_pdf_rounded
                              : Icons.cloud_upload_outlined,
                          size: 36,
                          color: darkMaroon,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        selectedFileName ?? "Ketuk untuk memilih file PDF",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedFileName != null
                              ? blackColor
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedFileName != null
                            ? "File terpilih siap diunggah"
                            : "Format yang didukung: .pdf",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          color: selectedFileName != null
                              ? succesColor
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          if (CV == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Pilih file CV terlebih dahulu!"),
                              ),
                            );
                            return;
                          }
                          final int idpelamar = user != null
                              ? (user['id_pelamar'] ?? 1)
                              : 1;
                          uploadFile(idpelamar, CV!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Unggah CV",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
