import 'dart:io';

import 'package:crypt/crypt.dart';
import 'package:isar/isar.dart';
import 'package:shelf/shelf.dart';
import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:ssdc_companion_api/exceptions/user_suspended_exception.dart';
import 'package:ssdc_companion_api/helpers/user/user.trait-helpers.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/routes/models/login_request.dart';
import 'package:ssdc_companion_api/services/api_service.dart';
import 'package:ssdc_companion_api/utilities/utilities.dart';

extension LoginSessionEx on LoginSession {}

class LoginSessionHelper {
  static Future<LoginSession> fromRequest(Request request) async {
    return request.context['session'] as LoginSession;
  }

  static Future<LoginSession?> fromLoginRequest(Request request) async {
    final loginRequest = await LoginRequest.fromRequest(request);
    final isar = serviceCollection.get<Isar>();
    final user = await isar.users.where().usernameEqualTo(loginRequest.username).findFirst();

    if (user == null) {
      return null;
    }

    final crypt = Crypt.sha256(loginRequest.password!, salt: user.salt);

    if (crypt.hash != user.hashedPassword) {
      return null;
    }

    if (user.hasTrait(Trait.suspended)) {
      throw UserSuspendedException();
    }

    final session = await LoginSessionHelper.fromUser(user, request);
    return session;
  }

  static Future<LoginSession> fromUser(User user, Request? request) async {
    final ipAddress = ((request?.context['shelf.io.connection_info'] as HttpConnectionInfo).remoteAddress.address);
    final userAgent = (request?.headers['user-agent'] ?? request?.headers['User-Agent']) ?? 'Unknown';
    final session = LoginSession()
      ..userAgent = userAgent
      ..ipAddress = ipAddress
      ..token = Utilities.generateRandomString(128)
      ..refreshToken = Utilities.generateRandomString(128)
      ..expiresAt = DateTime.now().add(Duration(hours: 1))
      ..refreshExpiresAt = DateTime.now().add(Duration(days: 30))
      ..user.value = user;

    user.loginSessions.add(session);
    session.user.value = user;

    // Insert into database
    final isar = serviceCollection.get<Isar>();
    await isar.writeTxn(() async {
      await isar.loginSessions.put(session);
      await user.loginSessions.save();
    });

    return session;
  }
}
