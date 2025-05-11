import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mad005/screens/portfolio_tab/widgets/badges_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/name_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/profile_picture_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/skills_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/training_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/work_history_widget.dart';
import 'package:mad005/screens/portfolio_tab/widgets/work_showcase_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/contact_widget.dart';

class PortfolioScreen extends StatefulWidget {
  final bool isViewer;

  const PortfolioScreen({super.key, required this.isViewer});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _key = GlobalKey<ExpandableFabState>();

  // ✨ NEW: GlobalKeys for sections
  final GlobalKey nameKey = GlobalKey();
  final GlobalKey badgesKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();
  final GlobalKey workHistoryKey = GlobalKey();
  final GlobalKey skillsKey = GlobalKey();
  final GlobalKey trainingKey = GlobalKey();
  final GlobalKey showcaseKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  void _showQrCodeDialog(BuildContext context) {
    final String portfolioLink = 'https://your-portfolio-link.com/karma-thapkhey';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan to view portfolio'),
          content: SizedBox(
            width: 250,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: portfolioLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 10),
                Text(portfolioLink, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Portfolio')),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        overlayStyle: ExpandableFabOverlayStyle(color: Colors.white.withOpacity(0.9)),
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        children: [
          Row(
            children: [
              const Text('Share profile'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  final content = 'https://my_profile.com';
                  Share.share(content, subject: 'Profile link');
                },
                child: const Icon(Icons.share),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Show QR code'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  _showQrCodeDialog(context);
                },
                child: const Icon(Icons.qr_code),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Export to LinkedIn'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  launchUrl(Uri.parse("https://www.linkedin.com/in/karma-thapkhey-567bb12b4"));
                },
                child: const Icon(FontAwesomeIcons.linkedin),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Export as PDF'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {},
                child: const Icon(FontAwesomeIcons.filePdf),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Report profile'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {},
                child: const Icon(FontAwesomeIcons.flag),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Claim this Profile'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {},
                child: const Icon(FontAwesomeIcons.shield),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            final sectionWidgets = [
              NameWidget(key: nameKey, userId: userId, isViewer: widget.isViewer),
              BadgesWidget(key: badgesKey, userId: userId),
              ContactDetailsWidget(key: contactKey, userId: userId, isViewer: widget.isViewer),
              WorkHistoryWidget(key: workHistoryKey, userId: userId, isViewer: widget.isViewer),
              SkillsWidget(key: skillsKey, userId: userId, isViewer: widget.isViewer),
              TrainingCertificationsWidget(key: trainingKey, userId: userId, isViewer: widget.isViewer),
              WorkShowcaseWidget(key: showcaseKey, userId: userId, isViewer: widget.isViewer),
            ];

            Widget buildContent() {
              if (isWide) {
                // Split into two roughly equal columns
                final mid = (sectionWidgets.length / 2).ceil();
                final leftColumn = sectionWidgets.sublist(0, mid);
                final rightColumn = sectionWidgets.sublist(mid);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: leftColumn,
                      ),
                    ),
                    const SizedBox(width: 24), // space between columns
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rightColumn,
                      ),
                    ),
                  ],
                );
              } else {
                // Default single column
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: sectionWidgets,
                );
              }
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfilePortfolioWidget(userId: userId, isViewer: widget.isViewer),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Go to section",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: "name", child: Text("Name")),
                        DropdownMenuItem(value: "badges", child: Text("Badges")),
                        DropdownMenuItem(value: "contact", child: Text("Contact Details")),
                        DropdownMenuItem(value: "work", child: Text("Work History")),
                        DropdownMenuItem(value: "skills", child: Text("Skills")),
                        DropdownMenuItem(value: "training", child: Text("Training/Certifications")),
                        DropdownMenuItem(value: "showcase", child: Text("Work Showcase")),
                      ],
                      onChanged: (value) {
                        if (value == "name") _scrollToSection(nameKey);
                        if (value == "badges") _scrollToSection(badgesKey);
                        if (value == "contact") _scrollToSection(contactKey);
                        if (value == "work") _scrollToSection(workHistoryKey);
                        if (value == "skills") _scrollToSection(skillsKey);
                        if (value == "training") _scrollToSection(trainingKey);
                        if (value == "showcase") _scrollToSection(showcaseKey);
                      },
                    ),
                  ),
                  if (widget.isViewer)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hire request sent!')),
                          );
                        },
                        icon: const Icon(Icons.handshake),
                        label: const Text('Hire Me', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 50),

                  // 🎉 Here’s the responsive content!
                  buildContent(),
                ],
              ),
            );
          },
        ),
      ),

    );
  }
}
