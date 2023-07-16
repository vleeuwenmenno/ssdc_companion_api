import 'dart:async';
import 'dart:convert';

import 'package:ssdc_companion_ui/api/embedding_response.dart';
import 'package:ssdc_companion_ui/api/lora_response.dart';
import 'package:ssdc_companion_ui/api/model_response.dart';
import 'package:ssdc_companion_ui/api/progress_response.dart';
import 'package:ssdc_companion_ui/api/sampler_response.dart';
import 'package:ssdc_companion_ui/api/upscaler_response.dart';
import 'package:ssdc_companion_ui/utils/debug.dart';
import 'package:http/http.dart' as http;

class A1111Api {
  A1111Api(this._host);

  final String _host;
  DateTime _lastRequestTime = DateTime.now();

  String getHost() => _host;

  Uri getApiUrl([String path = '', bool root = false]) => Uri.parse(root ? '$_host/$path' : '$_host/sdapi/v1/$path');

  static String basicAuthorization(String username, String password) {
    final userPass = '$username:$password';
    return userPass.isEmpty ? 'Basic ' : 'Basic ${base64Encode(utf8.encode(userPass))}';
  }

  Future<Map<String, String>> getHeaders({bool post = true}) async {
    final headers = <String, String>{};
    if (post) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<void> waitIfNeeded() async {
    final diff = DateTime.now().difference(_lastRequestTime);
    if (diff.inMilliseconds < 100) {
      await Future<void>.delayed(const Duration(milliseconds: 100) - diff);
    }
    _lastRequestTime = DateTime.now();
  }

  Future<void> interrupt() async {
    await waitIfNeeded();
    await _post('interrupt', {});
  }

  Future<ProgressResponse> progress() async {
    await waitIfNeeded();
    final response = await _get('progress');
    return ProgressResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Upscaler>> upscalers() async {
    await waitIfNeeded();
    final response = await _get('upscalers') as List;
    final upscalers = <Upscaler>[];
    final latentUpscalers = <Upscaler>[];

    for (final latentUpscaler in <String>[
      'Latent',
      'Latent (antialiased)',
      'Latent (bicubic)',
      'Latent (bicubic antialiased)',
      'Latent (nearest)',
      'Latent (nearest-exact)'
    ]) {
      latentUpscalers.add(
        Upscaler(
          name: latentUpscaler,
          modelName: latentUpscaler,
          modelPath: latentUpscaler,
          modelUrl: latentUpscaler,
          scale: 2,
        ),
      );
    }

    upscalers
      ..addAll(latentUpscalers)
      ..addAll(
        response.map((e) => Upscaler.fromJson(e as Map<String, dynamic>)).toList(),
      );

    return upscalers;
  }

  Future<List<LyCORIS>> lycos() async {
    await waitIfNeeded();
    final response = await _get('lycos') as List;
    return response.map((e) => LyCORIS.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.name!.compareTo(b.name!));
  }

  Future<List<Lora>> loras() async {
    await waitIfNeeded();
    final response = await _get('loras') as List;
    return response.map((e) => Lora.fromJson(e as Map<String, dynamic>)).toList()..sort((a, b) => a.name!.compareTo(b.name!));
  }

  Future<List<Embedding>> embeddings() async {
    await waitIfNeeded();
    final response = await _get('embeddings') as Map<String, dynamic>;
    return EmbeddingRequestResponse.fromJson(response).loaded;
  }

  Future<List<Sampler>> samplers() async {
    await waitIfNeeded();
    final response = await _get('samplers') as List;
    return response.map((e) => Sampler.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.name!.compareTo(b.name!));
  }

  Future<List<Checkpoint>> checkpoints() async {
    await waitIfNeeded();
    final response = await _get('sd-models') as List;
    return response.map((e) => Checkpoint.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.modelName!.compareTo(b.modelName!));
  }

  Future<Map<String, dynamic>> getApiInfo() async {
    await waitIfNeeded();
    return await _get('internal/sysinfo?attachment=false', false, true) as Map<String, dynamic>;
  }

  Future<void> setCheckpoint(String modelName) async {
    await waitIfNeeded();
    await _post('options', {'sd_model_checkpoint': modelName});
  }

  Future<String> getCheckpoint() async {
    await waitIfNeeded();
    final response = await _get('internal/sysinfo?attachment=false', false, true) as Map<String, dynamic>;
    // ignore: avoid_dynamic_calls
    return response['Config']['sd_model_checkpoint'] == null ? 'None' : response['Config']['sd_model_checkpoint'] as String;
  }

  Future<void> refreshCheckpoints() async {
    await waitIfNeeded();
    await _post('refresh-checkpoints');
  }

  Future<void> refreshLoras() async {
    await waitIfNeeded();
    await _post('refresh-loras');
  }

  Future<bool> setConfig(Map<String, dynamic> config) async {
    return await _post('options', config) == 'null';
  }

  Future<Map<String, dynamic>> getConfig() async {
    return await _get('options') as Map<String, dynamic>;
  }

  Future<dynamic> _get(String path, [bool isRetry = false, bool customPath = false]) async {
    final client = http.Client();
    final headers = await getHeaders(post: false);
    final request = http.Request('GET', getApiUrl(path, customPath))..headers.addAll(headers);

    final streamedResponse = await client.send(request);
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return jsonDecode(responseBody);
    }

    throw ApiException(
      'HTTP Status code ${streamedResponse.statusCode}',
      streamedResponse.reasonPhrase,
      'HTTP Status code ${streamedResponse.statusCode} - ${streamedResponse.reasonPhrase}',
    );
  }

  Future<dynamic> _post(
    String path, [
    Map<String, dynamic>? body,
    bool customPath = false,
  ]) async {
    final client = http.Client();
    final request = http.Request('POST', getApiUrl(path, customPath))
      ..headers.addAll(await getHeaders())
      ..body = body != null ? jsonEncode(body) : jsonEncode({});

    final streamedResponse = await client.send(request);
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return body != null ? jsonDecode(responseBody) : null;
    } else {
      throw ApiException(
        responseBody,
        responseBody,
        responseBody,
      );
    }
  }

  Future<bool> connection() async {
    try {
      final response =
          await http.head(Uri.parse(_host), headers: await getHeaders(post: false)).timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } on TimeoutException {
      return false;
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.error, this.detail) {
    log('API Exception, $detail', 'API', 'EXCEPTION');
  }
  final String? message;
  final String? error;
  final String? detail;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
      'detail': detail,
    };
  }
}
