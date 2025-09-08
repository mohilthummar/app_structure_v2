// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MyWebView extends StatefulWidget {
//   final String webURL;
//   final String? title;
//   final Widget? myWidget;

//   const MyWebView({super.key, required this.webURL, this.title, this.myWidget});

//   @override
//   State<MyWebView> createState() => _MyWebViewState();
// }

// class _MyWebViewState extends State<MyWebView> {
//   late final WebViewController controller;
//   RxBool isLoading = true.obs;

//   @override
//   void initState() {
//     super.initState();
//     try {
//       controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(const Color(0x00000000))
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onProgress: (int progress) {},
//             onPageStarted: (String url) {},
//             onPageFinished: (String url) {
//               isLoading.value = false;
//             },
//             onUrlChange: (UrlChange change) {},
//             onWebResourceError: (WebResourceError error) {
//               printYellow('Error loading page: ${error.description}');
//               isLoading.value = false;
//             },
//             onNavigationRequest: (NavigationRequest request) {
//               if (request.url.startsWith('https://www.youtube.com/')) {
//                 return NavigationDecision.prevent;
//               }
//               return NavigationDecision.navigate;
//             },
//           ),
//         )
//         ..loadRequest(Uri.parse(widget.webURL));
//     } catch (e) {
//       printOkStatus(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: !isValEmpty(widget.title) ? AppBar(title: Text(widget.title ?? "")) : null,
//       body: Obx(
//         () => AnimatedSwitcher(
//           duration: const Duration(seconds: 1),
//           child: isLoading.isFalse ? WebViewWidget(controller: controller, gestureRecognizers: {Factory(() => VerticalDragGestureRecognizer())}) : CircularLoader(color: Theme.of(context).primaryColor),
//         ),
//       ),
//     );
//   }
// }
