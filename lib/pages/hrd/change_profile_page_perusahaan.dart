import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final PerusahaanAPI perusahaanAPI = PerusahaanAPI();
  final ImagePicker _picker = ImagePicker();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Map<String, dynamic>? user;
  File? selectedImage;

  bool isLoading = true;
  bool isUploading = false;

  static const Color darkMaroon = Color(0xFF5B1720);
  static const Color maroon = Color(0xFF7A2633);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserProfile();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await meapi.getUserProfile();

      if (!mounted) return;

      if (response['status'] == true) {
        setState(() {
          user = Map<String, dynamic>.from(response['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar('Gagal memuat profil perusahaan.');
    }
  }

  ImageProvider _getProfileImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }

    final imagePath = user?['profile_pict']?.toString();

    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/img/defaultPict.png');
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }

    return const AssetImage('assets/img/defaultPict.png');
  }

  Future<void> _showImageSourceDialog() async {
    if (isUploading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih sumber foto yang ingin digunakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.camera_alt_rounded,
                        title: 'Kamera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Galeri',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: maroon,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();

        if (!status.isGranted) {
          if (!mounted) return;

          _showSnackBar('Izin kamera diperlukan untuk mengambil foto.');

          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }

          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memilih gambar.');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (selectedImage == null || user == null || isUploading) {
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final int idUser = int.tryParse(user!['id_perusahaan'].toString()) ?? 1;

      final bool success = await perusahaanAPI.updateProfilePicture(
        idperusahaan: idUser,
        imagePath: selectedImage!,
      );

      if (!mounted) return;

      if (success) {
        await _showNotification();

        if (!mounted) return;

        _showSnackBar('Foto profil berhasil diperbarui.');

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/pageHRD',
          (route) => false,
        );
      } else {
        _showSnackBar('Gagal memperbarui foto profil.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Terjadi kesalahan saat mengunggah foto.');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'profile_channel',
      'Profile Notification',
      channelDescription: 'Notifikasi perubahan foto profil',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Profil Diperbarui',
      'Foto profil perusahaan berhasil diperbarui.',
      notificationDetails,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
          ),
        ),
        backgroundColor: darkMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E8EA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.business_rounded,
            color: darkMaroon,
            size: 25,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Profil',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Kelola foto profil perusahaan Anda',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkMaroon, maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Foto Profil',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gunakan logo perusahaan yang jelas dan mudah dikenali. '
                  'Disarankan menggunakan gambar berbentuk persegi '
                  'dengan kualitas yang baik.',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 11,
                    height: 1.7,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final String companyName = user?['nama_perusahaan']?.toString() ??
        user?['nama']?.toString() ??
        'Perusahaan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 132,
                height: 132,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF0DDE0),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image(
                    image: _getProfileImage(),
                    width: 124,
                    height: 124,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/img/defaultPict.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: maroon,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            companyName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user?['email']?.toString() ?? '-',
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUploading ? null : _showImageSourceDialog,
              icon: const Icon(
                Icons.edit_rounded,
                size: 17,
              ),
              label: const Text('Pilih Foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: maroon,
                side: const BorderSide(color: maroon),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (selectedImage != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 17,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Foto baru siap digunakan',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          setState(() {
                            selectedImage = null;
                          });
                        },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            selectedImage == null || isUploading ? null : _uploadProfilePicture,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkMaroon,
          disabledBackgroundColor: const Color(0xFFD6C6C9),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isUploading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.3,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 19),
                  SizedBox(width: 9),
                  Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: darkMaroon,
                ),
              )
            : user == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 45,
                          color: secondaryColor,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gagal memuat data profil.',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: _loadUserProfile,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildInformationCard(),
                      const SizedBox(height: 28),
                      const Text(
                        'Foto Profil Perusahaan',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Perbarui identitas visual perusahaan Anda.',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileCard(),
                      const SizedBox(height: 22),
                      _buildUploadButton(),
                    ],
                  ),
      ),
    );
  }
}
