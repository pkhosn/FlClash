import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final version = await system.version;
    final container = await globalState.init(version);
    container.read(v2etBridgeProvider);
    HttpOverrides.global = FlClashHttpOverrides();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    return runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}
