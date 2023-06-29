import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ssdc_companion_api/utilities/request_utils.dart';
import 'package:shelf/shelf.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({required String? username, required String? password}) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  static Future<LoginRequest> fromRequest(Request request) async => RequestUtils.bodyFromRequest<LoginRequest>(request);
}
