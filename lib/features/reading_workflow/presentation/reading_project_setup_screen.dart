import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/reading_workflow_models.dart';
import 'reading_workflow_controller.dart';
import 'reading_workflow_labels.dart';

class ReadingProjectSetupScreen extends ConsumerStatefulWidget {
  const ReadingProjectSetupScreen({super.key});

  @override
  ConsumerState<ReadingProjectSetupScreen> createState() {
    return _ReadingProjectSetupScreenState();
  }
}

class _ReadingProjectSetupScreenState
    extends ConsumerState<ReadingProjectSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _stakesController = TextEditingController();

  ReadingUseCase _useCase = ReadingUseCase.professional;
  ReadingScore _score = const ReadingScore.zero();
  ReadingStrategy _selectedStrategy = ReadingStrategy.selective;
  bool _hasManualStrategyOverride = false;

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _stakesController.dispose();
    super.dispose();
  }

  void _updateCriterion(ReadingScoreCriterion criterion, int value) {
    setState(() {
      _score = _score.copyWithCriterion(criterion, value);
      if (!_hasManualStrategyOverride) {
        _selectedStrategy = _score.recommendedStrategy;
      }
    });
  }

  void _selectStrategy(ReadingStrategy strategy) {
    setState(() {
      _selectedStrategy = strategy;
      _hasManualStrategyOverride = strategy != _score.recommendedStrategy;
    });
  }

  void _createProject() {
    if (!_formKey.currentState!.validate()) return;

    final projectId = ref
        .read(readingWorkflowControllerProvider.notifier)
        .createProject(
          title: _titleController.text.trim(),
          goal: _goalController.text.trim(),
          useCase: _useCase,
          stakesNote: _stakesController.text.trim(),
          score: _score,
          selectedStrategy: _selectedStrategy,
        );

    context.goNamed(
      'readingWorkspace',
      pathParameters: {'projectId': projectId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendedStrategy = _score.recommendedStrategy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New reading project'),
        leading: BackButton(onPressed: () => context.goNamed('dashboard')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Project setup', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Score the reading context, then choose the reading mode.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Book or document title',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      labelText: 'Reading goal',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ReadingUseCase>(
                    initialValue: _useCase,
                    decoration: const InputDecoration(
                      labelText: 'Use case',
                      border: OutlineInputBorder(),
                    ),
                    items: ReadingUseCase.values
                        .map(
                          (useCase) => DropdownMenuItem(
                            value: useCase,
                            child: Text(useCase.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (useCase) {
                      if (useCase == null) return;
                      setState(() => _useCase = useCase);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stakesController,
                    decoration: const InputDecoration(
                      labelText: 'Deadline or stakes note',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Text('Reading score', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...ReadingScoreCriterion.values.map((criterion) {
                    return _ScoreCriterionControl(
                      criterion: criterion,
                      value: _score.valueFor(criterion),
                      onChanged: (value) => _updateCriterion(criterion, value),
                    );
                  }),
                  const SizedBox(height: 16),
                  _ReadingStrategySummary(
                    score: _score,
                    recommendedStrategy: recommendedStrategy,
                    selectedStrategy: _selectedStrategy,
                    onStrategyChanged: _selectStrategy,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const ValueKey('create-reading-project-button'),
                    onPressed: _createProject,
                    icon: const Icon(Icons.check),
                    label: const Text('Create project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}

class _ScoreCriterionControl extends StatelessWidget {
  const _ScoreCriterionControl({
    required this.criterion,
    required this.value,
    required this.onChanged,
  });

  final ReadingScoreCriterion criterion;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selector = SegmentedButton<int>(
          showSelectedIcon: false,
          selected: <int>{value},
          onSelectionChanged: (selection) => onChanged(selection.single),
          segments: const [
            ButtonSegment(value: 0, label: Text('0')),
            ButtonSegment(value: 1, label: Text('1')),
            ButtonSegment(value: 2, label: Text('2')),
          ],
        );

        if (constraints.maxWidth < 520) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(criterion.label),
                const SizedBox(height: 8),
                selector,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(criterion.label)),
              selector,
            ],
          ),
        );
      },
    );
  }
}

class _ReadingStrategySummary extends StatelessWidget {
  const _ReadingStrategySummary({
    required this.score,
    required this.recommendedStrategy,
    required this.selectedStrategy,
    required this.onStrategyChanged,
  });

  final ReadingScore score;
  final ReadingStrategy recommendedStrategy;
  final ReadingStrategy selectedStrategy;
  final ValueChanged<ReadingStrategy> onStrategyChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended: ${recommendedStrategy.label} (${score.total}/12)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              recommendedStrategy.helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ReadingStrategy>(
              selected: <ReadingStrategy>{selectedStrategy},
              onSelectionChanged: (selection) {
                onStrategyChanged(selection.single);
              },
              segments: ReadingStrategy.values
                  .map(
                    (strategy) => ButtonSegment(
                      value: strategy,
                      label: Text(strategy.label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
