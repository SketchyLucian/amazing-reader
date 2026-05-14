import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/reading_workflow_models.dart';
import 'reading_workflow_controller.dart';
import 'reading_workflow_labels.dart';

class ReadingDashboardScreen extends ConsumerWidget {
  const ReadingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(readingWorkflowControllerProvider);
    final activeProjects = workflowState.activeProjects;
    final dueReviews = workflowState.dueReviewItems();

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Dashboard')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _DashboardHeader(
                  activeCount: activeProjects.length,
                  dueReviewCount: dueReviews.length,
                  onStartProject: () => context.goNamed('newReadingProject'),
                ),
                const SizedBox(height: 24),
                _DueReviewsSection(
                  reviews: dueReviews,
                  state: workflowState,
                  onOpenProject: (projectId) => context.goNamed(
                    'readingWorkspace',
                    pathParameters: {'projectId': projectId},
                  ),
                ),
                const SizedBox(height: 24),
                _ActiveProjectsSection(
                  projects: activeProjects,
                  dueReviews: dueReviews,
                  onOpenProject: (projectId) => context.goNamed(
                    'readingWorkspace',
                    pathParameters: {'projectId': projectId},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.activeCount,
    required this.dueReviewCount,
    required this.onStartProject,
  });

  final int activeCount;
  final int dueReviewCount;
  final VoidCallback onStartProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reading Dashboard', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              '$activeCount active projects - $dueReviewCount reviews due',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: onStartProject,
          icon: const Icon(Icons.add),
          label: const Text('Start reading project'),
        ),
      ],
    );
  }
}

class _DueReviewsSection extends StatelessWidget {
  const _DueReviewsSection({
    required this.reviews,
    required this.state,
    required this.onOpenProject,
  });

  final List<ReviewItem> reviews;
  final ReadingWorkflowState state;
  final ValueChanged<String> onOpenProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due reviews', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          Text(
            'No review prompts are due.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...reviews.map((review) {
            final project = state.projectById(review.projectId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: Text(review.prompt, maxLines: 2),
              subtitle: Text(project?.title ?? 'Unknown project'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenProject(review.projectId),
            );
          }),
      ],
    );
  }
}

class _ActiveProjectsSection extends StatelessWidget {
  const _ActiveProjectsSection({
    required this.projects,
    required this.dueReviews,
    required this.onOpenProject,
  });

  final List<ReadingProject> projects;
  final List<ReviewItem> dueReviews;
  final ValueChanged<String> onOpenProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active projects', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (projects.isEmpty)
          _EmptyProjectsMessage(
            onStartProject: () => context.goNamed('newReadingProject'),
          )
        else
          ...projects.map((project) {
            final dueCount = dueReviews
                .where((review) => review.projectId == project.id)
                .length;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.menu_book),
              title: Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${project.selectedStrategy.label} read - '
                '${project.score.total}/12 score - '
                '$dueCount due reviews',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenProject(project.id),
            );
          }),
      ],
    );
  }
}

class _EmptyProjectsMessage extends StatelessWidget {
  const _EmptyProjectsMessage({required this.onStartProject});

  final VoidCallback onStartProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a project to plan a full, hybrid, or selective read.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onStartProject,
            icon: const Icon(Icons.add),
            label: const Text('Create first project'),
          ),
        ],
      ),
    );
  }
}
