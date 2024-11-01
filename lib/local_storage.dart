import 'dart:async';
import 'dart:convert';

import 'package:experiment_sdk_flutter/types/experiment_variant.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  @protected
  final String namespace;

  @protected
  Map<String, ExperimentVariant> map = {};

  LocalStorage({required String apiKey}) : namespace = _getNamespace(apiKey);

  void put(String key, ExperimentVariant value) {
    map[key] = value;
  }

  ExperimentVariant? get(String key) {
    final variant = map[key];

    return variant;
  }

  void clear() {
    map = {};
  }

  Map<String, ExperimentVariant> getAll() {
    return map;
  }

  FutureOr<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final experiments = prefs.getString(namespace);

    if (experiments != null) {
      final Map<String, dynamic> experimentsMap = jsonDecode(experiments);

      map = experimentsMap.map((key, value) {
        return MapEntry(key, ExperimentVariant.fromJson(value));
      });
    }
  }

  FutureOr<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(namespace, jsonEncode(map));
  }

  static _getNamespace(String apiKey) {
    final apiKeyToSubstring = apiKey.length > 6 ? apiKey : 'default-api-key';
    String shortApiKey =
        apiKeyToSubstring.substring(apiKeyToSubstring.length - 6);

    return 'ampli-$shortApiKey';
  }
}
