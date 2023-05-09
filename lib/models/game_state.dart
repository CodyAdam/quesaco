import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/foundation.dart';

part 'game_state.g.dart';

@JsonSerializable()
class GameState extends ChangeNotifier {
  @JsonKey()
  int currentMiniGameIndex = 0;
  Map<String, int> scores = {};
  List<String> players = [];

  GameState(); // Empty constructor for json_serializable

  GameState.init(this.players) {
    _initializeScores();
  }

  void _initializeScores() {
    for (var player in players) {
      scores[player] = 0;
    }
  }

  void updateScore(String playerId, int newScore) {
    scores[playerId] = newScore;
    notifyListeners();
  }

  void nextMiniGame() {
    currentMiniGameIndex++;
    notifyListeners();
  }

  void resetGameState() {
    currentMiniGameIndex = 0;
    _initializeScores();
    notifyListeners();
  }

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory GameState.from(String jsonString) {
    return GameState.fromJson(jsonDecode(jsonString));
  }
}
