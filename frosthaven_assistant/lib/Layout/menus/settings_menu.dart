import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/save_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/clear_unlocked_classes_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_ally_deck_in_og_gloom_command.dart';
import 'package:frosthaven_assistant/Resource/commands/track_standees_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../Resource/scaling.dart';
import '../../Resource/settings.dart';
import '../../Resource/ui_utils.dart';
import '../../services/network/client.dart';
import '../../services/network/network.dart';
import '../../services/service_locator.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  SettingsMenuState createState() => SettingsMenuState();
}

final networkInfo = NetworkInfo();

class SettingsMenuState extends State<SettingsMenu> {
  final TextEditingController _serverTextController = TextEditingController();
  final TextEditingController _portTextController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  late Settings settings;

  @override
  initState() {
    // at the beginning, all items are shown
    super.initState();
    settings = getIt<Settings>();
    getIt<Network>().networkInfo.initNetworkInfo();
    _serverTextController.text = settings.lastKnownConnection;
    _portTextController.text = settings.lastKnownPort;
  }

  List<DropdownMenuItem<String>> getIPList() {
    List<DropdownMenuItem<String>> retVal = [];
    for (var item in getIt<Network>().networkInfo.wifiIPv4List) {
      retVal.add(DropdownMenuItem<String>(value: item, child: Text(item)));
    }
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double referenceMinBarWidth = 40 * 6.5;
    double maxBarScale = screenWidth / referenceMinBarWidth;

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Column(
                            children: [
                              const Text(
                                "Settings",
                                style: TextStyle(fontSize: 18),
                              ),
                              CheckboxListTile(
                                  title: const Text("Dark mode"),
                                  value: settings.darkMode.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.darkMode.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Soft numpad for input"),
                                  value: settings.softNumpadInput.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.softNumpadInput.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Don't ask for initiative"),
                                  value: settings.noInit.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.noInit.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Expire Conditions"),
                                  value: settings.expireConditions.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.expireConditions.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Don't track Standees"),
                                  value: settings.noStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      getIt<GameState>().action(
                                          TrackStandeesCommand(!value!));
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Auto Add Standees"),
                                  value: settings.autoAddStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.autoAddStandees.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Auto Add Timed Spawns"),
                                  value: settings.autoAddSpawns.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.autoAddSpawns.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Random Standees"),
                                  value: settings.randomStandees.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.randomStandees.value = value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("No Calculations"),
                                  value: settings.noCalculation.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.noCalculation.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateList.value++;
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Hide Loot Deck"),
                                  value: settings.hideLootDeck.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.hideLootDeck.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Stat card text shimmers"),
                                  value: settings.shimmer.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.shimmer.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text(
                                      "Use Frosthaven Hazardous Terrain Calculation in OG Gloomhaven"),
                                  value:
                                      settings.fhHazTerrainCalcInOGGloom.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.fhHazTerrainCalcInOGGloom.value =
                                          value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text(
                                      "Use Ally Attack Modifier Deck in OG Gloomhaven"),
                                  value: getIt<GameState>()
                                      .allyDeckInOGGloom
                                      .value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      getIt<GameState>().action(
                                          SetAllyDeckInOgGloomCommand(value!));
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                      const Text("Show Scenario names in list"),
                                  value: settings.showScenarioNames.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showScenarioNames.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                      const Text("Show Battle Goal Reminder"),
                                  value: settings.showBattleGoalReminder.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showBattleGoalReminder.value =
                                          value!;
                                      settings.saveToDisk();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text("Show Custom Content"),
                                  value: settings.showCustomContent.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showCustomContent.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text(
                                      "Show Sections in Main Screen"),
                                  value: settings.showSectionsInMainView.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showSectionsInMainView.value =
                                          value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title: const Text(
                                      "Show Round Special Rule Reminders"),
                                  value: settings.showReminders.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showReminders.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              CheckboxListTile(
                                  title:
                                      const Text("Show Attack Modifier Decks"),
                                  value: settings.showAmdDeck.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      settings.showAmdDeck.value = value!;
                                      settings.saveToDisk();
                                      getIt<GameState>().updateAllUI();
                                    });
                                  }),
                              if (!kIsWeb && !Platform.isIOS)
                                CheckboxListTile(
                                    title: const Text("Fullscreen"),
                                    value: settings.fullScreen.value,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        settings.setFullscreen(value!);
                                        settings.saveToDisk();
                                      });
                                    }),
                              Container(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                padding:
                                    const EdgeInsets.only(left: 16, top: 10),
                                alignment: Alignment.bottomLeft,
                                child: const Text("Main List Scaling:"),
                              ),
                              Slider(
                                min: 0.2,
                                max: 3.0,
                                value: settings.userScalingMainList.value,
                                onChanged: (value) {
                                  setState(() {
                                    settings.userScalingMainList.value = value;
                                    setMaxWidth();
                                    settings.saveToDisk();
                                  });
                                },
                              ),
                              Container(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                padding:
                                    const EdgeInsets.only(left: 16, top: 10),
                                alignment: Alignment.bottomLeft,
                                child: const Text("App Bar Scaling:"),
                              ),
                              Slider(
                                min: min(0.8, maxBarScale),
                                max: min(maxBarScale, 3.0),
                                value: min(settings.userScalingBars.value,
                                    maxBarScale),
                                onChanged: (value) {
                                  setState(() {
                                    settings.userScalingBars.value = value;
                                    settings.saveToDisk();
                                  });
                                },
                              ),
                              const Text(
                                "Style:",
                                style: TextStyle(fontSize: 18),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                          value: Style.frosthaven,
                                          groupValue: settings.style.value,
                                          onChanged: (index) {
                                            setState(() {
                                              settings.style.value =
                                                  Style.frosthaven;
                                              settings.saveToDisk();
                                              getIt<GameState>()
                                                  .updateList
                                                  .value++;
                                            });
                                          }),
                                      const Text('Frosthaven')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                          value: Style.original,
                                          groupValue: settings.style.value,
                                          onChanged: (index) {
                                            setState(() {
                                              settings.style.value =
                                                  Style.original;
                                              settings.saveToDisk();
                                              if (getIt<GameState>()
                                                      .currentCampaign
                                                      .value ==
                                                  "Frosthaven") {
                                              } else {}
                                              getIt<GameState>()
                                                  .updateList
                                                  .value++;
                                            });
                                          }),
                                      const Text('Original')
                                    ],
                                  ),
                                ],
                              ),
                              ListTile(
                                  title:
                                      const Text("Clear unlocked characters"),
                                  onTap: () {
                                    setState(() {
                                      getIt<GameState>().action(
                                          ClearUnlockedClassesCommand());
                                    });
                                  }),
                              const Text("Connect devices on local wifi:"),
                              ValueListenableBuilder<ClientState>(
                                  valueListenable: settings.client,
                                  builder: (context, value, child) {
                                    bool connected = false;
                                    String connectionText = "Connect as Client";
                                    if (settings.client.value ==
                                        ClientState.connected) {
                                      connected = true;
                                      connectionText = "Connected as Client";
                                    }
                                    if (settings.client.value ==
                                        ClientState.connecting) {
                                      connectionText = "Connecting...";
                                    }
                                    return CheckboxListTile(
                                        enabled:
                                            settings.server.value == false &&
                                                settings.client.value !=
                                                    ClientState.connecting,
                                        title: Text(connectionText),
                                        value: connected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (settings.client.value !=
                                                ClientState.connected) {
                                              settings.client.value =
                                                  ClientState.connecting;
                                              settings.lastKnownPort =
                                                  _portTextController.text;
                                              getIt<Client>()
                                                  .connect(_serverTextController
                                                      .text)
                                                  .then((value) => null);
                                              settings.lastKnownConnection =
                                                  _serverTextController.text;
                                              settings.saveToDisk();
                                            } else {
                                              getIt<Client>().disconnect(null);
                                            }
                                          });
                                        });
                                  }),

                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 200,
                                height: 40,
                                child: TextField(
                                    controller: _serverTextController,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      helperText: "server ip address",
                                    ),
                                    maxLength: 20),
                              ),

                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: 200,
                                height: 40,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _portTextController,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    helperText: "port",
                                  ),
                                  maxLength: 6,
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                  valueListenable: settings.server,
                                  builder: (context, value, child) {
                                    return CheckboxListTile(
                                        title: Text(settings.server.value
                                            ? "Stop Server"
                                            : "Start Host Server"),
                                        value: settings.server.value,
                                        onChanged: (bool? value) {
                                          if (!settings.server.value) {
                                            settings.lastKnownPort =
                                                _portTextController.text;
                                            settings.lastKnownHostIP =
                                                "(${getIt<Network>().networkInfo.wifiIPv4.value})";
                                            settings.saveToDisk();
                                            getIt<Network>()
                                                .server
                                                .startServer();
                                          } else {
                                            //close server
                                            getIt<Network>()
                                                .server
                                                .stopServer(null);
                                          }
                                        });
                                  }),
                              ValueListenableBuilder<String>(
                                  valueListenable:
                                      getIt<Network>().networkInfo.wifiIPv4,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                      width: 200,
                                      height: 20,
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                              value: getIt<Network>()
                                                  .networkInfo
                                                  .wifiIPv4
                                                  .value,
                                              items: getIPList(),
                                              onChanged: (value) =>
                                                  getIt<Network>()
                                                      .networkInfo
                                                      .wifiIPv4
                                                      .value = value!)),
                                    );
                                  }),
                              ValueListenableBuilder<String>(
                                  valueListenable:
                                      getIt<Network>().networkInfo.outgoingIPv4,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                        width: 200,
                                        height: 20,
                                        child: Text(getIt<Network>()
                                            .networkInfo
                                            .outgoingIPv4
                                            .value));
                                  }),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: 200,
                                height: 40,
                                child: TextField(
                                  controller: _portTextController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    helperText: "port",
                                  ),
                                  maxLength: 6,
                                ),
                              ),
                              ListTile(
                                  title: const Text("Load/Save State"),
                                  onTap: () {
                                    openDialog(context, const SaveMenu());
                                  }),
                              //checkbox client + host + port
                              //checkbox server - show ip, port
                            ],
                          )),
                      const SizedBox(
                        height: 34,
                      ),
                    ],
                  ),
                  Positioned(
                      width: 100,
                      height: 40,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            settings.saveToDisk();
                          }))
                ]))));
  }
}
