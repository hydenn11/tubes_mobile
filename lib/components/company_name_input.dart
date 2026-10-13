import 'package:flutter/material.dart';
import 'package:rekanpabrik/shared/shared.dart';

class companyname_input extends StatelessWidget {
  final TextEditingController companyNameInputController;
  final String label;
  final bool isEror;

  const companyname_input({
    super.key,
    required this.companyNameInputController,
    required this.label,
    required this.isEror,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: companyNameInputController, // Menghubungkan controller
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          size: 20,
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: greyColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isEror ? Colors.red : thirdColor,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isEror ? Colors.red : thirdColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
