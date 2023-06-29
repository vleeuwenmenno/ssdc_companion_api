import 'dart:convert';

import 'package:darq/darq.dart';
import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/helpers/login/session.helpers.dart';
import 'package:ssdc_companion_api/helpers/user/user.helpers.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/models/user/user_trait.dart';
import 'package:ssdc_companion_api/models/user/user_viewed_by.dart';
import 'package:ssdc_companion_api/services/api_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserManagementRouter {
  Router get router {
    final router = Router();

    router.get('/logout', (Request request) async {
      final session = await LoginSessionHelper.fromRequest(request);

      // Remove session from database
      final isar = serviceCollection.get<Isar>();
      await isar.writeTxn(() => isar.loginSessions.delete(session.id));

      return Response(200);
    });

    router.get('/logout-all', (Request request) async {
      final session = await LoginSessionHelper.fromRequest(request);

      // Remove session from database
      final isar = serviceCollection.get<Isar>();

      // Get all sessions for user
      final sessions = session.user.value?.loginSessions.toList();
      sessions?.forEach((element) async {
        await isar.writeTxn(() => isar.loginSessions.delete(element.id));
      });

      return Response(200);
    });

    router.get('/sessions', (Request request) async {
      final user = await User_.fromRequest(request);
      final sessions = user.loginSessions
          .map((s) => {'ipAddress': s.ipAddress, 'userAgent': s.userAgent, 'expiresAt': s.expiresAt!.toIso8601String()});
      return Response(200, body: json.encode(sessions.toList()), headers: {'Content-Type': 'application/json'});
    });

    router.get('/traits', (Request request) async {
      final user = await User_.fromRequest(request);
      return Response(200, body: json.encode(user.traits.toList()), headers: {'Content-Type': 'application/json'});
    });

    router.delete('/delete', (Request request) async {
      final isar = serviceCollection.get<Isar>();
      final user = await User_.fromRequest(request);

      // Delete all users trait links
      user.traits.toList().forEach((element) async {
        await isar.writeTxn(() => isar.userTraits.delete(element.id));
      });

      //Delete all user sessions
      user.loginSessions.toList().forEach((element) async {
        await isar.writeTxn(() => isar.loginSessions.delete(element.id));
      });

      // Delete all user views
      final views = await isar.userViews.filter().subject((q) => q.idEqualTo(user.id)).findAll();
      await isar.writeTxn(() => isar.userViews.deleteAll(views.select((e, index) => e.id).toList()));

      await isar.writeTxn(() => isar.users.delete(user.id));
      return Response(204);
    });

    return router;
  }
}
