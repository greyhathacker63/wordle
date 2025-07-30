import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DictionaryService {
  List<String> _validWords = [];

  DictionaryService() {
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final List<dynamic> data = json.decode(response);
      _validWords = data.map((word) => word.toString().toUpperCase()).toList();
      print('Loaded ${_validWords.length} words from local assets.');
    } catch (e) {
      print('Error loading words from assets: $e');
      _validWords = [];
    }
  }

  Future<bool> isValidWord(String word) async {
    if (_validWords.isEmpty) {
      await _loadWords();
    }
    return _validWords.contains(word.toUpperCase());
  }
}
