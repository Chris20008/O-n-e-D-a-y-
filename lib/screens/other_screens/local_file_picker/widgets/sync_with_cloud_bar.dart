import 'package:fitness_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SyncWithCloudBar extends StatelessWidget {
  const SyncWithCloudBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CnHomepage, bool>(
      selector: (_, cn) => cn.isSyncingWithCloud,
      builder: (context, isSyncing, child) {
        if (!isSyncing) return const SizedBox();

        return RepaintBoundary(
          child: IgnorePointer(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withAlpha(100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 5),
          
                        /// 🔹 Selector für msg
                        RepaintBoundary(
                          child: Selector<CnHomepage, String>(
                            selector: (_, cn) => cn.msg,
                            builder: (_, msg, __) => Text(
                              msg,
                              style: const TextStyle(color: CupertinoColors.white),
                            ),
                          ),
                        ),
          
                        const SizedBox(width: 5),
          
                        /// 🔹 Selector für percent
                        RepaintBoundary(
                          child: Selector<CnHomepage, double?>(
                            selector: (_, cn) => cn.percent,
                            builder: (_, percent, __) {
                              if (percent == null) return const SizedBox();
                              return Row(
                                children: [
                                  Text("${(percent * 100).round()}%",
                                      style: const TextStyle(color: CupertinoColors.white)),
                                  const SizedBox(width: 5),
                                ],
                              );
                            },
                          ),
                        ),
          
                        /// 🔹 Selector für syncWithCloudCompleted
                        RepaintBoundary(
                          child: Selector<CnHomepage, bool>(
                            selector: (_, cn) => cn.syncWithCloudCompleted,
                            builder: (_, completed, __) {
                              return completed
                                  ? const Icon(Icons.check_circle, size: 15, color: Colors.green)
                                  : const SizedBox(
                                height: 15,
                                width: 15,
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 8.0,
                                    color: Colors.amber,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
          
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
