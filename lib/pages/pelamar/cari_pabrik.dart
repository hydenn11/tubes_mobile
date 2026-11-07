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
        title: const Text(''),
      ),
      body: SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Daftar Perusahaan",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'poppins',
                            color: blackColor),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cari profil perusahaan manufaktur dan lihat lowongan yang tersedia.",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'poppins',
                            color: greyColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const searchBarCariPabrik(),
              const SizedBox(
                height: 30,
              ),
            ],
          )),
    );
  }
}
