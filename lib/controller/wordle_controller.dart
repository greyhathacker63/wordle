import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wordle/models/wordle_model.dart';
import 'package:wordle/services/dictionary_service.dart';
import 'package:wordle/utils/constants.dart';
import 'package:wordle/widgets/custom_snackbar.dart';

class WordleController extends GetxController {
  RxList<WordleRow> grid = List.generate(
    MAX_ATTEMPTS,
    (rowIndex) => WordleRow(
      tiles: List.generate(WORD_LENGTH, (colIndex) => WordleTile()),
    ),
  ).obs;
  RxInt currentAttempt = 0.obs;
  RxInt currentTileIndex = 0.obs;
  Rx<GameStatus> gameStatus = GameStatus.playing.obs;
  RxMap<String, KeyboardKey> keyboardState = RxMap<String, KeyboardKey>();
  RxString currentWord = ''.obs;
  Rx<GameMode> gameMode = GameMode.timeRestricted.obs;

  RxInt timeRemaining = 0.obs;
  RxInt score = 0.obs;
  Timer? _countdownTimer;
  DateTime? _gameStartTime;
  Duration _gameDuration = const Duration(minutes: 5);
  final DictionaryService _dictionaryService = DictionaryService();
  late SharedPreferences _prefs;

  final List<String> _wordList = [
    'APPLE',
    'BAKER',
    'CRANE',
    'DREAM',
    'EAGLE',
    'FLAME',
    'GRAPE',
    'HOUSE',
    'IGLOO',
    'JUMBO',
    'KNIFE',
    'LEMON',
    'MANGO',
    'NIGHT',
    'OCEAN',
    'PLANT',
    'QUEEN',
    'RIVER',
    'SPACE',
    'TABLE',
    'UNITY',
    'VILLA',
    'WHALE',
    'YACHT',
    'ZEBRA',
    'ABOVE',
    'BLANK',
    'CHAIR',
    'DAISY',
    'EARTH',
    'FROST',
    'GLORY',
    'HAPPY',
    'IDEAL',
    'JOLLY',
    'KITES',
    'LIGHT',
    'MUSIC',
    'NOBLE',
    'OPERA',
    'PEACE',
    'QUICK',
    'ROBIN',
    'SHINE',
    'TIGER',
    'ULTRA',
    'VIVID',
    'WATER',
    'YIELD',
    'ZONAL',
    'ALERT',
    'BRICK',
    'CANDY',
    'DANCE',
    'EXACT',
    'FANCY',
    'GIANT',
    'HEART',
    'INDEX',
    'JAZZY',
    'KUDOS',
    'LUCKY',
    'MERRY',
    'NEVER',
    'OASIS',
    'PRIME',
    'QUOTA',
    'RUSTY',
    'SMILE',
    'TRUST',
    'URBAN',
    'VAPOR',
    'WAGON',
    'YUMMY',
    'ZILLY',
    'ADAPT',
    'BLAST',
    'CLICK',
    'DRIVE',
    'ENJOY',
    'FIGHT',
    'GREAT',
    'HUMAN',
    'IMAGE',
    'JOINT',
    'KINDY',
    'LEAVE',
    'MAGIC',
    'NUDGE',
    'OTHER',
    'PITCH',
    'QUAKE',
    'ROUND',
    'SURET',
    'TOWEL',
    'UNDER',
    'VALID',
    'WIDER',
    'YELLO',
    'ZINGY',
  ];

  @override
  void onInit() {
    super.onInit();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGameState();
  }

  String _generateRandomWord() {
    final random = Random();
    return _wordList[random.nextInt(_wordList.length)].toUpperCase();
  }

  void initializeGame({
    GameMode mode = GameMode.timeRestricted,
    bool isResuming = false,
  }) {
    gameMode.value = mode;
    currentWord.value = _generateRandomWord(); // Set a new word for a new game
    _resetGrid();
    _resetKeyboard();
    currentAttempt.value = 0;
    currentTileIndex.value = 0;
    gameStatus.value = GameStatus.playing;
    score.value = 0; // Reset score for new games

    if (mode == GameMode.timeRestricted) {
      if (!isResuming) {
        _gameStartTime = DateTime.now();
        timeRemaining.value = _gameDuration.inSeconds;
      }
      _startCountdown();
    } else {
      _stopCountdown();
    }

    _saveGameState();

    CustomSnackbar.show(
      'New Game Started!',
      'Guess the ${WORD_LENGTH}-letter word.',
    );
  }

