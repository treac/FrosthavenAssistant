import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/draw_button.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../Resource/enums.dart';
import '../services/service_locator.dart';
import 'element_button.dart';

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: _createElementButtonsList(),
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

List<Widget> _createElementButtonsList() {
  final elementData = [
    (
      color: const Color.fromARGB(255, 226, 66, 30),
      element: Elements.fire,
      icon: 'assets/images/psd/element-fire.png'
    ),
    (
      color: const Color.fromARGB(255, 85, 200, 239),
      element: Elements.ice,
      icon: 'assets/images/psd/element-ice.png'
    ),
    (
      color: const Color.fromARGB(255, 152, 176, 181),
      element: Elements.air,
      icon: 'assets/images/psd/element-air.png'
    ),
    (
      color: const Color.fromARGB(255, 124, 168, 42),
      element: Elements.earth,
      icon: 'assets/images/psd/element-earth.png'
    ),
    (
      color: const Color.fromARGB(255, 236, 166, 15),
      element: Elements.light,
      icon: 'assets/images/psd/element-light.png'
    ),
    (
      color: const Color.fromARGB(255, 31, 50, 131),
      element: Elements.dark,
      icon: 'assets/images/psd/element-dark.png'
    ),
  ];

  return elementData
      .map((data) => ElementButton(
            key: UniqueKey(),
            color: data.color,
            element: data.element,
            icon: data.icon,
          ))
      .toList();
}

Shadow _createShadow(Settings settings) {
  return Shadow(
    offset: Offset(
      settings.userScalingBars.value,
      settings.userScalingBars.value,
    ),
    color: Colors.black87,
    blurRadius: settings.userScalingBars.value,
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
