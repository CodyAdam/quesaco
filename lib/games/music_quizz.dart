import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quesaco/widget/answer.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/connection_manager.dart';

class Music extends StatefulWidget {
  const Music({super.key});

  @override
  State<Music> createState() => _HomeState();
}

class _HomeState extends State<Music> {
  late Timer timer;
  Stopwatch stopwatch = Stopwatch();
  int timeLimit = 15;
  String timeRemaining = "";

  Manager m = Manager();

  var list = random();
  bool endOfQuiz = false;
  bool answerWasSelected = false;
  int totalScore = 0;
  int questionIndex = 0;
  bool taped = false;
  List<String> answers = List<String>.filled(map.length, "");

  void questionAnswered(bool answerScore, String answerMusic) {
    setState(() {
      answers[questionIndex] = answerMusic;
      answerWasSelected = true;
      if (answerScore) {
        totalScore++;
      }
      if (questionIndex + 1 == list.length) {
        endOfQuiz = true;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      questionIndex++;
      answerWasSelected = false;
    });
    if (questionIndex >= list.length) {
      goToMenu();
    }
    m.audioPlayer.stop();
  }

  void goToMenu() {
    setState(() {
      questionIndex = 0;
      totalScore = 0;
      endOfQuiz = false;
      timeLimit = 15;
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), onTimerTick);
    stopwatch.start();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void onTimerTick(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {
        if(timeLimit-stopwatch.elapsed.inSeconds.remainder(60) < 0) {
          timeRemaining = "0";
        } else {
          timeRemaining = formatDuration(stopwatch.elapsed);
        }
      });
    }
  }

  void pause(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    stopwatch.reset();
    nextQuestion();
  }

  String formatDuration(Duration duration) {
    int remaining = timeLimit-duration.inSeconds.remainder(60);
    if(remaining<=0) {
      if(answers[questionIndex] == "") {
        questionAnswered(false, "");
      }
      pause(3);
    }
    return remaining.toString();
  }

