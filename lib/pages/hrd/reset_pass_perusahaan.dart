import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Resetpassperusahaan extends StatefulWidget {
  const Resetpassperusahaan({super.key});

  @override
  State<Resetpassperusahaan> createState() => _ResetpassperusahaanState();
}

class _ResetpassperusahaanState extends State<Resetpassperusahaan> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController ConfirmNewpasswordController =
      TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final PerusahaanAPI perusahaanapi = PerusahaanAPI();

  bool passIsEror = false;
  bool newPassIsEror = false;
  bool ConfirmNewpassIsEror = false;
  bool _obscureText = true;
  bool isLoading = false;
  String errMassage = '';
  var user;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
  }

  Future<void> initUser() async {
    var response = await meAPI().getUserProfile();

    if (response['status'] == true && response['data'] != null) {
      setState(() {
        user = response['data'];
      });
    } else {
      print("Failed to retrieve user data: ${response['message']}");
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

  void showPasswordResetNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'password_channel',
      'Password Reset Notifications',
      channelDescription: 'Notifications for password reset',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Password Reset Successful',
      'Your password has been reset successfully. Please use the new password to log in.',
      platformChannelSpecifics,
    );
  }

  void resetPass(String newPass, String confirmNewPass) async {
    setState(() {
      passIsEror = false;
      newPassIsEror = false;
      ConfirmNewpassIsEror = false;
      errMassage = '';

      if (newPass.isNotEmpty && confirmNewPass.isNotEmpty) {
        if (newPass == confirmNewPass) {
          _showConfirmationDialog(context, newPass, confirmNewPass);
        } else {
          newPassIsEror = true;
          ConfirmNewpassIsEror = true;
          errMassage = 'Password baru anda tidak sesuai';
        }
      } else {
        passIsEror = true;
        newPassIsEror = true;
        ConfirmNewpassIsEror = true;
        errMassage = 'Semua Inputan Harus Terisi';
      }
    });
  }

  void _showConfirmationDialog(
      BuildContext parentContext, String newPass, String confirmNewPass) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengubah password?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                showLoadingDialog(parentContext);

                bool success = await _updatePassword(newPass);
                if (!parentContext.mounted) return;

                Navigator.of(parentContext).pop();

                if (success) {
                  showPasswordResetNotification();
                  Navigator.pushNamed(context, '/pageHRD');
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Gagal mengubah password.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<bool> _updatePassword(
      String newPassword,
      ) async {
    return await PerusahaanAPI().changePassword(
      newPassword: newPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            children: [
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: newPasswordController, // Menghubungkan controller
                obscureText: _obscureText, // Kontrol visibilitas password
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20),
                  labelText: 'Password Baru',
                  labelStyle: TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: newPassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: newPassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
              ),
              if (errMassage.isNotEmpty)
                Text(
                  errMassage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller:
                    ConfirmNewpasswordController, // Menghubungkan controller
                obscureText: _obscureText, // Kontrol visibilitas password
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20),
                  labelText: 'Konfirmasi Password',
                  labelStyle: TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: ConfirmNewpassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: ConfirmNewpassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
              ),
              if (errMassage.isNotEmpty)
                Text(
                  errMassage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String newPass = newPasswordController.text;
                        String confirmNewPass =
                            ConfirmNewpasswordController.text;

                        resetPass(newPass, confirmNewPass);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: thirdColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
