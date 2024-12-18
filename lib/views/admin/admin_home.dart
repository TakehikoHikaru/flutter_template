import 'package:flutter/material.dart';
import 'package:flutter_template/components/customDrawer.dart';
import 'package:flutter_template/services/authService.dart';
import 'package:flutter_template/utils/enums/permisions.dart';
import 'package:flutter_template/views/admin/analytics_screen.dart';
import 'package:flutter_template/views/admin/dashBoard.dart';
import 'package:flutter_template/views/admin/users.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Lista simulada de usuários

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomDrawer(
        child: Container(),
        drawerItens: [
          if (AuthService.currentUser!.permissions.contains(
            permisions.userManagement.name,
          )) ...[
            DrawerItem(
              itemText: "usuarios",
              child: Users(),
              icon: Icons.person,
            ),
          ],
          DrawerItem(
            itemText: "Analytics",
            child: AnalyticsScreen(),
            icon: Icons.analytics,
          ),
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
