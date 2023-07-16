class Checkpoint {
  Checkpoint({
    this.title,
    this.modelName,
    this.hash,
    this.sha256,
    this.filename,
    this.config,
  });

  Checkpoint.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    modelName = json['model_name'] as String?;
    hash = json['hash'] as String?;
    sha256 = json['sha256'] as String?;
    filename = json['filename'] as String?;
    config = json['config'] as String?;
  }

  String? title;
  String? modelName;
  String? hash;
  String? sha256;
  String? filename;
  String? config;

  String get modelNameWithoutExt =>
      title!.replaceAll('.ckpt', '').replaceAll('.safetensors', '');

  String get modelNamePretty {
    var prettyName = modelNameWithoutExt.replaceAll('_', ' ');

    // matches strings like "v30", "V30", "v12" etc.
    final regExp = RegExp(r'v\d+', caseSensitive: false);

    final matches = regExp.allMatches(prettyName).toList();

    // If we found more than one version tag, remove all but the first.
    if (matches.length > 1) {
      for (var i = 1; i < matches.length; i++) {
        prettyName = prettyName.replaceFirst(matches[i].group(0)!, '');
      }
    }

    // matches strings like "v30", "V30", "v12" etc, and checks if they are attached to other words
    final regExpSpaces = RegExp(r'(\w+)(v\d+)', caseSensitive: false);

    // Separate version tags attached to other words with a space
    prettyName = prettyName.replaceAllMapped(
      regExpSpaces,
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Make sure all version tags are lowercase.
    return prettyName
        .replaceAllMapped(
          regExp,
          (match) => match.group(0)!.toLowerCase(),
        )
        .replaceAll('BakedVae', '')
        .replaceAll('Baked', '')
        .replaceAll('Pruned', '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['model_name'] = modelName;
    data['hash'] = hash;
    data['sha256'] = sha256;
    data['filename'] = filename;
    data['config'] = config;
    return data;
  }
}
