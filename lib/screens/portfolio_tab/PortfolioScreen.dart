import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // profile image
          // verified by admin (ticked)
          // username
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // shrink wrap
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // occupation
                // description
              ],
            ),
          ),
        ],
      ),
    );
  }
}