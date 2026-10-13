part of '../page.dart';

class Posthistory extends StatefulWidget {
  const Posthistory({super.key});

  @override
  State<Posthistory> createState() => _PosthistoryState();
}

class _PosthistoryState extends State<Posthistory> {
  final meAPI meapi = meAPI();
  final Postingpekerjaanapi postpekerjaanapi = Postingpekerjaanapi();
  var user;

  List<Map<String, dynamic>> resultsJob = [];
  String selectedFilter = 'Tanggal Terbaru';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostPekerjaan();
  }

  Future<void> initUser() async {
    var response = await meapi.getUserProfile();

    print("========== USER ==========");
    print(response);
    print("==========================");

    if (response['status'] == true && response['data'] != null) {
      setState(() {
        user = response['data'];
      });
    }
  }

  Future<void> _fetchPostPekerjaan() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    await initUser();
    if (user == null || user.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda tidak login di aplikasi ')));
      Navigator.pushNamed(context, '/login');
    }
    try {
      if (!mounted) return;
      final data =
          await postpekerjaanapi.getPostPekerjaan(user['id_perusahaan']);

      setState(() {
        resultsJob = data;
      });
      _sortResults();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda Belum memposting pekerjaann ')));
      setState(() {
        isLoading = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sortResults() {
    setState(() {
      if (selectedFilter == 'Tanggal Terbaru') {
        resultsJob.sort(
          (a, b) => DateTime.parse(b['createdAt'])
              .compareTo(DateTime.parse(a['createdAt'])),
        );
      } else if (selectedFilter == 'Status Terbuka') {
        resultsJob.sort((a, b) {
          if (a['status'] == 'terbuka' && b['status'] != 'terbuka') {
            return -1;
          } else if (a['status'] != 'terbuka' && b['status'] == 'terbuka') {
            return 1;
          }
          return 0;
        });
      } else if (selectedFilter == 'Status Berakhir') {
        resultsJob.sort((a, b) {
          if (a['status'] == 'ditutup' && b['status'] != 'ditutup') {
            return -1;
          } else if (a['status'] != 'ditutup' && b['status'] == 'ditutup') {
            return 1;
          }
          return 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const SizedBox(height: 50),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Riwayat Unggahan Lamaran",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: thirdColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 350,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Lacak dan Kelola semua unggahan pekerjaan Anda ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: thirdColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Dengan Rekan Pabrik, Anda memiliki visibilitas penuh atas semua lowongan pekerjaan Anda yang lalu dan saat ini. Akses riwayat lowongan pekerjaan Anda dengan mudah untuk meninjau kinerja, melacak lamaran, dan mengelola status setiap lowongan. Jaga proses perekrutan Anda tetap teratur dan efisien dengan tampilan komprehensif atas upaya perekrutan Anda.",
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
                  const SizedBox(height: 20),
                  // Dropdown untuk mengurutkan
                  DropdownButton<String>(
                    value: selectedFilter,
                    items: [
                      'Tanggal Terbaru',
                      'Status Terbuka',
                      'Status Berakhir',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                        _sortResults(); // Update the sorting based on selection
                      });
                    },
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: thirdColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    hint: Text(
                      'Pilih Filter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    height: 400,
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: thirdColor,
                            ),
                          )
                        : resultsJob.isEmpty
                            ? Center(
                                child: Text(
                                  "Anda belum memposting pekerjaan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: resultsJob.length,
                                itemBuilder: (context, index) {
                                  final job = resultsJob[index];
                                  final date = DateTime.parse(job['createdAt']);
                                  final formattedDate =
                                      DateFormat('dd-MM-yyyy').format(date);
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailPekerjaanHRD(
                                                    jobId: job[
                                                        'id_post_pekerjaan']),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        title: Text(job['posisi']),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Lokasi: ${job['lokasi']}"),
                                            Text("Status: ${job['status']}"),
                                            Text("Tanggal: $formattedDate"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          )),
    );
  }
}
