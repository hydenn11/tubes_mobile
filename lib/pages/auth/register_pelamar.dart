part of '../page.dart';

class register_pelamar extends StatefulWidget {
  @override
  _registerPelamarState createState() => _registerPelamarState();
}

class _registerPelamarState extends State<register_pelamar> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController EmailController = TextEditingController();
  String emailErrorMessage = '';
  bool mailIsEror = false;

  final TextEditingController passwordController = TextEditingController();
  String passErrorMessage = '';
  bool passIsEror = false;

  final TextEditingController confirmPasswordController =
      TextEditingController();
  String confirmPassErrorMessage = '';
  bool confirmPassIsEror = false;

  final TextEditingController fullNameController = TextEditingController();
  String fullNameErrorMessage = '';
  bool fullNameIsEror = false;

  bool agreeTerms = false;
  String termsErrorMessage = '';

  final TextEditingController usernameController = TextEditingController();
  String usernameErrorMessage = '';
  bool usernameIsEror = false;

  String generalMassageEror = '';
  bool generalEror = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  bool isEmailValid(String email) {
    return email.contains('@');
  }

  bool isPassValid(String pass) {
    return pass.isNotEmpty;
  }

  bool checkConfirmPass(String pass, String confirmPass) {
    return (pass == confirmPass);
  }

  Future<void> createAccount(String fullName, String username, String email,
      String password, String confirmPass) async {
    setState(() {
      fullNameErrorMessage = '';
      usernameErrorMessage = '';
      emailErrorMessage = '';
      passErrorMessage = '';
      confirmPassErrorMessage = '';
      termsErrorMessage = '';

      fullNameIsEror = false;
      usernameIsEror = false;
      mailIsEror = false;
      passIsEror = false;
      confirmPassIsEror = false;

      if (fullName.isEmpty) {
        fullNameErrorMessage = "Nama lengkap tidak boleh kosong";
        fullNameIsEror = true;
      }
      if (username.isEmpty) {
        usernameErrorMessage = "Username tidak boleh kosong";
        usernameIsEror = true;
      } else if (username.contains(' ')) {
        usernameErrorMessage = "Username tidak boleh mengandung spasi";
        usernameIsEror = true;
      }
      if (email.isEmpty) {
        emailErrorMessage = "Email tidak boleh kosong";
        mailIsEror = true;
      } else if (!isEmailValid(email)) {
        emailErrorMessage = "Format email tidak valid";
        mailIsEror = true;
      }
      if (password.isEmpty) {
        passErrorMessage = "Password tidak boleh kosong";
        passIsEror = true;
      }
      if (confirmPass.isEmpty) {
        confirmPassErrorMessage = "Konfirmasi password tidak boleh kosong";
        confirmPassIsEror = true;
      } else if (confirmPass != password) {
        confirmPassErrorMessage = "Konfirmasi password tidak sesuai.";
        confirmPassIsEror = true;
      }
      if (!agreeTerms) {
        termsErrorMessage = "Anda harus menyetujui Syarat & Ketentuan";
      }
    });

    if (!fullNameIsEror &&
        !usernameIsEror &&
        !mailIsEror &&
        !passIsEror &&
        !confirmPassIsEror &&
        agreeTerms) {
      try {
        final nameParts = fullName.trim().split(RegExp(r'\s+'));
        final fName = nameParts.first;
        final lName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final result = await Pelamarapi().createAccount(
          fName,
          lName,
          email,
          password,
          username: username.trim(),
        );

        if (result['status'] == true) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => login_page()),
            (route) => false,
          );
          showProfileUpdatedNotification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Akun berhasil dibuat! Silakan masuk."),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Ooppss, pendaftaran gagal!"),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error ketika membuat akun!"),
          ),
        );
      }
    }
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
      'account_creation_channel',
      'Notifikasi Pembuatan Akun',
      channelDescription: 'Notifications for successful account creation',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Akun Berhasil Dibuat',
      'Selamat datang di platform kami! Mulailah menjelajahi peluang sekarang!',
      platformChannelSpecifics,
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(
                "Syarat & Ketentuan",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: darkMaroon,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Selamat datang di RekanPabrik. Dengan mendaftar akun pelamar, Anda menyetujui ketentuan berikut:",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                _termsItem("1. Keaslian Data",
                    "Semua informasi dan dokumen profil yang Anda berikan adalah benar dan akurat."),
                _termsItem("2. Keamanan Akun",
                    "Anda bertanggung jawab penuh menjaga kerahasiaan kata sandi akun Anda."),
                _termsItem("3. Penggunaan Layanan",
                    "Layanan ini digunakan secara sah untuk keperluan melamar pekerjaan di industri manufaktur & pabrik."),
                _termsItem("4. Privasi & Data",
                    "Data profil Anda dapat dibagikan kepada perusahaan mitra yang Anda lamar."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  agreeTerms = true;
                  termsErrorMessage = '';
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Saya Setuju",
                style: TextStyle(
                    fontFamily: 'poppins', fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Tutup",
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: greyColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _termsItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: greyColor,
            ),
          ),
        ],
      ),
    );
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
              height: 185 + topSafeArea,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                  color: darkMaroon.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: darkMaroon.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.business_rounded,
                                      color: darkMaroon, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mendaftar sebagai Perusahaan?",
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: blackColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Pasang lowongan & kelola pelamar",
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 11,
                                          color: greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => register_hrd()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    backgroundColor: darkMaroon,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Pindah",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Daftar Akun Pelamar",
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
                                  "Lengkapi data diri untuk mulai mencari kerja",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
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

                          const SizedBox(height: 20),

                          name_input(
                            nameInputController: fullNameController,
                            label: "Nama Lengkap",
                            hintText: "contoh: Budi Santoso",
                            isEror: fullNameIsEror,
                          ),
                          if (fullNameErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                fullNameErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 14),

                          name_input(
                            nameInputController: usernameController,
                            label: "Username",
                            hintText: "contoh: arvin_12",
                            isEror: usernameIsEror,
                          ),
                          if (usernameErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                usernameErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 14),

                          EmailInput(
                              emailController: EmailController,
                              isEror: mailIsEror),
                          if (emailErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                emailErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 14),

                          PassInput(
                              controller: passwordController,
                              isEror: passIsEror),
                          if (passErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                passErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 14),

                          ConfirmPassInput(
                            controller: confirmPasswordController,
                            isEror: confirmPassIsEror,
                          ),
                          if (confirmPassErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                confirmPassErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 18),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: agreeTerms,
                                  activeColor: darkMaroon,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: termsErrorMessage.isNotEmpty
                                        ? dangerColor
                                        : const Color(0xFFBDBDBD),
                                    width: 1.5,
                                  ),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreeTerms = value ?? false;
                                      if (agreeTerms) {
                                        termsErrorMessage = '';
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      agreeTerms = !agreeTerms;
                                      if (agreeTerms) {
                                        termsErrorMessage = '';
                                      }
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'poppins',
                                        color: blackColor,
                                        height: 1.4,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text: "Saya menyetujui "),
                                        TextSpan(
                                          text: "Syarat & Ketentuan",
                                          style: TextStyle(
                                            color: darkMaroon,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _showTermsDialog(context);
                                            },
                                        ),
                                        const TextSpan(text: " yang berlaku"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (termsErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 34),
                              child: Text(
                                termsErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                String fullName =
                                    fullNameController.text.trim();
                                String username =
                                    usernameController.text.trim();
                                String email = EmailController.text.trim();
                                String pass = passwordController.text.trim();
                                String confirmPass =
                                    confirmPasswordController.text.trim();

                                createAccount(fullName, username, email, pass,
                                    confirmPass);
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
                                'Daftar Akun Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'poppins',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

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
                                  const TextSpan(text: "Sudah punya akun? "),
                                  TextSpan(
                                    text: "Masuk Sekarang",
                                    style: TextStyle(
                                      color: darkMaroon,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  login_page()),
                                          (route) => false,
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
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
