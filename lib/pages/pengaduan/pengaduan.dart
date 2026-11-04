import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/pengaduan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Pengaduan extends StatefulWidget {
  const Pengaduan({super.key});

  @override
  State<Pengaduan> createState() => _PengaduanState();
}

class _PengaduanState extends State<Pengaduan> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initUser();
    _initializeNotifications();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _initUser() async {
    try {
      final response = await meAPI().getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        if (!mounted) return;
        setState(() {
          if (firstNameController.text.isEmpty) {
            firstNameController.text =
                (data['first_name'] ?? data['nama_perusahaan'] ?? '').toString();
          }
          if (lastNameController.text.isEmpty) {
            lastNameController.text = (data['last_name'] ?? '').toString();
          }
          if (emailController.text.isEmpty) {
            emailController.text = (data['email'] ?? '').toString();
          }
          if (phoneController.text.isEmpty) {
            phoneController.text =
                (data['phone'] ?? data['no_telp'] ?? data['nomor_telepon'] ?? '')
                    .toString();
          }
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

  void _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'complaint_channel',
      'Pengaduan & Bantuan',
      channelDescription: 'Notifikasi status pengaduan pelanggan',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Pengaduan Terkirim',
      'Terima kasih! Pesan atau pertanyaan Anda telah kami terima dan akan segera ditindaklanjuti.',
      platformDetails,
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 13,
        color: Color(0xFF94A3B8),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 13,
        color: Color(0xFF64748B),
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

  Future<void> _submitComplaint() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final message = messageController.text.trim();

    setState(() {
      errorMessage = '';
    });

    if (firstName.isEmpty || email.isEmpty || message.isEmpty) {
      setState(() {
        errorMessage = 'Nama, email, dan pesan pengaduan wajib diisi.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Format email tidak valid.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final bool status = await Pengaduanapi().kirimPengaduan(
        firstName,
        lastName,
        email,
        phone,
        message,
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (status) {
        messageController.clear();
        _showNotification();

        showDialog(
          context: context,
          builder: (dialogCtx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Pengaduan Terkirim",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              content: const Text(
                "Pesan pengaduan Anda berhasil dikirim ke tim Customer Service. Kami akan menindaklanjutinya secepat mungkin.",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(fontFamily: 'poppins'),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim pengaduan. Silakan coba lagi."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
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
          "Customer Service",
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
              "Pusat Bantuan & Pengaduan",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Sampaikan kendala, pertanyaan, atau laporan Anda terkait lowongan maupun penggunaan aplikasi.",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstNameController,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
                    decoration: _inputDeco(
                      label: 'Nama Depan',
                      hint: 'Depan',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: lastNameController,
                    style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
                    decoration: _inputDeco(
                      label: 'Nama Belakang',
                      hint: 'Belakang',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
              decoration: _inputDeco(
                label: 'Alamat Email',
                hint: 'nama@email.com',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
              decoration: _inputDeco(
                label: 'Nomor Telepon (Opsional)',
                hint: '08xxxxxxxxxx',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: messageController,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Isi Pesan / Pengaduan',
                hintText: 'Tuliskan detail kendala atau pengaduan Anda di sini...',
                hintStyle: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
                labelStyle: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
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
              ),
            ),

            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 15, color: dangerColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage,
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

            const SizedBox(height: 28),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Kirim Pengaduan',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
