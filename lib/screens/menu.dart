import 'package:flutter/material.dart';

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
                    MaterialPageRoute(builder: (context) => const TestScene()),
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
                    MaterialPageRoute(builder: (context) => const TestScene()),
                  );
                },
                child: const Text('Join a room'),
              ),
            ],
          ),
        ));
  }
}

class TestScene extends StatelessWidget {
  const TestScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [Text('Create a room')],
          ),
        ));
  }
}
