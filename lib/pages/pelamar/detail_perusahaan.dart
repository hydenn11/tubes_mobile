part of '../page.dart';

class DetailPerusahaan extends StatefulWidget {
  final int companyId;

  const DetailPerusahaan({super.key, required this.companyId});

  @override
  State<DetailPerusahaan> createState() => _DetailPerusahaanState();
}

class _DetailPerusahaanState extends State<DetailPerusahaan> {
  var user;
  Map<String, dynamic>? selectedJob;
  bool isLoading = true;
  String defaultFotoIMG = 'assets/img/iconRekanPabrik.png';

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
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
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Anda belum login ')));
      Navigator.pushNamed(context, '/login');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      List<Map<String, dynamic>> jobDetails =
          await PerusahaanAPI().getPerusahaanByIDPerusahaan(widget.companyId);
      if (jobDetails.isNotEmpty) {
        setState(() {
          selectedJob = jobDetails.first;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading job details: $e");
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
        appBar: AppBar(
          title: Text("Detail Perusahaan"),
        ),
        body: Center(
          child: CircularProgressIndicator(color: thirdColor),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text("Detail Perusahaan"),
        ),
        body: Center(
          child: Text(
            "Data perusahaan tidak ditemukan.",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Align(
                  child: Column(
                children: [
                  selectedJob!['profile_pict'] != null &&
                          selectedJob!['profile_pict'].toString().isNotEmpty
                      ? Image.network(
                          selectedJob!['profile_pict'],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          defaultFotoIMG,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(height: 20),
                  Text(
                    selectedJob!['nama_perusahaan'].toString(),
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
              Container(
                child: Column(
                  children: [
                    Text(
                      '${selectedJob!['alamat'].toString()} Lowongan',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedJob!['about_me'].toString()}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 20),
                          // Container untuk jumlah lowongan
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5), // Padding di dalam Container
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(
                                  217, 217, 217, 100), // Warna latar belakang
                              borderRadius:
                                  BorderRadius.circular(10), // Border radius
                            ),
                            child: Text(
                              '${selectedJob!['jumlah_posting'].toString()} Lowongan',
                              style: TextStyle(
                                color: Colors.black, // Warna teks
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
