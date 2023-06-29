import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ssdc_companion_api/utilities/request_utils.dart';
import 'package:shelf/shelf.dart';

part 'register_request.freezed.dart';
part 'register_request.g.dart';

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String password,
    required String username,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  static Future<RegisterRequest> fromRequest(Request request) async => RequestUtils.bodyFromRequest<RegisterRequest>(request);
}
