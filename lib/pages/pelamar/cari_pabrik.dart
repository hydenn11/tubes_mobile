part of '../page.dart';

class CariPabrik extends StatefulWidget {
  const CariPabrik({super.key});

  @override
  State<CariPabrik> createState() => _CariPabrik();
}

class _CariPabrik extends State<CariPabrik> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(''),
      ),
      body: SafeArea(
          bottom: true,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Temukan Perusahaan Terbaik",
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
                      child: Text(
                        "Mencari pekerjaan pabrik yang sempurna? Baik Anda seorang pekerja terampil atau baru memulai karier, menemukan peluang yang tepat bisa jadi sulit. Platform kami mempermudahnya dengan menghubungkan para pencari kerja dengan perusahaan manufaktur terkemuka di industri ini.",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: thirdColor),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              searchBarCariPabrik(),
              SizedBox(
                height: 30,
              ),
            ],
          )),
      //bottomNavigationBar: navbarComponent(),
    );
  }
}
