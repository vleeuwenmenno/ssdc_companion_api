import 'dart:convert';

class Sampler {
  Sampler({this.name, this.aliases, this.options});

  Sampler.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    aliases = (json['aliases'] as List).cast<String>();
    options = json['options'] != null
        ? Options.fromJson(json['options'] as Map<String, dynamic>)
        : null;
  }
  String? name;
  List<String>? aliases;
  Options? options;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['aliases'] = aliases;
    if (options != null) {
      data['options'] = options!.toJson();
    }
    return data;
  }
}

class Options {
  Options({this.usesEnsd});

  Options.fromJson(Map<String, dynamic> json) {
    usesEnsd = jsonEncode(json['uses_ensd']);
  }
  String? usesEnsd;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uses_ensd'] = usesEnsd;
    return data;
  }
}
