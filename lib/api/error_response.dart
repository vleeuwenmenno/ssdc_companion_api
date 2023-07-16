class ErrorResponse {
  ErrorResponse({this.error, this.errors, this.detail});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'] as String;
    errors = json['errors'] as String;
    detail = json['detail'] as String;
  }
  String? error;
  String? errors;
  String? detail;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['error'] = error;
    data['errors'] = errors;
    data['detail'] = detail;
    return data;
  }
}
