import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:ssdc_companion_api/middleware/authentication.dart';
import 'package:ssdc_companion_api/middleware/bad_request_handler.dart';
import 'package:ssdc_companion_api/middleware/logger.dart';
import 'package:ssdc_companion_api/middleware/route_not_found_handler.dart';
import 'package:ssdc_companion_api/routes/debug_router.dart';
import 'package:ssdc_companion_api/routes/root_router.dart';
import 'package:ssdc_companion_api/routes/stable_diffusion_router.dart';
import 'package:ssdc_companion_api/routes/user_management_router.dart';
import 'package:ssdc_companion_api/routes/user_router.dart';
import 'package:ssdc_companion_api/services/service_collection.dart';

final serviceCollection = ServiceCollection();

class ApiService {
  Future startApi() async {
    final app = Router();
    final pipeline = Pipeline()
        .addMiddleware(routeNotFoundHandler())
        .addMiddleware(badRequestHandler())
        .addMiddleware(loggingHandler())
        .addHandler(app.call);

    final dotEnv = serviceCollection.get<DotEnv>();

    app.mount('/user/', UserRouter().router);
    app.mount('/user/manage', await authenticatedRouter(UserManagementRouter().router));
    app.mount('/sdapi/v1', await authenticatedRouter(StableDiffusionRouter().router));

    if (dotEnv['DEBUG'] != 'FALSE') {
      app.mount('/debug/', await authenticatedRouter(DebugRouter().router));
      app.mount('/debug-noauth/', DebugRouter().router);
    }

    app.mount('/', RootRouter().router);

    final server = await io.serve(pipeline, dotEnv['HTTP_HOST']!, int.parse(dotEnv['HTTP_PORT']!));

    // Enable gzip:
    server.autoCompress = true;
  }

  authenticatedRouter(Router router,
          {List<Trait> requiredTraits = const [], List<Trait> requiredMissingTraits = const [Trait.suspended]}) async =>
      Pipeline()
          .addMiddleware(
              await authenticateMiddleware(requiredTraits: requiredTraits, requiredMissingTraits: requiredMissingTraits))
          .addHandler(router);
}

class AuthenticatedUsersRouter {}
