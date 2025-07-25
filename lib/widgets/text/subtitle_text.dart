import 'package:flutter/material.dart';

class SubtitleText extends StatelessWidget {
  final String text;
  final TextAlign align;
  final Color? color;

  const SubtitleText(
      this.text, {
        super.key,
        this.align = TextAlign.center,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 14,
        color: color ?? Colors.grey,
      ),
    );
  }
}