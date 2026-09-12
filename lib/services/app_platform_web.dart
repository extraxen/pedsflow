// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.

import 'dart:js_interop';

@JS('pedsFlowSetWakeLock')
external JSPromise<JSBoolean> _setWakeLock(JSBoolean enabled);


Future<bool> setPlatformWakeLock(bool enabled) async {
  try {
    final JSBoolean applied = await _setWakeLock(enabled.toJS).toDart;
    return applied.toDart;
  } catch (_) {
    return false;
  }
}

