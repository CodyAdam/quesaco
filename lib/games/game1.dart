// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quesaco/widget/answer.dart';

import '../models/game_state.dart';
import '../services/connection_manager.dart';

class Flag extends StatefulWidget {
  const Flag({super.key});

  @override
  State<Flag> createState() => _HomeState();
}

class _HomeState extends State<Flag> {
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  int timeLimit = 45;
  String timeRemaining = "";

  Manager m = Manager();
  Random r = Random(Manager().getInt(SEED) ?? 0);

  late List<List<Pair<String, bool>>> list;
  bool endOfQuiz = false;
  bool answerWasSelected = false;
  int questionIndex = 0;
  bool taped = false;
  List<String> answers = [];
  bool gameStarted = false;

  void questionAnswered(bool answerScore, String answerCountry) {
    setState(() {
      answers.add(answerCountry);
      answerWasSelected = true;
      if (answerScore) {
        m.setInt(m.me, m.getInt(m.me)! + 40);
      } else {
        showPopupFor3Seconds();
      }
      if (questionIndex + 1 == list.length) {
        endOfQuiz = true;
      }
    });
  }

  void showPopup() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Text(
              "Mauvaise réponse !\nPénalité de 3 secondes !",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 244, 125, 116),
          );
        });
  }

  void showPopupFor3Seconds() {
    showPopup();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }

  void nextQuestion() {
    setState(() {
      questionIndex++;
      answerWasSelected = false;
    });
    if (questionIndex >= list.length) {
      endTheGame();
    }
  }

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  void endTheGame() {
    setState(() {
      m.audioPlayer.stop();
      questionIndex = 0;
      endOfQuiz = false;
      m.clearGamesData();
      m.setInt("MinigameId", -1);
    });
  }

  @override
  void initState() {
    super.initState();
    m.audioPlayer.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      list = random(r);
      gameStarted = true;
      timer = Timer.periodic(const Duration(seconds: 1), onTimerTick);
      stopwatch.start();
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void onTimerTick(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {
        timeRemaining = formatDuration(stopwatch.elapsed);
      });
    }
  }

  String formatDuration(Duration duration) {
    int remaining = timeLimit - duration.inSeconds.remainder(60) - 1;
    if (remaining <= 0) {
      endTheGame();
      //stopwatch.reset();
    }
    return remaining.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!gameStarted) {
      return const Scaffold(body: Center(child: Text("En attente ...")));
    } else {
      var goodList = getGoodOnes(list);
      loadAndPlayMusic("musics/game.mp3");

      return Scaffold(
        body: Center(
          child: Column(children: [
            Container(
              height: 200.0,
              width: 300.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0.0, 2.0),
                        blurRadius: 6.0)
                  ],
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/flags/${goodList[questionIndex]}.png'),
                    fit: BoxFit.scaleDown,
                  )),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  timeRemaining,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 30.0, fontWeight: FontWeight.bold),
                )),
            const SizedBox(
              height: 20,
            ),
            ...list[questionIndex].map(
              (answer) => Answer(
                answerText: map[answer.country],
                answerTap: () {
                  if (answerWasSelected) {
                    return;
                  }
                  questionAnswered(answer.goodOne, answer.country);
                },
                answerColor: answerWasSelected
                    ? answer.goodOne
                        ? const Color.fromARGB(255, 178, 237, 180)
                        : answer.country.compareTo(answers[questionIndex]) == 0
                            ? const Color.fromARGB(255, 236, 171, 167)
                            : const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100.0, 40.0)),
                onPressed: () {
                  if (!answerWasSelected) {
                    return;
                  }
                  nextQuestion();
                },
                child:
                    Text(endOfQuiz ? 'Retour au menu' : 'Question suivante')),
          ]),
        ),
      );
    }
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

