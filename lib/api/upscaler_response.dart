class Upscaler {
  Upscaler({
    this.name,
    this.modelName,
    this.modelPath,
    this.modelUrl,
    this.scale,
  });

  Upscaler.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    modelName = json['model_name'] as String?;
    modelPath = json['model_path'] as String?;
    modelUrl = json['model_url'] as String?;
    scale = json['scale'] as double?;
  }

  String? name;
  String? modelName;
  String? modelPath;
  String? modelUrl;
  double? scale;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['model_name'] = modelName;
    data['model_path'] = modelPath;
    data['model_url'] = modelUrl;
    data['scale'] = scale;
    return data;
  }
}
