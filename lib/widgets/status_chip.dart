import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/request_model.dart';

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colors(RequestStatus s) {
    switch (s) {
      case RequestStatus.open:
        return (const Color(0xFFDBEAFE), AppColors.primaryDark);
      case RequestStatus.negotiation:
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
      case RequestStatus.waitingConfirmation:
        return (const Color(0xFFFFEDD5), const Color(0xFFC2410C));
      case RequestStatus.accepted:
        return (const Color(0xFFD1FAE5), const Color(0xFF065F46));
      case RequestStatus.purchased:
        return (const Color(0xFFE0E7FF), const Color(0xFF3730A3));
      case RequestStatus.completed:
        return (const Color(0xFFE5E7EB), const Color(0xFF374151));
    }
  }
}
