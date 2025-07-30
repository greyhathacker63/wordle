import 'package:flutter/material.dart';

const int WORD_LENGTH = 5;
const int MAX_ATTEMPTS = 6;

// Local Storage Keys
const String GAME_STATE_KEY = 'wordle_game_state';
const String CURRENT_WORD_KEY = 'wordle_current_word';
const String GAME_MODE_KEY = 'wordle_game_mode';
const String TIME_RESTRICTED_START_TIME_KEY =
    'wordle_time_restricted_start_time';
const String TIME_RESTRICTED_DURATION_KEY = 'wordle_time_restricted_duration';
const String TIME_RESTRICTED_SCORE_KEY = 'wordle_time_restricted_score';

// Game Colors
const Color correctGreen = Color(
  0xFF6aaa64,
); // Letter is in the word and in the correct spot.
const Color presentYellow = Color(
  0xFFc9b458,
); // Letter is in the word but in the wrong spot.
const Color absentGrey = Color(
  0xFF787c7e,
); // Letter is not in the word in any spot.
const Color defaultTileColor = Color(
  0xFFd3d6da,
); // Default color for empty tiles.
const Color defaultKeyColor = Color(
  0xFFd3d6da,
); // Default color for keyboard keys.
const Color pressedKeyColor = Color(0xFFa0a0a0);
const Color textColor = Colors.white;
const Color keyboardTextColor = Colors.black;

enum GameMode { timeRestricted }
