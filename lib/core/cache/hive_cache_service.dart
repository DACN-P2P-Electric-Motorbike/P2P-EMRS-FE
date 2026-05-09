import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheService {
  static const _boxName = 'dreamride_cache';

  Box<dynamic>? _box;
  bool _initialized = false;
  final _changes = StreamController<String>.broadcast();

  Stream<String> get changes => _changes.stream;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
    _initialized = true;
  }

  Future<T?> read<T>(String key, {Duration? maxAge}) async {
    await init();
    final entry = _box?.get(key);
    if (entry is! Map) return null;

    final cachedAtRaw = entry['cachedAt'];
    final cachedAt = cachedAtRaw is String
        ? DateTime.tryParse(cachedAtRaw)
        : null;
    if (maxAge != null && cachedAt != null) {
      final isExpired = DateTime.now().difference(cachedAt) > maxAge;
      if (isExpired) return null;
    }

    final payload = entry['payload'];
    return payload is T ? payload : null;
  }

  Future<void> write(String key, Object? payload) async {
    await init();
    final previous = _box?.get(key);
    final previousPayload = previous is Map ? previous['payload'] : null;
    final hasChanged = jsonEncode(previousPayload) != jsonEncode(payload);
    await _box?.put(key, {
      'payload': payload,
      'cachedAt': DateTime.now().toIso8601String(),
    });
    if (hasChanged) _changes.add(key);
  }

  Future<void> delete(String key) async {
    await init();
    await _box?.delete(key);
    _changes.add(key);
  }

  Future<void> deleteByPrefix(String prefix) async {
    await init();
    final keys = _box?.keys.where((key) => key.toString().startsWith(prefix));
    if (keys == null) return;
    final keysToDelete = keys.toList();
    await _box?.deleteAll(keysToDelete);
    for (final key in keysToDelete) {
      _changes.add(key.toString());
    }
  }
}
