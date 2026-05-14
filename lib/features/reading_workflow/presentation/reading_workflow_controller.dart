import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reading_workflow_models.dart';

final readingWorkflowControllerProvider =
    NotifierProvider<ReadingWorkflowController, ReadingWorkflowState>(
      ReadingWorkflowController.new,
    );

@immutable
class ReadingWorkflowState {
  const ReadingWorkflowState({
    this.projects = const <ReadingProject>[],
    this.sections = const <ReadingSection>[],
    this.notes = const <ReadingNote>[],
    this.reviewItems = const <ReviewItem>[],
  });

  final List<ReadingProject> projects;
  final List<ReadingSection> sections;
  final List<ReadingNote> notes;
  final List<ReviewItem> reviewItems;

  List<ReadingProject> get activeProjects {
    return projects
        .where((project) => project.status == ReadingProjectStatus.active)
        .toList(growable: false);
  }

  ReadingProject? projectById(String id) {
    for (final project in projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  List<ReadingSection> sectionsForProject(String projectId) {
    return sections
        .where((section) => section.projectId == projectId)
        .toList(growable: false);
  }

  List<ReadingNote> notesForProject(String projectId) {
    final projectNotes = notes
        .where((note) => note.projectId == projectId)
        .toList(growable: false);

    return projectNotes.reversed.toList(growable: false);
  }

  List<ReviewItem> reviewItemsForProject(String projectId) {
    return reviewItems
        .where((item) => item.projectId == projectId)
        .toList(growable: false);
  }

  List<ReviewItem> dueReviewItems([DateTime? now]) {
    final currentTime = now ?? DateTime.now();
    return reviewItems
        .where((item) => item.isDue(currentTime))
        .toList(growable: false);
  }

  ReadingWorkflowState copyWith({
    List<ReadingProject>? projects,
    List<ReadingSection>? sections,
    List<ReadingNote>? notes,
    List<ReviewItem>? reviewItems,
  }) {
    return ReadingWorkflowState(
      projects: projects ?? this.projects,
      sections: sections ?? this.sections,
      notes: notes ?? this.notes,
      reviewItems: reviewItems ?? this.reviewItems,
    );
  }
}

class ReadingWorkflowController extends Notifier<ReadingWorkflowState> {
  @override
  ReadingWorkflowState build() => const ReadingWorkflowState();

  String createProject({
    required String title,
    required String goal,
    required ReadingUseCase useCase,
    required String stakesNote,
    required ReadingScore score,
    ReadingStrategy? selectedStrategy,
    String? documentName,
    String? documentPath,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final recommendedStrategy = score.recommendedStrategy;
    final project = ReadingProject(
      id: _createId('project', timestamp, state.projects.length),
      title: title,
      goal: goal,
      useCase: useCase,
      stakesNote: stakesNote,
      score: score,
      recommendedStrategy: recommendedStrategy,
      selectedStrategy: selectedStrategy ?? recommendedStrategy,
      status: ReadingProjectStatus.active,
      createdAt: timestamp,
      updatedAt: timestamp,
      documentName: documentName,
      documentPath: documentPath,
    );

    state = state.copyWith(
      projects: <ReadingProject>[...state.projects, project],
    );
    return project.id;
  }

  void setSelectedStrategy(String projectId, ReadingStrategy strategy) {
    _updateProject(
      projectId,
      (project, now) =>
          project.copyWith(selectedStrategy: strategy, updatedAt: now),
    );
  }

  String addSection({
    required String projectId,
    required String title,
    required ReadingSectionPriority priority,
    int? startPage,
    int? endPage,
    String note = '',
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final section = ReadingSection(
      id: _createId('section', timestamp, state.sections.length),
      projectId: projectId,
      title: title,
      startPage: startPage,
      endPage: endPage,
      priority: priority,
      status: ReadingSectionStatus.unread,
      note: note,
      createdAt: timestamp,
    );

    state = state.copyWith(
      sections: <ReadingSection>[...state.sections, section],
    );
    return section.id;
  }

  void setSectionStatus(String sectionId, ReadingSectionStatus status) {
    state = state.copyWith(
      sections: [
        for (final section in state.sections)
          if (section.id == sectionId)
            section.copyWith(status: status)
          else
            section,
      ],
    );
  }

  String addNote({
    required String projectId,
    required ReadingNoteType type,
    required String text,
    int? pageNumber,
    String? sectionTitle,
    String quoteOrEvidence = '',
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final note = ReadingNote(
      id: _createId('note', timestamp, state.notes.length),
      projectId: projectId,
      pageNumber: pageNumber,
      sectionTitle: sectionTitle,
      type: type,
      text: text,
      quoteOrEvidence: quoteOrEvidence,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    state = state.copyWith(notes: <ReadingNote>[...state.notes, note]);
    return note.id;
  }

  void updateSynthesis(String projectId, String synthesisText) {
    _updateProject(
      projectId,
      (project, now) =>
          project.copyWith(synthesisText: synthesisText, updatedAt: now),
    );
  }

  String addReviewItem({
    required String projectId,
    required String prompt,
    required int intervalDays,
    int? pageNumber,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final reviewItem = ReviewItem(
      id: _createId('review', timestamp, state.reviewItems.length),
      projectId: projectId,
      prompt: prompt,
      dueDate: timestamp.add(Duration(days: intervalDays)),
      intervalDays: intervalDays,
      status: ReviewItemStatus.pending,
      createdAt: timestamp,
      pageNumber: pageNumber,
    );

    state = state.copyWith(
      reviewItems: <ReviewItem>[...state.reviewItems, reviewItem],
    );
    return reviewItem.id;
  }

  void setReviewItemStatus(String itemId, ReviewItemStatus status) {
    state = state.copyWith(
      reviewItems: [
        for (final item in state.reviewItems)
          if (item.id == itemId) item.copyWith(status: status) else item,
      ],
    );
  }

  void _updateProject(
    String projectId,
    ReadingProject Function(ReadingProject project, DateTime now) update,
  ) {
    final timestamp = DateTime.now();
    state = state.copyWith(
      projects: [
        for (final project in state.projects)
          if (project.id == projectId) update(project, timestamp) else project,
      ],
    );
  }

  static String _createId(String prefix, DateTime timestamp, int index) {
    return '$prefix-${timestamp.microsecondsSinceEpoch}-$index';
  }
}
