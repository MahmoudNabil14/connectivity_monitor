# Connectivity Monitor

`connectivity_monitor` is a Flutter package that simplifies network connectivity handling in your apps. It provides a robust service (`ConnectivityService`) and a flexible widget (`ConnectivityMonitor`) to help you manage connectivity changes seamlessly and enhance user experience.

---

## Features

*   **Global Connectivity Monitoring**: Automatically tracks network changes and validates active internet access.
*   **Customizable Connectivity Indicator**: Display dialogs, custom widgets, or toast notifications to inform users of connectivity changes.
*   **Debouncing Events**: Reduces excessive updates by applying debounce logic to connectivity events.
*   **Callbacks for Connectivity Events**: Easily handle `onConnected` and `onDisconnected` events with custom logic.
*   **Cross-Platform Support**: Works flawlessly on Android, iOS.
*   **Customizable Options**: Tailor toast messages, colors, and widgets to match your app's theme and design.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  connectivity_monitor: ^1.0.5
```

Then run:
```bash
flutter pub get
```
---

## Important Note

To use the `ConnectivityMonitor` widget effectively, the `ConnectivityService.startConnectionNotifier` must be called first to initialize the global connectivity listener. This ensures that the connectivity events are properly monitored and can be utilized by the `ConnectivityMonitor` widget or any custom logic you implement.

You can use `ConnectivityMonitor` to adapt your UI based on connectivity changes or choose not to use it and rely solely on the `ConnectivityService` for monitoring and callbacks.

## Usage

### 1. Start Global Monitoring with `ConnectivityService`

Start monitoring network connectivity in your app's `main` function:

**Note:** Ensure that `WidgetsFlutterBinding.ensureInitialized();` is called before starting the connectivity service.

```dart
import 'package:flutter/material.dart';
import 'package:connectivity_monitor/connectivity_monitor.dart';

