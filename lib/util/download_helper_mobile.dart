import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

Future<void> downloadForWeb(List<int> fileBytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(fileBytes, flush: true);
  Share.shareFiles([file.path], text: 'Datos Hidrológicos');
}
