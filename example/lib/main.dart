import 'package:connectivity_monitor/connectivity_monitor.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConnectivityService.validateInternetConnection();

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
      body: Center(child: Text('Home Screen')),
    );
  }
}
