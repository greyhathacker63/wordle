import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordle/controller/wordle_controller.dart';
import 'package:wordle/models/wordle_model.dart';
import 'package:wordle/utils/constants.dart';
import 'package:wordle/views/grid_widget.dart';
import 'package:wordle/views/keyboard_widget.dart';
import 'package:wordle/widgets/custom_snackbar.dart';

class WordleView extends StatelessWidget {
  final WordleController controller = Get.put(WordleController());

  WordleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wordle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        actions: [
          // Share Score Button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              if (controller.gameStatus.value == GameStatus.won ||
                  controller.gameStatus.value == GameStatus.lost) {
                controller.shareScore();
              } else {
                CustomSnackbar.show(
                  'Cannot Share',
                  'You can only share your score after the game is complete.',
                  backgroundColor: Colors.orange,
                );
              }
            },
            tooltip: 'Share Score',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Game Status and Timer Display
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() {
                  String statusText = '';
                  Color statusColor = Colors.white;

                  if (controller.gameStatus.value == GameStatus.won) {
                    statusText = 'You Won!';
                    statusColor = correctGreen;
                  } else if (controller.gameStatus.value == GameStatus.lost) {
                    statusText =
                        'Game Over! Word: ${controller.currentWord.value}';
                    statusColor = absentGrey;
                  } else if (controller.gameStatus.value == GameStatus.paused) {
                    statusText = 'Game Paused';
                    statusColor = Colors.orange;
                  } else {
                    statusText = 'Guess the Word!';
                  }

                  return Column(
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      if (controller.gameMode.value == GameMode.timeRestricted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Obx(() {
                            final int minutes =
                                controller.timeRemaining.value ~/ 60;
                            final int seconds =
                                controller.timeRemaining.value % 60;
                            return Text(
                              'Time Left: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    controller.timeRemaining.value <= 10 &&
                                        controller.gameStatus.value ==
                                            GameStatus.playing
                                    ? Colors.redAccent
                                    : Colors.amberAccent,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                    ],
                  );
                }),
              ),

              // Wordle Grid
              Expanded(child: Center(child: GridWidget())),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pause/Resume Button
                    Obx(
                      () => _buildActionButton(
                        icon: controller.gameStatus.value == GameStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                        label: controller.gameStatus.value == GameStatus.paused
                            ? 'Resume'
                            : 'Pause',
                        onPressed:
                            controller.gameStatus.value == GameStatus.playing
                            ? () => controller.pauseGame()
                            : (controller.gameStatus.value == GameStatus.paused
                                  ? () => controller.resumeGame()
                                  : null), // Disable if game won/lost
                        color: controller.gameStatus.value == GameStatus.paused
                            ? Colors.lightGreen
                            : Colors.orange,
                      ),
                    ),
                    // New Game Button
                    _buildActionButton(
                      icon: Icons.refresh,
                      label: 'New Game',
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Start New Game'),
                            content: const Text('Are you Sure:'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  // controller.initializeGame(mode: GameMode.standard);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.initializeGame(
                                    mode: GameMode.timeRestricted,
                                  );
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              // Keyboard
              KeyboardWidget(),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a styled action button.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),
    );
  }
}
