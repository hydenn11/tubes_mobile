part of '../page.dart';

class Detailhistorylamaran extends StatefulWidget {
  final int idLamaranPekerjaan;

  const Detailhistorylamaran({super.key, required this.idLamaranPekerjaan});

  @override
  State<Detailhistorylamaran> createState() => _DetailhistorylamaranState();
}

class _DetailhistorylamaranState extends State<Detailhistorylamaran> {
  var user;
  Map<String, dynamic>? selectedJob;
  bool isLoading = true;

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

  Future<void> _fetchJobDetails() async {
    try {
      final jobDetail = await MelamarPekerjaanapi()
          .getDetailPostinganByIdPostingan(widget.idLamaranPekerjaan);

      setState(() {
        selectedJob = jobDetail;
        isLoading = false;
      });
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
        body: Center(
          child: CircularProgressIndicator(
            color: thirdColor,
          ),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Detail Riwayat Lamaran"),
        ),
        body: Center(
          child: Text("Pekerjaan tidak ditemukan."),
        ),
      );
    }

    Color statusColor;
    String statusText;

    if (selectedJob!['status'] == 'diterima') {
      statusColor = Colors.green;
      statusText = "diterima";
    } else if (selectedJob!['status'] == 'ditolak') {
      statusColor = Colors.red;
      statusText = "ditolak";
    } else if (selectedJob!['status'] == 'diproses') {
      statusColor = Colors.grey;
      statusText = "diproses";
    } else {
      statusColor = Colors.black;
      statusText = "null";
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text("Lamar Pekerjaan"),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(height: 30),
            Align(
              child: Text(
                DateFormat('dd MMMM yyyy').format(
                    DateTime.parse(selectedJob!['createdAt'].toString())
                        .toLocal()),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50),
            Align(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Status: $statusText",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
            Align(
              child: Column(
                children: [
                  Text(
                    selectedJob!['nama_perusahaan'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    selectedJob!['posisi'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: user != null &&
                            user['profile_pict'] != null &&
                            user['profile_pict'].toString().isNotEmpty
                        ? NetworkImage(user['profile_pict'])
                        : null,
                    child: (user == null ||
                            user['profile_pict'] == null ||
                            user['profile_pict'].toString().isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.black,
                          )
                        : null,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: TextEditingController(
                          text: user?['first_name']?.toString() ?? ''),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Nama Depan',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: TextEditingController(
                          text: user?['last_name']?.toString() ?? ''),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Nama Belakang',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Align(
                alignment: Alignment.center,
                child: Text(
                  "Lamaran anda sedang di proses oleh HRD perusahaan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
