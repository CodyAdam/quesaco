// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

const String HOST_USERNAME = "Host";
const String PLAYER_USERNAME = "Player";
const String MINIGAME_ID = "MinigameId";
const String UPCOMING_MINIGAMES_ID = "UpcomingMinigamesId";

class GameState extends ChangeNotifier {
  Map<String, String> data = {};

  GameState(); // Empty constructor for json_serializable

  void init() {
    clear();
    setInt(HOST_USERNAME, 0);
    setInt(PLAYER_USERNAME, 0);
    setInt(MINIGAME_ID, 0);
    notifyListeners();
  }

  void clearGamesData() {
    var minigameId = getInt(MINIGAME_ID);
    var host = getInt(HOST_USERNAME);
    var player = getInt(PLAYER_USERNAME);
    var upcomingMinigamesId = getString(UPCOMING_MINIGAMES_ID);
    data.clear();
    setInt(MINIGAME_ID, minigameId ?? 0);
    setInt(HOST_USERNAME, host ?? 0);
    setInt(PLAYER_USERNAME, player ?? 0);
    set(UPCOMING_MINIGAMES_ID, upcomingMinigamesId ?? "");
    notifyListeners();
  }

  void clear() {
    data.clear();
    notifyListeners();
  }

  void set(String key, String value) {
    data[key] = value;
    notifyListeners();
  }

  void setInt(String key, int value) {
    data[key] = value.toString();
    notifyListeners();
  }

  void setBool(String key, bool value) {
    data[key] = value.toString();
    notifyListeners();
  }

  void setDouble(String key, double value) {
    data[key] = value.toString();
    notifyListeners();
  }

  void setNull(String key) {
    // remove key from map
    data.remove(key);
    notifyListeners();
  }

  int? getInt(String key) {
    // parse int, or return null
    var value = data[key];
    if (value == null) return null;
    return int.tryParse(value);
  }

  double? getDouble(String key) {
    // parse double, or return null
    var value = data[key];
    if (value == null) return null;
    return double.tryParse(value);
  }

  bool? getBool(String key) {
    // parse bool, or return null
    var value = data[key];
    if (value == null) return null;
    return value == "true";
  }

  String? getString(String key) {
    // parse string, or return null
    return data[key];
  }
}
