import 'package:flutter/material.dart';
import '../Resource/commands/imbue_element_command.dart';
import '../Resource/commands/use_element_command.dart';
import '../Resource/enums.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../services/service_locator.dart';

class ElementButton extends StatefulWidget {
  static const double width = 40;
  static const double borderWidth = 2;

  final String icon;
  final Color color;
  final Elements element;

  const ElementButton(
      {super.key,
      required this.icon,
      required this.color,
      required this.element});

  @override
  State<ElementButton> createState() => ElementButtonState();
}

class ElementButtonState extends State<ElementButton> {
  final _gameState = getIt<GameState>();
  final _settings = getIt<Settings>();

  late double _height;
  late Color _color;
  late BorderRadiusGeometry _borderRadius;

  void _updateState(ElementState state) {
    final scale = _settings.userScalingBars.value;
    final baseWidth = ElementButton.width * scale;

    switch (state) {
      case ElementState.full:
        _color = widget.color;
        _height = baseWidth - ElementButton.borderWidth * scale * 2;
        _borderRadius = BorderRadius.circular(
            baseWidth - ElementButton.borderWidth * scale * 2);
      case ElementState.half:
        _color = widget.color;
        _height = baseWidth / 2 - ElementButton.borderWidth * scale;
        _borderRadius = BorderRadius.vertical(
            bottom: Radius.circular(
                baseWidth / 2 - ElementButton.borderWidth * scale * 2));
      case ElementState.inert:
        _color = Colors.transparent;
        _height = 4 * scale;
        _borderRadius = BorderRadius.zero;
    }
  }

  void _handleTap() => _gameState.action(
      _gameState.elementState[widget.element] == ElementState.inert
          ? ImbueElementCommand(widget.element, false)
          : UseElementCommand(widget.element));

  @override
  void initState() {
    super.initState();
    _updateState(ElementState.inert);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _gameState.commandIndex,
      builder: (context, _, __) {
        _updateState(
            _gameState.elementState[widget.element] ?? ElementState.inert);
        return _buildElementButton();
      },
    );
  }

  Widget _buildElementButton() {
    return Container(
      margin: EdgeInsets.only(right: 2 * _settings.userScalingBars.value),
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: const Color(0x44000000),
        highlightColor: Colors.transparent,
        onTap: _handleTap,
        onDoubleTap: () =>
            _gameState.action(ImbueElementCommand(widget.element, true)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildBackgroundContainer(),
            _buildElementIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundContainer() {
    final scale = _settings.userScalingBars.value;
    return Container(
      padding: EdgeInsets.only(bottom: 2 * scale),
      width: ElementButton.width * scale,
      height: ElementButton.width * scale,
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        width:
            ElementButton.width * scale - ElementButton.borderWidth * scale * 2,
        height: _height,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: _borderRadius,
          boxShadow: _color != Colors.transparent
              ? [BoxShadow(blurRadius: 4 * scale)]
              : null,
        ),
        duration: const Duration(milliseconds: 350),
        curve: Curves.decelerate,
      ),
    );
  }

  Widget _buildElementIcon() {
    return ValueListenableBuilder<bool>(
      valueListenable: _settings.darkMode,
      builder: (context, isDark, _) {
        final scale = _settings.userScalingBars.value;
        final size = ElementButton.width * scale * 0.65;
        return Image(
          height: size,
          width: size,
          image: AssetImage(widget.icon),
          color:
              (!isDark && _color == Colors.transparent) ? Colors.black : null,
        );
      },
    );
  }
}
