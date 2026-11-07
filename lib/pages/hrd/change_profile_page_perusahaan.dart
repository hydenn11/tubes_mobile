import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Changeprofilepageperusahaan extends StatefulWidget {
  const Changeprofilepageperusahaan({super.key});

  @override
  State<Changeprofilepageperusahaan> createState() =>
      _ChangeprofilepageperusahaanState();
}

class _ChangeprofilepageperusahaanState
    extends State<Changeprofilepageperusahaan> {
  final meAPI meapi = meAPI();
  var user;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isLoading = true;
  bool isUploading = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showProfileUpdatedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'profile_picture_channel',
      'Notifikasi Logo Perusahaan',
      channelDescription: 'Notifikasi saat logo perusahaan berhasil diperbarui',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Logo Perusahaan Diperbarui',
      'Logo perusahaan Anda telah berhasil diperbarui!',
      platformChannelSpecifics,
    );
  }

  Future<void> initUser() async {
    try {
      var response = await meapi.getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      File? imageFile;
      if (source == ImageSource.gallery) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
          );
          if (result != null && result.files.single.path != null) {
            imageFile = File(result.files.single.path!);
          }
        } catch (e) {
          debugPrint("FilePicker error: $e");
        }
      }

      if (imageFile == null) {
        final pickedImage = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedImage != null) {
          imageFile = File(pickedImage.path);
        }
      }

      if (imageFile != null) {
        setState(() {
          selectedImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _updateProfileData(File imageFile, int idUser) async {
    setState(() {
      isUploading = true;
    });
    try {
      var response = await PerusahaanAPI().updateProfilePicture(
        idperusahaan: idUser,
        imagePath: imageFile,
      );

      if (!mounted) return;
      setState(() {
        isUploading = false;
      });

      if (response) {
        showProfileUpdatedNotification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo perusahaan berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui logo. Silakan coba lagi.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Pilih Sumber Logo",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B)),
                  title: const Text(
                    'Kamera',
                    style: TextStyle(fontFamily: 'poppins', fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF64748B)),
                  title: const Text(
                    'Galeri',
                    style: TextStyle(fontFamily: 'poppins', fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: darkMaroon),
        ),
      );
    }

    final bool hasExistingPic = user != null &&
        user['profile_pict'] != null &&
        user['profile_pict'].toString().isNotEmpty &&
        !user['profile_pict'].toString().startsWith('assets/');

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
          "Ubah Logo Perusahaan",
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
            children: [
              const SizedBox(height: 10),
              Text(
                "Pratinjau Logo Perusahaan",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Gunakan logo resmi perusahaan dengan resolusi proporsional.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedImage != null ? darkMaroon : const Color(0xFFCBD5E1),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : _buildPreviewWidget(user?['profile_pict']?.toString()),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: isUploading ? null : showImageSourceDialog,
                icon: Icon(
                  Icons.photo_camera_outlined,
                  size: 18,
                  color: darkMaroon,
                ),
                label: Text(
                  selectedImage != null ? "Ganti Pilihan Logo" : "Pilih Logo Baru",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkMaroon,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: darkMaroon, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (selectedImage != null && !isUploading)
                      ? () {
                          final int idUser = user != null ? (user['id_perusahaan'] ?? 1) : 1;
                          _updateProfileData(selectedImage!, idUser);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          "Simpan Logo Perusahaan",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
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

  Widget _buildPreviewWidget(String? path) {
    if (path == null || path.isEmpty) {
      return _defaultPlaceholder();
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultPlaceholder(),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultPlaceholder(),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return _defaultPlaceholder();
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.business_rounded,
        size: 70,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
