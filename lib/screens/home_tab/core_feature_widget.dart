import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeatureWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isSmallScreen; // Optional parameter for explicit control

  const FeatureWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isSmallScreen = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size if not explicitly set
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = isSmallScreen || screenWidth < 350;
    final isLarge = screenWidth > 600;

    // Responsive sizing
    final iconSize = isSmall ? 36.0 : (isLarge ? 56.0 : 48.0);
    final titleSize = isSmall ? 14.0 : (isLarge ? 18.0 : 16.0);
    final subtitleSize = isSmall ? 12.0 : (isLarge ? 14.0 : 13.0);
    final padding = isSmall ? 12.0 : (isLarge ? 24.0 : 16.0);
    final spacing = isSmall ? 4.0 : 8.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(isSmall ? 4.0 : 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: spacing),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing / 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}