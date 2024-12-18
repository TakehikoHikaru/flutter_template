import 'package:flutter/material.dart';
import 'package:flutter_template/components/PaginationComponent.dart';
import 'package:flutter_template/services/userService.dart';
import 'package:flutter_template/utils/appLocalization.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({Key? key}) : super(key: key);

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final GlobalKey _buttonKey = GlobalKey(); // GlobalKey para acessar o botão
  final List<String> _notifications = [
    "Notificação 1: Você recebeu uma mensagem.",
    "Notificação 2: Nova tarefa adicionada.",
    "Notificação 3: Atualização do sistema disponível.",
  ];

  OverlayEntry? _overlayEntry;

  // Cria o OverlayEntry com posicionamento dinâmico
  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Size buttonSize = renderBox.size;
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calcula o espaço disponível
    final double spaceBelow =
        screenHeight - buttonPosition.dy - buttonSize.height;
    final double spaceAbove = buttonPosition.dy;
    final double spaceRight = screenWidth - buttonPosition.dx;
    final double spaceLeft = buttonPosition.dx;

    // Decide onde exibir o dropdown verticalmente
    bool showAbove = spaceBelow < 200; // Altura estimada do dropdown

    // Ajusta horizontalmente se ultrapassar os limites
    double dropdownWidth = 300;
    double leftPosition = buttonPosition.dx;

    if (spaceRight < dropdownWidth) {
      leftPosition =
          screenWidth - dropdownWidth - 16; // Ajusta para caber na tela
    } else if (spaceLeft < dropdownWidth && spaceRight >= dropdownWidth) {
      leftPosition = buttonPosition.dx; // Posição original
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        top: showAbove
            ? buttonPosition.dy - 200 - 8 // Exibe acima do botão
            : buttonPosition.dy +
                buttonSize.height +
                8, // Exibe abaixo do botão
        left: leftPosition,
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: dropdownWidth,
            height: 200, // Altura fixa do dropdown
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sem notificações no momento.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  Expanded(
                    child: PaginationComponent(
                      itemWidget: (e) => Text(AppLocalizations.translate("email." + e.msg)),
                      getNextItems: (int page, int length) =>
                      UserService().getNotifications(
                        page,
                        length,
                      ),
                      length: 10,
                      itemHeight: 80,
                    ),
                  ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    _removeOverlay(); // Fechar o dropdown
                  },
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mostra o Overlay
  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // Remove o Overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _buttonKey, // Associa o botão ao GlobalKey
      onTap: () {
        if (_overlayEntry == null) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          const Icon(Icons.notifications, size: 30),
          if (_notifications.isNotEmpty)
            const CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
