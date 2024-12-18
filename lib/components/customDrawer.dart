// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_template/components/customButtom.dart';
import 'package:flutter_template/services/authService.dart';

import '../utils/Dialogs.dart';

class CustomDrawer extends StatefulWidget {
  Widget child;
  List<DrawerItem> drawerItens = [];
  CustomDrawer({super.key, required this.child, required this.drawerItens});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int currentItem = 0;
  bool collapse = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width <= 700
        ? Scaffold(
            key: scaffoldKey,
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 60,
              child: SingleChildScrollView(
                child: widget.drawerItens[currentItem].child,
              ),
            ),
            appBar: AppBar(
              toolbarHeight: 60,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            drawer: Drawer(
              backgroundColor: Color.fromRGBO(82, 82, 82, 1),
              child: DrawerComponent(),
            ),
          )
        : Scaffold(
            key: scaffoldKey,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey[600],
                  width:
                      collapse ? 80 : MediaQuery.of(context).size.width * 0.2,
                  child: collapse ? CollapseDrawer() : DrawerComponent(),
                ),
                SingleChildScrollView(
                  child: Container(
                    width: collapse
                        ? MediaQuery.of(context).size.width - 80
                        : MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(40),
                    child: widget.drawerItens[currentItem].child,
                  ),
                ),
              ],
            ),
          );
  }

  Widget CollapseDrawer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      collapse = !collapse;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              ...getButtons(true),
            ],
          ),
          CustomButtom(
            onPressed: () {
              try {
                Dialogs().confirm(context, "Deseja sair?", () async {
                  await AuthService().logout();
                  Navigator.popAndPushNamed(context, "/login");
                });
                // Dialogs().dialog(context, "teste");
              } catch (e, t) {
                debugPrint("error 1: " + t.toString());
              }
            },
            width: 40,
            height: 40,
            icon: Icons.power_settings_new,
          )
        ],
      ),
    );
  }

  Widget DrawerComponent() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.maxFinite,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(16),
                      child: Image.asset("assets/logo.png",
                          fit: BoxFit.fitWidth, width: 100),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (MediaQuery.of(context).size.width <= 700) {
                            scaffoldKey.currentState!.closeDrawer();
                          } else {
                            collapse = !collapse;
                          }
                        });
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...getButtons(false)
            ],
          ),
          CustomButtom(
            onPressed: () {
              try {
                Dialogs().confirm(context, "Deseja sair?", () async {
                  await AuthService().logout();
                  Navigator.popAndPushNamed(context, "/login");
                });
                // Dialogs().dialog(context, "teste");
              } catch (e, t) {
                debugPrint("error 1: " + t.toString());
              }
            },
            text: "Sair",
            icon: Icons.logout,
          )
        ],
      ),
    );
  }

  List<Widget> getButtons(bool collapse) {
    List<Widget> items = [];

    for (var i = 0; i < widget.drawerItens.length; i++) {
      if (collapse) {
        items.add(CollapseButton(widget.drawerItens[i], i));
      } else {
        items.add(DrawerButtom(widget.drawerItens[i], i));
      }
    }
    // items.add();
    return items;
  }

  Widget CollapseButton(DrawerItem item, int index) {
    return Tooltip(
      message: item.itemText,
      child: InkWell(
        onTap: () {
          setState(() {
            currentItem = index;
          });
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentItem == index ? Color.fromRGBO(14, 43, 154, 1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              Container(
                child: Icon(item.icon,
                    color: currentItem == index ? Colors.white : Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget DrawerButtom(DrawerItem item, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          currentItem = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: currentItem == index ? Color.fromRGBO(14, 43, 154, 1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            Container(
              child: Icon(item.icon,
                  color: currentItem == index ? Colors.white : Colors.blue),
            ),
            Container(
              child: Text(
                item.itemText,
                style: TextStyle(
                    color: currentItem == index
                        ? Colors.white
                        : Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem {
  String itemText;
  IconData icon;
  Widget child;

  DrawerItem({
    required this.itemText,
    required this.child,
    required this.icon,
  });
}
