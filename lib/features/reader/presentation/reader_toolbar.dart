import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/reader_document.dart';
import 'reader_formatters.dart';
import 'reader_state.dart';

class ReaderToolbar extends StatelessWidget {
  const ReaderToolbar({
    super.key,
    required this.document,
    required this.pageStatus,
    required this.readerMode,
    required this.onReaderModeChanged,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onGoToPage,
  });

  final ReaderDocument? document;
  final ReaderPageStatus pageStatus;
  final ReaderMode readerMode;
  final ValueChanged<ReaderMode> onReaderModeChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onGoToPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final document = this.document;
    final modeSelector = _ReaderModeSelector(
      mode: readerMode,
      onModeChanged: onReaderModeChanged,
    );
    final pageControls = _PageControls(
      currentPage: pageStatus.currentPage,
      pageCount: pageStatus.pageCount,
      canNavigate: pageStatus.canNavigate,
      onPreviousPage: onPreviousPage,
      onNextPage: onNextPage,
      onGoToPage: onGoToPage,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 560;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: isCompact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _DocumentSummary(document: document),
                            ),
                            const SizedBox(width: 12),
                            pageControls,
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: modeSelector,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _DocumentSummary(document: document)),
                        const SizedBox(width: 12),
                        modeSelector,
                        const SizedBox(width: 12),
                        pageControls,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ReaderModeSelector extends StatelessWidget {
  const _ReaderModeSelector({required this.mode, required this.onModeChanged});

  final ReaderMode mode;
  final ValueChanged<ReaderMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;

    return SegmentedButton<ReaderMode>(
      showSelectedIcon: false,
      selected: <ReaderMode>{mode},
      onSelectionChanged: (selection) => onModeChanged(selection.single),
      segments: ReaderMode.values
          .map((mode) {
            return ButtonSegment<ReaderMode>(
              value: mode,
              tooltip: mode.tooltip,
              icon: Icon(mode.icon, size: 18),
              label: compact ? null : Text(mode.label),
            );
          })
          .toList(growable: false),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

extension _ReaderModeDetails on ReaderMode {
  String get label {
    return switch (this) {
      ReaderMode.scroll => 'Scroll',
      ReaderMode.flip => 'Flip',
    };
  }

  String get tooltip {
    return switch (this) {
      ReaderMode.scroll => 'Continuous scroll',
      ReaderMode.flip => 'Book flip',
    };
  }

  IconData get icon {
    return switch (this) {
      ReaderMode.scroll => Icons.swap_vert,
      ReaderMode.flip => Icons.auto_stories,
    };
  }
}

class _DocumentSummary extends StatelessWidget {
  const _DocumentSummary({required this.document});

  final ReaderDocument? document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = this.document;

    return Row(
      children: [
        Icon(
          document == null ? Icons.menu_book : Icons.picture_as_pdf,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                document?.name ?? 'No book open',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                document == null
                    ? 'Choose a PDF file to begin.'
                    : formatByteSize(document.sizeInBytes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageControls extends StatelessWidget {
  const _PageControls({
    required this.currentPage,
    required this.pageCount,
    required this.canNavigate,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onGoToPage,
  });

  final int? currentPage;
  final int? pageCount;
  final bool canNavigate;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onGoToPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = currentPage == null || pageCount == null
        ? '- / -'
        : '$currentPage / $pageCount';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Previous page',
          child: IconButton(
            onPressed: canNavigate && (currentPage ?? 1) > 1
                ? onPreviousPage
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
        ),
        SizedBox(
          width: 88,
          child: TextButton(
            onPressed: canNavigate ? () => _showPageJumpDialog(context) : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(72, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
        Tooltip(
          message: 'Next page',
          child: IconButton(
            onPressed: canNavigate && (currentPage ?? 0) < (pageCount ?? 0)
                ? onNextPage
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  Future<void> _showPageJumpDialog(BuildContext context) async {
    final currentPage = this.currentPage;
    final pageCount = this.pageCount;
    if (currentPage == null || pageCount == null) return;

    final controller = TextEditingController(text: currentPage.toString());
    try {
      final pageNumber = await showDialog<int>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Go to page'),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Page number',
                helperText: '1-$pageCount',
              ),
              onSubmitted: (value) {
                Navigator.of(context).pop(int.tryParse(value));
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(int.tryParse(controller.text));
                },
                child: const Text('Go'),
              ),
            ],
          );
        },
      );

      if (pageNumber != null && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onGoToPage(pageNumber);
        });
      }
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }
}
