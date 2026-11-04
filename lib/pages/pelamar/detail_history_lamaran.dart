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
    try {
      var response = await meAPI().getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      final jobDetail = await MelamarPekerjaanapi()
          .getDetailPostinganByIdPostingan(widget.idLamaranPekerjaan);

      if (!mounted) return;
      setState(() {
        selectedJob = jobDetail;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading job details: $e");
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Detail Lamaran",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: darkMaroon),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Detail Lamaran",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            "Data lamaran tidak ditemukan.",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    final String jobStatus = (selectedJob!['status'] ??
            selectedJob!['status_lamaran'] ??
            'diproses')
        .toString()
        .toLowerCase();

    Color statusColor;
    Color statusBgColor;
    String statusText;
    String keteranganStatus;

    if (jobStatus == 'diterima') {
      statusColor = const Color(0xFF047857);
      statusBgColor = const Color(0xFFECFDF5);
      statusText = "Diterima";
      keteranganStatus =
          "Selamat! Lamaran Anda diterima oleh HRD perusahaan. Tunggu arahan selanjutnya.";
    } else if (jobStatus == 'ditolak') {
      statusColor = const Color(0xFFB91C1C);
      statusBgColor = const Color(0xFFFEF2F2);
      statusText = "Ditolak";
      keteranganStatus =
          "Mohon maaf, lamaran Anda belum sesuai dengan kebutuhan posisi ini.";
    } else {
      statusColor = const Color(0xFFB45309);
      statusBgColor = const Color(0xFFFFFBEB);
      statusText = "Diproses";
      keteranganStatus =
          "Lamaran Anda sedang diproses oleh HRD perusahaan.";
    }

    final String companyName =
        selectedJob!['nama_perusahaan']?.toString() ?? 'PT Rekan Pabrik';
    final String posisi =
        selectedJob!['posisi']?.toString() ?? 'Operator Produksi';

    final String firstName = user?['first_name']?.toString() ?? '';
    final String lastName = user?['last_name']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: blackColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Lamaran",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF1F5F9),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            Text(
              posisi,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: blackColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              companyName,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              keteranganStatus,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 24),

            const Text(
              "Data Pelamar",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow("Nama Depan", firstName.isNotEmpty ? firstName : "-"),
            const SizedBox(height: 12),
            _buildInfoRow(
                "Nama Belakang", lastName.isNotEmpty ? lastName : "-"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
          ),
        ),
      ],
    );
  }
}
