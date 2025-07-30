import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordle/controller/wordle_controller.dart';
import 'package:wordle/models/wordle_model.dart';

class KeyboardWidget extends StatelessWidget {
  final WordleController controller = Get.put(WordleController());

  KeyboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _buildKeyboardRow('QWERTYUIOP'.split('')),
          _buildKeyboardRow('ASDFGHJKL'.split('')),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> letters) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((letter) => _buildKey(letter)).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKey('ENTER', flex: 2),
          ...('ZXCVBNM'.split('').map((letter) => _buildKey(letter))),
          _buildKey('BACK', flex: 2),
        ],
      ),
    );
  }

  // Helper method to build an individual keyboard key.
  Widget _buildKey(String keyText, {int flex = 1}) {
    // Get the current state of the key from the controller's keyboardState.
    final KeyboardKey key =
        controller.keyboardState[keyText] ??
        KeyboardKey(letter: keyText, state: TileState.empty);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: InkWell(
          onTap: () {
            controller.onKeyPress(keyText);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: key.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              keyText == 'BACK' ? '⌫' : keyText,
              style: TextStyle(
                color: key.textColor,
                fontSize: keyText.length > 1 ? 14 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
