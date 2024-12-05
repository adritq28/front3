//import 'dart:html' as html;
//import 'dart:html' as html if (dart.library.io) 'dart:io';////
import 'dart:io';

//import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
// import 'dart:io' as io;
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter_archive/flutter_archive.dart';
// import 'dart:typed_data';
// import 'package:path/path.dart' as path;
// import 'dart:io' as io;
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:archive/archive.dart'; // Asegúrate de importar esta biblioteca
// import 'package:path/path.dart' as path;

Future<void> downloadExcelMobile(List<int> fileBytes, 
String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    // Compartir el archivo utilizando el paquete share
    Share.shareFiles([file.path], text: 'Datos Hidrológicos');
  } catch (e) {
    print('Error al guardar el archivo: $e');
  }
}
// Future<void> downloadCSV(List<int> fileBytes, String fileName) async {
//   try {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/$fileName');
//     await file.writeAsBytes(fileBytes, flush: true);

//     // Compartir el archivo utilizando el paquete share
//     Share.shareFiles([file.path], text: 'Datos Hidrológicos');
//   } catch (e) {
//     print('Error al guardar el archivo: $e');
//   }
// }


Future<void> downloadExcelMobile2(List<int> fileBytes,
String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    // Compartir el archivo utilizando el paquete share
    Share.shareFiles([file.path], text: 'Umbrales');
  } catch (e) {
    print('Error al guardar el archivo: $e');
  }
}






// Future<void> exportToCSVWeb(List<int> csvBytes, String fileName) async {
//   final blob = html.Blob([csvBytes]);
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   final anchor = html.AnchorElement(href: url)
//     ..setAttribute("download", fileName)
//     ..click();
//   html.Url.revokeObjectUrl(url);
// }



// Future<void> exportToCSVWeb(List<int> csvBytes, String fileName) async {
//   if (kIsWeb) {
//     // Código específico de la web
//     final blob = html.Blob([csvBytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", fileName)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   } else {
//     // Código para otras plataformas (móvil)
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/$fileName';
//     final file = File(path);
//     await file.writeAsBytes(csvBytes);
//   }
// }




// Future<void> downloadExcelWebCSV(List<int> fileBytes, 
// String fileName) async {
//   try {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/$fileName');
//     await file.writeAsBytes(fileBytes, flush: true);

//     // Compartir el archivo utilizando el paquete share
//     Share.shareFiles([file.path], text: 'Datos Hidrológicos CSV');
//   } catch (e) {
//     print('Error al guardar el archivo: $e');
//   }
// }





// Future<void> downloadExcelMobile(Uint8List fileBytes, String fileName) async {
//   try {
//     final directory = await getExternalStorageDirectory(); // Obtén el directorio de almacenamiento externo
//     final path = '${directory!.path}/$fileName'; // Ruta del archivo
//     final file = File(path);

//     await file.writeAsBytes(fileBytes); // Escribe los bytes en el archivo

//     // Abre el archivo usando el paquete open_file
//     OpenFile.open(path);
//   } catch (e) {
//     print('Error al guardar el archivo: $e');
//   }
// }