  void loadAndPlayMusic(String music) async {
    print(music);
    if(m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  @override
  Widget build(BuildContext context) {
    var goodList = getGoodOnes(list);
    print(goodList);

    loadAndPlayMusic('musics/${goodList[questionIndex]}.mp3');

    return Scaffold(
      body: Center(
        child: Column(children: [
          Text(
            timeRemaining,
            textAlign: TextAlign.center,
          ),
          Container(
            width: 500.0,
            height: 250.0,
            margin: const EdgeInsets.only(
                bottom: 10.0, top: 20.0, left: 30.0, right: 30.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                  image: AssetImage('assets/flags/orateur.png'),
                  fit: BoxFit.scaleDown,
                )),
          ),
          const SizedBox(
            height: 40,
          ),
          ...list[questionIndex].map(
            (answer) => Answer(
              answerText: map[answer.game],
              answerTap: () {
                if (answerWasSelected) {
                  return;
                }
                questionAnswered(answer.goodOne, answer.game);
              },
              answerColor: answerWasSelected
                  ? answer.goodOne
                      ? Colors.green
                      : answer.game.compareTo(answers[questionIndex])==0
                          ? Colors.red
                          : null
                  : null,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            totalScore.toString(),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

class Pair<A, B> {
  A _country;
  B _goodOne;

  Pair(this._country, this._goodOne);

  A get game => _country;

  set game(A value) => _country = value;

  B get goodOne => _goodOne;

  set goodOne(B value) => _goodOne = value;

  @override
  String toString() => '($_country, $_goodOne)';
}

List<List<Pair<String, bool>>> random() {
  var listOfList = <List<Pair<String, bool>>>[];
  var keys = map.keys.toList();
  var random = Random();
  int numberOfQuestions = 10;
  while (keys.length > map.length - numberOfQuestions * 4) {
    var countriesTrueOrNot = <Pair<String, bool>>[];
    var randomOrder = Random();
    var order = randomOrder.nextInt(4);
    for (int i = 0; i < 4; i++) {
      var index = random.nextInt(keys.length);
      var key = keys[index];
      keys[index] = keys.last;
      keys.length--;
      countriesTrueOrNot.add(Pair(key, i == order ? true : false));
    }
    listOfList.add(countriesTrueOrNot);
  }
  return listOfList;
}

List<String> getGoodOnes(List<List<Pair<String, bool>>> list) {
  var goodList = <String>[];
  for (List l in list) {
    for (Pair p in l) {
      if (p.goodOne) {
        goodList.add(p.game);
      }
    }
  }
  return goodList;
}


var map = {
  'Age_of_Empire_2': 'Age of Empire 2',
  'Animal_Crossing_New_Horizons' : 'Animal Crossing : New Horizons',
  'Assassins_Creed_2' : 'Assassin\'s Creed 2',
  'Banjo_Kazooie' : 'Banjo-Kazooie',
  'Castlevania' : 'Castlevania',
  'Civilization_4' : 'Civilization 4',
  'Crash_Bandicoot' : 'Crash Bandicoot',
  'Dark_Souls' : 'Dark Souls',
  'Donkey_Kong_Country' : 'Donkey Kong Country',
  'Doom' : 'Doom',
  'F_Zero' : 'F-Zero',
  'Final_Fantasy_VII' : 'Final Fantasy VII',
  'Final_Fantasy_X' : 'Final Fantasy X',
  'GTA_San_Andreas' : 'GTA San Andreas',
  'Halo_2' : 'Halo 2',
  'Kingdom_Hearts' : 'Kingdom Hearts',
  'Kirby_Superstar' : 'Kirby Superstar',
  'Luigis_Mansion' : 'Luigi\'s Mansion',
  'Mario_Kart_8' : 'Mario Kart 8',
  'Mega_Man_2' : 'Mega Man 2',
  'Metal_Gear_Solid' : 'Metal Gear Solid',
  'Metroid_Prime' : 'Metroid Prime',
  'Minecraft' : 'Minecraft',
  'Mortal_Kombat' : 'Mortal Kombat',
  'Persona_5' : 'Persona 5',
  'Phoenix_Wright_Ace_Attorney' : 'Phoenix Wright : Ace Attorney',
  'Pokemon_Diamant_Perle' : 'Pokémon Diamant/Perle',
  'Pokemon_Rouge_Bleu' : 'Pokémon Rouge/Bleu',
  'Portal' : 'Portal',
  'Professeur_Layton_and_the_Curious_Village' : 'Professeur Layton and the Curious Village',
  'Punch-Out!!' : 'Punch-Out!!',
  'Ratchet_e_Clank' : 'Ratchet & Clank',
  'Shadow_of_the_Colossus' : 'Shadow of the Colossus',
  'Sonic_The_Hedgehog' : 'Sonic The Hedgehog',
  'Spyro_the_Dragon' : 'Spyro the Dragon',
  'Star_Fox' : 'Star Fox',
  'Street_Fighter_2' : 'Street Fighter 2',
  'Super_Mario_Bros' : 'Super Mario Bros',
  'Super_Mario_Odyssey' : 'Super Mario Odyssey',
  'Super_Mario_64' : 'Super Mario 64',
  'Team_Fortress_2' : 'Team Fortress 2',
  'Tetris' : 'Tetris',
  'The_Elder_Scrolls_V_Skyrim' : 'The Elder Scrolls V : Skyrim',
  'The_Last_of_Us' : 'The Last of Us',
  'The_Legend_of_Zelda' : 'The Legend Of Zelda',
  'The_Legend_of_Zelda_Ocarina_of_Time' : 'The Legend of Zelda : Ocarina of Time',
  'The_Witcher_3' : 'The Witcher 3',
  'Uncharted_2' : 'Uncharted 2',
  'Undertale' : 'Undertale',
  'Wii_Sports' : 'Wii Sports'
};
