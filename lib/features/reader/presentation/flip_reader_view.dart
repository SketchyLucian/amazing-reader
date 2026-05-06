import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:turnable_page/turnable_page.dart';

import '../domain/reader_document.dart';
import 'reader_state.dart';

class FlipReaderView extends StatefulWidget {
  const FlipReaderView({
    super.key,
    required this.document,
    required this.pageStatus,
    required this.onDocumentReady,
    required this.onPageChanged,
  });

  final ReaderDocument document;
  final ReaderPageStatus pageStatus;
  final ValueChanged<PdfDocument> onDocumentReady;
  final ValueChanged<int> onPageChanged;

  @override
  State<FlipReaderView> createState() => _FlipReaderViewState();
}

class _FlipReaderViewState extends State<FlipReaderView> {
  late PdfDocumentRef _documentRef;
  int? _reportedPageCount;
  final PageFlipController _flipController = PageFlipController();

  @override
  void initState() {
    super.initState();
    _documentRef = _buildDocumentRef(widget.document);
  }

  @override
  void didUpdateWidget(covariant FlipReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.document.id != oldWidget.document.id) {
      _documentRef = _buildDocumentRef(widget.document);
      _reportedPageCount = null;
    }

    final newPage = widget.pageStatus.currentPage ?? 1;
    final oldPage = oldWidget.pageStatus.currentPage ?? 1;
    if (newPage != oldPage &&
        newPage != (_flipController.currentPageIndex + 1)) {
      _flipController.goToPage(newPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: PdfDocumentViewBuilder(
        documentRef: _documentRef,
        loadingBuilder: _buildDocumentLoading,
        errorBuilder: _buildDocumentError,
        builder: (context, document) {
          if (document == null) return _buildDocumentLoading(context);

          _notifyDocumentReady(document);

          final pageNumber = _clampPageNumber(
            widget.pageStatus.currentPage,
            document.pages.length,
          );

          return TurnablePage(
            controller: _flipController,
            pageCount: document.pages.length,
            onPageChanged: (leftIndex, rightIndex) {
              widget.onPageChanged(leftIndex + 1);
            },
            settings: FlipSettings(
              startPageIndex: pageNumber - 1,
              drawShadow: true,
              cornerTriggerAreaSize: 1.0,
            ),
            builder: (context, index, constraints) {
              return _FlipPage(document: document, pageNumber: index + 1);
            },
          );
        },
      ),
    );
  }

  void _notifyDocumentReady(PdfDocument document) {
    final pageCount = document.pages.length;
    if (_reportedPageCount == pageCount) return;

    _reportedPageCount = pageCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDocumentReady(document);
    });
  }

  static int _clampPageNumber(int? pageNumber, int pageCount) {
    return math.max(1, math.min(pageCount, pageNumber ?? 1));
  }

  static PdfDocumentRef _buildDocumentRef(ReaderDocument document) {
    final bytes = document.bytes;
    if (bytes != null) {
      return PdfDocumentRefData(bytes, sourceName: document.sourceName);
    }

    return PdfDocumentRefFile(document.path!);
  }

  static Widget _buildDocumentLoading(BuildContext context) {
    return const Center(
      child: SizedBox.square(dimension: 44, child: CircularProgressIndicator()),
    );
  }

  static Widget _buildDocumentError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
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

class _FlipPage extends StatelessWidget {
  const _FlipPage({required this.document, required this.pageNumber});

  final PdfDocument document;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return PdfPageView(
      document: document,
      pageNumber: pageNumber,
      maximumDpi: 220,
      backgroundColor: Colors.white,
      decoration: const BoxDecoration(color: Colors.white),
    );
  }
}
