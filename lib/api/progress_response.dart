class ProgressResponse {
  ProgressResponse({
    this.progress,
    this.etaRelative,
  });

  ProgressResponse.fromJson(Map<String, dynamic> json) {
    progress = json['progress'] as double?;
    etaRelative = json['eta_relative'] as double?;
  }

  double? progress;
  double? etaRelative;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['progress'] = progress;
    data['eta_relative'] = etaRelative;
    return data;
  }
}
