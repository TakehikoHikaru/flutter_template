import '../models/Document.dart';

class ApiResp<T extends Object> {
  bool isOk;
  T? resp;
  String? error;
  List<Document> docErros = [];
  ApiResp({
    required this.isOk,
    required this.resp,
    this.error,
    docErros,
  }) {
    this.docErros = docErros ?? [];
  }
}
