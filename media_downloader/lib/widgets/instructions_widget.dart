import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'custom_card.dart';

class InstructionsWidget extends StatelessWidget {
  final bool permissionGranted;

  const InstructionsWidget({
    super.key,
    required this.permissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              permissionGranted ? Icons.download_for_offline_rounded : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            permissionGranted 
                ? 'Ready to Download Media'
                : 'Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            permissionGranted 
                ? 'Paste any video or audio URL from supported platforms like YouTube, Spotify, SoundCloud, etc.'
                : 'Please grant storage permission to enable downloads. Click the menu button to request access.',
            style: TextStyle(
              color: AppConstants.hintColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (permissionGranted)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPlatformChip('YouTube'),
                _buildPlatformChip('Spotify'),
                _buildPlatformChip('SoundCloud'),
                _buildPlatformChip('+ More'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Text(platform, style: TextStyle(color: AppConstants.primaryColor, fontSize: 12)),
    );
  }
}