import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class FirebaseLogger {
  static const String _name = 'FirebaseLogger';

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        '🔵 INFO: $message',
        name: _name,
        error: error,
        stackTrace: stackTrace,
        level: 800, // INFO
      );
    }
  }

  static void request(String operation, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      developer.log(
        '🔄 REQ [$operation] ${data != null ? '- Data: $data' : ''}',
        name: _name,
        level: 800,
      );
    }
  }

  static void response(String operation, [Object? result]) {
    if (kDebugMode) {
      developer.log(
        '✅ RES [$operation] ${result != null ? '- Result: $result' : ''}',
        name: _name,
        level: 800,
      );
    }
  }

  static void error(String operation, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '❌ ERR [$operation]',
        name: _name,
        error: error,
        stackTrace: stackTrace,
        level: 1000, // SEVERE
      );
    }
  }

  static void auth(String event, {String? userId, String? email}) {
    if (kDebugMode) {
      developer.log(
        '🔐 AUTH [$event] ${userId != null ? 'UID: $userId ' : ''}${email != null ? 'Email: $email' : ''}',
        name: _name,
        level: 800,
      );
    }
  }
}
