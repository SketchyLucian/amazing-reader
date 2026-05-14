import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../reader/presentation/reader_screen.dart';
import 'reading_workflow_controller.dart';
import 'reading_workflow_panel.dart';

class ReadingWorkspaceScreen extends ConsumerWidget {
  const ReadingWorkspaceScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref
        .watch(readingWorkflowControllerProvider)
        .projectById(projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Project not found'),
          leading: BackButton(onPressed: () => context.goNamed('dashboard')),
        ),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => context.goNamed('dashboard'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to dashboard'),
          ),
        ),
      );
    }

    return ReaderScreen(
      title: project.title,
      leading: BackButton(onPressed: () => context.goNamed('dashboard')),
      workflowPanel: ReadingWorkflowPanel(projectId: projectId),
    );
  }
}
