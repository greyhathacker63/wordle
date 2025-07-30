import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordle/controller/wordle_controller.dart';
import 'package:wordle/models/wordle_model.dart';
import 'package:wordle/utils/constants.dart';

class GridWidget extends StatelessWidget {
  final WordleController controller = Get.put(WordleController());

  GridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(MAX_ATTEMPTS, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(WORD_LENGTH, (colIndex) {
              final WordleTile tile = controller.grid[rowIndex].tiles[colIndex];

              final bool hasBorder =
                  (rowIndex == controller.currentAttempt.value &&
                      tile.state == TileState.typed) ||
                  tile.state == TileState.empty;

              return Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tile.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: hasBorder
                      ? Border.all(color: tile.borderColor, width: 2)
                      : null,
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
                  tile.letter.toUpperCase(),
                  style: TextStyle(
                    color: tile.textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
