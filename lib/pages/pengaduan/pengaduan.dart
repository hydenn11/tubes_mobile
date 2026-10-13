import 'package:flutter/material.dart';
import 'package:rekanpabrik/pages/pengaduan/kirim_pengaduan.dart';
import 'package:rekanpabrik/shared/shared.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class Pengaduan extends StatefulWidget {
  const Pengaduan({super.key});

  @override
  State<Pengaduan> createState() => _PengaduanState();
}

class _PengaduanState extends State<Pengaduan> {
  final String url = dotenv.env['WA_URL'].toString();
  Uri? WhatsAppURL;

  @override
  void initState() {
    super.initState();
    WhatsAppURL = Uri.parse(url);
  }

  Future<void> _launchWhatsApp() async {
    try {
      if (WhatsAppURL != null) {
        await launchUrl(WhatsAppURL!, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $WhatsAppURL')),
        );
      }
    } catch (e) {
      print("error klik wa $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Customer Service",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(color: thirdColor),
          ),
        ),
        backgroundColor: primaryColor,
        body: SafeArea(
          bottom: true,
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Hubungi Customer Service Kami",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: thirdColor),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 350,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Tim Customer Service kami siap membantu Anda. Apapun masalah atau pertanyaan yang Anda miliki, kami ada untuk memberikan solusi terbaik dengan cepat dan efisien. Jangan ragu untuk menghubungi kami melalui salah satu opsi di bawah ini. ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: thirdColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _launchWhatsApp();
                        },
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          "Live Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: succesColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KirimPengaduan(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: const Text(
                          "Email",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ]),
        ));
  }
}
