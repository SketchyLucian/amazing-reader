import 'package:flutter/foundation.dart';

enum ReadingUseCase { academic, professional, leisureNonfiction, literary }

enum ReadingStrategy { selective, hybrid, full }

enum ReadingProjectStatus { active, archived }

enum ReadingScoreCriterion {
  costOfBeingWrong,
  citationNeed,
  cumulativeStructure,
  styleImportance,
  expectedRedundancy,
  deadlinePressure,
}

enum ReadingSectionPriority { high, medium, low }

enum ReadingSectionStatus { unread, reading, done, skipped }

enum ReadingNoteType {
  claim,
  evidence,
  question,
  quote,
  objection,
  application,
}

enum ReviewItemStatus { pending, completed, skipped }

@immutable
class ReadingScore {
  const ReadingScore({
    required this.costOfBeingWrong,
    required this.citationNeed,
    required this.cumulativeStructure,
    required this.styleImportance,
    required this.expectedRedundancy,
    required this.deadlinePressure,
  }) : assert(costOfBeingWrong >= 0 && costOfBeingWrong <= 2),
       assert(citationNeed >= 0 && citationNeed <= 2),
       assert(cumulativeStructure >= 0 && cumulativeStructure <= 2),
       assert(styleImportance >= 0 && styleImportance <= 2),
       assert(expectedRedundancy >= 0 && expectedRedundancy <= 2),
       assert(deadlinePressure >= 0 && deadlinePressure <= 2);

  const ReadingScore.zero()
    : costOfBeingWrong = 0,
      citationNeed = 0,
      cumulativeStructure = 0,
      styleImportance = 0,
      expectedRedundancy = 0,
      deadlinePressure = 0;

  final int costOfBeingWrong;
  final int citationNeed;
  final int cumulativeStructure;
  final int styleImportance;
  final int expectedRedundancy;
  final int deadlinePressure;

  int get total {
    return costOfBeingWrong +
        citationNeed +
        cumulativeStructure +
        styleImportance +
        expectedRedundancy +
        deadlinePressure;
  }

  ReadingStrategy get recommendedStrategy {
    final score = total;
    if (score <= 4) return ReadingStrategy.selective;
    if (score <= 7) return ReadingStrategy.hybrid;
    return ReadingStrategy.full;
  }

  int valueFor(ReadingScoreCriterion criterion) {
    return switch (criterion) {
      ReadingScoreCriterion.costOfBeingWrong => costOfBeingWrong,
      ReadingScoreCriterion.citationNeed => citationNeed,
      ReadingScoreCriterion.cumulativeStructure => cumulativeStructure,
      ReadingScoreCriterion.styleImportance => styleImportance,
      ReadingScoreCriterion.expectedRedundancy => expectedRedundancy,
      ReadingScoreCriterion.deadlinePressure => deadlinePressure,
    };
  }

  ReadingScore copyWithCriterion(ReadingScoreCriterion criterion, int value) {
    return switch (criterion) {
      ReadingScoreCriterion.costOfBeingWrong => copyWith(
        costOfBeingWrong: value,
      ),
      ReadingScoreCriterion.citationNeed => copyWith(citationNeed: value),
      ReadingScoreCriterion.cumulativeStructure => copyWith(
        cumulativeStructure: value,
      ),
      ReadingScoreCriterion.styleImportance => copyWith(styleImportance: value),
      ReadingScoreCriterion.expectedRedundancy => copyWith(
        expectedRedundancy: value,
      ),
      ReadingScoreCriterion.deadlinePressure => copyWith(
        deadlinePressure: value,
      ),
    };
  }

