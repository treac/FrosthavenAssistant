import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/select_health_wheel.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../Resource/state/game_state.dart';
import '../services/service_locator.dart';

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    return translation != null && renderObject?.paintBounds != null
        ? renderObject!.paintBounds.shift(Offset(translation.x, translation.y))
        : null;
  }
}

class HealthWheelController extends StatefulWidget {
  final String figureId;
  final String ownerId;
  final Widget child;

  const HealthWheelController(
      {super.key,
      required this.figureId,
      required this.ownerId,
      required this.child});

  @override
  HealthWheelControllerState createState() => HealthWheelControllerState();
}

class HealthWheelControllerState extends State<HealthWheelController> {
  OverlayEntry? entry;

  final wheelDelta = ValueNotifier<double>(0);
  final wheelTimeDelta = ValueNotifier<int>(0);
  final gameState = getIt<GameState>();
  int? lastTimeStamp;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    hideOverlay();
    super.dispose();
  }

  void hideOverlay() {
    if (entry?.mounted ?? false) {
      entry!.remove();
      entry!.dispose();
      entry = null;
      gameState.updateList.value++;
    }
  }

  void showOverlay(String figureId, double scale, BuildContext context) {
    final bounds = context.globalPaintBounds!;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: bounds.topCenter.dx - 100 * scale,
        top: bounds.topCenter.dy - 40 * scale,
        width: 200 * scale,
        height: 50 * scale,
        child: Material(
          color: Colors.transparent,
          child: SelectHealthWheel(
            key: UniqueKey(),
            data: GameMethods.getFigure(widget.ownerId, widget.figureId)!,
            figureId: figureId,
            ownerId: widget.ownerId,
            delta: wheelDelta,
            time: wheelTimeDelta,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry!);
  }

  void _handleHealthChange(int amount) {
    final figure = GameMethods.getFigure(widget.ownerId, widget.figureId);
    if (figure != null) {
      if ((amount > 0 && figure.health.value < figure.maxHealth.value) ||
          (amount < 0 && figure.health.value > 0)) {
        gameState.action(ChangeHealthCommand(amount, widget.figureId, widget.ownerId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = getScaleByReference(context);
    return GestureDetector(
      onTap: () => _handleHealthChange(1),
      onDoubleTap: () => _handleHealthChange(-1),
      onHorizontalDragStart: (details) {
        hideOverlay();
        Overlay.of(context).deactivate();
        showOverlay(widget.figureId, scale, context);
      },
      onHorizontalDragCancel: hideOverlay,
      onHorizontalDragUpdate: (details) {
        wheelTimeDelta.value = lastTimeStamp != null
            ? details.sourceTimeStamp!.inMicroseconds - lastTimeStamp!
            : 0;
        wheelDelta.value = details.delta.dx;
        lastTimeStamp = details.sourceTimeStamp!.inMicroseconds;
      },
      onHorizontalDragEnd: (_) => hideOverlay(),
      child: widget.child,
    );
  }
}
