import 'package:flutter/material.dart';
import 'package:wordle/utils/constants.dart';
import 'package:wordle/utils/constants.dart' as constants;

enum TileState {
  empty, 
  typed, 
  correct, 
  present,
  absent,
}


enum GameStatus {
  playing, 
  won, 
  lost,
  paused,
}

class WordleTile {
  String letter;
  TileState state;

  WordleTile({this.letter = '', this.state = TileState.empty});

  factory WordleTile.fromJson(Map<String, dynamic> json) {
    return WordleTile(
      letter: json['letter'] as String,
      state: TileState.values[json['state'] as int], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'state': state.index, // Store enum as int index
    };
  }

  Color get backgroundColor {
    switch (state) {
      case TileState.correct:
        return correctGreen;
      case TileState.present:
        return presentYellow;
      case TileState.absent:
        return absentGrey;
      case TileState.typed:
        return defaultTileColor; 
      case TileState.empty:
      return defaultTileColor;
    }
  }

  Color get textColor {
    if (state == TileState.empty || state == TileState.typed) {
      return keyboardTextColor; 
    }
    return constants
        .textColor; 
  }

  Color get borderColor {
    if (state == TileState.empty) {
      return defaultTileColor; 
    } else if (state == TileState.typed) {
      return absentGrey; 
    }
    return Colors.transparent; 
  }
}

class WordleRow {
  List<WordleTile> tiles; // List of WordleTile objects in this row.

  WordleRow({required this.tiles});
  factory WordleRow.fromJson(Map<String, dynamic> json) {
    return WordleRow(
      tiles: (json['tiles'] as List<dynamic>)
          .map((e) => WordleTile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tiles': tiles.map((e) => e.toJson()).toList()};
  }
}

class KeyboardKey {
  String letter; 
  TileState state;
  KeyboardKey({required this.letter, this.state = TileState.empty});

  factory KeyboardKey.fromJson(Map<String, dynamic> json) {
    return KeyboardKey(
      letter: json['letter'] as String,
      state: TileState.values[json['state'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {'letter': letter, 'state': state.index};
  }

  Color get backgroundColor {
    switch (state) {
      case TileState.correct:
        return correctGreen;
      case TileState.present:
        return presentYellow;
      case TileState.absent:
        return absentGrey;
      case TileState
          .typed: 
        return pressedKeyColor;
      case TileState.empty:
      return defaultKeyColor;
    }
  }

  Color get textColor {
    if (state == TileState.empty || state == TileState.typed) {
      return keyboardTextColor; 
    }
    return constants
        .textColor; 
  }
}
