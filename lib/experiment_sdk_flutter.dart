import 'package:amplitude_flutter/amplitude.dart';
import 'package:experiment_sdk_flutter/experiment_client.dart';
import 'package:experiment_sdk_flutter/integrations/experiment_analytics.dart';
import 'package:experiment_sdk_flutter/types/experiment_config.dart';

final Map<String, ExperimentClient> instances = {};

// Experiment class is the initial main point of contact and responsible to construct ExperimentClient
class Experiment {
  /// Initialize basic ExperimentClient
  static ExperimentClient initialize(
      {required String apiKey, ExperimentConfig? config}) {
    final instanceName = config?.instanceName;
    final instanceKey = '$instanceName.$apiKey';

    if (instances[instanceKey] == null) {
      instances[instanceKey] = ExperimentClient(apiKey: apiKey, config: config);
    }

    return instances[instanceKey]!;
  }

  /// Initialize ExperimentClient with Amplitude instance to handle exposure events
  static ExperimentClient initializeWithAmplitude({
    required Amplitude amplitude,
    required String apiKey,
    ExperimentConfig? config,
  }) {
    final trackExposureProvider = AnalyticsExposureTrackingProvider(amplitude);

    final newConfig = (config ?? const ExperimentConfig())
        .copyWith(exposureTrackingProvider: trackExposureProvider);

    return Experiment.initialize(apiKey: apiKey, config: newConfig);
  }
}
