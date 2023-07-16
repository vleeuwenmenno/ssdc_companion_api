import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

@immutable
class LoginResponse {
  const LoginResponse({
    this.userAgent,
    this.ipAddress,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.refreshExpiresAt,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> data) => LoginResponse(
        userAgent: data['userAgent'] as String?,
        ipAddress: data['ipAddress'] as String?,
        token: data['token'] as String?,
        refreshToken: data['refreshToken'] as String?,
        expiresAt: data['expiresAt'] == null ? null : DateTime.parse(data['expiresAt'] as String),
        refreshExpiresAt: data['refreshExpiresAt'] == null ? null : DateTime.parse(data['refreshExpiresAt'] as String),
      );

  /// Parses the string and returns the resulting Json object as [LoginResponse].
  factory LoginResponse.fromJson(String data) {
    return LoginResponse.fromMap(json.decode(data) as Map<String, dynamic>);
  }
  final String? userAgent;
  final String? ipAddress;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? refreshExpiresAt;

  @override
  String toString() {
    return 'LoginResponse(userAgent: $userAgent, ipAddress: $ipAddress, token: $token, refreshToken: $refreshToken, expiresAt: $expiresAt, refreshExpiresAt: $refreshExpiresAt)';
  }

  Map<String, dynamic> toMap() => {
        'userAgent': userAgent,
        'ipAddress': ipAddress,
        'token': token,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'refreshExpiresAt': refreshExpiresAt?.toIso8601String(),
      };

  /// Converts [LoginResponse] to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! LoginResponse) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode =>
      userAgent.hashCode ^
      ipAddress.hashCode ^
      token.hashCode ^
      refreshToken.hashCode ^
      expiresAt.hashCode ^
      refreshExpiresAt.hashCode;
}
