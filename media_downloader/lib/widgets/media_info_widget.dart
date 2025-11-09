import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'custom_card.dart';

class MediaInfoWidget extends StatelessWidget {
  final Map<String, dynamic> mediaInfo;
  final String selectedFormat;
  final String selectedPath;

  const MediaInfoWidget({
    super.key,
    required this.mediaInfo,
    required this.selectedFormat,
    required this.selectedPath,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mediaInfo['type'] == 'playlist' 
                      ? Icons.playlist_play_rounded 
                      : Icons.video_library_rounded,
                  color: AppConstants.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mediaInfo['title'] ?? 'Unknown', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip('Type', mediaInfo['type'] == 'playlist' ? 'Playlist' : 'Single Video'),
              _buildInfoChip('Videos', '${mediaInfo['video_count']}'),
              _buildInfoChip('Platform', mediaInfo['platform'] ?? 'Unknown'),
              _buildInfoChip('Format', selectedFormat == 'audio' ? 'MP3 Audio' : 'MP4 Video'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Save to: ${Helpers.getShortPath(selectedPath)}', 
            style: TextStyle(fontSize: 12, color: AppConstants.hintColor),
          ),
          const SizedBox(height: 16),
          if (mediaInfo['videos'] != null && mediaInfo['videos'].isNotEmpty) ...[
            Text('Content:', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mediaInfo['videos']?.length ?? 0,
                itemBuilder: (context, index) {
                  final video = mediaInfo['videos'][index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('${index + 1}', 
                                style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['title'] ?? 'Unknown', 
                                style: TextStyle(color: AppConstants.textColor),
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis
                              ),
                              if (video['duration'] > 0) 
                                Text('Duration: ${Helpers.formatDuration(video['duration'])}', 
                                  style: TextStyle(color: AppConstants.hintColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value', style: TextStyle(color: AppConstants.hintColor, fontSize: 12)),
    );
  }
}