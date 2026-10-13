part of '../page.dart';

class savedJobs extends StatefulWidget {
  const savedJobs({super.key});

  @override
  State<savedJobs> createState() => _savedJobsState();
}

class _savedJobsState extends State<savedJobs> {

  @override

  Widget build(BuildContext context) {
    return Scaffold(
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
                        "Pekerjaan Tersimpan",
                        style: TextStyle(
                            fontSize: 30,
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
                        width: 350, // Sesuaikan dengan kebutuhan
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "Pantau Peluang yang Penting ", // Teks yang di-bold
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold, // Membuat teks bold
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Pekerjaan yang telah Anda simpan ada di sini, siap untuk saat Anda siap mengambil langkah berikutnya. Di",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text: " RekanPabrik", // Teks yang di-bold
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold, // Membuat teks bold
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ", kami memahami betapa pentingnya tetap terorganisasi dalam pencarian pekerjaan Anda. Dengan pekerjaan yang tersimpan, Anda dapat dengan mudah kembali ke peluang yang menarik perhatian Anda.",
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
                    SizedBox(
                      height: 30,
                    ),
                    searchBarSavedJobs(),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          )),
      //bottomNavigationBar: navbarComponent(),
    );
  }
}
