import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:quesaco/screens/game.dart';
import '../services/connection_manager.dart';
import '../widget/menu_background.dart';
import 'host.dart';
import 'join.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MenuState();
  }
}

class _MenuState extends State<Menu> {
  Manager m = Manager();

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }


  @override
  Widget build(BuildContext context) {
    loadAndPlayMusic("musics/main_menu.mp3");
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.7, // Set the opacity value
            child: GameWidget(game: MenuBackground()),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset("assets/icon/banner.png"),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(2),
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(136, 104, 175, 234),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the value to control the roundness
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // Navigate
                            Manager().isSolo = true;
                            Manager().startGame();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GamePage()),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Jouer en Solo',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(2),
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(136, 119, 238, 159),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the value to control the roundness
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // Navigate
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HostPage()),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Créer une partie',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(2),
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(136, 119, 238, 159),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the value to control the roundness
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // Navigate
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const JoinPage()),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Rejoindre une partie',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0, // Set to 0 to remove the default card shadow
                    color: Colors.white, // Background color of the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "© 2023 Quesaco - Arthur & Cody",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
