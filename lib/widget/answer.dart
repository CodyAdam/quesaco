import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String? answerText;
  final Color? answerColor;
  final VoidCallback answerTap;

  const Answer(
      {super.key,
      required this.answerText,
      required this.answerColor,
      required this.answerTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: answerTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        width: 400,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1.0,
              blurRadius: 5.0,
              offset: const Offset(0, 3),
            ),
          ],
          color: answerColor,
          border: Border.all(color: Color.fromARGB(41, 76, 76, 76)),
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
