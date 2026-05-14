import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'empty_reader_state.dart';
import 'flip_reader_view.dart';
import 'pdf_reader_view.dart';
import 'reader_controller.dart';
import 'reader_message_banner.dart';
import 'reader_state.dart';
import 'reader_toolbar.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    this.title = 'Book Reader',
    this.leading,
    this.workflowPanel,
  });

  final String title;
  final Widget? leading;
  final Widget? workflowPanel;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();

  Future<void> _goToRelativePage(int offset) async {
    final pageStatus = ref.read(readerControllerProvider).pageStatus;
    final pageCount = pageStatus.pageCount;
    if (pageCount == null) return;

    final currentPage = pageStatus.currentPage ?? 1;
    await _goToPageNumber(currentPage + offset);
  }

  Future<void> _goToPageNumber(int pageNumber) async {
    final readerState = ref.read(readerControllerProvider);
    final pageStatus = readerState.pageStatus;
    final pageCount = pageStatus.pageCount;
    if (pageCount == null) return;

    final nextPage = math.max(1, math.min(pageCount, pageNumber));
    if (nextPage == pageStatus.currentPage) return;

    if (readerState.readerMode.isFlip) {
      ref.read(readerControllerProvider.notifier).setCurrentPage(nextPage);
      return;
    }

    if (!_pdfController.isReady) return;

    await _pdfController.goToPage(
      pageNumber: nextPage,
      duration: const Duration(milliseconds: 180),
    );
  }

  void _setReaderMode(ReaderMode mode) {
    if (ref.read(readerControllerProvider).readerMode == mode) return;
    ref.read(readerControllerProvider.notifier).setReaderMode(mode);
  }

  void _handleViewerReady(
    PdfDocument document,
    PdfViewerController controller,
  ) {
    if (!mounted) return;
    ref
        .read(readerControllerProvider.notifier)
        .setPageStatus(
          ReaderPageStatus(
            currentPage: controller.pageNumber ?? 1,
            pageCount: document.pages.length,
          ),
        );
  }

  void _handlePageChanged(int? pageNumber) {
    if (!mounted || pageNumber == null) return;
    ref.read(readerControllerProvider.notifier).setCurrentPage(pageNumber);
  }

  void _handleFlipDocumentReady(PdfDocument document) {
    if (!mounted) return;

    final pageCount = document.pages.length;
    final requestedPage =
        ref.read(readerControllerProvider).pageStatus.currentPage ?? 1;
    final currentPage = math.max(1, math.min(pageCount, requestedPage));
    ref
        .read(readerControllerProvider.notifier)
        .setPageStatus(
          ReaderPageStatus(currentPage: currentPage, pageCount: pageCount),
        );
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerControllerProvider);
    final readerController = ref.read(readerControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final document = readerState.document;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: widget.leading,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: readerState.isOpening
                  ? null
                  : readerController.openPdf,
              icon: readerState.isOpening
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open),
              label: const Text('Open PDF'),
            ),
          ),
        ],
      ),
      body: _ReaderWorkspaceLayout(
        workflowPanel: widget.workflowPanel,
        child: Column(
          children: [
            ReaderToolbar(
              document: document,
              pageStatus: readerState.pageStatus,
              readerMode: readerState.readerMode,
              onReaderModeChanged: _setReaderMode,
              onPreviousPage: () => _goToRelativePage(-1),
              onNextPage: () => _goToRelativePage(1),
              onGoToPage: _goToPageNumber,
            ),
            if (readerState.errorMessage != null)
              ReaderMessageBanner(
                message: readerState.errorMessage!,
                onDismiss: readerController.clearError,
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: document == null
                    ? EmptyReaderState(
                        onOpenPdf: readerState.isOpening
                            ? null
                            : readerController.openPdf,
                      )
                    : readerState.readerMode.isFlip
                    ? FlipReaderView(
                        key: ValueKey('flip-${document.id}'),
                        document: document,
                        pageStatus: readerState.pageStatus,
                        onDocumentReady: _handleFlipDocumentReady,
                        onPageChanged: _handlePageChanged,
                      )
                    : PdfReaderView(
                        key: ValueKey('scroll-${document.id}'),
                        controller: _pdfController,
                        document: document,
                        initialPageNumber:
                            readerState.pageStatus.currentPage ?? 1,
                        onViewerReady: _handleViewerReady,
                        onPageChanged: _handlePageChanged,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderWorkspaceLayout extends StatelessWidget {
  const _ReaderWorkspaceLayout({required this.child, this.workflowPanel});

  final Widget child;
  final Widget? workflowPanel;

  @override
  Widget build(BuildContext context) {
    final workflowPanel = this.workflowPanel;
    if (workflowPanel == null) return child;

    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            key: const ValueKey('reader-workspace-wide'),
            children: [
              Expanded(child: child),
              SizedBox(
                width: 380,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      left: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: workflowPanel,
                ),
              ),
            ],
          );
        }

        final panelHeight = (constraints.maxHeight * 0.36).clamp(220.0, 320.0);
        return Column(
          key: const ValueKey('reader-workspace-compact'),
          children: [
            Expanded(child: child),
            SizedBox(
              height: panelHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: workflowPanel,
              ),
            ),
          ],
        );
      },
    );
  }
}
