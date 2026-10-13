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

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
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

  void showComplaintSentNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'complaint_channel',
      'Complaint Notifications',
      channelDescription: 'Notifications for sent complaints',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
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

  Future<void> submitComplaint(String firstName, String lastName, String email,
      String phone, String message) async {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Semua kolom harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("========== DATA PENGADUAN ==========");
    print("FIRST NAME : $firstName");
    print("LAST NAME  : $lastName");
    print("EMAIL      : $email");
    print("PHONE      : $phone");
    print("MESSAGE    : $message");
    print("====================================");

    try {
      setState(() {
        isLoading = true;
      });
      bool status = await Pengaduanapi()
          .kirimPengaduan(firstName, lastName, email, phone, message);
      if (status) {
        setState(() {
          isLoading = false;
        });
        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        phoneController.clear();
        messageController.clear();

        showComplaintSentNotification();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim pengaduan, coba lagi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saat mengirim pengaduan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kirim Pengaduan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: thirdColor),
        ),
      ),
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Depan
              const Text(
                "Nama Depan",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Masukkan Nama Depan",
                ),
              ),
              const SizedBox(height: 16),
              // Nama Belakang
              const Text(
                "Nama Belakang",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Masukkan Nama Belakang",
                ),
              ),
              const SizedBox(height: 16),
              // Email
              const Text(
                "Email",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Masukkan Email",
                ),
              ),
              const SizedBox(height: 16),
              // Nomor Telepon
              const Text(
                "Nomor Telepon",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Masukkan Nomor Telepon",
                ),
              ),
              const SizedBox(height: 16),
              // Pesan Pengaduan
              const Text(
                "Pesan Pengaduan",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Tuliskan pesan pengaduan Anda",
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: isLoading
                    ? CircularProgressIndicator(
                        color: thirdColor,
                      )
                    : ElevatedButton(
                        onPressed: () {
                          final String firstName = firstNameController.text;
                          final String lastName = lastNameController.text;
                          final String email = emailController.text;
                          final String phone = phoneController.text;
                          final String message = messageController.text;

                          submitComplaint(
                              firstName, lastName, email, phone, message);
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
                          'Kirim',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontFamily: 'poppins',
                          ),
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
