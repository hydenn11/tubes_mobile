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

  Future<void> sendEmail(String email) async {
    try {
      bool status = await LupaPasswordapi().requestResetPassword(email);
      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tautan reset kata sandi telah dikirim."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim tautan, coba lagi."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error mengirim tautan."),
        ),
      );
    }
  }

  bool isValidEmail(String email) {
    return email.contains('@');
  }

  void handleSubmit() async {
    setState(() {
      errMessage = "";
    });

    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errMessage = "Email tidak boleh kosong.";
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        errMessage = "Format email tidak valid.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await sendEmail(email);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errMessage = "Gagal mengirim email. Coba lagi nanti.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lupa Password",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: thirdColor),
        ),
      ),
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lupa kata sandi Anda?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan email yang Anda gunakan untuk mendaftar. Kami akan mengirimkan tautan untuk mereset kata sandi Anda.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                errorText: errMessage.isEmpty ? null : errMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: thirdColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Kirim",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
