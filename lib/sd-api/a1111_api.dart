class A1111Api {
  A1111Api(this._host);

  final String _host;

  String getHost() => _host;

  Uri getApiUrl([String path = '']) => Uri.parse('$_host$path');

  Map<String, String> getHeaders({bool post = true}) {
    final headers = <String, String>{};
    if (post) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.error, this.detail);
  final String? message;
  final String? error;
  final String? detail;

  String get prettyError {
    switch (error) {
      case 'OutOfMemoryError':
        return 'Out of memory';
      default:
        return '${error ?? 'Unknown'} - ${detail ?? 'Unknown detail'}';
    }
  }
}

class ApiOutOfMemoryException extends ApiException {
  ApiOutOfMemoryException(super.message, super.error, super.detail);
}
