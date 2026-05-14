import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_book_reader/features/reading_workflow/domain/reading_workflow_models.dart';
import 'package:minimal_book_reader/features/reading_workflow/presentation/reading_workflow_controller.dart';

void main() {
  group('ReadingScore', () {
    test('recommends selective reading for scores from 0 to 4', () {
      expect(
        const ReadingScore.zero().recommendedStrategy,
        ReadingStrategy.selective,
      );
      expect(
        const ReadingScore(
          costOfBeingWrong: 2,
          citationNeed: 1,
          cumulativeStructure: 1,
          styleImportance: 0,
          expectedRedundancy: 0,
          deadlinePressure: 0,
        ).recommendedStrategy,
        ReadingStrategy.selective,
      );
    });

    test('recommends hybrid reading for scores from 5 to 7', () {
      expect(
        const ReadingScore(
          costOfBeingWrong: 2,
          citationNeed: 2,
          cumulativeStructure: 1,
          styleImportance: 0,
          expectedRedundancy: 0,
          deadlinePressure: 0,
        ).recommendedStrategy,
        ReadingStrategy.hybrid,
      );
      expect(
        const ReadingScore(
          costOfBeingWrong: 2,
          citationNeed: 2,
          cumulativeStructure: 1,
          styleImportance: 1,
          expectedRedundancy: 1,
          deadlinePressure: 0,
        ).recommendedStrategy,
        ReadingStrategy.hybrid,
      );
    });

    test('recommends full reading for scores from 8 to 12', () {
      expect(
        const ReadingScore(
          costOfBeingWrong: 2,
          citationNeed: 2,
          cumulativeStructure: 2,
          styleImportance: 1,
          expectedRedundancy: 1,
          deadlinePressure: 0,
        ).recommendedStrategy,
        ReadingStrategy.full,
      );
    });
  });

  test('stores both recommended and overridden reading strategies', () {
    final container = _createContainer();
    final controller = container.read(
      readingWorkflowControllerProvider.notifier,
    );

    final projectId = controller.createProject(
      title: 'Example Book',
      goal: 'Prepare a decision memo',
      useCase: ReadingUseCase.professional,
      stakesNote: 'Team planning',
      score: const ReadingScore.zero(),
      selectedStrategy: ReadingStrategy.full,
      now: DateTime(2026, 5, 9),
    );

    final project = container
        .read(readingWorkflowControllerProvider)
        .projectById(projectId);
    expect(project, isNotNull);
    expect(project!.recommendedStrategy, ReadingStrategy.selective);
    expect(project.selectedStrategy, ReadingStrategy.full);
  });

  test('records sections, notes, synthesis, and review prompts', () {
    final container = _createContainer();
    final controller = container.read(
      readingWorkflowControllerProvider.notifier,
    );
    final now = DateTime(2026, 5, 9);
    final projectId = controller.createProject(
      title: 'Example Book',
      goal: 'Learn the framework',
      useCase: ReadingUseCase.academic,
      stakesNote: '',
      score: const ReadingScore.zero(),
      now: now,
    );

    final sectionId = controller.addSection(
      projectId: projectId,
      title: 'Chapter 1',
      priority: ReadingSectionPriority.high,
      startPage: 1,
      endPage: 12,
      now: now,
    );
    controller.setSectionStatus(sectionId, ReadingSectionStatus.done);
    controller.addNote(
      projectId: projectId,
      type: ReadingNoteType.claim,
      text: 'The author frames reading as a workflow.',
      pageNumber: 4,
      now: now,
    );
    controller.updateSynthesis(
      projectId,
      '3 claims, 2 objections, 1 application',
    );
    controller.addReviewItem(
      projectId: projectId,
      prompt: 'Explain the main claim without opening the book.',
      intervalDays: 1,
      now: now,
    );

    final state = container.read(readingWorkflowControllerProvider);
    expect(
      state.sectionsForProject(projectId).single.status,
      ReadingSectionStatus.done,
    );
    expect(state.notesForProject(projectId).single.pageNumber, 4);
    expect(state.projectById(projectId)!.synthesisText, contains('3 claims'));
    expect(state.dueReviewItems(DateTime(2026, 5, 10)), hasLength(1));
  });
}

ProviderContainer _createContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}
