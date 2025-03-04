import '../../../services/service_locator.dart';
import '../../enums.dart';
import '../../state/game_state.dart';

abstract class ChangeStatCommand extends Command {
  final String ownerId;
  int change;
  final String figureId;
  ChangeStatCommand(this.change, this.figureId, this.ownerId);

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
