import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Layout/menus/main_menu.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/network.dart';

import '../Resource/enums.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

ValueListenableBuilder<int> _buildUndo() {
  final gameState = getIt<GameState>();
  final settings = getIt<Settings>();
  return ValueListenableBuilder<int>(
    valueListenable: gameState.commandIndex,
    builder: (context, command, _) {
      String undoText = "Undo:";
      if (settings.client.value != ClientState.connected &&
          gameState.commandIndex.value >= 0 &&
          gameState.commandDescriptions.length > gameState.commandIndex.value) {
        undoText +=
            ": ${gameState.commandDescriptions[gameState.commandIndex.value]}";
      }
      return TextButton(
        onPressed: () {
          if (undoEnabled()) {
            gameState.undo();
          }
        },
        child: Text(
          undoText, // Ensure this is defined
          style: TextStyle(
            fontSize: 14 * settings.userScalingBars.value,
            color: undoEnabled() ? Colors.black : Colors.transparent,
            decoration: TextDecoration.none,
          ),
        ),
      );
    },
  );
}

ValueListenableBuilder<int> _buildRedo() {
  final gameState = getIt<GameState>();
  final settings = getIt<Settings>();
  return ValueListenableBuilder<int>(
    valueListenable: gameState.commandIndex,
    builder: (context, command, _) {
      String redoText = "Redo:";
      if (settings.client.value != ClientState.connected &&
          gameState.commandIndex.value <
              gameState.commandDescriptions.length - 1) {
        redoText +=
            ": ${gameState.commandDescriptions[gameState.commandIndex.value + 1]}";
      }
      return TextButton(
        onPressed: () {
          if (redoEnabled()) {
            gameState.redo();
          }
        },
        child: Text(
          redoText, // Ensure this is defined
          style: TextStyle(
            fontSize: 14 * settings.userScalingBars.value,
            color: redoEnabled() ? Colors.black : Colors.transparent,
            decoration: TextDecoration.none,
          ),
        ),
      );
    },
  );
}

PreferredSize createTopBar() {
  final settings = getIt<Settings>();

  return PreferredSize(
    preferredSize: Size.fromHeight(40 * settings.userScalingBars.value),
    child: ValueListenableBuilder<double>(
      valueListenable: settings.userScalingBars,
      builder: (context, scale, _) {
        final shadow = _createShadow(settings);
        return ValueListenableBuilder<bool>(
          valueListenable: settings.darkMode,
          builder: (context, isDark, _) => AppBar(
            iconTheme:
                IconThemeData(color: isDark ? Colors.white : Colors.black),
            leading: _buildMenuButton(context, settings, shadow),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildUndo()),
                Center(child: _createElementButtonsList()),
                Expanded(child: _buildRedo()),
              ],
            ),
            toolbarHeight: 40 * settings.userScalingBars.value,
            flexibleSpace: _buildBackground(settings, isDark),
            actions: const [DrawButton()],
          ),
        );
      },
    ),
  );
}

Row _createElementButtonsList() {
  final elementData = [
    (
      color: const Color.fromARGB(255, 226, 66, 30),
      element: Elements.fire,
    ),
    (
      color: const Color.fromARGB(255, 85, 200, 239),
      element: Elements.ice,
    ),
    (
      color: const Color.fromARGB(255, 152, 176, 181),
      element: Elements.air,
    ),
    (
      color: const Color.fromARGB(255, 124, 168, 42),
      element: Elements.earth,
    ),
    (
      color: const Color.fromARGB(255, 236, 166, 15),
      element: Elements.light,
    ),
    (
      color: const Color.fromARGB(255, 31, 50, 131),
      element: Elements.dark,
    ),
  ];
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: elementData
          .map((data) => ElementButton(
                key: UniqueKey(),
                color: data.color,
                element: data.element,
                icon: 'assets/images/psd/element-${data.element.name}.png',
              ))
          .toList());
}

Shadow _createShadow(Settings settings) {
  final scale = settings.userScalingBars.value;
  return Shadow(
    offset: Offset(scale, scale),
    color: Colors.black87,
    blurRadius: scale,
  );
}

Widget _buildMenuButton(
    BuildContext context, Settings settings, Shadow shadow) {
  return IconButton(
    padding: EdgeInsets.all(min(8.0 * settings.userScalingBars.value, 8.0)),
    icon: Icon(
      Icons.menu,
      shadows: [shadow],
      size: 24 * settings.userScalingBars.value,
    ),
    onPressed: () => Scaffold.of(context).openDrawer(),
  );
}

Widget _buildBackground(Settings settings, bool isDark) {
  return Container(
    height: 42 * settings.userScalingBars.value,
    color: isDark ? Colors.black : Colors.white,
    child: Image(
      height: 40 * settings.userScalingBars.value,
      image: AssetImage(isDark
          ? 'assets/images/psd/gloomhaven-bar.png'
          : 'assets/images/psd/frosthaven-bar.png'),
      fit: BoxFit.cover,
      repeat: ImageRepeat.repeatX,
    ),
  );
}
