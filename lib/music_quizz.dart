import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quesaco/answer.dart';

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

  var list = random();
  bool endOfQuiz = false;
  bool answerWasSelected = false;
  int totalScore = 0;
  int questionIndex = 0;
  bool taped = false;
  List<String> answers = [];

  void questionAnswered(bool answerScore, String answerMusic) {
    setState(() {
      answers.add(answerMusic);
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
        timeRemaining = formatDuration(stopwatch.elapsed);
      });
    }
  }

  void pause(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    nextQuestion();
    stopwatch.stop();
    stopwatch.reset();
  }

  String formatDuration(Duration duration) {
    int remaining = timeLimit-duration.inSeconds.remainder(60);
    if(remaining<=0) {
      stopwatch.stop();
      pause(3);
    }
    return remaining.toString();
  }


  @override
  Widget build(BuildContext context) {
    var goodList = getGoodOnes(list);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flag quiz',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
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
                  image: AssetImage('assets/orateur.png'),
                  fit: BoxFit.scaleDown,
                )),
          ),
          const SizedBox(
            height: 40,
          ),
          ...list[questionIndex].map(
            (answer) => Answer(
              answerText: map[answer.country],
              answerTap: () {
                if (answerWasSelected) {
                  print(answer.country.compareTo(answers[questionIndex])==0);
                  print(answers);
                  print(answer.country);
                  return;
                }
                questionAnswered(answer.goodOne, answer.country);
                print(answer.country.compareTo(answers[questionIndex])==0);
              },
              answerColor: answerWasSelected
                  ? answer.goodOne
                      ? Colors.green
                      : answer.country.compareTo(answers[questionIndex])==0
                          ? Colors.red
                          : null
                  : null,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          // ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //         minimumSize: const Size(100.0, 40.0)),
          //     onPressed: () {
          //       if (!answerWasSelected) {
          //         return;
          //       }
          //       nextQuestion();
          //     },
          //     child: Text(endOfQuiz ? 'Retour au menu' : 'Question suivante')),
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

  A get country => _country;

  set country(A value) => _country = value;

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
        goodList.add(p.country);
      }
    }
  }
  return goodList;
}


var map = {
  'Age of Empire 2': 'Age of Empire 2',
  'Animal Crossing New Horizons' : 'Animal Crossing : New Horizons',
  'Assassin\'s Creed 2' : 'Assassin\'s Creed 2',
  'Banjo-Kazooie' : 'Banjo-Kazooie',
  'Castlevania' : 'Castlevania',
  'Civilization 4' : 'Civilization 4',
  'Crash Bandicoot' : 'Crash Bandicoot',
  'Dark Souls' : 'Dark Souls',
  'Donkey Kong Country' : 'Donkey Kong Country',
  'Doom' : 'Doom',
  'F-Zero' : 'F-Zero',
  'Final Fantasy VII' : 'Final Fantasy VII',
  'Final Fantasy X' : 'Final Fantasy X',
  'GTA San Andreas' : 'GTA San Andreas',
  'Halo 2' : 'Halo 2',
  'Kingdom Hearts' : 'Kingdom Hearts',
  'Kirby Superstar' : 'Kirby Superstar',
  'Luigi\'s Mansion' : 'Luigi\'s Mansion',
  'Mario Kart 8' : 'Mario Kart 8',
  'Mega Man 2' : 'Mega Man 2',
  'Metal Gear Solid' : 'Metal Gear Solid',
  'Metroid Prime' : 'Metroid Prime',
  'Minecraft' : 'Minecraft',
  'Mortal Kombat' : 'Mortal Kombat',
  'Persona 5' : 'Persona 5',
  'Phoenix Wright Ace Attorney' : 'Phoenix Wright : Ace Attorney',
  'Pokémon Diamant-Perle' : 'Pokémon Diamant/Perle',
  'Pokémon Rouge-Bleu' : 'Pokémon Rouge/Bleu',
  'Portal' : 'Portal',
  'Professeur Layton and the Curious Village' : 'Professeur Layton and the Curious Village',
  'Punch-Out!!' : 'Punch-Out!!',
  'Ratchet & Clank' : 'Ratchet & Clank',
  'Shadow of the Colossus' : 'Shadow of the Colossus',
  'Sonic The Hedgehog' : 'Sonic The Hedgehog',
  'Spyro the Dragon' : 'Spyro the Dragon',
  'Star Fox' : 'Star Fox',
  'Street Fighter 2' : 'Street Fighter 2',
  'Super Mario Bros' : 'Super Mario Bros',
  'Super Mario Odyssey' : 'Super Mario Odyssey',
  'Super Mario 64' : 'Super Mario 64',
  'Team Fortress 2' : 'Team Fortress 2',
  'Tetris' : 'Tetris',
  'The Elder Scrolls V Skyrim' : 'The Elder Scrolls V : Skyrim',
  'The Last of Us' : 'The Last of Us',
  'The Legend Of Zelda' : 'The Legend Of Zelda',
  'The Legend of Zelda Ocarina of Time' : 'The Legend of Zelda : Ocarina of Time',
  'The Witcher 3' : 'The Witcher 3',
  'Uncharted 2' : 'Uncharted 2',
  'Undertale' : 'Undertale',
  'Wii Sports' : 'Wii Sports'
};
