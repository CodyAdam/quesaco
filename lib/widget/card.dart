import 'package:flutter/material.dart';

Widget gameImageCard(Function() callback, String imagePath) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(
        color: Color.fromARGB(255, 33, 30, 30),
        width: 0,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    ),
    margin: const EdgeInsets.all(8),
    clipBehavior: Clip.antiAlias,
    elevation: 10,
    child: InkWell(
      onTap: () => callback(),
      child: SizedBox(
        height: 200, // Set the desired height of the card
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    ),
  );
}
