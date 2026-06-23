import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notera',
      theme: appTheme,
      routes: AppRoutes.routes,
      initialRoute: RouteNames.splashScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
