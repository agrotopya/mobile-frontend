import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrotopya_app/theme/app_theme.dart';
import 'package:agrotopya_app/screens/login_screen.dart';
import 'package:agrotopya_app/screens/dashboard_screen.dart';
import 'package:agrotopya_app/screens/test_screen.dart';
import 'package:agrotopya_app/providers/auth_provider.dart';
import 'package:agrotopya_app/providers/field_provider.dart';
import 'package:agrotopya_app/providers/sensor_provider.dart';
import 'package:agrotopya_app/providers/irrigation_schedule_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationScheduleProvider()),
      ],
      child: const AgrotopyaApp(),
    ),
  );
}

class AgrotopyaApp extends StatelessWidget {
  const AgrotopyaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrotopya',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Test ekranını göstermek için
          // return TestScreen();
          
          return authProvider.isAuthenticated
              ? DashboardScreen()
              : LoginScreen();
        },
      ),
    );
  }
}
