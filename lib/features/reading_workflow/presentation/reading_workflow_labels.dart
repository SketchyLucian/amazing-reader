import '../domain/reading_workflow_models.dart';

extension ReadingUseCaseLabel on ReadingUseCase {
  String get label {
    return switch (this) {
      ReadingUseCase.academic => 'Academic',
      ReadingUseCase.professional => 'Professional',
      ReadingUseCase.leisureNonfiction => 'Leisure nonfiction',
      ReadingUseCase.literary => 'Literary',
    };
  }
}

extension ReadingStrategyLabel on ReadingStrategy {
  String get label {
    return switch (this) {
      ReadingStrategy.selective => 'Selective',
      ReadingStrategy.hybrid => 'Hybrid',
      ReadingStrategy.full => 'Full',
    };
  }

  String get helperText {
    return switch (this) {
      ReadingStrategy.selective => 'Focus only on sections tied to the goal.',
      ReadingStrategy.hybrid => 'Read high-value sections closely.',
      ReadingStrategy.full => 'Read the whole work with verification.',
    };
  }
}

extension ReadingScoreCriterionLabel on ReadingScoreCriterion {
  String get label {
    return switch (this) {
      ReadingScoreCriterion.costOfBeingWrong => 'Cost of being wrong',
      ReadingScoreCriterion.citationNeed => 'Need to quote or defend',
      ReadingScoreCriterion.cumulativeStructure => 'Cumulative structure',
      ReadingScoreCriterion.styleImportance => 'Style or voice matters',
      ReadingScoreCriterion.expectedRedundancy => 'Low redundancy expected',
      ReadingScoreCriterion.deadlinePressure => 'Deadline pressure',
    };
  }
}

extension ReadingSectionPriorityLabel on ReadingSectionPriority {
  String get label {
    return switch (this) {
      ReadingSectionPriority.high => 'High',
      ReadingSectionPriority.medium => 'Medium',
      ReadingSectionPriority.low => 'Low',
    };
  }
}

extension ReadingSectionStatusLabel on ReadingSectionStatus {
  String get label {
    return switch (this) {
      ReadingSectionStatus.unread => 'Unread',
      ReadingSectionStatus.reading => 'Reading',
      ReadingSectionStatus.done => 'Done',
      ReadingSectionStatus.skipped => 'Skipped',
    };
  }
}

extension ReadingNoteTypeLabel on ReadingNoteType {
  String get label {
    return switch (this) {
      ReadingNoteType.claim => 'Claim',
      ReadingNoteType.evidence => 'Evidence',
      ReadingNoteType.question => 'Question',
      ReadingNoteType.quote => 'Quote',
      ReadingNoteType.objection => 'Objection',
      ReadingNoteType.application => 'Application',
    };
  }
}
