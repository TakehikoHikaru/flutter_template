import 'package:flutter/material.dart';
import 'package:flutter_template/components/customDrawer.dart';
import 'package:flutter_template/views/admin/dashBoard.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomDrawer(
        child: Container(),
        drawerItens: [
          DrawerItem(
            itemText: "DashBoard",
            child: DashBoard(),
            icon: Icons.home,
          ),
        ],
      ),
    );
  }
}
