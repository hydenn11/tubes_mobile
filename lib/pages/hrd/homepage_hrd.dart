part of '../page.dart';

class Homepagehrd extends StatefulWidget {
  const Homepagehrd({super.key});

  @override
  State<Homepagehrd> createState() => _HomepagehrdState();
}

class _HomepagehrdState extends State<Homepagehrd> {
  var user;
  final String defaultFotoIMG = 'assets/img/defaultPict.png';
  bool isLoading = true;

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
                // Sesuaikan tinggi untuk menampung teks tambahan
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
                    // Membuat kolom di sebelah kiri untuk teks "Welcome" dan nama user
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Agar teks rata kiri
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Vertikal di tengah
                      children: [
                        Text(
                          "Selamat Datang!",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                            fontSize:
                                20, // Ukuran font lebih kecil untuk "Welcome"
                            fontWeight:
                                FontWeight.bold, // Berat font lebih ringan
                          ),
                        ),
                        SizedBox(
                            height: 5), // Jarak antara "Welcome" dan nama user
                        Text(
                          user['nama_perusahaan'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Avatar berada di kanan
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (user['profile_pict'] != null &&
                              user['profile_pict'].isNotEmpty)
                          ? NetworkImage(user['profile_pict'])
                          : null,
                      child: (user?['profile_pict'] == null ||
                              user['profile_pict'].isEmpty)
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
            SizedBox(
              height: 50,
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor, // Background color grey
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: thirdColor, // Warna border
                  width: 2.0, // Ketebalan border
                ), // Border radius 10
              ),
              child: Column(
                children: [
                  // Foto di dalam container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        8), // Membuat foto berbentuk rounded
                    child: Image.asset(
                      'assets/img/Image1.png', // Path ke foto Anda
                      height: 200, // Tinggi foto
                      width: 500, // Lebar foto
                      fit: BoxFit.fill, // Menjaga proporsi foto
                    ),
                  ),
                  SizedBox(height: 30), // Jarak antara foto dan teks
                  // Tulisan di bawah foto
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      child: Text(
                        "Mencari kandidat yang tepat?",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'poppins',
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      child: Text(
                        "Dapatkan kandidat yang sesuai dengan kriteria Anda",
                        style: TextStyle(
                          color: greyColor,
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HRDnavbarComponent(
                              initialIndex: 2,
                            ),
                          ),
                        );
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
                        'Unggah Lowongan',
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
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryColor, // Background color grey
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: thirdColor, // Warna border
                  width: 2.0, // Ketebalan border
                ), // Border radius 10
              ),
              child: Column(
                children: [
                  // Foto di dalam container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        8), // Membuat foto berbentuk rounded
                    child: Image.asset(
                      'assets/img/Image2.png', // Path ke foto Anda
                      height: 200, // Tinggi foto
                      width: 500, // Lebar foto
                      fit: BoxFit.fill, // Menjaga proporsi foto
                    ),
                  ),
                  SizedBox(height: 30), // Jarak antara foto dan teks
                  // Tulisan di bawah foto
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      child: Text(
                        "Telusuri kandidat yang tepat",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'poppins',
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      child: Text(
                        "Periksa kandidat yang sesuai dengan kriteria Anda",
                        style: TextStyle(
                          color: greyColor,
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HRDnavbarComponent(
                              initialIndex: 2,
                            ),
                          ),
                        );
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
                        'Unggah Lowongan',
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
            SizedBox(
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
