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
  File? _imageFile;
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
        namaPerusahaanController.text = (user['nama_perusahaan'] ?? '').toString();
        alamatPerusahaanController.text = (user['alamat'] ?? '').toString();
        emailController.text = (user['email'] ?? '').toString();
        tentangPerusahaanController.text = (user['deskripsi'] ?? user['about_me'] ?? user['aboutMe'] ?? '').toString();
        isLoading = false;
      });
    } else {

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print("Failed to retrieve user data: ${response['message']}");
    }
  }

  void _requestNotificationPermission() async {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && !granted) {
      print("Izin notifikasi ditolak oleh pengguna");
    }
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
      'Profil Anda telah berhasil diperbarui.',
      platformChannelSpecifics,
    );
  }

  Future<void> _updateProfileData(String email, String namaPerusahaan,
      String tentangPerusahaan, String alamatPerusahaan) async {
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
          idperusahaan: user['id_perusahaan'],
          email: email.trim(),
          namaPerusahaan: namaPerusahaan.trim(),
          tentangPerusahaan: tentangPerusahaan.trim(),
          alamatPerusahaan: alamatPerusahaan.trim());

      if (success) {
        showProfileUpdatedNotification();
        await initUser();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
          ),
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false, // Kembali ke menu awal dan hapus stack sebelumnya
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda sudah keluar")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal Keluar")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.transparent),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent, // Ikon customer service
              color: thirdColor,
              size: 50,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Pengaduan(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: true,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Color.fromARGB(255, 168, 97, 8),
              ))
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: (user['profile_pict'] != null &&
                                user['profile_pict'].isNotEmpty)
                            ? NetworkImage(user['profile_pict'])
                            : const AssetImage('assets/img/defaultPict.png')
                                as ImageProvider,
                      ),
                    ),
                    child: (user['profile_pict'] == null ||
                            user['profile_pict'].isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Changeprofilepageperusahaan(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: namaPerusahaanController,
                    decoration: const InputDecoration(
                      labelText: "Nama Perusahaan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: alamatPerusahaanController,
                    decoration: const InputDecoration(
                      labelText: "Alamat Perusahaan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tentangPerusahaanController,
                    decoration: const InputDecoration(
                      labelText: "Tentang Perusahaan",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: thirdColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Resetpassperusahaan(),
                              ),
                            );
                          },
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: succesColor),
                          onPressed: () {
                            String email = emailController.text;
                            String namaPerusahaan =
                                namaPerusahaanController.text;
                            String tentangPerusahaan =
                                tentangPerusahaanController.text;
                            String alamatPerusahaan =
                                alamatPerusahaanController.text;
                            _updateProfileData(email, namaPerusahaan,
                                tentangPerusahaan, alamatPerusahaan);
                          },
                          child: Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: dangerColor),
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                      "Keluar",
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
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
