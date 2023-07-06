import 'dart:convert';

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

      print('Passing ${req.requestedUri} ${req.method} to $path');

      final client = http.Client();
      final request = http.Request('POST', path)
        ..headers.addAll(req.headers)
        ..body = await req.readAsString();
      final streamedResponse = await client.send(request);
      final responseBody = jsonDecode(await streamedResponse.stream.bytesToString());
      print('Returning with response ${streamedResponse.statusCode} body:');
      try {
        printLimitedString(jsonEncode(responseBody));
        // ignore: empty_catches
      } catch (e) {}

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
