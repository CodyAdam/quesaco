import 'package:flutter/material.dart';
import 'package:quesaco/services/connection_manager.dart';

BottomAppBar gameScoreBar(Manager game) {
  final name1 = "Moi",
      name2 = "L'autre",
      score1 = game.getInt(game.me) ?? 0,
      score2 = game.getInt(game.other) ?? 0;
  return BottomAppBar(
    height: 70,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name1),
                const SizedBox(height: 4),
                Text(score1.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name2),
                const SizedBox(height: 4),
                Text(score2.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
