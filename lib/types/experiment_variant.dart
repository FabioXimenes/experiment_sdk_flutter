class ExperimentVariant {
  String value;
  Object? payload;

  ExperimentVariant({required this.value, this.payload});

  factory ExperimentVariant.fromJson(Map<String, dynamic> json) {
    return ExperimentVariant(
      value: json['value'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'payload': payload,
    };
  }
}
