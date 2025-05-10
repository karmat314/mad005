import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkShowcaseWidget extends StatefulWidget {
  final String userId;

  const WorkShowcaseWidget({super.key, required this.userId});

  @override
  State<WorkShowcaseWidget> createState() => _WorkShowcaseWidgetState();
}

class _WorkShowcaseWidgetState extends State<WorkShowcaseWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showAddWorkDialog() {
    final _nameController = TextEditingController();
    final _linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Work Showcase'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'YouTube Link'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final link = _linkController.text.trim();

                if (name.isNotEmpty && link.isNotEmpty) {
                  final showcaseRef = db
                      .collection('users')
                      .doc(widget.userId)
                      .collection('work_showcase');

                  await showcaseRef.add({
                    'name': name,
                    'link': link,
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String? getYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }

    return null;
  }

  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final showcaseRef = db
        .collection('users')
        .doc(widget.userId)
        .collection('work_showcase');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Work Showcase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddWorkDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: showcaseRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text('No work showcased yet.');
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? '';
                    final link = data['link'] ?? '';

                    final videoId = getYoutubeVideoId(link);
                    final thumbnailUrl = (videoId != null)
                        ? getThumbnailUrl(videoId)
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: thumbnailUrl != null
                            ? Image.network(
                          thumbnailUrl,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.broken_image, size: 60),
                        title: Text(name),
                        subtitle: Text(link, overflow: TextOverflow.ellipsis),
                          onTap: (link != null && link.isNotEmpty) ? () => launchUrl(Uri.parse(link)) : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
