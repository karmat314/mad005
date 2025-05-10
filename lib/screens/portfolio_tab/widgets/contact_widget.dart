import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsWidget extends StatefulWidget {
  final String userId;

  const ContactDetailsWidget({super.key, required this.userId});

  @override
  State<ContactDetailsWidget> createState() => _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void _showEditDialog(Map<String, dynamic> data) {
    final _phoneController = TextEditingController(text: data['phone']);
    final _emailController = TextEditingController(text: data['email']);
    final _locationController = TextEditingController(text: data['location']);
    final _websiteController = TextEditingController(text: data['website']);
    final _linkedinController = TextEditingController(text: data['linkedin']);
    final _twitterController = TextEditingController(text: data['twitter']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Contact Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
                TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website')),
                TextField(controller: _linkedinController, decoration: const InputDecoration(labelText: 'LinkedIn')),
                TextField(controller: _twitterController, decoration: const InputDecoration(labelText: 'Twitter')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final contactRef = db.collection('users').doc(widget.userId).collection('profile').doc('contact_details');

                await contactRef.set({
                  'phone': _phoneController.text.trim(),
                  'email': _emailController.text.trim(),
                  'location': _locationController.text.trim(),
                  'website': _websiteController.text.trim(),
                  'linkedin': _linkedinController.text.trim(),
                  'twitter': _twitterController.text.trim(),
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _socialLink(IconData icon, String label, String? url) {
    return InkWell(
      onTap: (url != null && url.isNotEmpty) ? () => launchUrl(Uri.parse(url)) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactRef = db.collection('users').doc(widget.userId).collection('profile').doc('contact_details');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<DocumentSnapshot>(
          stream: contactRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading contact details');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

            final phone = data['phone'] ?? '';
            final email = data['email'] ?? '';
            final location = data['location'] ?? '';
            final website = data['website'] ?? '';
            final linkedin = data['linkedin'] ?? '';
            final twitter = data['twitter'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone),
                    const SizedBox(width: 8),
                    const Text('Contact Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(data),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (phone.isNotEmpty) ListTile(leading: const Icon(Icons.phone), title: Text(phone)),
                if (email.isNotEmpty) ListTile(leading: const Icon(Icons.email), title: Text(email)),
                if (location.isNotEmpty) ListTile(leading: const Icon(Icons.location_on), title: Text(location)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialLink(Icons.language, 'Website', website),
                    _socialLink(FontAwesomeIcons.linkedin, 'LinkedIn', linkedin),
                    _socialLink(FontAwesomeIcons.twitter, 'Twitter', twitter),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
