import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/models/user/user.dart';

part 'user_viewed_by.g.dart';

@collection
class UserViews {
  Id id = Isar.autoIncrement;

  DateTime? dateTime;

  final subject = IsarLink<User>();
  final viewedBy = IsarLink<User>();
}
