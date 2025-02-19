import 'package:flutter/material.dart';

import '../Resource/commands/draw_command.dart';
import '../Resource/commands/next_round_command.dart';
import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class DrawButton extends StatefulWidget {
  const DrawButton({
    super.key,
  });

  @override
  DrawButtonState createState() => DrawButtonState();
}

class DrawButtonState extends State<DrawButton> {
  final GameState _gameState = getIt<GameState>();
  final Settings _settings = getIt<Settings>();

  void onPressed() {
    if (_gameState.roundState.value == RoundState.chooseInitiative) {
      if (GameMethods.canDraw()) {
        _gameState.action(DrawCommand());
      } else {
        String text = _gameState.currentList.isEmpty
            ? "Add characters first."
            : "Player Initiative numbers must be set (under the initiative marker to the right of the character symbol)";
        showToast(context, text);
      }
    } else {
      _gameState.action(NextRoundCommand());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _settings.darkMode,
      builder: (context, isDark, child) => _buildButton(isDark),
    );
  }

  Widget _buildButton(bool isDark) {
    var shadow = Shadow(
      offset: Offset(
          _settings.userScalingBars.value, _settings.userScalingBars.value),
      color: Colors.black87,
      blurRadius: _settings.userScalingBars.value,
    );

    return ValueListenableBuilder<double>(
      valueListenable: _settings.userScalingBars,
      builder: (context, scale, _) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          _buildRoundCounter(isDark, shadow),
          _buildActionButton(isDark, shadow),
        ],
      ),
    );
  }

  Widget _buildRoundCounter(bool isDark, Shadow shadow) {
    return ValueListenableBuilder<int>(
      valueListenable: _gameState.round,
      builder: (context, value, _) {
        String text = _gameState.round.value.toString();
        if (_gameState.totalRounds.value != _gameState.round.value) {
          text = "$text(${_gameState.totalRounds.value})";
        }

        return Positioned(
          bottom: 2 * _settings.userScalingBars.value,
          left: 45 * _settings.userScalingBars.value,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14 * _settings.userScalingBars.value,
              color: isDark ? Colors.white : Colors.black,
              shadows: [shadow],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(bool isDark, Shadow shadow) {
    return ValueListenableBuilder<int>(
      valueListenable: _gameState.commandIndex,
      builder: (context, _, __) => Container(
        margin: EdgeInsets.zero,
        height: 40 * _settings.userScalingBars.value,
        width:
            (_gameState.totalRounds.value != _gameState.round.value ? 75 : 60) *
                _settings.userScalingBars.value,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * _settings.userScalingBars.value,
            ),
            alignment: Alignment.center,
          ),
          onPressed: onPressed,
          child: Text(
            _gameState.roundState.value == RoundState.chooseInitiative
                ? "Draw"
                : "Next Round",
            style: TextStyle(
              height: 0.8,
              fontSize: 16 * _settings.userScalingBars.value,
              color: isDark ? Colors.white : Colors.black,
              shadows: [shadow],
            ),
          ),
        ),
      ),
    );
  }
}
