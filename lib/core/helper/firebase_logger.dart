import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// A centralized logging utility for Firebase operations.
///
/// This class formats logs with ANSI colors and emojis to make debugging easier in the console.
/// Note: Logs are only emitted when the application is running in [kDebugMode] to avoid spamming
/// or leaking data in production builds.
class FirebaseLogger {
  static const String _name = 'FB_Log';

  // ─── ANSI Color Codes ───────────────────────────────────────────────────
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  static String _prettyPrint(Object? object) {
    if (object == null) return 'null';
    if (object is Map || object is Iterable) {
      try {
        final encoder = JsonEncoder.withIndent('  ', (item) => item.toString());
        return '\n${encoder.convert(object)}';
      } catch (_) {
        return object.toString();
      }
    }
    return object.toString();
  }

  /// Logs general informational messages.
  ///
  /// Use this for non-critical lifecycle events or state changes.
  /// Output is colorized in cyan (🔵).
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        '$_cyan🔵 INFO: $message$_reset',
        name: _name,
        error: error,
        stackTrace: stackTrace,
        level: 800, // INFO
      );
    }
  }

  /// Logs an outbound request or the start of an operation.
  ///
  /// Provide the [operation] name and an optional map of [data] being sent or processed.
  /// Output is colorized in yellow (🔄).
  static void request(String operation, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final dataStr = data != null
          ? '- Data: ${_prettyPrint(data).replaceAll('\n', '\n$_yellow')}'
          : '';
      developer.log('$_yellow🔄 REQ [$operation] $dataStr$_reset', name: _name, level: 800);
    }
  }

  /// Logs a successful response or the completion of an operation.
  ///
  /// Provide the [operation] name and an optional [result] payload.
  /// Output is colorized in green (✅).
  static void response(String operation, [Object? result]) {
    if (kDebugMode) {
      final resultStr = result != null
          ? '- Result: ${_prettyPrint(result).replaceAll('\n', '\n$_green')}'
          : '';
      developer.log('$_green✅ RES [$operation] $resultStr$_reset', name: _name, level: 800);
    }
  }

  /// Logs caught exceptions and errors.
  ///
  /// Provide the [operation] that failed, along with the [error] object and optional [stackTrace].
  /// Output is colorized in red (❌) and uses severe log level.
  static void error(String operation, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '$_red❌ ERR [$operation]$_reset',
        name: _name,
        error: error,
        stackTrace: stackTrace,
        level: 1000, // SEVERE
      );
    }
  }

  /// Logs authentication-specific events.
  ///
  /// Use this for sign-in, sign-out, or token events with optional [userId] and [email].
  /// Output is colorized in magenta (🔐).
  static void auth(String event, {String? userId, String? email}) {
    if (kDebugMode) {
      developer.log(
        '$_magenta🔐 AUTH [$event] ${userId != null ? 'UID: $userId ' : ''}${email != null ? 'Email: $email' : ''}$_reset',
        name: _name,
        level: 800,
      );
    }
  }
}
