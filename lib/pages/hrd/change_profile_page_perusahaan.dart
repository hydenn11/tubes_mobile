import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Changeprofilepageperusahaan extends StatefulWidget {
  const Changeprofilepageperusahaan({super.key});

  @override
  State<Changeprofilepageperusahaan> createState() =>
      _ChangeprofilepageperusahaanState();
}

class _ChangeprofilepageperusahaanState
    extends State<Changeprofilepageperusahaan> {
  final meAPI meapi = meAPI();
  final PerusahaanAPI perusahaanapi = PerusahaanAPI();
  var user;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isLoading = true;
  bool isUploading = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
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
      'profile_picture_channel',
      'Profile picture Update Notifications',
      channelDescription: 'Notifications for profile picture updates',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Foto Profil Diperbarui',
      'Foto profil Anda telah berhasil diperbarui.',
      platformChannelSpecifics,
    );
  }

  Future<void> initUser() async {
    try {
      var response = await meapi.getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          isLoading = false;
        });
      } else {
        print("Failed to retrieve user data: ${response['message']}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.camera &&
        !(await Permission.camera.request().isGranted)) {
      openAppSettings();
      print("Izin kamera ditolak!");
      return;
    }

    if (source == ImageSource.gallery &&
        !(await Permission.photos.request().isGranted)) {
      openAppSettings();
      print("Izin Galeri Foto ditolak!");
      return;
    }

    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _updateProfileData(File selectedImage, int idUser) async {
    setState(() {
      isUploading = true;
    });
    try {
      var response = await perusahaanapi.updateProfilePicture(
          idperusahaan: idUser, imagePath: selectedImage);

      if (response) {
        showProfileUpdatedNotification();
        Navigator.pushNamed(context, '/pageHRD');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui foto: ${response}')),
        );
      }
    } catch (e) {
      print("Error updating profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengunggah foto.')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Ubah Foto Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(color: thirdColor),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: primaryColor),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFA86108), // Warna indikator
                  ),
                ))
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: primaryColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Foto Profil
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[400],
                        backgroundImage: selectedImage != null
                            ? FileImage(
                                selectedImage!,
                              )
                            : (user != null &&
                                    user['profile_pict'] != null
                                ? NetworkImage(user['profile_pict'])
                                    as ImageProvider
                                : const AssetImage(
                                    'assets/img/defaultPict.png')),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Pilih Sumber Gambar
                      ElevatedButton.icon(
                        onPressed: showImageSourceDialog,
                        icon: const Icon(Icons.image),
                        label: const Text("Pilih Gambar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryCoolor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Kirim
                      ElevatedButton(
                        onPressed: selectedImage != null && !isUploading
                            ? () => _updateProfileData(
                                  selectedImage!,
                                  user['id_perusahaan'],
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryCoolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          child: isUploading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Kirim",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
