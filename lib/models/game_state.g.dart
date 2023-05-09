// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState()
  ..currentMiniGameIndex = json['currentMiniGameIndex'] as int
  ..scores = Map<String, int>.from(json['scores'] as Map)
  ..players =
      (json['players'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'currentMiniGameIndex': instance.currentMiniGameIndex,
      'scores': instance.scores,
      'players': instance.players,
    };
