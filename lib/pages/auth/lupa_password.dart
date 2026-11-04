import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/lupa_password_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  String errMessage = "";
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> sendEmail(String email) async {
    try {
      bool status = await LupaPasswordapi().requestResetPassword(email);
      if (!mounted) return;
      if (status) {
        showDialog(
          context: context,
          builder: (dialogCtx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Tautan Terkirim",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              content: const Text(
                "Tautan untuk mengatur ulang kata sandi telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
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
            content: Text("Gagal mengirim tautan, silakan coba lagi."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat mengirim tautan: $e"),
        ),
      );
    }
  }

  void handleSubmit() async {
    setState(() {
      errMessage = "";
    });

    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errMessage = "Email tidak boleh kosong";
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        errMessage = "Format email tidak valid (contoh: user@email.com)";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await sendEmail(email);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errMessage = "Gagal mengirim email. Silakan coba lagi nanti.";
        isLoading = false;
      });
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
          "Lupa Password",
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
              "Atur Ulang Kata Sandi",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Masukkan alamat email yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi akun Anda.",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Alamat Email Terdaftar',
                hintText: 'nama@email.com',
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

            if (errMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 15, color: dangerColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errMessage,
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
                onPressed: isLoading ? null : handleSubmit,
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
                        'Kirim Tautan Reset',
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
