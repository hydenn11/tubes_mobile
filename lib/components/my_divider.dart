import 'package:flutter/material.dart';

class mydivider extends StatelessWidget {
  final Color color;
  final double thickness;

  const mydivider({
    Key? key,
    this.color = Colors.grey,
    this.thickness = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        thickness: thickness,
        color: color,
      ),
    );
  }
}
