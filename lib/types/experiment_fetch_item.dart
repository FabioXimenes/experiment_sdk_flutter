import 'package:experiment_sdk_flutter/types/experiment_variant.dart';

class ExperimentFetchItem {
  final String key;
  final dynamic payload;

  ExperimentFetchItem({required this.key, this.payload});

  factory ExperimentFetchItem.fromMap(Map<String, dynamic> map) {
    return ExperimentFetchItem(key: map['key'], payload: map['payload']);
  }

  ExperimentVariant toVariant() {
    return ExperimentVariant(value: key, payload: payload);
  }
}
