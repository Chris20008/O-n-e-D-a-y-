import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/local_file_picker/widgets/local_backups_list_view/local_backups_list_view.dart';
import 'package:fitness_app/util/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../screen_settings.dart';

class LocalFilePicker extends StatefulWidget {
  const LocalFilePicker({super.key});

  @override
  State<LocalFilePicker> createState() => _LocalFilePickerState();
}

class _LocalFilePickerState extends State<LocalFilePicker> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSettings cnSettings = Provider.of<CnSettings>(context, listen: false);
  bool _showLoadingIndicator = false;

  void setLoadingIndicator(bool value){
    setState(() {
      _showLoadingIndicator = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        extendBody: true,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.localBackups, textScaler: const TextScaler.linear(1.3),),
                const SizedBox(height: 20),
                LocalBackupsListView(
                    setLoadingIndicator: setLoadingIndicator,
                    cnScreenStatistics: cnScreenStatistics,
                    cnConfig: cnConfig,
                    cnHomepage: cnHomepage
                ),
                // const SizedBox(height: 20,)
              ],
            ),
            if (_showLoadingIndicator)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: RepaintBoundary(
                    child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.amber[800]
                    ),
                  ),
                ),
              ),

            // const SyncWithCloudBar()
          ],
        )
    );
  }
}
