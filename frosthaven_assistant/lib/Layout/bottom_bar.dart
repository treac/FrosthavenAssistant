import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/set_level_menu.dart';
import 'package:frosthaven_assistant/services/network/network_ui.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/state/game_state.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';
import 'modifier_deck_widget.dart';

String formattedScenarioName(GameState gameState) =>
    gameState.currentCampaign.value == "Solo"
        ? gameState.scenario.value.split(':')[1]
        : gameState.scenario.value;

Widget _buildIcon(
    {required double height,
    required String asset,
    Color? color,
    required Settings settings}) {
  const opacity = 0.3;
  return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha((opacity * 255).toInt()),
            spreadRadius: 1.0,
            blurRadius: 3.0 * settings.userScalingBars.value)
      ]),
      child: Image(
          height: height,
          filterQuality: FilterQuality.medium,
          color: color,
          image: AssetImage(asset)));
}

Widget createLevelWidget(BuildContext context) {
  final gameState = getIt<GameState>();
  final settings = getIt<Settings>();
  final fontHeight = 14 * settings.userScalingBars.value;
  final shadow = Shadow(
      offset: Offset(
          settings.userScalingBars.value, settings.userScalingBars.value),
      color: Colors.black87,
      blurRadius: settings.userScalingBars.value);

  return ValueListenableBuilder<bool>(
      valueListenable: settings.darkMode,
      builder: (context, isDark, _) {
        final textStyle = TextStyle(
          color: isDark ? Colors.white : Colors.black,
          overflow: TextOverflow.fade,
          fontSize: fontHeight,
          shadows: isDark
              ? [shadow]
              : [
                  Shadow(
                      offset: Offset(settings.userScalingBars.value,
                          settings.userScalingBars.value),
                      blurRadius: 3.0 * settings.userScalingBars.value,
                      color: Colors.white),
                  Shadow(
                      offset: Offset(settings.userScalingBars.value,
                          settings.userScalingBars.value),
                      blurRadius: 8.0 * settings.userScalingBars.value,
                      color: Colors.white),
                ],
        );

        return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () => openDialog(context, const SetLevelMenu()),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<String>(
                          valueListenable: gameState.scenario,
                          builder: (context, _, __) => SizedBox(
                              width: 174 * settings.userScalingBars.value,
                              child: Text(formattedScenarioName(gameState),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: textStyle))),
                      ValueListenableBuilder<int>(
                          valueListenable: gameState.commandIndex,
                          builder: (context, _, __) =>
                              Text.rich(TextSpan(children: [
                                WidgetSpan(
                                    child: _buildIcon(
                                        height: fontHeight * 0.6,
                                        asset: "assets/images/psd/level.png",
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        settings: settings)),
                                TextSpan(
                                    text: " ${gameState.level.value} ",
                                    style: textStyle),
                                WidgetSpan(
                                    child: _buildIcon(
                                        height: fontHeight,
                                        asset: "assets/images/psd/traps-fh.png",
                                        settings: settings)),
                                TextSpan(
                                    text: " ${GameMethods.getTrapValue()} ",
                                    style: textStyle),
                                WidgetSpan(
                                    child: _buildIcon(
                                        height: fontHeight,
                                        asset:
                                            "assets/images/psd/hazard-fh.png",
                                        settings: settings)),
                                TextSpan(
                                    text: " ${GameMethods.getHazardValue()} ",
                                    style: textStyle),
                                WidgetSpan(
                                    child: _buildIcon(
                                        height: fontHeight * 0.9,
                                        asset: "assets/images/psd/xp.png",
                                        color: Colors.blue,
                                        settings: settings)),
                                TextSpan(
                                    text: " +${GameMethods.getXPValue()} ",
                                    style: textStyle),
                                WidgetSpan(
                                    child: _buildIcon(
                                        height: fontHeight,
                                        asset: "assets/images/psd/coins-fh.png",
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        settings: settings)),
                                TextSpan(
                                    text: " x${GameMethods.getCoinValue()}",
                                    style: textStyle),
                              ])))
                    ])));
      });
}

Widget createBottomBar(BuildContext context) {
  final settings = getIt<Settings>();
  return ValueListenableBuilder<double>(
      valueListenable: settings.userScalingBars,
      builder: (_, __, ___) => SizedBox(
          height: 40 * settings.userScalingBars.value,
          child: Stack(children: [
            Positioned(
                bottom: 0,
                left: 0,
                child: ValueListenableBuilder<bool>(
                    valueListenable: settings.darkMode,
                    builder: (context, isDark, _) => Container(
                        height: 40 * settings.userScalingBars.value,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, -4))
                            ],
                            image: DecorationImage(
                                image: AssetImage(isDark
                                    ? 'assets/images/psd/gloomhaven-bar.png'
                                    : 'assets/images/psd/frosthaven-bar.png'),
                                fit: BoxFit.cover,
                                repeat: ImageRepeat.repeatX)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              createLevelWidget(context),
                              const NetworkUI(),
                              if (modifiersFitOnBar(context) &&
                                  settings.showAmdDeck.value &&
                                  getIt<GameState>().currentCampaign.value !=
                                      "Buttons and Bugs")
                                const ModifierDeckWidget(name: '')
                            ]))))
          ])));
}
