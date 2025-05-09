import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeatureWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // <-- add this

  const FeatureWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap, // <-- add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap, // <-- handle tap
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink wrap
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon),
              SizedBox(height: 8),
              Text(title),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
