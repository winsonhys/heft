import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart' as io;

/// Native platform HTTP client (iOS, Android, macOS, Windows, Linux)
HttpClient createHttpClient() => io.createHttpClient();
