import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/models/game_state.dart';
import 'package:quesaco/screens/menu.dart';
import 'package:quesaco/services/connection_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final MenuObserver menuObserver = MenuObserver(onMenuPagePush: () {
    log("Menu observer called");
    Manager().disconnect();
    // call _onResetEverything or any other function here
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Manager(),
      child: MaterialApp(
        title: 'Multiplayer Game',
        theme:
            ThemeData(primarySwatch: Colors.blue, fontFamily: "Josefa Rounded"),
        home: const Menu(),
        routes: {
          'menu': (context) => const Menu(),
        },
        navigatorObservers: [menuObserver],
      ),
    );
  }
}

class MenuObserver extends NavigatorObserver {
  final Function onMenuPagePush;
  Manager m = Manager();

  MenuObserver({required this.onMenuPagePush});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if(route is PopupRoute) {
    } else {
      if(m.getInt(MINIGAME_ID) != 0 && m.getInt(MINIGAME_ID) != -1) {
        m.audioPlayer.stop();
      }
      onMenuPagePush();
    }
    super.didPop(route, previousRoute);
  }
}
