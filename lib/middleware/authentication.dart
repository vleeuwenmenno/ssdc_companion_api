import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:ssdc_companion_api/exceptions/missing_trait_exception.dart';
import 'package:ssdc_companion_api/exceptions/unexpected_trait_exception.dart';
import 'package:ssdc_companion_api/helpers/user/user.trait-helpers.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/services/api_service.dart';
import 'package:shelf/shelf.dart';

FutureOr<Middleware> authenticateMiddleware(
    {List<Trait> requiredTraits = const [],
    List<Trait> requiredMissingTraits = const [Trait.suspended]}) {
  Future<LoginSession?> isValidToken(String token) async {
    final isar = serviceCollection.get<Isar>();
    final loginSession =
        await isar.loginSessions.filter().tokenEqualTo(token).findFirst();

    if (loginSession == null) {
      return null;
    }

    if (loginSession.expiresAt!.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      return null;
    }

    return loginSession;
  }

  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final session = await isValidToken(token);

        if (session != null) {
          final user = session.user.value as User;
          final updatedRequest = request.change(context: {'session': session});

          try {
            await user.assertHasTraits(requiredTraits);
          } on MissingTraitException {
            return Response.unauthorized(
                json.encode({'error': 'Invalid or missing Bearer token'}));
          }

          try {
            await user.assertMissingTraits(requiredMissingTraits);
          } on UnexpectedTraitException {
            if (requiredMissingTraits.contains(Trait.suspended)) {
              return Response.unauthorized(
                  json.encode({'error': 'This account has been suspended.'}));
            }
            return Response.unauthorized(
                json.encode({'error': 'Invalid or missing Bearer token'}));
          }

          return innerHandler(updatedRequest);
        }
      }
      return Response.unauthorized(
          json.encode({'error': 'Invalid or missing Bearer token'}));
    };
  };
}
