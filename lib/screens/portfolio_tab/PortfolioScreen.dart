import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mad005/screens/portfolio_tab/profile_picture_widget.dart';
import 'package:mad005/screens/portfolio_tab/skills_widget.dart';
import 'package:mad005/screens/portfolio_tab/training_widget.dart';
import 'package:mad005/screens/portfolio_tab/work_history_widget.dart';
import 'package:mad005/screens/portfolio_tab/work_showcase_widget.dart';

import 'contact_widget.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _key = GlobalKey<ExpandableFabState>();


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return Scaffold(
        body: const Center(
          child: Text('User not signed in'),
        ),
      );
    }

    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withOpacity(0.9),
        ),
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        children: [
          Row(
            children: [
              const Text('Share profile'),
              const SizedBox(width: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () async {

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
                onPressed: () async {

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
                onPressed: () {
                },
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
                onPressed: () {
                },
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
                onPressed: () {
                },
                child: const Icon(FontAwesomeIcons.shield),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea( // Optional: avoids notches/top bar
        child: SingleChildScrollView( // FIX: makes the screen scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Optional: adds padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // profile image
                // verified by admin (ticked)
                // username
                ProfilePortfolioWidget(userId: userId),
                ContactDetailsWidget(userId: userId),
                WorkHistoryWidget(userId: userId),
                SkillsWidget(userId: userId),
                TrainingCertificationsWidget(userId: userId),
                WorkShowcaseWidget(userId: userId),
                // occupation
                // description
              ],
            ),
          ),
        ),
      ),
    );
  }
}
