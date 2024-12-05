import 'dart:html' as html;

// Future<void> downloadExcelWeb(List<int> fileBytes, String fileName) async {
//   try {
//     final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
//     final url = html.Url.createObjectUrlFromBlob(blob);

//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", fileName)
//       ..click();

//     html.Url.revokeObjectUrl(url);
//   } catch (e) {
//     print('Error al descargar el archivo: $e');
//   }
// }

Future<void> downloadExcelWeb(List<int> fileBytes, String fileName) async {
  final blob = html.Blob([fileBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
