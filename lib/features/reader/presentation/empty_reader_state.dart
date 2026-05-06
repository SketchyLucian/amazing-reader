import 'package:flutter/material.dart';

class EmptyReaderState extends StatelessWidget {
  const EmptyReaderState({super.key, required this.onOpenPdf});

  final VoidCallback? onOpenPdf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Open a PDF to start reading',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The reader supports local PDF files on Android, Windows, and web.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onOpenPdf,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
