import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart'; // Opcional si deseas compartir el PDF


  // Future<void> guardarArchivoMobile(
  //     List<int> fileBytes, String nombreArchivo) async {
  //   // Lógica personalizada para manejar archivos en Flutter Web sin usar `dart:html`
  //   // Podrías usar bibliotecas como `universal_html` o `http` para enviar el archivo
  //   print('Guardar archivo en la web: $nombreArchivo');
  //   // Implementa el guardado o manejo de archivos para Flutter web aquí.
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/$nombreArchivo');
  //     await file.writeAsBytes(fileBytes, flush: true);

  //     // Compartir el archivo utilizando el paquete share
  //     Share.shareFiles([file.path], text: 'Datos umbrales');
  //   } catch (e) {
  //     print('Error al guardar el archivo: $e');
  //   }
  // }

  Future<void> guardarArchivoMobile(List<int> fileBytes, 
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

