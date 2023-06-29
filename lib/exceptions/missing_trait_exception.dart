import 'package:shelf/shelf.dart';
import 'package:ssdc_companion_api/enums/trait.dart';

class MissingTraitException {
  MissingTraitException(this.trait) {
    response = Response(403, body: 'missing-${trait.toString().toLowerCase()}');
  }
  final Trait trait;
  late final Response response;
}
