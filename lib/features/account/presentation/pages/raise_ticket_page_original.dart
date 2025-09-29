import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RaiseTicketPage extends StatefulWidget {
  const RaiseTicketPage({super.key});

  @override
  State<RaiseTicketPage> createState() => _RaiseTicketPageState();
}

class _RaiseTicketPageState extends State<RaiseTicketPage> {
  late final WebViewController _controller;
  bool _loading = true;
  final String ticketURL = 'https://support.artisansbridge.com/';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) async {
            // Inject dark-mode CSS similar to GetX app
            const js = '''(function(){
              let style = document.createElement('style');
              style.type = 'text/css';
              style.innerHTML = `
                body { background-color: #121212 !important; color: #e0e0e0 !important; }
                a { color: #bb86fc !important; }
                input, textarea, select, button {
                  background-color: #2a2a2a !important; color: #e0e0e0 !important; border: 1px solid #444 !important;
                }
              `;
              document.head.appendChild(style);
            })();''';
            try {
              await _controller.runJavaScript(js);
            } catch (_) {
              // Ignore JS result issues; styling is best-effort only
            }
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(ticketURL));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handleBack();
          if (shouldPop && context.mounted) Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Raise a ticket')),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const ColoredBox(
                color: Colors.white,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
