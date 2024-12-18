// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_template/components/customButtom.dart';
import '../models/genericModels/Model.dart';
import '../utils/firebase/pagination/cacheManagement.dart';

class PaginationTableComponent extends StatefulWidget {
  double width;
  double heigth;
  int length;
  String? noneItemText;
  double itemHeight;
  List<CustomTableItem> itemWidget;
  Function(int page, int length) getNextItems;
  Function(Model model)? syncCallback;

  bool updateOnSnapshot = true;
  PaginationTableComponent({
    required this.itemWidget,
    required this.getNextItems,
    required this.length,
    required this.itemHeight,
    this.noneItemText,
    this.width = 500,
    this.heigth = 300,
    this.updateOnSnapshot = true,
    this.syncCallback,
    super.key,
  });

  @override
  State<PaginationTableComponent> createState() =>
      PaginationTableComponentState();
}

class PaginationTableComponentState extends State<PaginationTableComponent> {
  int page = 1;

  bool loading = true;

  int? currentLength;
  double spacing = 5;

  int cacheListIndex = -1;

  @override
  void initState() {
    getData();
    super.initState();
  }

  refresh() async {
    page = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
    });
    setState(() {});
  }

  getData() async {
    await getCurrentLength();
    setState(() {
      loading = true;
    });
    cacheListIndex = await widget.getNextItems(1, currentLength!);
    setState(() {
      loading = false;
    });
  }

  getCurrentLength() {
    currentLength = widget.length;
    // if (currentLength == null) {}
    // var height = widget.heigth;
    // double length = (height) / (widget.itemHeight + spacing);
    // currentLength = length.floor();
    // if (currentLength == 0) {
    //   currentLength = 1;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: widget.width,
      // height: widget.heigth + 20,
      child: StreamBuilder(
          stream: cacheListIndex != -1
              ? cacheManagement.caches[cacheListIndex].key.stream
              : const Stream.empty(),
          builder: (context, snapshot) {
            return LayoutBuilder(
              builder: (BuildContext buildContext, BoxConstraints constraints) {
                if (widget.updateOnSnapshot) {
                  if (cacheListIndex != -1 &&
                      snapshot.connectionState == ConnectionState.active &&
                      snapshot.requireData != null) {
                    for (var doc in snapshot.requireData.docChanges) {
                      cacheManagement.alterItem(doc.doc.data() as Model,
                          cacheManagement.caches[cacheListIndex].key.path);
                      if (widget.syncCallback != null) {
                        widget.syncCallback!(doc.doc.data() as Model);
                      }
                    }
                  }
                }
                return SizedBox(
                  width: double.maxFinite,
                  // height: widget.heigth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                            width: double.maxFinite,
                            // height: widget.heigth,
                            child: loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : getTable(
                                    widget.itemWidget,
                                    cacheManagement
                                        .caches[cacheListIndex].items)

                            // ((cacheListIndex != -1) ? cacheManagement.caches[cacheListIndex].items.isEmpty : true)
                            //     ? Center(
                            //         child: Text(widget.noneItemText != null ? widget.noneItemText! : "Nenhum item encontrado"),
                            //       )
                            //     : SingleChildScrollView(
                            //         child: Column(
                            //           children: getWidgets(),
                            //         ),
                            //       ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  bool isLastPage() {
    if (cacheListIndex == -1) {
      return true;
    }
    int pageMaximun = cacheManagement.caches[cacheListIndex].items
        .getRange(
            page * currentLength! - currentLength!,
            (page * currentLength! >
                    cacheManagement.caches[cacheListIndex].items.length)
                ? cacheManagement.caches[cacheListIndex].items.length
                : page * currentLength!)
        .length;
    if (pageMaximun < widget.length) {
      return true;
    }
    return false;
  }

  int getMaxPages() {
    if (cacheListIndex == -1 || widget.length == 0) {
      return 0; // No pages if there's no valid cacheListIndex or if items per page is zero
    }

    // Total items in the current cache
    int totalItems = cacheManagement.caches[cacheListIndex].items.length;

    // Calculate the maximum pages, ensuring any remainder rounds up
    return (totalItems + widget.length - 1) ~/ widget.length;
  }

  goNext() {
    if (isLastPage()) {
      return;
    }
    page = page + 1;
    getItems();
  }

  goBack() {
    if (page - 1 < 1) {
      return;
    }
    page = page - 1;
    setState(() {});
  }

  // getWidgets() {
  //   List<Widget> list = [];

  //   for (var e in cacheManagement.caches[cacheListIndex].items
  //       .getRange(page * currentLength! - currentLength!, (page * currentLength! > cacheManagement.caches[cacheListIndex].items.length) ? cacheManagement.caches[cacheListIndex].items.length : page * currentLength!)) {
  //     list.add(Container(
  //       margin: EdgeInsets.symmetric(vertical: spacing),
  //       child: widget.itemWidget(e),
  //     ));
  //   }

  //   return list;
  // }

  getItems() async {
    setState(() {
      loading = true;
    });
    await widget.getNextItems(page, currentLength!);
    setState(() {
      loading = false;
    });
  }

  Widget getTable(List<CustomTableItem> columns, models) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        // border: TableBorder.all(),
        children: getRows(columns, models),
      ),
    );
  }

  getRows(List<CustomTableItem> columns, models) {
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            TableCell(
              child: Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(245, 245, 245, 1),
                  border: Border.symmetric(
                      horizontal:
                          BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                  borderRadius: BorderRadius.only(
                    topLeft: i == 0
                        ? const Radius.circular(10.0)
                        : const Radius.circular(0.0),
                    topRight: i == columns.length - 1
                        ? const Radius.circular(10.0)
                        : const Radius.circular(0.0),
                  ),
                ),
                child: Text(
                  columns[i].headerName,
                  style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.64)),
                ),
              ),
            ),
          ]
        ],
      ),
    );

    for (var e in cacheManagement.caches[cacheListIndex].items.getRange(
        page * currentLength! - currentLength!,
        (page * currentLength! >
                cacheManagement.caches[cacheListIndex].items.length)
            ? cacheManagement.caches[cacheListIndex].items.length
            : page * currentLength!)) {
      rows.add(
        TableRow(
          children: [
            for (var c in columns) ...[
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                  ),
                  child: c.item(e),
                ),
              )
            ]
          ],
        ),
      );
    }

    rows.add(
      TableRow(
        children: [
          for (var e = 0; e < columns.length; e++) ...[
            !(e == columns.length - 1)
                ? TableCell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(245, 245, 245, 1),
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.1))),
                        borderRadius: e == 0
                            ? BorderRadius.only(bottomLeft: Radius.circular(10))
                            : BorderRadius.circular(0),
                      ),
                      // color: Colors.indigo,
                      padding: EdgeInsets.all(16),
                      height: 48,
                      width: 200,
                    ),
                  )
                : TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(245, 245, 245, 1),
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.1))),
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(10)),
                      ),
                      // padding: EdgeInsets.only(left: 16, right: 16, top: 16, ),
                      padding: EdgeInsets.only(right: 16),
                      height: 48,
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 30,
                        children: [
                          CustomButtom(
                            height: 30,
                            width: 30,
                            deavited: (page - 1 < 1 || loading),
                            onPressed: () => goBack(),
                            icon: Icons.arrow_back,
                          ),
                          Text(
                            "${page.toString()}/${getMaxPages().toString()}",
                            style:
                                TextStyle(color: Color.fromRGBO(0, 0, 0, .58)),
                          ),
                          CustomButtom(
                            height: 30,
                            width: 30,
                            deavited: isLastPage() || loading,
                            onPressed: () => goNext(), 
                            icon: Icons.arrow_forward,
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );

    return rows;
  }
}

class CustomTableItem {
  Widget Function(dynamic) item;
  String headerName;

  CustomTableItem({required this.item, required this.headerName});
}
