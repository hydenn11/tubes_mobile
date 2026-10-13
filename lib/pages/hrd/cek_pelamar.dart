part of '../page.dart';

class Cekpelamar extends StatefulWidget {
  const Cekpelamar({super.key});

  @override
  State<Cekpelamar> createState() => _CekpelamarState();
}

class _CekpelamarState extends State<Cekpelamar> {
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
                        "Pelamar",
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
                                    "Tetap Terinformasi Tentang Proses Perekrutan Anda ", // Teks yang di-bold
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold, // Membuat teks bold
                                  color: thirdColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Di RekanPabrik, kami membantu Anda mengikuti setiap tahapan proses perekrutan. Dari lamaran baru hingga informasi terbaru tentang kandidat terpilih, Anda akan menemukan semua informasi terbaru di sini. Kelola lowongan pekerjaan Anda secara efisien dan buat keputusan yang tepat dengan wawasan waktu nyata.",
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
              SearchBarPelamarPekerjaan(),
              SizedBox(
                height: 100,
              ),
            ],
          )),
    );
  }
}
