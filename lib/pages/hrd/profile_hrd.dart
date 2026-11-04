part of '../page.dart';

class Profilehrd extends StatefulWidget {
  const Profilehrd({super.key});

  @override
  State<Profilehrd> createState() => _ProfilehrdState();
}

class _ProfilehrdState extends State<Profilehrd> {
  final TextEditingController namaPerusahaanController =
      TextEditingController();
  final TextEditingController alamatPerusahaanController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tentangPerusahaanController =
      TextEditingController();
  final String defaultFotoIMG = 'assets/img/defaultPict.png';
  final LoginAPI loginapi = LoginAPI();
  final meAPI meapi = meAPI();
  final PerusahaanAPI perusahaanapi = PerusahaanAPI();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
    _requestNotificationPermission();
  }

  Future<void> initUser() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    var response = await meapi.getUserProfile();

    if (response['status'] == true && response['data'] != null) {
      if (!mounted) return;
      setState(() {
        user = response['data'];
        namaPerusahaanController.text =
            (user['nama_perusahaan'] ?? '').toString();
        alamatPerusahaanController.text = (user['alamat'] ?? '').toString();
        emailController.text = (user['email'] ?? '').toString();
        tentangPerusahaanController.text = (user['deskripsi'] ??
                user['about_me'] ??
                user['aboutMe'] ??
                '')
            .toString();
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _requestNotificationPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showProfileUpdatedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'profile_channel',
      'Profile Update Notifications',
      channelDescription: 'Notifications for profile updates',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Profil Diperbarui',
      'Profil perusahaan Anda telah berhasil diperbarui.',
      platformChannelSpecifics,
    );
  }

  Future<void> _updateProfileData(
    String email,
    String namaPerusahaan,
    String tentangPerusahaan,
    String alamatPerusahaan,
  ) async {
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (namaPerusahaan.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama perusahaan tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final success = await perusahaanapi.updateProfileData(
        idperusahaan: user['id_perusahaan'] ?? 1,
        email: email.trim(),
        namaPerusahaan: namaPerusahaan.trim(),
        tentangPerusahaan: tentangPerusahaan.trim(),
        alamatPerusahaan: alamatPerusahaan.trim(),
      );

      if (success) {
        showProfileUpdatedNotification();
        await initUser();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui profil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error memperbarui profil"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout() async {
    bool result = await LoginAPI().logout();
    if (result) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda sudah keluar.")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal keluar akun.")),
      );
    }
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 13,
        color: Color(0xFF64748B),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: darkMaroon, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: darkMaroon),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          "Profil Perusahaan",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.support_agent_rounded, color: darkMaroon),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Pengaduan()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            const SizedBox(height: 10),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: (user != null &&
                            user['profile_pict'] != null &&
                            user['profile_pict'].toString().isNotEmpty)
                        ? NetworkImage(user['profile_pict'])
                        : null,
                    child: (user == null ||
                            user['profile_pict'] == null ||
                            user['profile_pict'].toString().isEmpty)
                        ? const Icon(
                            Icons.business,
                            size: 50,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Changeprofilepageperusahaan(),
                          ),
                        );
                        initUser();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: darkMaroon,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: namaPerusahaanController,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Nama Perusahaan"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: alamatPerusahaanController,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Alamat Perusahaan"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Email Kontak"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: tentangPerusahaanController,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Tentang Perusahaan"),
            ),

            const SizedBox(height: 14),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Resetpassperusahaan(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 20, color: darkMaroon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Ganti Password Perusahaan",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _updateProfileData(
                    emailController.text,
                    namaPerusahaanController.text,
                    tentangPerusahaanController.text,
                    alamatPerusahaanController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: logout,
                child: Text(
                  "Keluar",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: dangerColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
