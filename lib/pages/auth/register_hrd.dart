part of '../page.dart';

class register_hrd extends StatefulWidget {
  @override
  _registerHrdState createState() => _registerHrdState();
}

class _registerHrdState extends State<register_hrd> {
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

  final TextEditingController CompanyNameController = TextEditingController();
  String CompanyNameErrorMessage = '';
  bool CompanyNameIsEror = false;

  bool agreeTerms = false;
  String termsErrorMessage = '';

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

  Future<void> createAccountPerusahaan(String email, String password,
      String namaPerusahaan, String confirmPass) async {
    setState(() {
      CompanyNameErrorMessage = '';
      emailErrorMessage = '';
      passErrorMessage = '';
      confirmPassErrorMessage = '';
      termsErrorMessage = '';

      CompanyNameIsEror = false;
      mailIsEror = false;
      passIsEror = false;
      confirmPassIsEror = false;

      if (namaPerusahaan.isEmpty) {
        CompanyNameErrorMessage = "Nama perusahaan tidak boleh kosong";
        CompanyNameIsEror = true;
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

    if (!CompanyNameIsEror &&
        !mailIsEror &&
        !passIsEror &&
        !confirmPassIsEror &&
        agreeTerms) {
      try {
        bool status = await PerusahaanAPI()
            .createAccount(email, password, namaPerusahaan);

        if (status) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => login_page()),
            (route) => false,
          );
          showProfileUpdatedNotification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Akun perusahaan berhasil dibuat! Silakan masuk."),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ooppss, pendaftaran akun perusahaan gagal!"),
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
      'company_account_creation_channel',
      'Notifikasi Pembuatan Akun Perusahaan',
      channelDescription: 'Notifikasi untuk pembuatan akun perusahaan',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Akun Perusahaan Berhasil Dibuat',
      'Selamat datang di platform kami! Akun perusahaan Anda telah dibuat. Mulailah memasang lowongan pekerjaan sekarang!',
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
                  "Selamat datang di RekanPabrik. Dengan mendaftar akun perusahaan/HRD, Anda menyetujui ketentuan berikut:",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                _termsItem("1. Keabsahan Perusahaan",
                    "Perusahaan Anda merupakan badan usaha atau entitas legal yang sah beroperasi di Indonesia."),
                _termsItem("2. Informasi Lowongan",
                    "Lowongan pekerjaan yang dipublikasikan tidak memungut biaya apapun kepada pelamar dan merupakan informasi valid."),
                _termsItem("3. Kerahasiaan Data Pelamar",
                    "Data pribadi dan berkas CV pelamar hanya digunakan untuk keperluan rekrutmen dan wajib dijaga kerahasiaannya."),
                _termsItem("4. Penggunaan Layanan",
                    "Pengelola berhak menonaktifkan akun perusahaan yang melanggar ketentuan atau terindikasi melakukan penyalahgunaan."),
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
                                  child: Icon(Icons.person_outline_rounded,
                                      color: darkMaroon, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mendaftar sebagai Pelamar?",
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: blackColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Cari & lamar lowongan pekerjaan",
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
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                register_pelamar()),
                                      );
                                    }
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
                                  "Daftar Akun Perusahaan",
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
                                  "Lengkapi data perusahaan untuk mulai memasang lowongan",
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
                            nameInputController: CompanyNameController,
                            label: "Nama Perusahaan",
                            hintText: "contoh: PT Industri Maju Bersama",
                            isEror: CompanyNameIsEror,
                          ),
                          if (CompanyNameErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                CompanyNameErrorMessage,
                                style: TextStyle(
                                    color: dangerColor,
                                    fontSize: 11,
                                    fontFamily: 'poppins'),
                              ),
                            ),

                          const SizedBox(height: 14),

                          EmailInput(
                              emailController: EmailController,
                              isEror: mailIsEror,
                              labelText: 'Email Perusahaan',
                              hintText: 'hrd@perusahaan.com'),
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
                                String companyName =
                                    CompanyNameController.text.trim();
                                String email = EmailController.text.trim();
                                String pass = passwordController.text.trim();
                                String confirmPass =
                                    confirmPasswordController.text.trim();

                                createAccountPerusahaan(
                                    email, pass, companyName, confirmPass);
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
