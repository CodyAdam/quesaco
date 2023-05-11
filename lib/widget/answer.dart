import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String? answerText;
  final Color? answerColor;
  final VoidCallback answerTap;

  const Answer({super.key, required this.answerText, required this.answerColor, required this.answerTap});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: answerTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(
            left: 30.0, right: 30.0, top: 5.0, bottom: 15.0),
        width: 400,
        decoration: BoxDecoration(
          color: answerColor,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          answerText!,
          style: const TextStyle(
            fontSize: 15.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
