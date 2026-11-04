import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rekanpabrik/api/lupa_password_api.dart';
import 'package:rekanpabrik/components/email_input.dart';
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
      if (!mounted) return;
      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Tautan reset kata sandi telah dikirim ke email Anda.",
                    style: TextStyle(fontFamily: 'poppins', fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: dangerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text(
              "Gagal mengirim tautan, silakan coba lagi.",
              style: TextStyle(fontFamily: 'poppins', fontSize: 13),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: dangerColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            "Terjadi kesalahan saat mengirim tautan.",
            style: TextStyle(fontFamily: 'poppins', fontSize: 13),
          ),
        ),
      );
    }
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
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
    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140 + topSafeArea,
              child: SvgPicture.string(
                _topWaveSvg,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.string(
                _bottomWaveSvg,
                fit: BoxFit.contain,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),

                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Lupa Kata Sandi?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkMaroon,
                                    fontFamily: 'poppins',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Masukkan email yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi akun Anda.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          EmailInput(
                            emailController: _emailController,
                            isEror: errMessage.isNotEmpty,
                            labelText: 'Email Terdaftar',
                            hintText: 'nama@email.com',
                          ),

                          if (errMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 14,
                                    color: dangerColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      errMessage,
                                      style: TextStyle(
                                        color: dangerColor,
                                        fontSize: 12,
                                        fontFamily: 'poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: darkMaroon,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkMaroon,
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: darkMaroon.withValues(alpha: 0.35),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Kirim Tautan Reset',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'poppins',
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _topWaveSvg = '''
<svg width="393" height="281" viewBox="0 0 393 281" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M0 0H393L330.241 56.4373C325.459 60.7381 319.891 64.0758 313.844 66.2674L256.713 86.9719C249.797 89.4783 243.998 94.3624 240.352 100.751L219.347 137.556C214.142 146.677 204.672 152.542 194.187 153.14L156.573 155.284C144.619 155.965 134.127 163.47 129.619 174.562L119.256 200.061C115.348 209.676 106.888 216.698 96.7163 218.767L56.1527 227.018C49.5634 228.358 43.5885 231.805 39.1292 236.838L0 281V0Z" fill="#801C1C" fill-opacity="0.72"/>
<path d="M0 0H357.911L301.401 50.66C296.619 54.9473 291.056 58.2731 285.015 60.4555L234.747 78.6165C227.832 81.1147 222.03 85.9895 218.377 92.3703L200.516 123.57C195.304 132.673 185.843 138.524 175.371 139.119L144.322 140.883C132.378 141.562 121.89 149.053 117.374 160.131L109.18 180.232C105.264 189.838 96.8017 196.849 86.6344 198.911L52.031 205.928C45.4506 207.262 39.4813 210.697 35.0208 215.715L0 255.118V0Z" fill="#801C1C"/>
</svg>
''';

const String _bottomWaveSvg = '''
<svg width="143" height="159" viewBox="0 0 143 159" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M143 159H71.5L0 159L19.0157 132.408C23.2673 126.462 28.7708 121.521 35.1386 117.933L43.5407 113.197C49.9617 109.579 54.8833 103.791 57.4227 96.8715L61.8093 84.919C64.5041 77.5763 71.1961 72.4495 78.9871 71.7589C87.4822 71.0059 94.5889 64.9982 96.7452 56.7469L98.1009 51.5598C100.455 42.5524 107.268 35.3844 116.145 32.5767C122.649 30.5193 128.138 26.0839 131.515 20.1564L143 0L143 159Z" fill="#801C1C"/>
</svg>
''';
