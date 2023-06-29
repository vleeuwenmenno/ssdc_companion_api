import 'dart:convert';

import 'package:ssdc_companion_api/routes/models/login_request.dart';
import 'package:ssdc_companion_api/routes/models/register_request.dart';
import 'package:shelf/shelf.dart';

class RequestUtils {
  static Future<T> bodyFromRequest<T>(Request request) async {
    final content = await request.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    final body = getBodyFromJson<T>(json);
    return body;
  }

  static T getBodyFromJson<T>(Map<String, dynamic> json) {
    if (T == LoginRequest) {
      return LoginRequest.fromJson(json) as T;
    } else if (T == RegisterRequest) {
      return RegisterRequest.fromJson(json) as T;
    } else {
      throw Exception(
          'Invalid type parameter for fromRequest, must be $T but no such type exists in the function');
    }
  }
}