  // Resets the game grid to empty tiles.
  void _resetGrid() {
    grid.value = List.generate(
      MAX_ATTEMPTS,
      (rowIndex) => WordleRow(
        tiles: List.generate(WORD_LENGTH, (colIndex) => WordleTile()),
      ),
    );
  }

  // Resets the keyboard state to default for all keys.
  void _resetKeyboard() {
    keyboardState.value = {}; // Clear previous state
    for (int i = 0; i < 26; i++) {
      String letter = String.fromCharCode('A'.codeUnitAt(0) + i);
      keyboardState[letter] = KeyboardKey(
        letter: letter,
        state: TileState.empty,
      );
    }
    keyboardState['ENTER'] = KeyboardKey(
      letter: 'ENTER',
      state: TileState.empty,
    );
    keyboardState['BACK'] = KeyboardKey(letter: 'BACK', state: TileState.empty);
  }

  // Handles a key press from the on-screen keyboard.
  void onKeyPress(String key) async {
    if (gameStatus.value != GameStatus.playing) {
      return; // Ignore input if game is not playing
    }

    if (key == 'ENTER') {
      _handleEnter();
    } else if (key == 'BACK') {
      _handleBackspace();
    } else {
      _handleLetterInput(key);
    }
    _saveGameState();
  }

  // Handles letter input.
  void _handleLetterInput(String letter) {
    if (currentTileIndex.value < WORD_LENGTH) {
      grid[currentAttempt.value].tiles[currentTileIndex.value].letter = letter;
      grid[currentAttempt.value].tiles[currentTileIndex.value].state =
          TileState.typed;
      currentTileIndex.value++;
      grid.refresh();
    }
  }

  // Handles backspace input.
  void _handleBackspace() {
    if (currentTileIndex.value > 0) {
      currentTileIndex.value--;
      grid[currentAttempt.value].tiles[currentTileIndex.value].letter = '';
      grid[currentAttempt.value].tiles[currentTileIndex.value].state =
          TileState.empty;
      grid.refresh();
    }
  }

  Future<void> _handleEnter() async {
    if (currentTileIndex.value < WORD_LENGTH) {
      CustomSnackbar.show('Not enough letters', 'Please complete the word.');

      return;
    }

    String guessedWord = grid[currentAttempt.value].tiles
        .map((tile) => tile.letter)
        .join();

    bool isValid = await _dictionaryService.isValidWord(
      guessedWord.toLowerCase(),
    );
    if (!isValid) {
      CustomSnackbar.show('Invalid Word', 'This is not a valid English word.');

      return;
    }

    _checkGuess(guessedWord);
    _saveGameState(); // Save state after guess
  }

