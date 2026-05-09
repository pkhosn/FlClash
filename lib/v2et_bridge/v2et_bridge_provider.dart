import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flclash_v2et_bridge.dart';
import 'v2et_bridge.dart';

final v2etBridgeProvider = Provider<V2etBridge>((ref) {
  return FlClashV2etBridge(ref);
});
