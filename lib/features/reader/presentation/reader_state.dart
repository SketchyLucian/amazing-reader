import 'package:flutter/foundation.dart';

import '../domain/reader_document.dart';

const _unset = Object();

enum ReaderMode { scroll, flip }

extension ReaderModeDetails on ReaderMode {
  bool get isFlip => this == ReaderMode.flip;
}

@immutable
class ReaderState {
  const ReaderState({
    this.document,
    this.errorMessage,
    this.isOpening = false,
    this.readerMode = ReaderMode.scroll,
    this.pageStatus = const ReaderPageStatus(),
  });

  final ReaderDocument? document;
  final String? errorMessage;
  final bool isOpening;
  final ReaderMode readerMode;
  final ReaderPageStatus pageStatus;

  ReaderState copyWith({
    Object? document = _unset,
    Object? errorMessage = _unset,
    bool? isOpening,
    ReaderMode? readerMode,
    ReaderPageStatus? pageStatus,
  }) {
    return ReaderState(
      document: identical(document, _unset)
          ? this.document
          : document as ReaderDocument?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isOpening: isOpening ?? this.isOpening,
      readerMode: readerMode ?? this.readerMode,
      pageStatus: pageStatus ?? this.pageStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderState &&
        other.document == document &&
        other.errorMessage == errorMessage &&
        other.isOpening == isOpening &&
        other.readerMode == readerMode &&
        other.pageStatus == pageStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      document,
      errorMessage,
      isOpening,
      readerMode,
      pageStatus,
    );
  }
}

@immutable
class ReaderPageStatus {
  const ReaderPageStatus({this.currentPage, this.pageCount});

  final int? currentPage;
  final int? pageCount;

  bool get canNavigate => pageCount != null;

  ReaderPageStatus withCurrentPage(int pageNumber) {
    return ReaderPageStatus(currentPage: pageNumber, pageCount: pageCount);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderPageStatus &&
        other.currentPage == currentPage &&
        other.pageCount == pageCount;
  }

  @override
  int get hashCode => Object.hash(currentPage, pageCount);
}
