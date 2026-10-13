import 'package:flutter/material.dart';
import 'package:rekanpabrik/shared/shared.dart';

class ConfirmPassInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isEror;

  const ConfirmPassInput({
    super.key,
    required this.controller,
    required this.isEror,
  });

  @override
  _confirmPassInput createState() => _confirmPassInput();
}

class _confirmPassInput extends State<ConfirmPassInput> {
  bool _obscureText = true;

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
        controller: widget.controller,
        obscureText: _obscureText,
        style: TextStyle(
          color: blackColor,
          fontFamily: 'poppins',
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          prefixIcon: Icon(
            Icons.lock_reset_rounded,
            size: 22,
            color: widget.isEror ? dangerColor : thirdColor,
          ),
          labelText: 'Konfirmasi Password',
          hintText: 'Ulangi password Anda',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          labelStyle: TextStyle(
            color: widget.isEror ? dangerColor : greyColor,
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
              color: widget.isEror ? dangerColor : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: widget.isEror ? dangerColor : thirdColor,
              width: 2.0,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: greyColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}
