part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class CharacterState extends FigureState {
  CharacterState();

  ValueListenable<String> get display => _display;
  setDisplay(_StateModifier stateModifier, String value) {_display.value = value;}
  final _display = ValueNotifier<String>("");

  ValueListenable<int> get initiative => _initiative;
  setInitiative(_StateModifier stateModifier, int value) {_initiative.value = value;}
  final _initiative = ValueNotifier<int>(0);

  ValueListenable<int> get xp => _xp;
  setXp(_StateModifier stateModifier, int value) {_xp.value = value;}
  final _xp = ValueNotifier<int>(0);

  BuiltList<MonsterInstance> get summonList => BuiltList.of(_summonList);
  getMutableSummonList(_StateModifier stateModifier) {return _summonList;}
  final List<MonsterInstance> _summonList = [];

  @override
  String toString() {
    return '{'
        '"initiative": ${initiative.value}, '
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"xp": ${xp.value}, '
        '"chill": ${chill.value}, '
        '"display": ${jsonEncode(display.value)}, '
        '"summonList": ${_summonList.toString()}, '
        '"conditions": ${conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${conditionsAddedThisTurn.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${conditionsAddedPreviousTurn.toList().toString()}, '
        '"conditionsHealthChangedPreviousTurn": $_conditionsHealthChangedPreviousTurn '
        '}';
  }

  CharacterState.fromJson(Map<String, dynamic> json) {
    _initiative.value = json['initiative'];
    _xp.value = json['xp'];
    _chill.value = json['chill'];
    _health.value = json["health"];
    _level.value = json["level"];
    _maxHealth.value = json["maxHealth"];
    _display.value = json['display'];

    for (var item in json["summonList"]) {
      _summonList.add(MonsterInstance.fromJson(item));
    }

    for (int item in json["conditions"]) {
      conditions.value.add(Condition.values[item]);
    }

    if (json.containsKey("conditionsAddedThisTurn")) {
      for (int item in json["conditionsAddedThisTurn"]) {
        _conditionsAddedThisTurn.add(Condition.values[item]);
      }
    }
    if (json.containsKey("conditionsAddedPreviousTurn")) {
      for (int item in json["conditionsAddedPreviousTurn"]) {
        _conditionsAddedPreviousTurn.add(Condition.values[item]);
      }
    }
    _conditionsHealthChangedPreviousTurn =
        json["conditionsHealthChangedPreviousTurn"];
  }
}
