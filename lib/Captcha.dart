// import 'dart:async';

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart'; // Importar el paquete Android

// class CaptchaScreen extends StatefulWidget {
//   @override
//   _CaptchaScreenState createState() => _CaptchaScreenState();
// }

// class _CaptchaScreenState extends State<CaptchaScreen> {
//   late WebViewController controller;

//   @override
//   void initState() {
//     super.initState();
//     // Inicializamos WebView en el initState
//     WebViewPlatform.instance = SurfaceAndroidWebView();
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted) // Habilitar JavaScript
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             print('Page started: $url');
//           },
//           onPageFinished: (String url) {
//             print('Page finished: $url');
//           },
//           onHttpError: (HttpResponseError error) {
//             print('HTTP Error: $error');
//           },
//           onWebResourceError: (WebResourceError error) {
//             print('Web resource error: $error');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Condición para bloquear ciertas URLs (por ejemplo, YouTube)
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://YOUR-DOMAIN.com/fluttercaptcha.html')); // URL de tu página HTML
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Captcha Screen'),
//       ),
//       body: WebViewWidget(controller: controller), // Pasamos el WebViewController
//     );
//   }
// }