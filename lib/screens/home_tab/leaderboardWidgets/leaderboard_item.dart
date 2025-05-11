import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../portfolio_tab/PortfolioScreen.dart';

class LeaderBoardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;
  final bool isFullLeaderboard;

  const LeaderBoardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
    this.isFullLeaderboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 10,),
          SizedBox(
            width: 28,
            child: Text(
              "$rank",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ),
          Chip(
            backgroundColor: isCurrentUser
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surfaceContainerHighest,
            label: Text(
              "$points pts",
              style: TextStyle(
                color: isCurrentUser
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isFullLeaderboard) ...[
            const SizedBox(height: 4),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              color: colorScheme.onSurfaceVariant,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortfolioScreen(isViewer: true,)
                  ),
                );
              },
              splashRadius: 20,
            ),
          ]
        ],
      ),
    );
  }
}
