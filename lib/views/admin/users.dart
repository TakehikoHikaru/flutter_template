import 'package:flutter/material.dart';
import 'package:flutter_template/components/PaginationComponent.dart';
import 'package:flutter_template/components/PaginationTableComponent.dart';
import 'package:flutter_template/components/customButtom.dart';
import 'package:flutter_template/components/screen_header.dart';
import 'package:flutter_template/models/user.dart';
import 'package:flutter_template/services/userService.dart';
import 'package:flutter_template/views/admin/userForm.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {

  User? _currentUser = null;
  bool _registering = false;
  TextEditingController _searchController = TextEditingController();
  String? _currentSearch = null;
  GlobalKey<PaginationTableComponentState> _paginationKey = GlobalKey();
  void _openUserForm({User? user}) {
    setState(() {
      if(user == null) {
        _registering = true;
      }else{
        _currentUser = user;
    
      }
      });
  }

  @override
  Widget build(BuildContext context) {
    if(_currentUser != null || _registering) {
      return UserFormScreen(user: _currentUser, callback: () {
        setState(() {
          _currentUser = null;
          _registering = false;
        });
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(title: "Usuarios"),
        SizedBox(
          width: double.maxFinite,
          height: 10,
        ),
        
        CustomButtom(
          width: 150,
          height: 30,
          onPressed: () => _openUserForm(),
          icon: Icons.add,
          text: "Cadastrar",
        ),
        SizedBox(
          width: double.maxFinite,
          height: 10,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    width: constraints.maxWidth - 120,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(
                                () {}); // Atualiza para mostrar/esconder o botão de limpar
                          },
                          onSubmitted: (value) => _submitSearch(value),
                          decoration: InputDecoration(
                            hintText: "Buscar",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(
                                right: 40,
                                left: 10,
                                top: 2,
                                bottom: 2), // Espaço para o botão de limpar
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _submitSearch(_searchController.text);
                                setState(
                                    () {}); // Atualiza para esconder o botão de limpar
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  CustomButtom(
                    onPressed: () => _submitSearch(_searchController.text),
                    width: 110,
                    height: 50,
                    icon: Icons.search,
                    text: "Buscar",
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(
          width: double.maxFinite,
          height: 10,
        ),
        PaginationTableComponent(
          key: _paginationKey,
          itemWidget: [
            CustomTableItem(
              item: (e) => Container(
                  alignment: Alignment.centerLeft,
                  height: 30,
                  child: Text(
                    e.name,
                  )),
              headerName: "Name",
            ),
            CustomTableItem(
              item: (e) => Container(
                  alignment: Alignment.centerLeft,
                  height: 30,
                  child: Text(
                    e.email,
                  )),
              headerName: "Email",
            ),
            CustomTableItem(
              item: (e) => Container(
                height: 30,
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 5,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _openUserForm(user: e),
                    ),
                  ],
                ),
              ),
              headerName: " ",
            ),
          ],
          getNextItems: (page, length) =>
              UserService().getUsers(page, length, _currentSearch),
          length: 5,
          itemHeight: 100,
        ),
        SizedBox(
          width: double.maxFinite,
          height: 10,
        ),
      ],
    );
  }

  void _submitSearch(String searchText) {
    setState(() {
      if (searchText.trim() == "") {
        _currentSearch = null;
      } else {
        _currentSearch = searchText;
      }
    });
    _paginationKey.currentState!.refresh();
  }
}