  void _checkGuess(String guessedWord) {
    String targetWord = currentWord.value;
    List<String> targetLetters = targetWord.split('');
    List<String> guessedLetters = guessedWord.split('');

    Map<String, int> targetLetterCounts = {};
    for (var char in targetLetters) {
      targetLetterCounts[char] = (targetLetterCounts[char] ?? 0) + 1;
    }

    for (int i = 0; i < WORD_LENGTH; i++) {
      if (guessedLetters[i] == targetLetters[i]) {
        grid[currentAttempt.value].tiles[i].state = TileState.correct;
        _updateKeyboardKey(guessedLetters[i], TileState.correct);
        targetLetterCounts[guessedLetters[i]] =
            (targetLetterCounts[guessedLetters[i]] ?? 0) - 1;
      }
    }

    for (int i = 0; i < WORD_LENGTH; i++) {
      if (grid[currentAttempt.value].tiles[i].state == TileState.typed) {
        if (targetLetters.contains(guessedLetters[i]) &&
            (targetLetterCounts[guessedLetters[i]] ?? 0) > 0) {
          grid[currentAttempt.value].tiles[i].state = TileState.present;
          _updateKeyboardKey(guessedLetters[i], TileState.present);
          targetLetterCounts[guessedLetters[i]] =
              (targetLetterCounts[guessedLetters[i]] ?? 0) - 1;
        } else {
          grid[currentAttempt.value].tiles[i].state = TileState.absent;
          _updateKeyboardKey(guessedLetters[i], TileState.absent);
        }
      }
    }

    grid.refresh(); // Refresh grid to show updated tile states

    if (guessedWord == targetWord) {
      gameStatus.value = GameStatus.won;
      _stopCountdown();
      if (gameMode.value == GameMode.timeRestricted) {
        score.value += 1; // Increment score for time-restricted mode
        _showGameEndDialog(true); // Show dialog on win in time-restricted mode
      } else {
        CustomSnackbar.show(
          'Congratulations!',
          'You guessed the word in ${currentAttempt.value + 1} attempts!',
        );
      }
    } else if (currentAttempt.value == MAX_ATTEMPTS - 1) {
      gameStatus.value = GameStatus.lost;
      _stopCountdown();
      if (gameMode.value == GameMode.timeRestricted) {
        _showGameEndDialog(false);
      } else {
        CustomSnackbar.show(
          'Game Over!',
          'The word was "${currentWord.value}". Try again!',
        );
      }
    } else {
      currentAttempt.value++;
      currentTileIndex.value = 0;
    }
  }

  void _updateKeyboardKey(String letter, TileState newState) {
    KeyboardKey? key = keyboardState[letter];
    if (key != null) {
      if (key.state == TileState.correct) {
        return;
      } else if (key.state == TileState.present &&
          newState == TileState.correct) {
        key.state = newState;
      } else if (key.state == TileState.empty || key.state == TileState.typed) {
        key.state = newState;
      } else if (key.state == TileState.absent &&
          (newState == TileState.correct || newState == TileState.present)) {
        key.state = newState;
      }
      keyboardState[letter] = key;
      keyboardState.refresh();
    }
  }

  Future<void> _saveGameState() async {
    final List<Map<String, dynamic>> gridJson = grid
        .map((row) => row.toJson())
        .toList();
    final Map<String, dynamic> keyboardJson = keyboardState.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await _prefs.setString(
      GAME_STATE_KEY,
      json.encode({
        'grid': gridJson,
        'currentAttempt': currentAttempt.value,
        'currentTileIndex': currentTileIndex.value,
        'gameStatus': gameStatus.value.index,
        'keyboardState': keyboardJson,
        'currentWord': currentWord.value,
        'gameMode': gameMode.value.index,
        'score': score.value,
        'gameStartTime': _gameStartTime?.toIso8601String(),
        'gameDurationSeconds': _gameDuration.inSeconds,
      }),
    );
    print('Game state saved.');
  }

  Future<void> _loadGameState() async {
    final String? savedState = _prefs.getString(GAME_STATE_KEY);
    final String? savedCurrentWord = _prefs.getString(CURRENT_WORD_KEY);
    if (savedState != null) {
      try {
        final Map<String, dynamic> data = json.decode(savedState);

        gameMode.value = GameMode
            .values[data['gameMode'] as int? ?? GameMode.timeRestricted.index];

        List<dynamic> gridJson = data['grid'] as List<dynamic>;
        grid.value = gridJson
            .map((e) => WordleRow.fromJson(e as Map<String, dynamic>))
            .toList();

        currentAttempt.value = data['currentAttempt'] as int;
        currentTileIndex.value = data['currentTileIndex'] as int;
        gameStatus.value = GameStatus.values[data['gameStatus'] as int];
        currentWord.value = data['currentWord'] as String;
        score.value = data['score'] as int? ?? 0;
        Map<String, dynamic> keyboardJson =
            data['keyboardState'] as Map<String, dynamic>;
        keyboardState.value = keyboardJson.map(
          (key, value) => MapEntry(
            key,
            KeyboardKey.fromJson(value as Map<String, dynamic>),
          ),
        );

        if (gameMode.value == GameMode.timeRestricted) {
          String? startTimeString = data['gameStartTime'] as String?;
          if (startTimeString != null) {
            _gameStartTime = DateTime.parse(startTimeString);
            _gameDuration = Duration(
              seconds:
                  data['gameDurationSeconds'] as int? ??
                  _gameDuration.inSeconds,
            );
            _calculateTimeRemaining();
          }
          if (gameStatus.value == GameStatus.playing) {
            _startCountdown();
          }
        } else {
          _stopCountdown();
        }

        CustomSnackbar.show('Game Loaded!', 'Resuming your previous game.');

        print('Game state loaded.');
      } catch (e) {
        print('Error loading game state: $e');
        // If loading fails, start a new game to prevent app crash
        initializeGame();
      }
    } else if (savedCurrentWord != null) {
      currentWord.value = savedCurrentWord;
      initializeGame(); // Start new game with loaded word
      print('Legacy game state loaded, initializing new game.');
    } else {
      initializeGame();
      print('No saved game found, starting new game.');
    }
  }

