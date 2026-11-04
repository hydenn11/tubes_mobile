import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Resetpassperusahaan extends StatefulWidget {
  const Resetpassperusahaan({super.key});

  @override
  State<Resetpassperusahaan> createState() => _ResetpassperusahaanState();
}

class _ResetpassperusahaanState extends State<Resetpassperusahaan> {
  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final PerusahaanAPI perusahaanapi = PerusahaanAPI();

  bool newPassIsError = false;
  bool confirmPassIsError = false;

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;

  String newPasswordError = '';
  String confirmPasswordError = '';

  dynamic user;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> initUser() async {
    try {
      final response = await meAPI().getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
        });
      } else {
        setState(() {
          user = null;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil data user: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showPasswordResetNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'password_channel',
      'Password Reset Notifications',
      channelDescription: 'Notifications for password reset',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Password Reset Successful',
      'Your password has been reset successfully.',
      platformChannelSpecifics,
    );
  }

  void resetPass(String newPass, String confirmNewPass) {
    setState(() {
      newPassIsError = false;
      confirmPassIsError = false;

      newPasswordError = '';
      confirmPasswordError = '';
    });

    if (newPass.isEmpty || confirmNewPass.isEmpty) {
      setState(() {
        if (newPass.isEmpty) {
          newPassIsError = true;
          newPasswordError = 'Password baru harus diisi.';
        }

        if (confirmNewPass.isEmpty) {
          confirmPassIsError = true;
          confirmPasswordError = 'Konfirmasi password harus diisi.';
        }
      });

      return;
    }

    if (newPass != confirmNewPass) {
      setState(() {
        newPassIsError = true;
        confirmPassIsError = true;

        newPasswordError = 'Password tidak sesuai.';
        confirmPasswordError = 'Konfirmasi password tidak cocok.';
      });

      return;
    }

    _showConfirmationDialog(newPass);
  }

  void _showConfirmationDialog(String newPass) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: darkMaroon.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: darkMaroon,
              size: 30,
            ),
          ),
          title: Text(
            'Konfirmasi Perubahan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin mengubah password akun perusahaan Anda?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: greyColor,
              fontFamily: 'Poppins',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: greyColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _processPasswordUpdate(newPass);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ya, Ubah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPasswordUpdate(String newPass) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: darkMaroon,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memperbarui password...',
                  style: TextStyle(
                    fontSize: 12,
                    color: blackColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    bool success = false;

    try {
      success = await _updatePassword(newPass);
    } catch (e) {
      debugPrint('Gagal mengubah password: $e');
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      try {
        await showPasswordResetNotification();
      } catch (e) {
        debugPrint('Notifikasi gagal ditampilkan: $e');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password berhasil diperbarui.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/pageHRD',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal mengubah password. Silakan coba lagi.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<bool> _updatePassword(String newPassword) async {
    return await perusahaanapi.changePassword(
      newPassword: newPassword,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkMaroon.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            color: darkMaroon,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Akun',
                style: TextStyle(
                  fontSize: 13,
                  color: greyColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkMaroon,
                  fontFamily: 'Poppins',
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
        color: darkMaroon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'KEAMANAN AKUN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jaga Keamanan Akun Perusahaan Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Perbarui password secara berkala untuk menjaga '
            'keamanan akun RekanPabrik Anda. Gunakan password '
            'yang kuat dan jangan membagikannya kepada orang lain.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              height: 1.7,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Lindungi akun dengan password yang aman',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perbarui Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkMaroon,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Masukkan password baru untuk akun perusahaan Anda.',
          style: TextStyle(
            fontSize: 12,
            color: greyColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField(
                title: 'Password Baru',
                hint: 'Masukkan password baru',
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                hasError: newPassIsError,
                errorMessage: newPasswordError,
                onToggle: () {
                  setState(() {
                    obscureNewPassword = !obscureNewPassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                title: 'Konfirmasi Password',
                hint: 'Masukkan kembali password baru',
                controller: confirmNewPasswordController,
                obscureText: obscureConfirmPassword,
                hasError: confirmPassIsError,
                errorMessage: confirmPasswordError,
                onToggle: () {
                  setState(() {
                    obscureConfirmPassword =
                        !obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    resetPass(
                      newPasswordController.text.trim(),
                      confirmNewPasswordController.text.trim(),
                    );
                  },
                  icon: const Icon(
                    Icons.lock_reset_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Ubah Password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required bool hasError,
    required String errorMessage,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: blackColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 12,
            color: blackColor,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 11,
              color: greyColor.withOpacity(0.7),
              fontFamily: 'Poppins',
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 19,
              color: darkMaroon,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: greyColor,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.redAccent
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : darkMaroon,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
        if (hasError && errorMessage.isNotEmpty) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.redAccent,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInformationCard(),
            const SizedBox(height: 24),
            _buildPasswordSection(),
          ],
        ),
      ),
    );
  }
}