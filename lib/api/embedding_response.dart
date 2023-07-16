class Embedding {
  Embedding({
    required this.name,
    this.step,
    this.sdCheckpoint,
    this.sdCheckpointName,
    this.shape,
    this.vectors,
  });

  factory Embedding.fromJson(String name, Map<String, dynamic> json) {
    return Embedding(
      name: name,
      step: json['step'] as int?,
      sdCheckpoint: json['sd_checkpoint'] as String?,
      sdCheckpointName: json['sd_checkpoint_name'] as String?,
      shape: json['shape'] as int?,
      vectors: json['vectors'] as int?,
    );
  }

  final String name;
  final int? step;
  final String? sdCheckpoint;
  final String? sdCheckpointName;
  final int? shape;
  final int? vectors;
}

class EmbeddingRequestResponse {
  EmbeddingRequestResponse({
    required this.loaded,
    required this.skipped,
  });

  factory EmbeddingRequestResponse.fromJson(Map<String, dynamic> json) {
    final loadedJson = json['loaded'] as Map<String, dynamic>;
    final loadedList = loadedJson.entries
        .map(
          (entry) => Embedding.fromJson(
            entry.key,
            entry.value as Map<String, dynamic>,
          ),
        )
        .toList();

    final skippedJson = json['skipped'] as Map<String, dynamic>;

    return EmbeddingRequestResponse(
      loaded: loadedList,
      skipped: skippedJson,
    );
  }

  final List<Embedding> loaded;
  final Map<String, dynamic> skipped;
}
