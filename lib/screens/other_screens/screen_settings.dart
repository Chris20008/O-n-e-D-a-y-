import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../util/constants.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,

  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    return PopScope(
        canPop: true,
        onPopInvoked: (doPop){
          cnScreenStatistics.panelControllerSettings.animatePanelToPosition(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate
          );
        },
        child: LayoutBuilder(
            builder: (context, constraints){
              return SlidingUpPanel(
                controller: cnScreenStatistics.panelControllerSettings,
                defaultPanelState: PanelState.CLOSED,
                maxHeight: constraints.maxHeight - 50,
                minHeight: 0,
                isDraggable: true,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                backdropEnabled: true,
                backdropColor: Colors.black,
                color: Colors.transparent,
                onPanelSlide: onPanelSlide,
                panel: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        panelTopBar,
                        const SizedBox(height: 10,),
                        const Text("Settings",textScaler: TextScaler.linear(1.4), ),

                        /// General
                        CupertinoListSection.insetGrouped(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1)
                          ),
                          backgroundColor: Colors.transparent,
                          header: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("General", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                          ),
                          children: [
                            CupertinoListTile.notched(
                              leading: const Icon(
                                Icons.language
                              ),
                              trailing: Row(
                                children: [
                                  Text(
                                    getLanguageAsString(context),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 6,),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                              title: const Text("Language", style: TextStyle(color: Colors.white)),
                            ),
                            CupertinoListTile.notched(
                              leading: const Icon(
                                  Icons.school
                              ),
                              trailing: CupertinoSwitch(
                                  value: true,
                                  activeColor: const Color(0xFFC16A03),
                                  onChanged: (value){
                                    // if(Platform.isAndroid){
                                    //   HapticFeedback.selectionClick();
                                    // }
                                    // cnScreenStatistics.showAvgWeightPerSetLine = value;
                                    // cnStandardPopUp.child = getPopUpChild(cnScreenStatistics.showAvgWeightPerSetLine);
                                    // cnStandardPopUp.refresh();
                                  }
                              ),
                              title: const Text("Show Tutorial", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),

                        /// Backup
                        CupertinoListSection.insetGrouped(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1)
                          ),
                          backgroundColor: Colors.transparent,
                          header: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Backup", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                          ),
                          footer: GestureDetector(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return Center(
                                      child: getBackupDialogChild()
                                    );
                                  }
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.info, size:12),
                                  SizedBox(width: 5,),
                                  Text("More Informations about Backups", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                          ),
                          children: [
                            const CupertinoListTile.notched(
                              onTap: saveBackup,
                              leading: Icon(
                                  Icons.backup
                              ),
                              title: Text("Save Backup", style: TextStyle(color: Colors.white)),
                            ),
                            const CupertinoListTile.notched(
                              onTap: loadBackup,
                              leading: Icon(
                                  Icons.cloud_download
                              ),
                              title: Text("Load Backup", style: TextStyle(color: Colors.white)),
                            ),
                            CupertinoListTile.notched(
                              leading: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                      Icons.cloud
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.sync,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ]
                              ),
                              trailing: CupertinoSwitch(
                                  value: true,
                                  activeColor: const Color(0xFFC16A03),
                                  onChanged: (value){
                                    // if(Platform.isAndroid){
                                    //   HapticFeedback.selectionClick();
                                    // }
                                    // cnScreenStatistics.showAvgWeightPerSetLine = value;
                                    // cnStandardPopUp.child = getPopUpChild(cnScreenStatistics.showAvgWeightPerSetLine);
                                    // cnStandardPopUp.refresh();
                                  }
                              ),
                              title: const Text("Sync via iCloud", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),

                        /// About
                        CupertinoListSection.insetGrouped(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1)
                          ),
                          backgroundColor: Colors.transparent,
                          header: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("About", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                          ),
                          children: const [
                            CupertinoListTile.notched(
                              leading: Icon(
                                  Icons.help_outline
                              ),
                              title: Text("Contact", style: TextStyle(color: Colors.white)),
                            ),
                            CupertinoListTile.notched(
                              leading: Icon(
                                  Icons.my_library_books_rounded
                              ),
                              title: Text("Term of Use", style: TextStyle(color: Colors.white)),
                            ),
                            CupertinoListTile.notched(
                              leading: Icon(
                                  Icons.lock_outline
                              ),
                              title: Text("Privacy Policy", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }

  void onPanelSlide(value){
    cnScreenStatistics.animationControllerSettingPanel.value = value;
    cnBottomMenu.adjustHeight(value);
  }

  Widget getBackupDialogChild() {
    return standardDialog(
        context: context,
        child: const Center(
            child: Text("test")
        )
    );
  }
}


























