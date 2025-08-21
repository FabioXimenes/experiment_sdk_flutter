import 'package:experiment_sdk_flutter/types/experiment_variant.dart';

abstract class ExperimentExposureTrackingProvider {
  Future<void> exposure(String flagkey, ExperimentVariant? variant) async {}
}
