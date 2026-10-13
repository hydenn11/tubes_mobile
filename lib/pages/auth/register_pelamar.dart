part of '../page.dart';

class register_pelamar extends StatefulWidget {
  @override
  _registerPelamarState createState() => _registerPelamarState();
}

class _registerPelamarState extends State<register_pelamar> {
  // VARIABLE
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

  final TextEditingController FNameController = TextEditingController();
  String FNameErrorMessage = '';
  bool FNameIsEror = false;

  final TextEditingController LNameController = TextEditingController();
  String LNameErrorMessage = '';
  bool LNameIsEror = false;

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

  // FUNGSI
  bool isEmailValid(String email) {
    return email.contains('@');
  }

  bool isPassValid(String pass) {
    return pass.isNotEmpty;
  }

  bool checkConfirmPass(String pass, String confirmPass) {
    return (pass == confirmPass);
  }

  Future<void> createAccount(String Fname, String Lname, String username, String email,
      String password, String confirmPass) async {
    setState(() {
      // Reset semua error messages
      FNameErrorMessage = '';
      LNameErrorMessage = '';
      usernameErrorMessage = '';
      emailErrorMessage = '';
      passErrorMessage = '';
      confirmPassErrorMessage = '';

      // Reset status error
      FNameIsEror = false;
      LNameIsEror = false;
      usernameIsEror = false;
      mailIsEror = false;
      passIsEror = false;
      confirmPassIsEror = false;

      // Cek jika ada field yang kosong dan set error message yang sesuai
      if (Fname.isEmpty) {
        FNameErrorMessage = "Nama depan tidak boleh kosong";
        FNameIsEror = true;
      }
      if (Lname.isEmpty) {
        LNameErrorMessage = "Nama belakang tidak boleh kosong";
        LNameIsEror = true;
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
    });

    if (!FNameIsEror &&
        !LNameIsEror &&
        !usernameIsEror &&
        !mailIsEror &&
        !passIsEror &&
        !confirmPassIsEror) {
      try {
        final result = await Pelamarapi().createAccount(
          Fname,
          Lname,
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
      'Selamat datang di platform kami! Akun Anda telah dibuat. Mulailah menjelajahi peluang sekarang!',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: blackColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
        ),


      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Switch role banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: secondaryCoolor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: thirdColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_rounded, color: thirdColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            horizontal: 12, vertical: 6),
                        backgroundColor: thirdColor,
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

              const SizedBox(height: 24),

              // Title
              Text(
                "Buat Akun Pelamar",
                style: TextStyle(
                  color: blackColor,
                  fontFamily: 'poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Lengkapi data diri untuk mulai mencari peluang kerja.",
                style: TextStyle(
                  color: greyColor,
                  fontFamily: 'poppins',
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              // First Name & Last Name (Row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        name_input(
                          nameInputController: FNameController,
                          label: "Nama Depan",
                          isEror: FNameIsEror,
                        ),
                        if (FNameErrorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              FNameErrorMessage,
                              style: TextStyle(
                                  color: dangerColor,
                                  fontSize: 11,
                                  fontFamily: 'poppins'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        name_input(
                          nameInputController: LNameController,
                          label: "Nama Belakang",
                          isEror: LNameIsEror,
                        ),
                        if (LNameErrorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              LNameErrorMessage,
                              style: TextStyle(
                                  color: dangerColor,
                                  fontSize: 11,
                                  fontFamily: 'poppins'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Username
              name_input(
                nameInputController: usernameController,
                label: "Username",
                hintText: "contoh: arvin_12",
                prefixIcon: Icons.alternate_email_rounded,
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

              // Email
              EmailInput(emailController: EmailController, isEror: mailIsEror),
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

              // Password
              PassInput(controller: passwordController, isEror: passIsEror),
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

              // Confirm Password
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

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    String Fname = FNameController.text.trim();
                    String Lname = LNameController.text.trim();
                    String username = usernameController.text.trim();
                    String email = EmailController.text.trim();
                    String pass = passwordController.text.trim();
                    String confirmPass = confirmPasswordController.text.trim();

                    createAccount(Fname, Lname, username, email, pass, confirmPass);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: thirdColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: thirdColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Daftar Akun Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Link
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
                          color: thirdColor,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => login_page()),
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
    );
  }
}
