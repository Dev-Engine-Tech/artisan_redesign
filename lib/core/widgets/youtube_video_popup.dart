import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeVideoPopup extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final VoidCallback? onClose;

  const YouTubeVideoPopup({
    super.key,
    required this.videoUrl,
    this.title,
    this.onClose,
  });

  @override
  State<YouTubeVideoPopup> createState() => _YouTubeVideoPopupState();
}

class _YouTubeVideoPopupState extends State<YouTubeVideoPopup> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      // Extract video ID and create embed URL
      final videoId = _extractVideoId(widget.videoUrl);

      if (videoId == null) {
        setState(() => _hasError = true);
        return;
      }

      // Create YouTube embed URL
      final embedUrl =
          'https://www.youtube.com/embed/$videoId?autoplay=0&rel=0&showinfo=0&controls=1';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(embedUrl));
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  String? _extractVideoId(String url) {
    // Handle YouTube Shorts URLs
    final shortsMatch =
        RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (shortsMatch != null) {
      return shortsMatch.group(1);
    }

    // Handle regular YouTube URLs
    final regularMatch =
        RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)').firstMatch(url);
    if (regularMatch != null) {
      return regularMatch.group(1);
    }

    // Handle youtu.be URLs
    final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (shortMatch != null) {
      return shortMatch.group(1);
    }

    return null;
  }

  void _closePopup() {
    try {
      widget.onClose?.call();
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? 'Welcome to Artisans Circle!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closePopup,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Video content
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _hasError ? _buildErrorWidget() : _buildVideoPlayer(),
              ),
            ),

            // Bottom padding and optional message
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Watch this quick tutorial to get started with our platform!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _closePopup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF654321),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Continue to App'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9, // Standard video aspect ratio
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF654321),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load video',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the popup
void showYouTubeVideoPopup(
  BuildContext context, {
  required String videoUrl,
  String? title,
  VoidCallback? onClose,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => YouTubeVideoPopup(
      videoUrl: videoUrl,
      title: title,
      onClose: onClose,
    ),
  );
}
