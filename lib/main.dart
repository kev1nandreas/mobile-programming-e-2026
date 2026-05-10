import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash Classifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TrashClassifier(),
    );
  }
}

// Maps YOLO class labels to trash categories
const Map<String, _TrashCategory> _classToCategory = {
  'bottle':       _TrashCategory.plastic,
  'cup':          _TrashCategory.plastic,
  'fork':         _TrashCategory.metal,
  'knife':        _TrashCategory.metal,
  'spoon':        _TrashCategory.metal,
  'bowl':         _TrashCategory.organic,
  'banana':       _TrashCategory.organic,
  'apple':        _TrashCategory.organic,
  'sandwich':     _TrashCategory.organic,
  'orange':       _TrashCategory.organic,
  'broccoli':     _TrashCategory.organic,
  'carrot':       _TrashCategory.organic,
  'hot dog':      _TrashCategory.organic,
  'pizza':        _TrashCategory.organic,
  'donut':        _TrashCategory.organic,
  'cake':         _TrashCategory.organic,
  'book':         _TrashCategory.paper,
  'cell phone':   _TrashCategory.ewaste,
  'laptop':       _TrashCategory.ewaste,
  'tv':           _TrashCategory.ewaste,
  'remote':       _TrashCategory.ewaste,
  'keyboard':     _TrashCategory.ewaste,
  'mouse':        _TrashCategory.ewaste,
  'wine glass':   _TrashCategory.glass,
  'vase':         _TrashCategory.glass,
  'backpack':     _TrashCategory.other,
  'handbag':      _TrashCategory.other,
  'suitcase':     _TrashCategory.other,
  'umbrella':     _TrashCategory.other,
  'tie':          _TrashCategory.other,
  'scissors':     _TrashCategory.metal,
  'toothbrush':   _TrashCategory.plastic,
  'hair drier':   _TrashCategory.ewaste,
};

enum _TrashCategory {
  plastic,
  metal,
  paper,
  glass,
  organic,
  ewaste,
  other;

  String get label => switch (this) {
        plastic => 'Plastic',
        metal   => 'Metal',
        paper   => 'Paper',
        glass   => 'Glass',
        organic => 'Organic',
        ewaste  => 'E-Waste',
        other   => 'Other',
      };

  String get bin => switch (this) {
        plastic => 'Yellow Bin',
        metal   => 'Yellow Bin',
        paper   => 'Blue Bin',
        glass   => 'Green Bin',
        organic => 'Brown Bin',
        ewaste  => 'E-Waste Drop-off',
        other   => 'General Waste',
      };

  String get icon => switch (this) {
        plastic => '♻️',
        metal   => '🔩',
        paper   => '📄',
        glass   => '🍶',
        organic => '🌿',
        ewaste  => '💻',
        other   => '🗑️',
      };

  Color get color => switch (this) {
        plastic => const Color(0xFFFDD835),
        metal   => const Color(0xFF90A4AE),
        paper   => const Color(0xFF42A5F5),
        glass   => const Color(0xFF66BB6A),
        organic => const Color(0xFF8D6E63),
        ewaste  => const Color(0xFFEF5350),
        other   => const Color(0xFFBDBDBD),
      };
}

_TrashCategory _categorize(String className) =>
    _classToCategory[className.toLowerCase()] ?? _TrashCategory.other;

class TrashClassifier extends StatefulWidget {
  const TrashClassifier({super.key});

  @override
  State<TrashClassifier> createState() => _TrashClassifierState();
}

class _TrashClassifierState extends State<TrashClassifier> {
  List<YOLOResult> _detections = [];
  double _fps = 0;

  // Aggregate detected categories (deduplicated by class)
  List<_TrashCategory> get _categories =>
      _detections.map((d) => _categorize(d.className)).toSet().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera + YOLO overlay
          YOLOView(
            modelPath: 'assets/models/yolo11n_int8.tflite',
            confidenceThreshold: 0.5,
            iouThreshold: 0.45,
            lensFacing: LensFacing.back,
            showOverlays: true,
            onResult: (results) {
              setState(() => _detections = results);
            },
            onPerformanceMetrics: (metrics) {
              setState(() => _fps = metrics.fps);
            },
          ),

          // Top status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(fps: _fps, count: _detections.length),
          ),

          // Bottom detection panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _DetectionPanel(
              detections: _detections,
              categories: _categories,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double fps;
  final int count;

  const _TopBar({required this.fps, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.delete_outline, color: Color(0xFF66BB6A), size: 28),
          const SizedBox(width: 8),
          const Text(
            'Trash Classifier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _Pill(
            label: '$count item${count == 1 ? '' : 's'}',
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: '${fps.toStringAsFixed(1)} FPS',
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetectionPanel extends StatelessWidget {
  final List<YOLOResult> detections;
  final List<_TrashCategory> categories;

  const _DetectionPanel({
    required this.detections,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detections.isEmpty)
            const Center(
              child: Text(
                'Point camera at trash to classify',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else ...[
            // Category chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(category: c),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Detected items list
            ...detections.take(4).map((d) => _DetectionRow(result: d)),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _TrashCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.25),
        border: Border.all(color: category.color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.label,
                style: TextStyle(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                category.bin,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetectionRow extends StatelessWidget {
  final YOLOResult result;

  const _DetectionRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final category = _categorize(result.className);
    final confidence = (result.confidence * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.className,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Text(
            category.label,
            style: TextStyle(color: category.color, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            '$confidence%',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
