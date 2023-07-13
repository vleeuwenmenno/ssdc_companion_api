import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:ssdc_companion_api/sd-api/a1111_api.dart';
import 'package:ssdc_companion_api/services/api_service.dart';

import 'package:http/http.dart' as http;

class StableDiffusionRouter {
  Router get router {
    final router = Router();

    router.post('/<route>', (Request req, String route) async {
      final api = serviceCollection.get<A1111Api>();
      final path = api.getApiUrl('${req.handlerPath}$route');
      var body = await req.readAsString();

      if (path.path.endsWith('/sdapi/v1/txt2img') && File('./filters.json').existsSync()) {
        final filters = jsonDecode(File('./filters.json').readAsStringSync());
        final ttiRequest = jsonDecode(body);
        String prompt = ttiRequest['prompt'];
        String negativePrompt = ttiRequest['negative_prompt'];

        for (final filter in filters['banned_words']) {
          if (prompt.contains(filter)) {
            print('Filtering banned word $filter from positive prompt');
          }
          if (negativePrompt.contains(filter)) {
            print('Filtering banned word $filter from negative prompt');
          }
          prompt = prompt.replaceAll(filter, '');
          negativePrompt = negativePrompt.replaceAll(filter, '');
        }

        for (final filter in filters['banned_words_positive']) {
          if (prompt.contains(filter)) {
            print('Filtering positive banned word $filter from positive prompt');
            negativePrompt = '$filter,$negativePrompt';
          }
          prompt = prompt.replaceAll(filter, '');
        }

        for (final filter in filters['banned_words_negative']) {
          if (negativePrompt.contains(filter)) {
            print('Filtering negative banned word $filter from negative prompt');
          }
          negativePrompt = negativePrompt.replaceAll(filter, '');
        }

        prompt = filters['positiveAddition'] + prompt;
        negativePrompt = filters['negativeAddition'] + negativePrompt;

        ttiRequest['prompt'] = prompt;
        ttiRequest['negative_prompt'] = negativePrompt;
        body = jsonEncode(ttiRequest);
      }

      print('Passing ${req.requestedUri} ${req.method} to $path');

      final headers = Map<String, String>.from(req.headers)..remove('content-length');
      final client = http.Client();
      final request = http.Request('POST', path)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await client.send(request);
      final responseBody = jsonDecode(await streamedResponse.stream.bytesToString());
      // print('Returning with response ${streamedResponse.statusCode} body:');
      // try {
      //   printLimitedString(jsonEncode(responseBody));
      //   // ignore: empty_catches
      // } catch (e) {}

      return Response(streamedResponse.statusCode, body: jsonEncode(responseBody));
    });

    router.get('/<route>', (Request req, String route) async {
      final api = serviceCollection.get<A1111Api>();
      final path = api.getApiUrl('${req.handlerPath}$route');

      print('Passing ${req.requestedUri} ${req.method} to $path');

      final client = http.Client();
      final request = http.Request('GET', path)..headers.addAll(req.headers);
      final streamedResponse = await client.send(request);
      final responseBody = jsonDecode(await streamedResponse.stream.bytesToString());
      print('Returning with response ${streamedResponse.statusCode} body:');
      try {
        printLimitedString(jsonEncode(responseBody));
        // ignore: empty_catches
      } catch (e) {}

      return Response(streamedResponse.statusCode, body: jsonEncode(responseBody));
    });

    return router;
  }

  void printLimitedString(String input) {
    if (input.length <= 1000) {
      print(input);
    } else {
      print(input.substring(0, 1000));
    }
  }
}
