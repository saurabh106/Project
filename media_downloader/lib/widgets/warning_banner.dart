import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WarningBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onAction;
  final Color color;
  final bool isLoading;

  const WarningBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 12),
            isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                : ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(actionText, style: const TextStyle(fontSize: 12)),
                  ),
          ],
        ],
      ),
    );
  }
}