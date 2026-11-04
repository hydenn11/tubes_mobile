import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rekanpabrik/api/pengaduan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class KirimPengaduan extends StatefulWidget {
  const KirimPengaduan({super.key});

  @override
  State<KirimPengaduan> createState() => _KirimPengaduanState();
}

class _KirimPengaduanState extends State<KirimPengaduan> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;

  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryColor = Color(0xFF7B1E2B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
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

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showComplaintSentNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'complaint_channel',
      'Complaint Notifications',
      channelDescription: 'Notifications for sent complaints',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Pengaduan Terkirim',
      'Terima kasih atas pengaduan Anda! Kami akan meninjau laporan Anda dan segera menghubungi Anda jika diperlukan.',
      platformChannelSpecifics,
    );
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              isSuccess ? const Color(0xFF15803D) : const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> submitComplaint(
    String firstName,
    String lastName,
    String email,
    String phone,
    String message,
  ) async {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        message.isEmpty) {
      _showMessage('Semua kolom harus diisi!');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Masukkan alamat email yang valid!');
      return;
    }

    if (phone.length < 8) {
      _showMessage('Nomor telepon terlalu pendek!');
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

      if (status) {
        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        phoneController.clear();
        messageController.clear();

        _showMessage(
          'Pengaduan berhasil dikirim!',
          isSuccess: true,
        );

        await showComplaintSentNotification();
      } else {
        _showMessage('Gagal mengirim pengaduan. Silakan coba lagi.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan saat mengirim pengaduan.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            color: _textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: maxLines > 1
                ? Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Icon(
                        icon,
                        size: 19,
                        color: _secondaryTextColor,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: 19,
                    color: _secondaryTextColor,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextField(
            label: 'Nama Depan',
            hint: 'Nama depan',
            icon: Icons.person_outline_rounded,
            controller: firstNameController,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            label: 'Nama Belakang',
            hint: 'Nama belakang',
            icon: Icons.person_outline_rounded,
            controller: lastNameController,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Informasi Pengirim',
            subtitle: 'Lengkapi informasi diri Anda terlebih dahulu.',
          ),
          const SizedBox(height: 20),
          _buildNameFields(),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'Alamat Email',
            hint: 'contoh@email.com',
            icon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'Nomor Telepon',
            hint: 'Masukkan nomor telepon aktif',
            icon: Icons.phone_outlined,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          _buildSectionTitle(
            'Detail Pengaduan',
            subtitle: 'Jelaskan kendala atau masukan yang ingin disampaikan.',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Pesan Pengaduan',
            hint: 'Tuliskan pengaduan Anda secara jelas dan lengkap...',
            icon: Icons.message_outlined,
            controller: messageController,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: _secondaryTextColor,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Pastikan informasi yang Anda berikan sudah benar agar kami dapat menindaklanjuti pengaduan dengan tepat.',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                submitComplaint(
                  firstNameController.text.trim(),
                  lastNameController.text.trim(),
                  emailController.text.trim(),
                  phoneController.text.trim(),
                  messageController.text.trim(),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: _primaryColor.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Kirim Pengaduan',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Kirim Pengaduan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ada yang bisa kami bantu?',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Sampaikan kendala atau masukan Anda melalui formulir berikut.',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 10,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildFormCard(),
              const SizedBox(height: 22),
              _buildSubmitButton(),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Terima kasih telah membantu kami menjadi lebih baik.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                    color: _secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
