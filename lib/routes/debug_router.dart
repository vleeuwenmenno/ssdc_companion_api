import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:ssdc_companion_api/exceptions/missing_trait_exception.dart';
import 'package:ssdc_companion_api/exceptions/unexpected_trait_exception.dart';
import 'package:ssdc_companion_api/helpers/login/session.helpers.dart';
import 'package:ssdc_companion_api/helpers/user/user.helpers.dart';
import 'package:ssdc_companion_api/helpers/user/user.trait-helpers.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/services/api_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class DebugRouter {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final session = request.context['session'] as LoginSession?;
      final isar = serviceCollection.get<Isar>();
      final details = {
        'currentSession': {
          'session': session?.toJson(),
          'user': session?.user.value?.toJson(),
        },
        'users': await isar.users.where().findAll(),
        'loginSessions': await isar.loginSessions.where().findAll(),
      };
      return Response.ok(json.encode(details), headers: {'Content-Type': 'application/json'});
    });

    router.get('/from-request', (Request request) async {
      return Response.ok(
          json.encode({
            'userFromRequest': await User_.fromRequest(request),
            'sessionFromRequest': await LoginSessionHelper.fromRequest(request)
          }),
          headers: {'Content-Type': 'application/json'});
    });

    router.get('/suspend-me', (Request request) async {
      final user = await User_.fromRequest(request);

      // Ban the user by adding a trait to it.
      await user.suspendUser();

      return Response(204);
    });

    router.get('/trait-test', (Request request) async {
      final user = await User_.fromRequest(request);
      bool unexpectedTraitExceptionThrown = false;
      bool missingTraitExceptionThrown = false;

      try {
        await user.assertMissingTraits([Trait.suspended]);
      } on UnexpectedTraitException {
        unexpectedTraitExceptionThrown = true;
      }

      try {
        await user.assertHasTraits([Trait.suspended]);
      } on MissingTraitException {
        missingTraitExceptionThrown = true;
      }

      return Response.ok('suspended: ${user.hasTrait(Trait.suspended)}, '
          'unexpectedTraitExceptionThrown: $unexpectedTraitExceptionThrown, '
          'missingTraitExceptionThrown: $missingTraitExceptionThrown');
    });

    return router;
  }
}
