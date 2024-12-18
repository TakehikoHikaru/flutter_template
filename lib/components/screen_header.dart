import 'package:flutter/material.dart';
import 'package:flutter_template/components/notification_buttom.dart';

class ScreenHeader extends StatefulWidget {
  String title ;
  ScreenHeader({
    required this.title,
    super.key});

  @override
  State<ScreenHeader> createState() => _ScreenHeaderState();
}

class _ScreenHeaderState extends State<ScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(width: double.maxFinite,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          NotificationButton(),
      
        ],
      ),
    );
  }
}