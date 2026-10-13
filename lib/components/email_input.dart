import 'package:flutter/material.dart';
import 'package:rekanpabrik/shared/shared.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController emailController;
  final bool isEror;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;

  const EmailInput({
    super.key,
    required this.emailController,
    required this.isEror,
    this.labelText = 'Email',
    this.hintText = 'nama@email.com',
    this.prefixIcon = Icons.email_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: blackColor,
          fontFamily: 'poppins',
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          prefixIcon: Icon(
            prefixIcon,
            size: 22,
            color: isEror ? dangerColor : thirdColor,
          ),
          labelText: labelText,
          hintText: hintText,

          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          labelStyle: TextStyle(
            color: isEror ? dangerColor : greyColor,
            fontFamily: 'poppins',
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isEror ? dangerColor : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isEror ? dangerColor : thirdColor,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