List<List<Pair<String, bool>>> random(Random r) {
  var listOfList = <List<Pair<String, bool>>>[];
  var keys = map.keys.toList();
  int numberOfQuestions = 50;
  while (keys.length > map.length - numberOfQuestions * 4) {
    var countriesTrueOrNot = <Pair<String, bool>>[];
    var order = r.nextInt(4);
    for (int i = 0; i < 4; i++) {
      var index = r.nextInt(keys.length);
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
  'ad': 'Andorre',
  'af': 'Afghanistan',
  'za': 'Afrique du Sud',
  'ax': 'Åland',
  'al': 'Albanie',
  'dz': 'Algérie',
  'de': 'Allemagne',
  'gb-eng': 'Angleterre',
  'ao': 'Angola',
  'ai': 'Anguilla',
  'aq': 'Antarctique',
  'ag': 'Antigua-et-Barbuda',
  'sa': 'Arabie saoudite',
  'ar': 'Argentine',
  'am': 'Arménie',
  'aw': 'Aruba',
  'au': 'Australie',
  'at': 'Autriche',
  'az': 'Azerbaïdjan',
  'bs': 'Bahamas',
  'bh': 'Bahreïn',
  'bd': 'Bangladesh',
  'bb': 'Barbade',
  'be': 'Belgique',
  'bz': 'Belize',
  'bj': 'Bénin',
  'bm': 'Bermudes',
  'bt': 'Bhoutan',
  'by': 'Biélorussie',
  'mm': 'Birmanie',
  'bo': 'Bolivie',
  'ba': 'Bosnie-Herzégovine',
  'bw': 'Botswana',
  'br': 'Brésil',
  'bn': 'Brunei',
  'bg': 'Bulgarie',
  'bf': 'Burkina Faso',
  'bi': 'Burundi',
  'kh': 'Cambodge',
  'cm': 'Cameroun',
  'ca': 'Canada',
  'cl': 'Chili',
  'cn': 'Chine',
  'cy': 'Chypre',
  'va': 'Vatican',
  'co': 'Colombie',
  'km': 'Comores',
  'cg': 'Congo',
  'cd': 'Congo (Rép. dém.)',
  'kp': 'Corée du Nord',
  'kr': 'Corée du Sud',
  'cr': 'Costa Rica',
  'ci': 'Côte d\'Ivoire',
  'hr': 'Croatie',
  'cu': 'Cuba',
  'cw': 'Curaçao',
  'dk': 'Danemark',
  'dj': 'Djibouti',
  'dm': 'Dominique',
  'gb-sct': 'Écosse',
  'eg': 'Égypte',
  'ae': 'Émirats arabes unis',
  'ec': 'Équateur',
  'er': 'Érythrée',
  'es': 'Espagne',
  'ee': 'Estonie',
  'us': 'États-Unis',
  'et': 'Éthiopie',
  'fj': 'Fidji',
  'fi': 'Finlande',
  'fr': 'France',
  'ga': 'Gabon',
  'gm': 'Gambie',
  'ge': 'Géorgie',
  'gs': 'Géorgie du Sud-et-les Îles Sandwich du Sud',
  'gh': 'Ghana',
  'gi': 'Gibraltar',
  'gr': 'Grèce',
  'gd': 'Grenade',
  'gl': 'Groenland',
  'gp': 'Guadeloupe',
  'gu': 'Guam',
  'gt': 'Guatemala',
  'gg': 'Guernesey',
  'gn': 'Guinée',
  'gq': 'Guinée équatoriale',
  'gw': 'Guinée-Bissau',
  'gy': 'Guyana',
  'gf': 'Guyane',
  'ht': 'Haïti',
  'hn': 'Honduras',
  'hk': 'Hong Kong',
  'hu': 'Hongrie',
  'bv': 'Île Bouvet',
  'cx': 'Île Christmas',
  'im': 'Île de Man',
  'mu': 'Maurice',
  'nf': 'Île Norfolk',
  'ky': 'Îles Caïmans',
  'cc': 'Îles Cocos',
  'ck': 'Îles Cook',
  'cv': 'Cap-Vert',
  'fo': 'Îles Féroé',
  'hm': 'Îles Heard-et-MacDonald',
  'fk': 'Îles Malouines',
  'mp': 'Îles Mariannes du Nord',
  'mh': 'Îles Marshall',
  'um': 'Îles mineures éloignées des États-Unis',
  'pn': 'Îles Pitcairn',
  'sb': 'Îles Salomon',
  'tc': 'Îles Turques-et-Caïques',
  'vg': 'Îles Vierges britanniques',
  'vi': 'Îles Vierges des États-Unis',
  'in': 'Inde',
  'id': 'Indonésie',
  'iq': 'Irak',
  'ir': 'Iran',
  'ie': 'Irlande',
  'gb-nir': 'Irlande du Nord',
  'is': 'Islande',
  'il': 'Israël',
  'it': 'Italie',
  'jm': 'Jamaïque',
  'jp': 'Japon',
  'je': 'Jersey',
  'jo': 'Jordanie',
  'kz': 'Kazakhstan',
  'ke': 'Kenya',
  'kg': 'Kirghizistan',
  'ki': 'Kiribati',
  'xk': 'Kosovo',
  'kw': 'Koweït',
  'la': 'Laos',
  'ls': 'Lesotho',
  'lv': 'Lettonie',
  'lb': 'Liban',
  'lr': 'Liberia',
  'ly': 'Libye',
  'li': 'Liechtenstein',
  'lt': 'Lituanie',
  'lu': 'Luxembourg',
  'mo': 'Macao',
  'mk': 'Macédoine du Nord',
  'mg': 'Madagascar',
  'my': 'Malaisie',
  'mw': 'Malawi',
  'mv': 'Maldives',
  'ml': 'Mali',
  'mt': 'Malte',
  'ma': 'Maroc',
  'mq': 'Martinique',
  'mr': 'Mauritanie',
  'yt': 'Mayotte',
  'mx': 'Mexique',
  'fm': 'Micronésie',
  'md': 'Moldavie',
  'mc': 'Monaco',
  'mn': 'Mongolie',
  'me': 'Monténégro',
  'ms': 'Montserrat',
  'mz': 'Mozambique',
  'na': 'Namibie',
  'nr': 'Nauru',
  'np': 'Népal',
  'ni': 'Nicaragua',
  'ne': 'Niger',
  'ng': 'Nigeria',
  'nu': 'Niue',
  'no': 'Norvège',
  'nc': 'Nouvelle-Calédonie',
  'nz': 'Nouvelle-Zélande',
  'om': 'Oman',
  'ug': 'Ouganda',
  'uz': 'Ouzbékistan',
  'pk': 'Pakistan',
  'pw': 'Palaos',
  'ps': 'Palestine',
  'pa': 'Panama',
  'pg': 'Papouasie-Nouvelle-Guinée',
  'py': 'Paraguay',
  'gb-wls': 'Pays de Galles',
  'nl': 'Pays-Bas',
  'bq': 'Pays-Bas caribéens',
  'pe': 'Pérou',
  'ph': 'Philippines',
  'pl': 'Pologne',
  'pf': 'Polynésie française',
  'pr': 'Porto Rico',
  'pt': 'Portugal',
  'qa': 'Qatar',
  'cf': 'République centrafricaine',
  'do': 'République dominicaine',
  're': 'Réunion',
  'ro': 'Roumanie',
  'gb': 'Royaume-Uni',
  'ru': 'Russie',
  'rw': 'Rwanda',
  'eh': 'Sahara Occidental',
  'bl': 'Saint-Barthélemy',
  'kn': 'Saint-Christophe-et-Niévès',
  'sm': 'Saint-Marin',
  'mf': 'Saint-Martin (Antilles françaises)',
  'sx': 'Saint-Martin (royaume des Pays-Bas)',
  'pm': 'Saint-Pierre-et-Miquelon',
  'vc': 'Saint-Vincent-et-les-Grenadines',
  'sh': 'Sainte-Hélène, Ascension et Tristan da Cunha',
  'lc': 'Sainte-Lucie',
  'sv': 'Salvador',
  'ws': 'Samoa',
  'as': 'Samoa américaines',
  'st': 'Sao Tomé-et-Principe',
  'sn': 'Sénégal',
  'rs': 'Serbie',
  'sc': 'Seychelles',
  'sl': 'Sierra Leone',
  'sg': 'Singapour',
  'sk': 'Slovaquie',
  'si': 'Slovénie',
  'so': 'Somalie',
  'sd': 'Soudan',
  'ss': 'Soudan du Sud',
  'lk': 'Sri Lanka',
  'se': 'Suède',
  'ch': 'Suisse',
  'sr': 'Suriname',
  'sj': 'Svalbard et Jan Mayen',
  'sz': 'Eswatini',
  'sy': 'Syrie',
  'tj': 'Tadjikistan',
  'tw': 'Taïwan',
  'tz': 'Tanzanie',
  'td': 'Tchad',
  'cz': 'Tchéquie',
  'tf': 'Terres australes et antarctiques françaises',
  'io': 'Territoire britannique de l\'océan Indien',
  'th': 'Thaïlande',
  'tl': 'Timor oriental',
  'tg': 'Togo',
  'tk': 'Tokelau',
  'to': 'Tonga',
  'tt': 'Trinité-et-Tobago',
  'tn': 'Tunisie',
  'tm': 'Turkménistan',
  'tr': 'Turquie',
  'tv': 'Tuvalu',
  'ua': 'Ukraine',
  'uy': 'Uruguay',
  'vu': 'Vanuatu',
  've': 'Venezuela',
  'vn': 'Viêt Nam',
  'wf': 'Wallis-et-Futuna',
  'ye': 'Yémen',
  'zm': 'Zambie',
  'zw': 'Zimbabwe',
};
