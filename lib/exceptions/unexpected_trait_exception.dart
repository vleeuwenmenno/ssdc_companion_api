import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:shelf/shelf.dart';

class UnexpectedTraitException {
  final Trait trait;
  late final Response response;

  UnexpectedTraitException(this.trait) {
    response =
        Response(403, body: 'unexpected-${trait.toString().toLowerCase()}');
  }
}
