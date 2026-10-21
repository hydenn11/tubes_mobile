part of '../page.dart';

class login_page extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<login_page> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final LoginAPI loginapi = LoginAPI();
  final meAPI meapi = meAPI();
  String emailErrorMessage = '';
  String passErrorMessage = '';
  bool mailIsEror = false;
  bool passIsEror = false;
  bool isLoading = false;

  bool isIdentifierValid(String identifier) {
    return identifier.trim().isNotEmpty;
  }

  bool isPassValid(String pass) {
    return pass.isNotEmpty;
  }

  bool cekEmailnPass(String email, String pass) {
    return (email.isNotEmpty && pass.isNotEmpty);
  }

  void LoginUser(String email, String pass) async {
    setState(() {
      emailErrorMessage = '';
      passErrorMessage = '';
      mailIsEror = false;
      passIsEror = false;
      isLoading = true;
    });

    if (!isIdentifierValid(email)) {
      setState(() {
        emailErrorMessage = 'Email atau username tidak boleh kosong';
        mailIsEror = true;
        isLoading = false;
      });
      return;
    }


    if (!isPassValid(pass)) {
      setState(() {
        passErrorMessage = 'Password tidak boleh kosong';
        passIsEror = true;
        isLoading = false;
      });
      return;
    }

    var response = await loginapi.login(email, pass);

    if (response['status'] == true) {
      var user = await meapi.getUserProfile();
      print("========== USER ==========");
      print("USER RESPONSE:");
      print(user);
      print("==========================");

      if (user['status'] == true && user['data'] != null) {
        print(user['data']);
        String role = user['data']['role'];
        print("ROLE = $role");
        if (role == 'pelamar') {
          Navigator.pushNamed(context, '/pagePelamar');
        } else if (role == 'perusahaan') {
          Navigator.pushNamed(context, '/pageHRD');
        } else {
          Navigator.pushNamed(context, '/');
        }
      } else {
        print('User profile retrieval failed: ${user['message']}');
        setState(() {
          emailErrorMessage = "Email atau password salah";
          passErrorMessage = "Email atau password salah";

          mailIsEror = true;
          passIsEror = true;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        emailErrorMessage = response['message'] ?? "Email atau password salah";
        passErrorMessage = response['message'] ?? "Email atau password salah";

        mailIsEror = true;
        passIsEror = true;
        isLoading = false;
      });
    }
  }

  void testing2() {
    Navigator.pushNamed(context, '/pagePelamar');
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
            // Top Wave SVG
            Positioned(
              top: topSafeArea,
              left: 0,
              right: 0,
              child: SvgPicture.string(
                _topWaveSvg,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
            ),

            // Bottom Wave SVG
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.string(
                _bottomWaveSvg,
                fit: BoxFit.contain,
              ),
            ),

            // Foreground Content
            SafeArea(
              child: Column(
                children: [
                  // Top Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false);
                          }
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Selamat Datang",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Masuk untuk melanjutkan dan mengelola akun RekanPabrik Anda.",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontFamily: 'poppins',
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 66),

              // Form Inputs
              EmailInput(
                emailController: EmailController,
                isEror: mailIsEror,
                labelText: 'Email atau Username',
                hintText: 'nama@email.com atau username',
              ),

              if (emailErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 14, color: dangerColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          emailErrorMessage,
                          style: TextStyle(
                              color: dangerColor,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              PassInput(
                controller: passwordController,
                isEror: passIsEror,
              ),
              if (passErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 14, color: dangerColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          passErrorMessage,
                          style: TextStyle(
                              color: dangerColor,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LupaPassword()),
                    );
                  },
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: darkMaroon,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Masuk
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
                        onPressed: () {
                          String email = EmailController.text.trim();
                          String pass = passwordController.text.trim();
                          LoginUser(email, pass);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkMaroon,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: darkMaroon.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              // Footer Register Link
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: greyColor,
                      fontFamily: 'poppins',
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: "Belum punya akun? "),
                      TextSpan(
                        text: "Daftar Sekarang",
                        style: TextStyle(
                          color: darkMaroon,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => register_pelamar()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
