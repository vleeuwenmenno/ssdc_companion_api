import 'dart:convert';

import 'package:ssdc_companion_api/exceptions/user_suspended_exception.dart';
import 'package:ssdc_companion_api/helpers/login/session.helpers.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserRouter {
  Router get router {
    final router = Router();

    router.post('/login', (Request request) async {
      try {
        final session = await LoginSessionHelper.fromLoginRequest(request);

        if (session == null) {
          return Response(401,
              body: json.encode({'error': 'invalid-credentials'}), headers: {'Content-Type': 'application/json'});
        }

        return Response(200, body: json.encode(session.toJson()), headers: {'Content-Type': 'application/json'});
      } on UserSuspendedException {
        return Response(401, body: json.encode({'error': 'user-suspended'}), headers: {'Content-Type': 'application/json'});
      }
    });

    // router.post('/register', (Request request) async {
    //   final body = await RegisterRequest.fromRequest(request);

    //   try {
    //     await User_.fromRegisterRequest(body);
    //     return Response(201);
    //   } on UsernameTakenException catch (e) {
    //     return Response(409, body: e.message);
    //   } on PasswordValidationException catch (e) {
    //     return Response(409, body: e.message);
    //   }
    // });

    return router;
  }
}
