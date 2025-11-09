import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'custom_card.dart';

class DownloadHistory extends StatelessWidget {
  final List<Map<String, dynamic>> downloadHistory;

  const DownloadHistory({
    super.key,
    required this.downloadHistory,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Download History', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${downloadHistory.where((item) => item['success'] == true).length} successful',
                  style: TextStyle(color: AppConstants.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: downloadHistory.length,
              itemBuilder: (context, index) {
                final item = downloadHistory[index];
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item['success'] == true 
                              ? AppConstants.accentColor.withOpacity(0.2) 
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['success'] == true ? Icons.download_done_rounded : Icons.error_rounded,
                          color: item['success'] == true ? AppConstants.accentColor : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item['format'] == 'audio' ? 'MP3 Audio' : 'MP4 Video'} • ${Helpers.getShortPath(item['download_path'])}',
                              style: TextStyle(color: AppConstants.hintColor, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateTime.parse(item['timestamp']!).toString().split(' ')[0],
                        style: TextStyle(color: AppConstants.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}