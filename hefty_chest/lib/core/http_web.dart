import 'package:connectrpc/connect.dart';
import 'package:connectrpc/web.dart' as web;

/// Web platform HTTP client (uses browser fetch API)
HttpClient createHttpClient() => web.createHttpClient();
