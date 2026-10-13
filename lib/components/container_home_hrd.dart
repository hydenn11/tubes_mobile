import 'package:flutter/material.dart';
import 'package:rekanpabrik/shared/shared.dart';

class containerHomeHRD extends StatelessWidget {
  final String textSatu;
  final String textDua;
  final String imgLinkk;

  const containerHomeHRD(
      {super.key,
      required this.textSatu,
      required this.textDua,
      required this.imgLinkk});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            borderRadius:
                BorderRadius.circular(8), // Membuat foto berbentuk rounded
            child: Image.asset(
              imgLinkk, // Path ke foto Anda
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
                textSatu,
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
                textDua,
                style: TextStyle(
                  color: greyColor,
                  fontFamily: 'poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                softWrap: true,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }
}
