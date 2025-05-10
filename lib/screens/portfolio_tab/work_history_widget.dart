import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkHistoryWidget extends StatefulWidget {

  const WorkHistoryWidget({
    super.key,
  });

  @override
  _WorkHistoryWidgetState createState() => _WorkHistoryWidgetState();
}

class _WorkHistoryWidgetState extends State<WorkHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text("Work history")
    );
  }
}
