import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/pelamar_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Resetpasspelamar extends StatefulWidget {
  const Resetpasspelamar({super.key});

  @override
  State<Resetpasspelamar> createState() => _ResetpasspelamarState();
}

class _ResetpasspelamarState extends State<Resetpasspelamar> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  String errMassage = '';
  var user;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
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

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showPasswordResetNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'password_channel',
      'Notifikasi Reset Password',
      channelDescription: 'Notifikasi untuk reset password',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Reset Password Berhasil',
      'Password Anda telah berhasil diubah! Gunakan password baru Anda untuk login.',
      platformChannelSpecifics,
    );
  }

  void resetPass(String newPass, String confirmNewPass) {
    setState(() {
      errMassage = '';
    });

    if (newPass.isEmpty || confirmNewPass.isEmpty) {
      setState(() {
        errMassage = 'Semua kolom kata sandi wajib diisi.';
      });
      return;
    }

    if (newPass.length < 6) {
      setState(() {
        errMassage = 'Kata sandi minimal 6 karakter.';
      });
      return;
    }

    if (newPass != confirmNewPass) {
      setState(() {
        errMassage = 'Konfirmasi kata sandi tidak cocok.';
      });
      return;
    }

    _showConfirmationDialog(context, newPass);
  }

  void _showConfirmationDialog(BuildContext parentContext, String newPass) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi',
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin memperbarui kata sandi akun ini?',
            style: TextStyle(fontFamily: 'poppins', fontSize: 13),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(fontFamily: 'poppins', color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Ubah',
                style: TextStyle(fontFamily: 'poppins'),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                showLoadingDialog(parentContext);

                bool success = await _updatePassword(newPass);
                if (!parentContext.mounted) return;

                Navigator.of(parentContext).pop();

                if (success) {
                  showPasswordResetNotification();
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil diperbarui!'),
                    ),
                  );
                  Navigator.pop(parentContext);
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Gagal mengubah password.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updatePassword(String newPassword) async {
    final int id = user != null ? (user['id_pelamar'] ?? 1) : 1;
    final bool success = await Pelamarapi().changePassword(
      idpelamar: id,
      newPassword: newPassword,
    );
    return success;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(color: darkMaroon),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 13,
        color: Color(0xFF64748B),
      ),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: Color(0xFF64748B),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: const Color(0xFF64748B),
        ),
        onPressed: onToggle,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: darkMaroon, width: 1.5),
      ),
    );
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
          "Ganti Password",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              "Buat Password Baru",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Masukkan kata sandi baru untuk mengamankan akun Anda. Pastikan kedua kolom terisi sama.",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: newPasswordController,
              obscureText: _obscureNewPass,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Password Baru',
                obscureText: _obscureNewPass,
                onToggle: () {
                  setState(() {
                    _obscureNewPass = !_obscureNewPass;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: confirmNewPasswordController,
              obscureText: _obscureConfirmPass,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Konfirmasi Password Baru',
                obscureText: _obscureConfirmPass,
                onToggle: () {
                  setState(() {
                    _obscureConfirmPass = !_obscureConfirmPass;
                  });
                },
              ),
            ),

            if (errMassage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 15, color: dangerColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errMassage,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        color: dangerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  resetPass(
                    newPasswordController.text.trim(),
                    confirmNewPasswordController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Simpan Password Baru',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