void main() {
  // Ensure bindings are initialized before starting the connectivity service
  WidgetsFlutterBinding.ensureInitialized();

  // Start monitoring network connectivity globally
  ConnectivityService.startConnectionNotifier(
    connectedToastMessage: "Connected!",
    disconnectedToastMessage: "No Internet Connection.",
    showToasts: true, // Show toast notifications for connectivity changes
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Monitor Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connectivity Monitor Example')),
      body: Center(child: Text('Home Screen')),
    );
  }
}
```

### 2. Use `ConnectivityMonitor` Widget

Wrap your app's widgets or pages with the `ConnectivityMonitor` widget to display custom UI or messages when the user is offline:

```dart
import 'package:flutter/material.dart';
import 'package:connectivity_monitor/connectivity_monitor.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Monitor Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConnectivityMonitor(
        child: HomeScreen(),
        customDisconnectedWidget: Center(
          child: Text(
            'No Internet Connection. Please reconnect.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
        customDialog: AlertDialog(
          title: Text('No Internet'),
          content: Text('Please check your connection and try again.'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connectivity Monitor Example')),
      body: Center(child: Text('Home Screen')),
    );
  }
}
```

#### Connectivity Monitor Widget

*   `child` (required): The main widget to display when connected.
*   `customDisconnectedWidget`: Custom widget to display when the device is disconnected. (default: `null`)
*   `requiresConnection`: If true, ensures that the `child` widget is displayed only when the device is connected to the internet. (default: `true`)
*   `useDialogAsConnectivityIndicator`: Whether to show a dialog as the connectivity indicator. (default: `true`)
*   `useWidgetAsConnectivityIndicator`: Whether to use a custom widget for the connectivity indicator. (default: `false`)
*   `customDialog`: Custom dialog widget for the disconnected state. (default: `null`)

---

## How to Work with ConnectivityService

### Connectivity Service Options

*   `startConnectionNotifier`: Initializes global connectivity monitoring, validating internet access and broadcasting changes.
*   `stopNotifier`: Stops global connectivity monitoring and cleans up resources.
*   `validateInternetConnection`: Checks if the device has access to the internet by pinging a specified URL (default: `https://google.com`).
---

### ConnectivityService Methods Explained

#### **`startConnectionNotifier()`**

The `startConnectionNotifier` method initializes global connectivity monitoring and listens for internet connection changes. It also provides options for displaying toast notifications, handling connection events, and debouncing network change events. This method must be called **before** using the `ConnectivityMonitor` widget to ensure connectivity updates are available.

**Features:**

1. Monitors network connectivity changes using `connectivity_plus`.
2. Validates actual internet access by pinging a reliable URL.
3. Triggers callbacks for `onConnected` and `onDisconnected` events.
4. Displays customizable toast notifications for connection status.
5. Debounces rapid network change events to prevent excessive updates.

**Parameters:**

- **`connectedToastMessage`** *(String, default: "You are now connected to the Internet.")*:  
  The message displayed when the device is connected to the internet.

- **`disconnectedToastMessage`** *(String, default: "No internet connection. Please check your network.")*:  
  The message displayed when the device is disconnected from the internet.

- **`testUrl`** *(String, default: "https://google.com")*:  
  The URL used to validate actual internet access.

- **`connectedToastBackgroundColor`** *(Color, default: `Colors.green`)*:  
  The background color of the toast message when connected.

- **`disconnectedToastBackgroundColor`** *(Color, default: `Colors.red`)*:  
  The background color of the toast message when disconnected.

- **`connectedWebToastBackgroundHexColor`** *(String, default: `"#4CAF50"`)*:  
  The background color (in hex) for web toasts when connected.

- **`disconnectedWebToastBackgroundHexColor`** *(String, default: `"#F44336"`)*:  
  The background color (in hex) for web toasts when disconnected.

- **`toastGravity`** *(ToastGravity, default: `ToastGravity.BOTTOM`)*:  
  The position of the toast on the screen.

- **`toastFontSize`** *(double, default: `16.0`)*:  
  The font size of the toast message.

- **`showToasts`** *(bool, default: `true`)*:  
  Whether to show toast notifications for connectivity changes.

- **`debounceDuration`** *(Duration, default: `Duration(milliseconds: 500)`)*:  
  The debounce duration for connectivity change events.

- **`onConnected`** *(Function, optional)*:  
  A callback function triggered when the device connects to the internet.

- **`onDisconnected`** *(Function, optional)*:  
  A callback function triggered when the device disconnects from the internet.

**Example Usage:**

Make sure to call `WidgetsFlutterBinding.ensureInitialized();` in your app's `main` function before starting the notifier.

```dart
import 'package:flutter/material.dart';
import 'package:connectivity_monitor/connectivity_service.dart';

void main() {
  // Ensure proper initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Start global connectivity monitoring
  ConnectivityService.startConnectionNotifier(
    connectedToastMessage: "Connected to the Internet!",
    disconnectedToastMessage: "No Internet Connection.",
    onConnected: () => debugPrint("Connected!"),
    onDisconnected: () => debugPrint("Disconnected!"),
    showToasts: true,
  );

  runApp(MyApp());
}
```

---

#### **`stopNotifier()`**

The `stopNotifier` method stops the global connectivity monitoring process and cleans up resources. It performs the following actions:

1. Cancels the current subscription to the connectivity listener, preventing further updates.
2. Closes the `StreamController` used for broadcasting connectivity changes, releasing all related resources.
3. Marks the connectivity notifier as inactive.

This method is particularly useful in scenarios where you no longer need to monitor connectivity, such as when the app is being disposed or during testing.

```dart
// Example usage of stopNotifier
void dispose() {
  ConnectivityService.stopNotifier();
  super.dispose();
}
```

**Note:** It is generally not necessary to call `stopNotifier` explicitly in most applications because the listener stops automatically when the app is closed. Use it only when specific cleanup is required.

---

#### **`validateInternetConnection()`**

The `validateInternetConnection` method checks whether the device has active internet access. Unlike basic network connectivity checks (e.g., Wi-Fi or mobile data), this method ensures that the device can actually access the internet by sending an HTTP request to a reliable URL.

##### Parameters:

*   `testUrl`: The URL used to verify internet access (default is `https://google.com`).
*   `retries`: The number of times to retry the request if it fails (default is 3).
*   `retryDelay`: The delay between retry attempts (default is 2 seconds).

##### How It Works:

1.  Sends an HTTP GET request to the specified `testUrl`.
2.  If the request succeeds and returns a `200` status code, it confirms internet access.
3.  If the request fails, it retries up to the specified number of times before returning `false`.

```dart
// Example usage of validateInternetConnection
Future<void> checkConnection() async {
  bool isConnected = await ConnectivityService.validateInternetConnection(
    testUrl: 'https://example.com',
    retries: 2,
    retryDelay: Duration(seconds: 1),
  );

  if (isConnected) {
    print('Internet is accessible');
  } else {
    print('No active internet connection');
  }
}
```

---


## Contributions

Contributions are welcome! Please feel free to submit issues or pull requests to improve this package.




