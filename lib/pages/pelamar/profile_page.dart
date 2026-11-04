part of '../page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();

  final String defaultFotoIMG = 'assets/img/defaultPict.png';
  String cvStatus = '';
  String? cvFileName;
  Uri? _cvURL;
  var user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await meAPI().getUserProfile();

      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          firstNameController.text = (user['first_name'] ?? '').toString();
          lastNameController.text = (user['last_name'] ?? '').toString();
          final about = user['about_me'] ?? user['aboutMe'] ?? '';
          aboutMeController.text = about.toString();
          emailController.text = (user['email'] ?? '').toString();
          final rawCv = (user['cv'] ?? user['curriculum_vitae'] ?? user['cv_path'])?.toString();

          if (rawCv != null && rawCv.isNotEmpty) {
            _cvURL = Uri.tryParse(rawCv);
            cvFileName = rawCv.split(RegExp(r'[\\/]')).last;
            cvStatus = "CV telah diunggah.";
          } else {
            _cvURL = null;
            cvFileName = null;
            cvStatus = "Anda belum mengupload CV.";
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: ${response['message']}"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _launchCV() async {
    if (_cvURL != null && _cvURL!.toString().isNotEmpty) {
      try {
        bool canLaunch = await canLaunchUrl(_cvURL!);
        if (canLaunch) {
          await launchUrl(_cvURL!, mode: LaunchMode.externalApplication);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka CV...')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka file CV.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka CV: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV belum tersedia.')),
      );
    }
  }

  Future<void> saveProfile(
    int idPelamar,
    String firstname,
    String lastname,
    String email,
    String aboutme,
  ) async {
    if (firstname.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama depan tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      bool status = await Pelamarapi().updateDataPelamar(
        idpelamar: idPelamar,
        firstname: firstname.trim(),
        lastname: lastname.trim(),
        email: email.trim(),
        aboutme: aboutme.trim(),
      );

      if (status) {
        await initUser();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error memperbarui profil.')),
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

  ImageProvider? _getAvatarImage(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
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

    final bool hasCV = cvFileName != null && cvFileName!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          "Profil Saya",
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
                    backgroundImage: _getAvatarImage(user?['profile_pict']?.toString()),
                    child: _getAvatarImage(user?['profile_pict']?.toString()) == null
                        ? const Icon(
                            Icons.person,
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
                            builder: (_) => const ChangeProfilePagePelamar(),
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
              controller: firstNameController,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Nama Depan"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: lastNameController,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Nama Belakang"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Email"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: aboutMeController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              decoration: _inputDeco("Tentang Saya"),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CV",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCV ? cvFileName! : "Belum mengunggah CV",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11.5,
                            fontWeight: hasCV ? FontWeight.w500 : FontWeight.normal,
                            color: hasCV ? blackColor : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadCv(),
                        ),
                      );
                      initUser();
                    },
                    child: Text(
                      hasCV ? "Ubah" : "Upload",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: darkMaroon,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Resetpasspelamar(),
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
                    Expanded(
                      child: Text(
                        "Ganti Password",
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
                  final int idpelamar = user['id_pelamar'] ?? 1;
                  saveProfile(
                    idpelamar,
                    firstNameController.text,
                    lastNameController.text,
                    emailController.text,
                    aboutMeController.text,
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
