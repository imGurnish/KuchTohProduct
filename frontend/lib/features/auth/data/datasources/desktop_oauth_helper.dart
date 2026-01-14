import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Desktop OAuth Helper
///
/// Handles Google OAuth for desktop platforms (Windows, Linux, macOS)
/// by running a local HTTP server to capture the OAuth callback.
class DesktopOAuthHelper {
  static const int _callbackPort = 8585;
  static const String _callbackPath = '/auth/callback';

  final SupabaseClient _supabaseClient;
  HttpServer? _server;

  DesktopOAuthHelper({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Sign in with Google on desktop platforms
  Future<AuthResponse> signInWithGoogle() async {
    final completer = Completer<AuthResponse>();

    try {
      // Start local server to receive callback
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _callbackPort,
      );

      // Build the OAuth URL using Supabase's PKCE-enabled method
      final redirectUri = 'http://localhost:$_callbackPort$_callbackPath';

      // Get OAuth URL from Supabase - this handles PKCE internally
      final oauthResponse = await _supabaseClient.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: redirectUri,
      );

      final oauthUrl = Uri.parse(oauthResponse.url);

      // Open browser for OAuth
      if (await canLaunchUrl(oauthUrl)) {
        await launchUrl(oauthUrl, mode: LaunchMode.externalApplication);
      } else {
        await _stopServer();
        throw Exception('Could not launch browser for OAuth');
      }

      // Listen for callback
      _server!.listen((request) async {
        final uri = request.requestedUri;

        if (uri.path == _callbackPath) {
          // Get parameters
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];
          final errorDescription = uri.queryParameters['error_description'];

          // Send response to browser first
          final html = _getSuccessHtml(error != null);
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.set(
            'Content-Type',
            'text/html; charset=utf-8',
          );
          request.response.headers.set(
            'Content-Length',
            html.length.toString(),
          );
          request.response.write(html);
          await request.response.close();

          // Stop server
          await _stopServer();

          if (error != null) {
            if (!completer.isCompleted) {
              completer.completeError(AuthException(errorDescription ?? error));
            }
            return;
          }

          if (code != null) {
            try {
              // Exchange code for session using Supabase's internal PKCE verifier
              await _supabaseClient.auth.exchangeCodeForSession(code);
              // Get session after exchange
              final user = _supabaseClient.auth.currentUser;
              final session = _supabaseClient.auth.currentSession;
              if (user != null && !completer.isCompleted) {
                completer.complete(AuthResponse(session: session, user: user));
              } else if (!completer.isCompleted) {
                completer.completeError(
                  AuthException('Failed to get user after auth'),
                );
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.completeError(e);
              }
            }
          } else if (!completer.isCompleted) {
            completer.completeError(
              AuthException('No authorization code received'),
            );
          }
        }
      });
    } catch (e) {
      await _stopServer();
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  Future<void> _stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  String _getSuccessHtml(bool isError) {
    if (isError) {
      return '''
<!DOCTYPE html>
<html>
<head>
  <title>Sign In Failed</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #ff6b6b 0%, #ee5a5a 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 40px;
      background: rgba(255,255,255,0.1);
      border-radius: 20px;
      backdrop-filter: blur(10px);
    }
    h1 { margin-bottom: 10px; }
    p { opacity: 0.9; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Sign In Failed</h1>
    <p>Please close this window and try again.</p>
  </div>
</body>
</html>
''';
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Sign In Successful</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 40px;
      background: rgba(255,255,255,0.1);
      border-radius: 20px;
      backdrop-filter: blur(10px);
    }
    h1 { margin-bottom: 10px; }
    p { opacity: 0.9; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Sign In Successful!</h1>
    <p>You can close this window and return to the app.</p>
  </div>
  <script>setTimeout(() => window.close(), 2000);</script>
</body>
</html>
''';
  }
}
