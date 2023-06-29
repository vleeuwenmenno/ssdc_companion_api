import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:isar/isar.dart';
import 'package:shelf/shelf.dart';
import 'package:ssdc_companion_api/exceptions/password_validation_exception.dart';
import 'package:ssdc_companion_api/exceptions/username_taken_exception.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/routes/models/register_request.dart';
import 'package:ssdc_companion_api/services/api_service.dart';

// ignore: camel_case_types
class User_ {
  static Future<User> fromRequest(Request request) async {
    final session = request.context['session'] as LoginSession;

    if (session.user.value == null) {
      throw Exception('User not found in session!');
    }

    return session.user.value!;
  }

  static Future fromRegisterRequest(RegisterRequest body) async {
    final isar = serviceCollection.get<Isar>();

    // Check if the username is taken.
    final user2 = await isar.users.where().usernameEqualTo(body.username).findFirst();
    if (user2 != null) {
      throw UsernameTakenException(json.encode({'error': 'username-in-use'}));
    }

    // Check if password is long enough and has at least a digit and a letter
    if (body.password.length < 8 || !body.password.contains(RegExp('[0-9]')) || !body.password.contains(RegExp('[a-zA-Z]'))) {
      throw PasswordValidationException(
        json.encode({
          'error': 'password-invalid',
          'message': 'Password must be at least 8 characters long and contain at least a digit and a letter.'
        }),
      );
    }

    await _createFromRegisterRequest(body);
  }

  static Future<User> _createFromRegisterRequest(RegisterRequest body) async {
    final isar = serviceCollection.get<Isar>();
    final hashedPassword = Crypt.sha256(body.password);
    final user = User()
      ..username = body.username
      ..hashedPassword = hashedPassword.hash
      ..salt = hashedPassword.salt;

    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
    return user;
  }
}
