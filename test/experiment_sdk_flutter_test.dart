import 'dart:io';

import 'package:experiment_sdk_flutter/experiment_sdk_flutter.dart';
import 'package:experiment_sdk_flutter/types/experiment_config.dart';
import 'package:experiment_sdk_flutter/types/experiment_exposure_tracking_provider.dart';
import 'package:experiment_sdk_flutter/types/experiment_variant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

class MockedTracker implements ExperimentExposureTrackingProvider {
  late int result;

  @override
  Future<void> exposure(String flagkey, ExperimentVariant? variant) async {
    // ↓ mock an result to exposure to ensure that is called
    result = 0;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // ↓ required to avoid HTTP error 400 mocked returns
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
  });

  test('Should throw error if called with wrong apikey', () {
    final experiment = Experiment.initialize(apiKey: '');

    expect(experiment.fetch(userId: 'testing'),
        throwsA(const TypeMatcher<Exception>()));
  });

  test('Should succesfull fetch with a valid apiKey', () async {
    final experiment = Experiment.initialize(
        apiKey: 'client-SyuVa4OF1vMBD5F59JMRwcZJutII4gZ2');

    expect(experiment.fetch(userId: 'testing'), completion(null));
  });

  test('Should has one variant', () async {
    final experiment = Experiment.initialize(
        apiKey: 'client-SyuVa4OF1vMBD5F59JMRwcZJutII4gZ2');

    await experiment.fetch(userId: 'testing');

    expect(experiment.variant('testing-sdk')?.value, 'control');
  });

  test('Should successfuly call track method inside tracker', () async {
    final mocked = MockedTracker();

    final experiment = Experiment.initialize(
        apiKey: 'client-SyuVa4OF1vMBD5F59JMRwcZJutII4gZ2',
        config: ExperimentConfig(
            automaticExposureTracking: true, exposureTrackingProvider: mocked));

    await experiment.fetch(userId: 'testing');
    experiment.variant('testing-sdk');
    experiment.exposure('testing-sdk');

    expect(mocked.result, 0);
  });

  test('Should return a map with variant on all method', () async {
    final experiment = Experiment.initialize(
        apiKey: 'client-SyuVa4OF1vMBD5F59JMRwcZJutII4gZ2');

    await experiment.fetch(userId: 'testing');
    final all = experiment.all();

    expect(all['testing-sdk']!.value, 'control');
  });

  test('Should succesfully clear cache', () async {
    final experiment = Experiment.initialize(
        apiKey: 'client-SyuVa4OF1vMBD5F59JMRwcZJutII4gZ2');

    await experiment.fetch(userId: 'testing');
    var all = experiment.all();

    expect(all['testing-sdk']!.value, 'control');

    experiment.clear();
    all = experiment.all();

    expect(all, {});
  });
}
