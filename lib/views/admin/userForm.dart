import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/components/customButtom.dart';
import 'package:flutter_template/components/custom_textfield.dart';
import 'package:flutter_template/models/user.dart';
import 'package:flutter_template/services/authService.dart';
import 'package:flutter_template/services/userService.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class UserFormScreen extends StatefulWidget {
  final User?
      user; // ID do usuário para edição; se nulo, significa criação de um novo usuário
  Function callback;
  UserFormScreen({
    Key? key,
    this.user,
    required this.callback,
  }) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      // Aqui você pode carregar os dados do usuário para edição
      // Exemplo fictício de carregamento de dados
      _nameController.text =
          widget.user!.name ?? ''; // Carregar nome do usuário
      _emailController.text =
          widget.user!.email ?? ''; // Carregar email do usuário
      _cpfController.text = widget.user!.cpf ?? '';
    }
  }

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      // Aqui você adicionaria a lógica para atualizar o usuário
      final String email = _emailController.text;
      final String name = _nameController.text;
      User user = widget.user ?? User();
      user.email = email;
      user.name = _nameController.text;

      await UserService().updatedUser(user,context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário salvo: $name ($email)')),
      );
      widget.callback();
    }
  }

  void _saveUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Aqui você adicionaria a lógica para salvar o usuário (adicionar ou editar)

      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String name = _nameController.text;
      User user = widget.user ?? User();
      user.email = email;
      user.name = _nameController.text;
      var resp = await UserService().createUser(user, password);
      setState(() {
        _isLoading = false;
      });
      if (!resp.isOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.error!)),
        );
        return;
      }
      // Exemplo de feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário salvo: $name ($email)')),
      );

      // Retornar à tela anterior
      widget.callback();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            widget.user != null ? 'Editar Usuário' : 'Novo Usuário',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
            width: double.maxFinite,
          ),
          CustomTextfield(
            controller: _nameController,
            label: 'Nome',
            hint: 'Digite o nome',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome';
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
            width: double.maxFinite,
          ),
          CustomTextfield(
            controller: _emailController,
            label: 'E-mail',
            hint: 'Digite o e-mail',
            readOnly: widget.user != null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o e-mail';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(
            height: 20,
            width: double.maxFinite,
          ),
          CustomTextfield(
            controller: _cpfController,
            label: 'CPF',
            hint: 'Digite o cpf',
            readOnly: widget.user != null,
            inputFormatter: MaskTextInputFormatter(
              mask: '###.###.###-##',
              filter: {"#": RegExp(r'[0-9]')},
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o cpf';
              }
              if (!CPFValidator.isValid(value)) {
                return 'Por favor, insira um cpf valido';
              }
              return null;
            },
            keyboardType: TextInputType.number,
          ),
          if (widget.user == null) ...[
            SizedBox(
              height: 20,
              width: double.maxFinite,
            ),
            CustomTextfield(
              controller: _passwordController,
              label: 'Senha',
              hint: 'Digite a senha',
              // readOnly: widget.user != null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a senha';
                }
                return null;
              },
            ),
          ],
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomButtom(
                onPressed: () {
                  widget.callback();
                },
                text: 'Cancelar',
              ),
              CustomButtom(
                onPressed: widget.user == null ? _saveUser : _updateUser,
                text: 'Salvar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
