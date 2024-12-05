// import 'package:flutter/foundation.dart'; // Para verificar la plataforma
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// String buildPageContent({String sitekey = "", String theme = "", String start = "auto", String lang = "", String puzzleEndpoint = ""}) {
//   return """
// <!DOCTYPE html>
// <html>
//   <head>
//     <meta charset="utf-8">
//     <title>Friendly Captcha Verification</title>

//     <script type="module" src="https://cdn.jsdelivr.net/npm/friendly-challenge@0.9.18/widget.module.min.js"></script>
//     <script nomodule src="https://cdn.jsdelivr.net/npm/friendly-challenge@0.9.18/widget.min.js"></script>
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <style>
//         html, body {
//             margin: 0;
//             padding: 0;
//             display: flex;
//             justify-content: center;
//             align-items: center;
//             height: 100%;
//             font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
//             ${theme == "dark" ? "background-color: #000;" : ""}
//         }
//     </style>
//   </head>
//   <body>
//     <form action="POST" method="?">
//       <div class="frc-captcha ${theme}" data-sitekey="${sitekey}" data-start="${start}" data-callback="doneCallback" data-lang="${lang}" data-puzzle-endpoint="${puzzleEndpoint}"></div>
//     </form>
//     <script>
//       let isFlutterInAppWebViewReady = false;
//       window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
//        isFlutterInAppWebViewReady = true;
//       });
//       function doneCallback(solution) {
//         if (!isFlutterInAppWebViewReady) { setTimeout(function(){doneCallback(solution)}, 500); } // Try again after 500ms
//         window.flutter_inappwebview.callHandler('solutionCallback', {solution: solution});
//       }
//     </script>
//   </body>
// </html>
// """;
// }

// class FriendlyCaptchaWidget extends StatelessWidget {
//   final Function(String solution) callback;
//   final String sitekey;
//   final String lang;
//   final String theme;

//   FriendlyCaptchaWidget({
//     required this.sitekey,
//     required this.callback,
//     this.lang = "en",
//     this.theme = "light",
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb) {
//       // Si es una aplicación web, mostramos el contenido HTML en un WebView.
//       String htmlSource = buildPageContent(
//         sitekey: sitekey,
//         lang: lang,
//         theme: theme,
//       );
//       return InAppWebView(
//         initialData: InAppWebViewInitialData(data: htmlSource),
//         initialOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(
//             useShouldOverrideUrlLoading: true,
//             disableContextMenu: true,
//             clearCache: true,
//             incognito: true,
//           ),
//         ),
//         onWebViewCreated: (InAppWebViewController w) {
//           w.addJavaScriptHandler(
//             handlerName: 'solutionCallback',
//             callback: (args) {
//               callback(args[0]["solution"]);
//             },
//           );
//         },
//       );
//     } else {
//       // Si es una app móvil, utilizamos el widget FriendlyCaptcha para Flutter
//       return FriendlyCaptchaWidget(
//         callback: callback,
//         sitekey: sitekey,
//         lang: lang,
//         theme: theme,
//       );
//     }
//   }
// }
