part of '../page.dart';

class home_pelamar extends StatefulWidget {
  const home_pelamar({super.key});

  @override
  State<home_pelamar> createState() => _homePelamar();
}

class _homePelamar extends State<home_pelamar> {
  var user;
  bool isLoading = true;
  final String defaultFotoIMG = 'assets/img/defaultPict.png';

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    var response = await meAPI().getUserProfile();
    try {
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        isLoading = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Anda belum login ')));
        Navigator.pushNamed(context, '/login');
        print("Failed to retrieve user data: ${response['message']}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Anda belum login ')));
      Navigator.pushNamed(context, '/login');
      print("Failed to retrieve user data: ${response['message']}");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: CircularProgressIndicator(
            color: thirdColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Container(
                width: 350,
                height: 120,
                decoration: BoxDecoration(
                  color: thirdColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 30,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Selamat Datang!",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user['first_name'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (user['profile_pict'] != null &&
                              user['profile_pict'].toString().isNotEmpty)
                          ? NetworkImage(user['profile_pict'])
                          : null,
                      child: (user['profile_pict'] == null ||
                              user['profile_pict'].toString().isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text(
                "Temukan Pekerjaan Impian Anda",
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              child: Text(
                "Telusuri profil perusahaan untuk menemukan tempat kerja yang tepat bagi Anda. Pelajari tentang pekerjaan, ulasan, budaya perusahaan, dan banyak lagi.",
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Carousel(
              dummyPerusahaan: dummyPerusahaan,
            ),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cariPabrik');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See More',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'poppins',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Containerhomepelamar(
                textSatu: "“Hello” untuk pencari kerja!",
                textDua: "Dapatkan pekerjaan impian Anda di sini",
                imgLinkk: 'assets/img/Image1.png'),
            SizedBox(
              height: 20,
            ),
            Containerhomepelamar(
                textSatu: "“Hello” untuk perusahaan!",
                textDua: "Dapatkan kandidat terbaik Anda di sini",
                imgLinkk: 'assets/img/Image2.png'),
            SizedBox(
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
