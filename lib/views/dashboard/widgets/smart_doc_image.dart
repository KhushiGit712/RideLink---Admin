import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class SmartDocImage extends StatefulWidget {
  final String imageUrl;
  final String label;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showOpenButton;

  const SmartDocImage({
    super.key,
    required this.imageUrl,
    required this.label,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.onTap,
    this.showOpenButton = true,
  });

  /// Returns the raw URL trimmed
  static String sanitizeUrl(String url) {
    return url.trim();
  }

  @override
  State<SmartDocImage> createState() => _SmartDocImageState();
}

class _SmartDocImageState extends State<SmartDocImage> {
  int _attemptTier =
      1; // 1: Direct, 2: wsrv.nl proxy, 3: corsproxy.io, 4: Failed
  late String _cleanUrl;

  @override
  void initState() {
    super.initState();
    _cleanUrl = SmartDocImage.sanitizeUrl(widget.imageUrl);
  }

  @override
  void didUpdateWidget(covariant SmartDocImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _cleanUrl = SmartDocImage.sanitizeUrl(widget.imageUrl);
        _attemptTier = 1;
      });
    }
  }

  void _handleError(Object? error) {
    debugPrint(
      '[SmartDocImage] Tier $_attemptTier failed for "${widget.label}": $error',
    );
    if (mounted && _attemptTier <= 3) {
      setState(() {
        _attemptTier++;
      });
      debugPrint(
        '[SmartDocImage] Switching to Tier $_attemptTier: ${_getEffectiveUrl()}',
      );
    }
  }

  String _getEffectiveUrl() {
    if (_attemptTier == 1) {
      return _cleanUrl;
    } else if (_attemptTier == 2) {
      // Tier 2: wsrv.nl CORS proxy
      return 'https://wsrv.nl/?url=${Uri.encodeComponent(_cleanUrl)}';
    } else if (_attemptTier == 3) {
      // Tier 3: corsproxy.io
      return 'https://corsproxy.io/?url=${Uri.encodeComponent(_cleanUrl)}';
    }
    return _cleanUrl;
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(_cleanUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cleanUrl.isEmpty) {
      return _buildNoFilePlaceholder();
    }

    // Handle Base64-encoded images
    if (!_cleanUrl.startsWith('http')) {
      return _buildBase64Image(_cleanUrl);
    }

    // If all proxy tiers failed, show interactive fallback
    if (_attemptTier > 3) {
      return _buildFallbackCard();
    }

    final currentUrl = _getEffectiveUrl();

    Widget imageWidget = Image.network(
      currentUrl,
      key: ValueKey('img_${widget.label}_tier_$_attemptTier'),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFF1F5F9),
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Automatically try next tier on error (e.g. CORS or network error)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleError(error);
        });
        return Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFF8FAFC),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF38BDF8),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return InkWell(onTap: widget.onTap, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildBase64Image(String raw) {
    try {
      String clean = raw.trim();
      if (clean.contains(',')) {
        clean = clean.split(',').last;
      }
      final bytes = base64Decode(clean);
      return Image.memory(
        bytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCard(),
      );
    } catch (_) {
      return _buildFallbackCard();
    }
  }

  Widget _buildNoFilePlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height ?? 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFF94A3B8),
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            'No file attached',
            style: AppTextStyle.text12MediumOrSmall.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard() {
    return Container(
      width: widget.width,
      height: widget.height ?? 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Color(0xFFDC2626),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF991B1B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (widget.showOpenButton && _cleanUrl.startsWith('http'))
            InkWell(
              onTap: _openInBrowser,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Open Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
