part of '../page.dart';

class Caripekerjaan extends StatefulWidget {
  const Caripekerjaan({super.key});

  @override
  State<Caripekerjaan> createState() => _CaripekerjaanState();
}

class _CaripekerjaanState extends State<Caripekerjaan> {
  final TextEditingController searchController = TextEditingController();
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
                        "Temukan Pekerjaan",
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
                                text: "Di ", // Teks awal
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text: "RekanPabrik", // Teks yang di-bold
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold, // Membuat teks bold
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ", kami memudahkan Anda menemukan peluang kerja yang sesuai dengan keterampilan, pengalaman, dan tujuan karier Anda. Telusuri daftar lengkap kami dan ambil langkah berikutnya dalam perjalanan karier Anda.",
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
              searchBarCariPekerjaan(),
              SizedBox(
                height: 30,
              ),
            ],
          )),
      //bottomNavigationBar: navbarComponent(),
    );
  }
}
