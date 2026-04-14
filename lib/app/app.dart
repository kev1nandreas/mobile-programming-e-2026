import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../pages/dashboard_page.dart';

class DeviceAccessApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const DeviceAccessApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Access',
      home: DashboardPage(cameras: cameras),
    );
  }
}
