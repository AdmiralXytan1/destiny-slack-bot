// Copyright (c) 2016 P.Y. Laligand

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;

/// Verifies that requests come from Slack and makes the content of these
/// requests more accessible to handlers.
class SlackMiddleware {
  static final log = new Logger('SlackMiddleware');

  static shelf.Middleware get(List<String> tokens) => (shelf.Handler handler) {
        return (shelf.Request request) async {
          final contentType = request.headers['content-type'];
          if (contentType != 'application/x-www-form-urlencoded') {
            log.warning('Invalid content type: $contentType');
            return new shelf.Response.notFound('Invalid content type');
          }
          final body = await request.readAsString();
          final params = Uri.splitQueryString(Uri.decodeFull(body));
          final requestToken = params['token'];
          if (!tokens.contains(requestToken)) {
            log.warning('Invalid token: $requestToken');
            return new shelf.Response.forbidden('Invalid token');
          }
          return handler(request.change(context: params));
        };
      };
}
