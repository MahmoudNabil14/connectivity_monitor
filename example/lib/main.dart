import 'package:connectivity_monitor/connectivity_monitor.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ConnectivityService.startConnectionNotifier(
  );
  ConnectivityService.connectivityStream.listen((connected) {
    print('Connectivity: $connected');
  });
  ///To start the listener without toasts
  // ConnectivityService.startConnectionNotifier(showToasts: false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Monitor Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConnectivityMonitor(
        useWidgetAsConnectivityIndicator: true,
        useDialogAsConnectivityIndicator: false,
        customDisconnectedWidget: Scaffold(body: Center(child: Text(" No Internet"),)),
        connectivityLoadingWidget: Scaffold(body: Center(child: CircularProgressIndicator())),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connectivity Monitor Example')),
      body: Center(child: Text('Home Screennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn')),
    );
  }
}
