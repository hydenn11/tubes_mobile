part of '../page.dart';

class riwayatLamaran extends StatefulWidget {
  const riwayatLamaran({super.key});

  @override
  State<riwayatLamaran> createState() => _riwayatLamaranState();
}

class _riwayatLamaranState extends State<riwayatLamaran> {
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
                        "Riwayat Lamaran",
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
                                    "Riwayat lamaran Anda memberikan gambaran lengkap tentang pekerjaan yang telah Anda lamar di Rekan Pabrik. Tetaplah teratur dan dapatkan informasi terkini dengan meninjau status setiap lamaran, mulai dari pengajuan hingga keputusan akhir. Kami siap membantu Anda tetap mengikuti perkembangan pencarian kerja dan terus maju.",
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
                    searchBarRiwayatLamaran(),
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