  ReadingScore copyWith({
    int? costOfBeingWrong,
    int? citationNeed,
    int? cumulativeStructure,
    int? styleImportance,
    int? expectedRedundancy,
    int? deadlinePressure,
  }) {
    return ReadingScore(
      costOfBeingWrong: costOfBeingWrong ?? this.costOfBeingWrong,
      citationNeed: citationNeed ?? this.citationNeed,
      cumulativeStructure: cumulativeStructure ?? this.cumulativeStructure,
      styleImportance: styleImportance ?? this.styleImportance,
      expectedRedundancy: expectedRedundancy ?? this.expectedRedundancy,
      deadlinePressure: deadlinePressure ?? this.deadlinePressure,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingScore &&
        other.costOfBeingWrong == costOfBeingWrong &&
        other.citationNeed == citationNeed &&
        other.cumulativeStructure == cumulativeStructure &&
        other.styleImportance == styleImportance &&
        other.expectedRedundancy == expectedRedundancy &&
        other.deadlinePressure == deadlinePressure;
  }

  @override
  int get hashCode {
    return Object.hash(
      costOfBeingWrong,
      citationNeed,
      cumulativeStructure,
      styleImportance,
      expectedRedundancy,
      deadlinePressure,
    );
  }
}

@immutable
class ReadingProject {
  const ReadingProject({
    required this.id,
    required this.title,
    required this.goal,
    required this.useCase,
    required this.stakesNote,
    required this.score,
    required this.recommendedStrategy,
    required this.selectedStrategy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.documentName,
    this.documentPath,
    this.synthesisText = '',
  });

  final String id;
  final String title;
  final String goal;
  final ReadingUseCase useCase;
  final String stakesNote;
  final ReadingScore score;
  final ReadingStrategy recommendedStrategy;
  final ReadingStrategy selectedStrategy;
  final ReadingProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? documentName;
  final String? documentPath;
  final String synthesisText;

  ReadingProject copyWith({
    String? title,
    String? goal,
    ReadingUseCase? useCase,
    String? stakesNote,
    ReadingScore? score,
    ReadingStrategy? recommendedStrategy,
    ReadingStrategy? selectedStrategy,
    ReadingProjectStatus? status,
    DateTime? updatedAt,
    String? documentName,
    String? documentPath,
    String? synthesisText,
  }) {
    return ReadingProject(
      id: id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      useCase: useCase ?? this.useCase,
      stakesNote: stakesNote ?? this.stakesNote,
      score: score ?? this.score,
      recommendedStrategy: recommendedStrategy ?? this.recommendedStrategy,
      selectedStrategy: selectedStrategy ?? this.selectedStrategy,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
      synthesisText: synthesisText ?? this.synthesisText,
    );
  }
}

@immutable
class ReadingSection {
  const ReadingSection({
    required this.id,
    required this.projectId,
    required this.title,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.startPage,
    this.endPage,
    this.note = '',
  });

  final String id;
  final String projectId;
  final String title;
  final int? startPage;
  final int? endPage;
  final ReadingSectionPriority priority;
  final ReadingSectionStatus status;
  final String note;
  final DateTime createdAt;

  ReadingSection copyWith({
    ReadingSectionPriority? priority,
    ReadingSectionStatus? status,
    String? note,
  }) {
    return ReadingSection(
      id: id,
      projectId: projectId,
      title: title,
      startPage: startPage,
      endPage: endPage,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}

@immutable
class ReadingNote {
  const ReadingNote({
    required this.id,
    required this.projectId,
    required this.type,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.pageNumber,
    this.sectionTitle,
    this.quoteOrEvidence = '',
  });

  final String id;
  final String projectId;
  final int? pageNumber;
  final String? sectionTitle;
  final ReadingNoteType type;
  final String text;
  final String quoteOrEvidence;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.projectId,
    required this.prompt,
    required this.dueDate,
    required this.intervalDays,
    required this.status,
    required this.createdAt,
    this.pageNumber,
  });

  final String id;
  final String projectId;
  final String prompt;
  final DateTime dueDate;
  final int intervalDays;
  final ReviewItemStatus status;
  final DateTime createdAt;
  final int? pageNumber;

  bool isDue(DateTime now) {
    if (status != ReviewItemStatus.pending) return false;
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !dueDay.isAfter(today);
  }

  ReviewItem copyWith({ReviewItemStatus? status}) {
    return ReviewItem(
      id: id,
      projectId: projectId,
      prompt: prompt,
      dueDate: dueDate,
      intervalDays: intervalDays,
      status: status ?? this.status,
      createdAt: createdAt,
      pageNumber: pageNumber,
    );
  }
}
