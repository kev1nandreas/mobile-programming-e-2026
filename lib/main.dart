import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await _loadCameras();

  runApp(DeviceAccessApp(cameras: cameras));
}

Future<List<CameraDescription>> _loadCameras() async {
  try {
    return await availableCameras();
  } catch (_) {
    return const [];
  }
}
