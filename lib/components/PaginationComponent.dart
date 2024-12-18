// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

import '../models/genericModels/Model.dart';
import '../utils/firebase/pagination/cacheManagement.dart';

class PaginationComponent extends StatefulWidget {
  double width;
  double heigth;
  int length;
  String? noneItemText;
  double itemHeight;
  Function(dynamic) itemWidget;
  Function(int page, int length) getNextItems;

  PaginationComponent({
    required this.itemWidget,
    required this.getNextItems,
    required this.length,
    required this.itemHeight,
    this.noneItemText,
    this.width = 500,
    this.heigth = 300,
    super.key,
  });

  @override
  State<PaginationComponent> createState() => PaginationComponentState();
}

class PaginationComponentState extends State<PaginationComponent> {
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
    if (currentLength == null) {}
    var height = widget.heigth;
    double length = (height) / (widget.itemHeight + spacing);
    currentLength = length.floor();
    if (currentLength == 0) {
      currentLength = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.heigth + 20,
      child: StreamBuilder(
          stream: cacheListIndex != -1 ? cacheManagement.caches[cacheListIndex].key.stream : const Stream.empty(),
          builder: (context, snapshot) {
            return LayoutBuilder(
              builder: (BuildContext buildContext, BoxConstraints constraints) {
                // if (cacheListIndex != -1 && snapshot.connectionState == ConnectionState.active && snapshot.requireData != null) {
                //   for (var doc in snapshot.requireData.docChanges) {
                //     cacheManagement.alterItem(doc.doc.data() as Model, cacheManagement.caches[cacheListIndex].key.path);
                //   }
                // }
                return SizedBox(
                  width: double.maxFinite,
                  height: widget.heigth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          height: widget.heigth,
                          child: loading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ((cacheListIndex != -1) ? cacheManagement.caches[cacheListIndex].items.isEmpty : true)
                                  ? Center(
                                      child: Text(
                                      widget.noneItemText != null ? widget.noneItemText! : "AppLocalizations.translate(context, translations().Warnings.Not_Found.None_Item_Found)",
                                    ))
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: getWidgets(),
                                      ),
                                    ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: 20,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: (page - 1 < 1) ? null : () => (loading) ? null : goBack(),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: (page - 1 < 1) ? Colors.black : null,
                                ),
                              ),
                              Text(page.toString()),
                              InkWell(
                                onTap: isLastPage() ? null : () => loading ? null : goNext(),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: isLastPage() ? Colors.black : null,
                                ),
                              )
                            ],
                          ),
                        )
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
    int pageMaximun = (cacheManagement.caches[cacheListIndex].numberOfItemsInDataBase / currentLength!).ceil();
    if (page >= pageMaximun) {
      return true;
    }
    return false;
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

  getWidgets() {
    List<Widget> list = [];

    for (var e in cacheManagement.caches[cacheListIndex].items
        .getRange(page * currentLength! - currentLength!, (page * currentLength! > cacheManagement.caches[cacheListIndex].items.length) ? cacheManagement.caches[cacheListIndex].items.length : page * currentLength!)) {
      list.add(Container(
        margin: EdgeInsets.symmetric(vertical: spacing),
        child: widget.itemWidget(e),
      ));
    }

    return list;
  }

  getItems() async {
    setState(() {
      loading = true;
    });
    await widget.getNextItems(page, currentLength!);
    setState(() {
      loading = false;
    });
  }
}
