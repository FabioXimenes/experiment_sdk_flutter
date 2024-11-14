import 'dart:async';
import 'dart:convert';

import 'package:experiment_sdk_flutter/types/experiment_fetch_item.dart';
import 'package:experiment_sdk_flutter/types/experiment_server_zone.dart';
import 'package:http/http.dart' as http;

extension ExperimentServerZoneClientExtension on ExperimentServerZone {
  String get baseUri {
    switch (this) {
      case ExperimentServerZone.us:
        return 'api.lab.amplitude.com';
      case ExperimentServerZone.eu:
        return 'api.lab.eu.amplitude.com';
    }
  }
}

abstract class QueryParameters {
  Map<String, dynamic> toJson();
}

// HTTP Client Class
class HttpClient {
  final String _apiKey;
  final String _baseUri;
  final bool _shouldRetry;
  final String? _proxyUrl;

  HttpClient({
    required apiKey,
    bool? shouldRetry,
    ExperimentServerZone? serverZone = ExperimentServerZone.us,
    String? proxyUrl,
  })  : _apiKey = apiKey,
        _shouldRetry = shouldRetry ?? true,
        _baseUri = serverZone?.baseUri ?? ExperimentServerZone.us.baseUri,
        _proxyUrl = proxyUrl;

  bool _isRetry = false;
  Map<String, ExperimentFetchItem> fetchResult = {};

  final httpClient = http.Client();

  static const featureFlagEndpoint = '/v1/vardata';

  /// Get function invoked on HTTP requests
  Future<void> get(QueryParameters queryParameters, [Duration? timeout]) async {
    final Uri uri;
    final maybeProxy = _proxyUrl;
    if (maybeProxy != null) {
      uri = Uri.parse(maybeProxy)
          .replace(queryParameters: queryParameters.toJson());
    } else {
      uri = Uri.https(_baseUri, featureFlagEndpoint, queryParameters.toJson());
    }

    final request =
        httpClient.get(uri, headers: {'Authorization': 'Api-Key $_apiKey'});

    if (timeout != null) {
      request.timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Request timed out!'),
      );
    }

    final response = await request;

    if (response.statusCode != 200) {
      String data = response.body;

      if (!_isRetry && _shouldRetry) {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception({
          'message': 'Failed to fetch through SDK!',
          'status': response.statusCode,
          'trace': data
        });
      }

      _isRetry = true;
      get(queryParameters, timeout);
    }

    Map<String, dynamic> data =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    fetchResult.clear();
    data.forEach((key, value) {
      fetchResult[key] = ExperimentFetchItem.fromMap(value);
    });

    _isRetry = false;
  }
}