  void pauseGame() {
    if (gameStatus.value == GameStatus.playing) {
      gameStatus.value = GameStatus.paused;
      _stopCountdown();
      _saveGameState();

      CustomSnackbar.show('Game Paused', 'Your game has been paused.');
    }
  }

  void resumeGame() {
    if (gameStatus.value == GameStatus.paused) {
      gameStatus.value = GameStatus.playing;
      if (gameMode.value == GameMode.timeRestricted) {
        _startCountdown();
      }
      _saveGameState();
      CustomSnackbar.show('Game Resumed', 'Welcome back!');
    }
  }

  void _startCountdown() {
    _stopCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeRemaining();
      if (timeRemaining.value <= 0) {
        _stopCountdown();
        if (gameStatus.value == GameStatus.playing) {
          gameStatus.value = GameStatus.lost;
          _showGameEndDialog(false);
          _saveGameState();
        }
      }
    });
  }

  void _calculateTimeRemaining() {
    if (_gameStartTime != null) {
      final elapsed = DateTime.now().difference(_gameStartTime!);
      final remaining = _gameDuration - elapsed;
      timeRemaining.value = remaining.inSeconds > 0 ? remaining.inSeconds : 0;
    } else {
      timeRemaining.value = 0;
    }
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _showGameEndDialog(bool didWin) {
    String title = didWin ? 'Congratulations!' : 'Game Over!';
    String message = didWin
        ? 'You guessed the word "${currentWord.value}"!'
        : 'Time ran out! The word was "${currentWord.value}".';

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 10),
            Text(
              'Final Score: ${score.value}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
              shareScore(); // Offer to share score
            },
            child: const Text('Share Score'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
              initializeGame(
                mode: GameMode.timeRestricted,
              ); // Start a new time-restricted game
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
      barrierDismissible: false, // User must interact with buttons
    );
  }

  void shareScore() {
    String message = '';
    if (gameMode.value == GameMode.timeRestricted) {
      message = 'I played Wordle and scored ${score.value} words!\n';
      if (gameStatus.value == GameStatus.won) {
        message += 'I guessed the last word!';
      } else if (gameStatus.value == GameStatus.lost) {
        message += 'Time ran out!';
      }
    } else {
      if (gameStatus.value == GameStatus.won) {
        message =
            'I guessed the Wordle in ${currentAttempt.value + 1} attempts!\n';
      } else if (gameStatus.value == GameStatus.lost) {
        message =
            'I failed to guess the Wordle. The word was "${currentWord.value}"\n';
      } else {
        message = 'I\'m playing Wordle! Can you beat me?';
      }
    }
    message += '\n#WordleApp'; // Add a hashtag for sharing

    Share.share(message);
  }

  static Map<String, dynamic> keyboardKeyToJson(KeyboardKey key) {
    return {'letter': key.letter, 'state': key.state.index};
  }

  static KeyboardKey keyboardKeyFromJson(Map<String, dynamic> json) {
    return KeyboardKey(
      letter: json['letter'] as String,
      state: TileState.values[json['state'] as int],
    );
  }

  @override
  void onClose() {
    _stopCountdown(); // Stop timer when controller is disposed
    super.onClose();
  }
}
