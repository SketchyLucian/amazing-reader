import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../domain/reader_document.dart';

const _scrollWheelMultiplier = 0.55;

class PdfReaderView extends StatelessWidget {
  const PdfReaderView({
    super.key,
    required this.controller,
    required this.document,
    required this.initialPageNumber,
    required this.onViewerReady,
    required this.onPageChanged,
  });

  final PdfViewerController controller;
  final ReaderDocument document;
  final int initialPageNumber;
  final PdfViewerReadyCallback onViewerReady;
  final PdfPageChangedCallback onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final params = PdfViewerParams(
      margin: 14,
      backgroundColor: colorScheme.surfaceContainerHighest,
      textSelectionParams: const PdfTextSelectionParams(enabled: false),
      pageDropShadow: null,
      limitRenderingCache: true,
      maxImageBytesCachedOnMemory: 48 * 1024 * 1024,
      horizontalCacheExtent: 0.25,
      verticalCacheExtent: 0.75,
      maxScale: 4.0,
      onePassRenderingScaleThreshold: 160 / 72,
      onePassRenderingSizeThreshold: 1600,
      scrollByMouseWheel: _scrollWheelMultiplier,
      linkHandlerParams: null,
      linkWidgetBuilder: null,
      behaviorControlParams: const PdfViewerBehaviorControlParams(
        trailingPageLoadingDelay: Duration(milliseconds: 220),
        pageImageCachingDelay: Duration(milliseconds: 40),
        partialImageLoadingDelay: Duration(milliseconds: 120),
      ),
      onViewerReady: onViewerReady,
      onPageChanged: onPageChanged,
      loadingBannerBuilder: _buildLoadingBanner,
      errorBannerBuilder: _buildPdfError,
    );

    return _buildViewer(
      document: document,
      controller: controller,
      params: params,
      initialPageNumber: initialPageNumber,
    );
  }

  static Widget _buildViewer({
    required ReaderDocument document,
    required PdfViewerController controller,
    required PdfViewerParams params,
    required int initialPageNumber,
  }) {
    final bytes = document.bytes;
    if (bytes != null) {
      return PdfViewer.data(
        bytes,
        sourceName: document.sourceName,
        controller: controller,
        params: params,
        initialPageNumber: initialPageNumber,
      );
    }

    return PdfViewer.file(
      document.path!,
      controller: controller,
      params: params,
      initialPageNumber: initialPageNumber,
    );
  }

  static Widget _buildLoadingBanner(
    BuildContext context,
    int bytesDownloaded,
    int? totalBytes,
  ) {
    final progress = totalBytes == null || totalBytes == 0
        ? null
        : bytesDownloaded / totalBytes;

    return Center(
      child: SizedBox.square(
        dimension: 44,
        child: CircularProgressIndicator(value: progress),
      ),
    );
  }

  static Widget _buildPdfError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    PdfDocumentRef documentRef,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'This PDF could not be rendered.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
