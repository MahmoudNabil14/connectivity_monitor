import 'dart:async';
import 'package:connectivity_monitor/src/connectivity_service.dart';
import 'package:flutter/material.dart';

/// ConnectivityMonitor is a widget that adapts its UI based on network status.
///
/// This widget listens to network changes via `ConnectivityService`
/// and provides customizable options for disconnected states.
class ConnectivityMonitor extends StatefulWidget {
  final Widget child; // The main widget to display when connected.
  final Widget?
      customDisconnectedWidget; // Custom widget for disconnected state.
  final bool
      requiresConnection; // Whether a connection is required to display the child.
  final bool
      useDialogAsConnectivityIndicator; // Use a dialog for connectivity indicator.
  final bool
      useWidgetAsConnectivityIndicator; // Use a custom widget for connectivity indicator.
  final Function? onDisconnected; // Callback when disconnected.
  final Function? onConnected; // Callback when connected.
  final Widget? customDialog; // Custom dialog for disconnected state.
  final Widget? connectivityLoadingWidget; // Custom widget for loading state.

  const ConnectivityMonitor({
    super.key,
    required this.child,
    this.requiresConnection = true,
    this.useDialogAsConnectivityIndicator = true,
    this.useWidgetAsConnectivityIndicator = false,
    this.customDisconnectedWidget,
    this.onConnected,
    this.onDisconnected,
    this.customDialog,
     this.connectivityLoadingWidget,
  });

  @override
  State<ConnectivityMonitor> createState() => _ConnectivityMonitorState();
}

class _ConnectivityMonitorState extends State<ConnectivityMonitor> {
  late StreamSubscription<bool> _connectivitySubscription;
  bool? _isConnected;
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _initializeConnectivity() {
    if (widget.requiresConnection) {
      _connectivitySubscription = ConnectivityService.connectivityStream.listen(
        (bool isConnected) {
          if (isConnected) {
            _handleWhenConnected();
          } else {
            _handleWhenDisconnected();
          }
        },
      );
    }
  }

  void _handleWhenConnected() {
    if (_isDialogVisible) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    setState(() {
      _isConnected = true;
      _isDialogVisible = false;
    });
    widget.onConnected?.call();
  }

  void _handleWhenDisconnected() {
    setState(() {
      _isConnected = false;
    });

    widget.onDisconnected?.call();

    if (widget.useDialogAsConnectivityIndicator && widget.requiresConnection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDisconnectedDialog();
      });
    }
  }

  void _showDisconnectedDialog() {
    if (_isDialogVisible) return;

    _isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: widget.customDialog ??
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28.0,
                  ),
                  const SizedBox(width: 10.0),
                  const Text(
                    "Connection Lost",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              content: const Text(
                "You are currently offline. Please check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDisconnectedWidget() {
    return widget.customDisconnectedWidget ??
        Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 100.0,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "No Internet Connection",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "It seems you're offline. Please check your connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected == null) {
      return widget.connectivityLoadingWidget??widget.child;
    }
    if (widget.requiresConnection &&
        !_isConnected! &&
        widget.useWidgetAsConnectivityIndicator) {
      return _buildDisconnectedWidget();
    }
    return widget.child;
  }
}
