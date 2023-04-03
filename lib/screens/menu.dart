import 'package:flutter/material.dart';

import 'host.dart';
import 'join.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostPage()),
                  );
                },
                child: const Text('Create a room'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JoinPage()),
                  );
                },
                child: const Text('Join a room'),
              ),
            ],
          ),
        ));
  }
}