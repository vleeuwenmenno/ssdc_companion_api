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
      final path = api.getApiUrl(route);
      print('Passing ${req.requestedUri} ${req.method} to ${api.getApiUrl(route)}');

      final client = http.Client();
      final request = http.Request('POST', path)
        ..headers.addAll(req.headers)
        ..body = await req.readAsString();
      final streamedResponse = await client.send(request);
      final responseBody = jsonDecode(await streamedResponse.stream.bytesToString());

      return Response(streamedResponse.statusCode, body: jsonEncode(responseBody));
    });

    router.get('/<route>', (Request req, String route) async {
      final api = serviceCollection.get<A1111Api>();
      final path = api.getApiUrl(route);
      print('Passing ${req.requestedUri} ${req.method} to ${api.getApiUrl(route)}');

      final client = http.Client();
      final request = http.Request('GET', path)..headers.addAll(req.headers);
      final streamedResponse = await client.send(request);
      final responseBody = jsonDecode(await streamedResponse.stream.bytesToString());

      return Response(streamedResponse.statusCode, body: jsonEncode(responseBody));
    });

    return router;
  }
}
