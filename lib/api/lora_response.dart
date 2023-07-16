class Lora {
  Lora({this.name, this.alias, this.path});

  Lora.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    alias = json['alias'] as String?;
    path = json['path'] as String?;
  }

  String get tag => '<lora:$name:1>';

  String? name;
  String? alias;
  String? path;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['alias'] = alias;
    data['path'] = path;
    return data;
  }
}

class LyCORIS {
  LyCORIS({this.name, this.path});

  LyCORIS.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    path = json['path'] as String?;
  }

  String get tag => '<lyco:$name:1>';

  String? name;
  String? path;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['path'] = path;
    return data;
  }
}
