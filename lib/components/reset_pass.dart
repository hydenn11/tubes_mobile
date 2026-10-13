import 'package:flutter/material.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Resetpass extends StatefulWidget {
  @override
  State<Resetpass> createState() => _ResetpassState();
}

class _ResetpassState extends State<Resetpass> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController ConfirmNewpasswordController =
      TextEditingController();

  bool passIsEror = false;
  bool newPassIsEror = false;
  bool ConfirmNewpassIsEror = false;
  bool _obscureText = true;

  String errMassage = '';
  final userData = {
    'first_name': 'John',
    'last_name': 'Doe',
    'pass': 'test123'
  };

  void resetPass(String oldPass, String newPass, String confirmNewPass) async {
    setState(() {
      // Reset error status
      passIsEror = false;
      newPassIsEror = false;
      ConfirmNewpassIsEror = false;
      errMassage = ''; // Reset pesan kesalahan

      if (oldPass.isNotEmpty &&
          newPass.isNotEmpty &&
          confirmNewPass.isNotEmpty) {
        if (oldPass == userData['pass']) {
          if (newPass == confirmNewPass) {
            _showConfirmationDialog(context, oldPass, newPass, confirmNewPass);
          } else {
            // Jika password baru tidak sama dengan konfirmasi
            newPassIsEror = true;
            ConfirmNewpassIsEror = true;
            errMassage = 'Password baru anda tidak sesuai';
          }
        } else {
          // Jika password lama salah
          passIsEror = true;
          errMassage = 'Password lama anda salah';
        }
      } else {
        // Jika ada inputan yang kosong
        passIsEror = true;
        newPassIsEror = true;
        ConfirmNewpassIsEror = true;
        errMassage = 'Semua Inputan Harus Terisi';
      }
    });
  }

  void _showConfirmationDialog(BuildContext context, String oldPass,
      String newPass, String confirmNewPass) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengubah password?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui!')),
                );
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            children: [
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: passwordController, // Menghubungkan controller
                obscureText: _obscureText, // Kontrol visibilitas password
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20),
                  labelText: 'Password Sekarang',
                  labelStyle: TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: passIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: passIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
              ),
              if (errMassage.isNotEmpty)
                Text(
                  errMassage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: newPasswordController, // Menghubungkan controller
                obscureText: _obscureText, // Kontrol visibilitas password
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20),
                  labelText: 'Password Baru',
                  labelStyle: TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: newPassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: newPassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
              ),
              if (errMassage.isNotEmpty)
                Text(
                  errMassage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller:
                    ConfirmNewpasswordController, // Menghubungkan controller
                obscureText: _obscureText, // Kontrol visibilitas password
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: 20),
                  labelText: 'Konfirmasi Password',
                  labelStyle: TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: ConfirmNewpassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: ConfirmNewpassIsEror ? Colors.red : thirdColor,
                        width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
              ),
              if (errMassage.isNotEmpty)
                Text(
                  errMassage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String oldPass = passwordController.text;
                        String newPass = newPasswordController.text;
                        String confirmNewPass =
                            ConfirmNewpasswordController.text;

                        resetPass(oldPass, newPass, confirmNewPass);
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
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
