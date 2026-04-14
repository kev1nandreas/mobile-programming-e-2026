import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_page.dart';
import 'gallery_page.dart';
import 'file_page.dart';
import 'gps_page.dart';

class DashboardPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const DashboardPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final hasCamera = cameras.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Main Dashboard')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            children: [
              _DashboardTile(
                icon: Icons.gps_fixed,
                title: 'GPS',
                subtitle: 'Locate the current position',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const GpsPage()));
                },
              ),
              _DashboardTile(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: hasCamera
                    ? 'Open the camera preview'
                    : 'No camera found on this device',
                enabled: hasCamera,
                onTap: hasCamera
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CameraPage(camera: cameras.first),
                          ),
                        );
                      }
                    : null,
              ),
              _DashboardTile(
                icon: Icons.folder,
                title: 'File',
                subtitle: 'Pick a file from storage',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const FilePage()));
                },
              ),
              _DashboardTile(
                icon: Icons.photo_library,
                title: 'Gallery',
                subtitle: 'Pick an image from gallery',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GalleryPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = enabled
        ? Theme.of(context).colorScheme.surface
        : Colors.grey.shade200;

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
