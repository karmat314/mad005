import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
