part of '../page.dart';

class register_hrd extends StatefulWidget {
  @override
  _registerHrdState createState() => _registerHrdState();
}

class _registerHrdState extends State<register_hrd> {
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

  final TextEditingController CompanyNameController = TextEditingController();
  String CompanyNameErrorMessage = '';
  bool CompanyNameIsEror = false;

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

  Future<void> createAccountPerusahaan(String email, String password,
      String namaPerusahaan, String confirmPass) async {
    setState(() {
      // Reset semua error messages
      CompanyNameErrorMessage = ' ';
      emailErrorMessage = '';
      passErrorMessage = '';
      confirmPassErrorMessage = '';

      // Reset status error
      CompanyNameIsEror = false;
      mailIsEror = false;
      passIsEror = false;
      confirmPassIsEror = false;

      // Cek jika ada field yang kosong dan set error message yang sesuai
      if (namaPerusahaan.isEmpty) {
        CompanyNameErrorMessage = "*Nama Perusahan tidak boleh kosong";
        CompanyNameIsEror = true;
      }
      if (email.isEmpty) {
        emailErrorMessage = "*Email tidak boleh kosong";
        mailIsEror = true;
      }
      if (password.isEmpty) {
        passErrorMessage = "*Password tidak boleh kosong";
        passIsEror = true;
      }
      if (confirmPass.isEmpty) {
        confirmPassErrorMessage = "*Konfirmasi password tidak boleh kosong";
        confirmPassIsEror = true;
      } else if (confirmPass != password) {
        confirmPassErrorMessage = "*konfirmasi password tidak sesuai.";
        confirmPassIsEror = true;
      }
    });

    if (!CompanyNameIsEror &&
        !mailIsEror &&
        !passIsEror &&
        !confirmPassIsEror) {
      try {
        bool status = await PerusahaanAPI()
            .createAccount(email, password, namaPerusahaan);

        if (status) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => login_page()),
            (route) => false,
          );
          showProfileUpdatedNotification();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ooppss, Email Sudah Terdaftar!"),
            ),
          );
        }
      } catch (e) {
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
      'Company Account Notifications',
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
      'Company Account Created Successfully',
      'Welcome to our platform! Your company account has been created. Start posting job opportunities now!',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Daftar Sebagai HRD',
          style: TextStyle(
            color: thirdColor,
            fontFamily: 'poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          bottom: true,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "Selamat Datang",
                style: TextStyle(
                  color: thirdColor,
                  fontFamily: 'poppins',
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Lanjutkan untuk membuat akun perusahaan anda",
                style: TextStyle(
                  color: greyColor,
                  fontFamily: 'poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              companyname_input(
                  companyNameInputController: CompanyNameController,
                  label: "Nama Perusahaan",
                  isEror: CompanyNameIsEror),
              if (CompanyNameErrorMessage.isNotEmpty)
                Text(
                  CompanyNameErrorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 10),
              EmailInput(emailController: EmailController, isEror: mailIsEror),
              if (emailErrorMessage.isNotEmpty)
                Text(
                  emailErrorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 10),
              PassInput(controller: passwordController, isEror: passIsEror),
              if (passErrorMessage.isNotEmpty)
                Text(
                  passErrorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 10),
              ConfirmPassInput(
                  controller: confirmPasswordController,
                  isEror: confirmPassIsEror),
              if (confirmPassErrorMessage.isNotEmpty)
                Text(
                  confirmPassErrorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  child: Text(
                    "Dengan melanjutkan Anda mengonfirmasi bahwa Anda telah membaca dan menyetujui ketentuan penggunaan dan pemberitahuan privasi kalender",
                    style: TextStyle(
                        color: greyColor, fontFamily: 'poppins', fontSize: 13),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    String Companyname = CompanyNameController.text;
                    String email = EmailController.text;
                    String pass = passwordController.text;
                    String confirmPass = confirmPasswordController.text;

                    createAccountPerusahaan(
                        email, pass, Companyname, confirmPass);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: thirdColor, // Warna tombol
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Buat Akun',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
