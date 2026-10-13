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
        setState(() {
          user = response['data'];
        });
      } else {
        print("Failed to retrieve user data: ${response['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data user')),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data user: ${e}')),
      );
    }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada file yang dipilih.")),
        );
      }
    } catch (e) {
      debugPrint("Error saat memilih file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih file: $e")),
      );
    }
  }

  Future<void> uploadFile(int idpelamar, File CV) async {
    if (CV == null || !CV!.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pilih file yang valid sebelum mengunggah.")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      bool status =
          await Pelamarapi().updateCV(idpelamar: idpelamar, imagePath: CV);

      if (status) {
        setState(() {
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV berhasil diunggah!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Gagal mengunggah CV. Silakan coba lagi.")),
        );
      }
    } catch (e) {
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
      appBar: AppBar(
        title: const Text("Unggah CV"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Pilih file CV dalam format PDF:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Pilih File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            if (selectedFileName != null)
              Text(
                "File dipilih: $selectedFileName",
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () {
                      int idpelamar = user['id_pelamar'];
                      if (CV != null) {
                        uploadFile(idpelamar, CV!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("File belum dipilih!")),
                        );
                      }
                    },
              child: isUploading
                  ? CircularProgressIndicator(color: thirdColor)
                  : const Text(
                      "Unggah CV",
                      style: TextStyle(color: Colors.white),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: thirdColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
