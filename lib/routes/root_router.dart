import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RootRouter {
  Router get router {
    final router = Router();

    router.head('/', (Request request) async {
      return Response(200);
    });

    router.get('/companion', (Request request) async {
      return Response(200, body: jsonEncode({'ssdc_companion_api': 'a1111', 'version': '1.0.1'}));
    });

    return router;
  }
}
