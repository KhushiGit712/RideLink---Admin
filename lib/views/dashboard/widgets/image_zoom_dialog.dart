import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageZoomDialog extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String? subtitle;

  const ImageZoomDialog({
    super.key,
    required this.title,
    required this.imageUrl,
    this.subtitle,
  });

  static void show({
    required String title,
    required String imageUrl,
    String? subtitle,
  }) {
    Get.dialog(
      ImageZoomDialog(
        title: title,
        imageUrl: imageUrl,
        subtitle: subtitle,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.85),
    );
  }

  @override
  State<ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<ImageZoomDialog> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.5).clamp(1.0, 4.0);
      _transformationController.value =
          Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.5).clamp(1.0, 4.0);
      _transformationController.value =
          Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.imageUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 900,
        height: 680,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.document_scanner_rounded,
                    color: Color(0xFF38BDF8),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyle.text16Medium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Open in full tab button
                  IconButton(
                    onPressed: _openExternal,
                    icon: const Icon(Icons.open_in_new_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Open Full Resolution in Browser',
                  ),
                  const SizedBox(width: 8),
                  // Zoom Controls
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _zoomOut,
                          icon: const Icon(Icons.zoom_out_rounded,
                              color: Colors.white, size: 20),
                          tooltip: 'Zoom Out',
                        ),
                        Text(
                          '${(_currentScale * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _zoomIn,
                          icon: const Icon(Icons.zoom_in_rounded,
                              color: Colors.white, size: 20),
                          tooltip: 'Zoom In',
                        ),
                        IconButton(
                          onPressed: _resetZoom,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 20),
                          tooltip: 'Reset Zoom',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 24),
                    tooltip: 'Close Preview',
                  ),
                ],
              ),
            ),

            // Interactive Image Canvas
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Container(
                  color: const Color(0xFF020617),
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image_rounded,
                                color: Color(0xFFEF4444),
                                size: 54,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Unable to load document image preview',
                                style: AppTextStyle.text14Medium.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
