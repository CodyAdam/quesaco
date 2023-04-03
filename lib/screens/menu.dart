import 'package:flutter/material.dart';

import 'host.dart';
import 'join.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Menu principal'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text("Quesaco",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  )),
              const Text("Édition Deluxe 2023",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 173, 173, 173),
                  )),
              const SizedBox(height: 70),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.lime)),
                    onPressed: () {
                      // Navigate
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HostPage()),
                      );
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Créer une room',
                          style: TextStyle(fontSize: 28),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green)),
                      onPressed: () {
                        // Navigate
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const JoinPage()),
                        );
                      },
                      child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Rejoindre une room',
                            style: TextStyle(fontSize: 28),
                          ))),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("© 2023 Quesaco - Arthur & Cody",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 173, 173, 173),
                    )),
              )
            ],
          ),
        ));
  }
}
