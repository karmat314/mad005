import 'package:flutter/material.dart';
import 'package:mad005/screens/home_tab/leaderboard_widget.dart';

import 'core_feature_widget.dart';

class HomeScreen extends StatefulWidget {
  final TabController tabController;

  const HomeScreen({super.key, required this.tabController});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data for feature widgets - can be expanded easily
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.document_scanner,
      'title': 'Document Scanner',
      'subtitle': 'Organize IDs & Certs',
      'tabIndex': 1,
    },
    {
      'icon': Icons.portrait_rounded,
      'title': 'Portfolio',
      'subtitle': 'Manage your portfolio',
      'tabIndex': 2,
    },
    // Add more features here as needed
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;
    final isLargeScreen = screenSize.width > 600;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    // Top Cards Section
                    _buildTopCardsSection(isSmallScreen, isLargeScreen),

                    // Core Features Title
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12.0 : 20.0,
                        horizontal: 16.0,
                      ),
                      child: Text(
                        "Core features",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20.0 : 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Responsive Features Grid
                    Container(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height * 0.4,
                        maxHeight: isLargeScreen ? screenSize.height * 0.6 : screenSize.height * 0.5,
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 1 : (isLargeScreen ? 3 : 2),
                          mainAxisSpacing: isSmallScreen ? 8.0 : 12.0,
                          crossAxisSpacing: isSmallScreen ? 8.0 : 12.0,
                          childAspectRatio: isSmallScreen ? 1.2 : (isLargeScreen ? 1.1 : 0.9),
                        ),
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          return FeatureWidget(
                            icon: features[index]['icon'],
                            title: features[index]['title'],
                            subtitle: features[index]['subtitle'],
                            onTap: () => widget.tabController.animateTo(features[index]['tabIndex']),
                            isSmallScreen: isSmallScreen,
                          );
                        },
                      ),
                    ),

                    // Add some bottom padding for better scrolling
                    SizedBox(height: isSmallScreen ? 20 : 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCardsSection(bool isSmallScreen, bool isLargeScreen) {
    final cardMargin = isSmallScreen ? 8.0 : (isLargeScreen ? 20.0 : 16.0);
    final cardPadding = isSmallScreen ? 12.0 : (isLargeScreen ? 20.0 : 16.0);
    final cardHeight = isSmallScreen ? 70.0 : (isLargeScreen ? 100.0 : 80.0);

    return Column(
      children: [
        _buildTopCard("Your points balance", cardMargin, cardPadding, cardHeight),
        LeaderboardWidget(),
        _buildTopCard("Grow our career", cardMargin, cardPadding, cardHeight),
        _buildTopCard("Stay Updated", cardMargin, cardPadding, cardHeight),
      ],
    );
  }

  Widget _buildTopCard(String title, double margin, double padding, double height) {
    return Card(
      margin: EdgeInsets.all(margin),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: height,
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: padding * 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}