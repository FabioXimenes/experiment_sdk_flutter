import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:experiment_sdk_flutter/types/experiment_exposure_tracking_provider.dart';
import 'package:experiment_sdk_flutter/types/experiment_variant.dart';

class AnalyticsExposureTrackingProvider
    implements ExperimentExposureTrackingProvider {
  AnalyticsExposureTrackingProvider(this.amplitude);

  final Amplitude amplitude;

  @override
  Future<void> exposure(String flagkey, ExperimentVariant? variant) async {
    final properties = {'variant': variant?.value, 'flag_key': flagkey};

    if (variant == null) {
      properties.remove('variant');
    }

    await amplitude.track(BaseEvent("\$exposure", eventProperties: properties));
    await amplitude.flush();
  }
}
