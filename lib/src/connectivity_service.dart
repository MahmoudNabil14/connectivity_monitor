import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart'; // For debounce functionality

/// ConnectivityService provides a global way to monitor internet connectivity.
///
/// This service utilizes the `connectivity_plus` package to detect changes in
/// network connectivity and validates internet access by making HTTP requests.
class ConnectivityService {
  ConnectivityService._(); // Private constructor to enforce singleton behavior.

  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// A stream that emits connectivity status (`true` for connected, `false` for disconnected).
  static Stream<bool> get connectivityStream => _connectivityController.stream;

  static StreamSubscription<bool>? _connectivitySubscription;

  /// Ensures that the notifier is active only once.
  static bool _isNotifierActive = false;

  /// Starts a global connection notifier with optional toast messages.
  ///
  /// [connectedToastMessage] - Message displayed when connected.
  /// [disconnectedToastMessage] - Message displayed when disconnected.
  /// [testUrl] - URL used to validate internet access (default: `https://google.com`).
  /// [connectedBackgroundColor] - Background color for the connected toast.
  /// [disconnectedBackgroundColor] - Background color for the disconnected toast.
  /// [toastGravity] - Position of the toast on the screen.
  /// [toastFontSize] - Font size for the toast message.
  /// [showToasts] - Whether to show toast notifications (default: `true`).
  /// [debounceDuration] - Debounce duration for network change events.
  static void startConnectionNotifier({
    String connectedToastMessage = "You are now connected to the Internet.",
    String disconnectedToastMessage =
        "No internet connection. Please check your network.",
    String testUrl = 'https://google.com',
    Color connectedBackgroundColor = Colors.green,
    Color disconnectedBackgroundColor = Colors.red,
    String connectedWebBackgroundHexColor = "#4CAF50",
    String disconnectedWebBackgroundHexColor = "#F44336",
    ToastGravity toastGravity = ToastGravity.BOTTOM,
    double toastFontSize = 16.0,
    bool showToasts = true,
    Duration debounceDuration = const Duration(milliseconds: 500),
    Function? onConnected,
    Function? onDisconnected,
  }) {
    if (_isNotifierActive) {
      debugPrint("ConnectivityService notifier is already running.");
      return;
    }

    _isNotifierActive = true;
    bool isFirstRun = true;

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .debounceTime(debounceDuration) // Apply debounce
        .asyncMap((List<ConnectivityResult> results) async {
      final lastResult =
          results.isNotEmpty ? results.last : ConnectivityResult.none;

      return lastResult != ConnectivityResult.none
          ? await validateInternetConnection(testUrl: testUrl)
          : false;
    }).listen((bool hasInternet) {
      final String message =
          hasInternet ? connectedToastMessage : disconnectedToastMessage;
      final Color backgroundColor =
          hasInternet ? connectedBackgroundColor : disconnectedBackgroundColor;

      final String webBackgroundColor = hasInternet
          ? connectedWebBackgroundHexColor
          : disconnectedWebBackgroundHexColor;

      if (!isFirstRun) {
        if (hasInternet) {
          onConnected?.call();
        } else {
          onDisconnected?.call();
        }
      }

      if (!isFirstRun || !hasInternet) {
        if (showToasts) {
          _showToast(
            message: message,
            backgroundColor: backgroundColor,
            webBackgroundColor: webBackgroundColor,
            gravity: toastGravity,
            fontSize: toastFontSize,
          );
        }

        // Broadcast connectivity status
        _connectivityController.add(hasInternet);
      }

      isFirstRun = false;
    });
  }

  /// Validates internet connectivity by making an HTTP request.
  ///
  /// [testUrl] - URL to ping for validation (default: `https://google.com`).
  /// [retries] - Number of retry attempts if the request fails.
  /// [retryDelay] - Delay between retries.
  static Future<bool> validateInternetConnection({
    String testUrl = 'https://google.com',
    int retries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.get(Uri.parse(testUrl)).timeout(
              const Duration(seconds: 5),
              onTimeout: () => http.Response('', 408),
            );
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        debugPrint("Retry ${i + 1}: Internet validation error: $e");
        if (i < retries - 1) await Future.delayed(retryDelay);
      }
    }
    return false; // All retries failed
  }

  /// Stops the connection notifier and cleans up resources.
  ///
  /// Should be called when the notifier is no longer needed.
  static void stopNotifier() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isNotifierActive = false;

    _connectivityController.close();
  }

  /// Displays a toast notification.
  static void _showToast({
    required String message,
    required Color backgroundColor,
    required String webBackgroundColor,
    ToastGravity gravity = ToastGravity.BOTTOM,
    WebToastPosition webPosition = WebToastPosition.center,
    double fontSize = 16.0,
  }) {
    if (!kIsWeb) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
        fontSize: fontSize,
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        webPosition: webPosition,
        gravity: gravity,
        webBgColor: webBackgroundColor,
        timeInSecForIosWeb: 3,
        textColor: Colors.white,
        fontSize: fontSize,
      );
    }
  }
}

enum WebToastPosition { left, right, center }
