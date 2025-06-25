import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../widgets/slide_up_panel/my_slide_up_panel.dart';
import '../../screen_settings.dart';
import '../initial_settings_screen/widgets/2_backup_options/backup_options.dart';
import '../local_file_picker/widgets/local_backups_list_view/local_backups_list_view.dart';

class BackupsScreen extends StatelessWidget {
  const BackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();

    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          const Text("Backups",textScaler: TextScaler.linear(1.4)),
          const SizedBox(height: 10),
          Expanded(
            child: ListViewScope.of(context).listView(
              physics: const BouncingScrollPhysics(),
              controller: cnSettings.scrollControllerBackupsScreen,
              child: Column(
                children: [
                  const BackupOptions(),
                  const SizedBox(height: 20,),
                  const LocalBackupsListView(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
