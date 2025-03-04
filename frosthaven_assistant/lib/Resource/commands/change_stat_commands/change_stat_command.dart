import '../../../services/service_locator.dart';
import '../../state/game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String ownerId;
  int change;
  final String figureId;
  final FigureState figure;
  ChangeStatCommand(this.change, this.figureId, this.ownerId)
      : figure = GameMethods.getFigure(ownerId, figureId)!;
  ChangeStatCommand.withFigure(this.change, this.figure)
      : figureId = '',
        ownerId = '';

  void setChange(int change) {
    this.change = change;
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "change stat";
  }
}
