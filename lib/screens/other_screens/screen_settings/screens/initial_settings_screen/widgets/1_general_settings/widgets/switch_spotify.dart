import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../assets/custom_icons/my_icons_icons.dart';
import '../../../../../../../../widgets/cupertino_switch_future.dart';

class CupertinoListTileSwitchSpotify extends StatefulWidget {

  final int delay;

  const CupertinoListTileSwitchSpotify({
    super.key,
    this.delay = 300
  });

  @override
  State<CupertinoListTileSwitchSpotify> createState() => _CupertinoListTileSwitchSpotifyState();
}

class _CupertinoListTileSwitchSpotifyState extends State<CupertinoListTileSwitchSpotify> {

  late CnConfig cnConfig;

  @override
  Widget build(BuildContext context) {

    cnConfig = context.read<CnConfig>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoListTile(
          leading: const Icon(
              MyIcons.spotify,
              color: Color(0xff1ed560)
          ),
          title: Text(AppLocalizations.of(context)!.settingsConnectSpotify, style: const TextStyle(color: Colors.white)),
          trailing: CupertinoSwitchFuture(
            initialState: cnConfig.useSpotify,
            onSwitch: (value){
              cnConfig.setSpotify(value);
            },
            future: () => cnConfig.isSpotifyInstalled(
                delayMilliseconds: widget.delay,
                context: context,
            )
          ),
        ),
      ],
    );
  }
}
