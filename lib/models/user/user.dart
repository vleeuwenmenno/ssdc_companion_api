import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user_trait.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: true)
  String? username;

  String? hashedPassword;
  String? salt;

  final traits = IsarLinks<UserTrait>();
  final loginSessions = IsarLinks<LoginSession>();

  dynamic toJsonAsync() async {
    return {
      'username': username,
      'traits': traits.toList(),
    };
  }

  dynamic toJson() {
    return {
      'id': id,
      'username': username,
      'traits': traits.toList(),
    };
  }
}
