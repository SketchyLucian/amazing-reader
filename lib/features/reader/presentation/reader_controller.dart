import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reader_document_picker.dart';
import 'reader_state.dart';

final readerDocumentPickerProvider = Provider<ReaderDocumentPicker>(
  (ref) => const FileSelectorReaderDocumentPicker(),
);

final readerControllerProvider =
    NotifierProvider<ReaderController, ReaderState>(ReaderController.new);

class ReaderController extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  Future<void> openPdf() async {
    if (state.isOpening) return;

    state = state.copyWith(isOpening: true, errorMessage: null);

    try {
      final document = await ref.read(readerDocumentPickerProvider).pickPdf();
      if (document == null) {
        state = state.copyWith(isOpening: false);
        return;
      }

      state = state.copyWith(
        document: document,
        errorMessage: null,
        isOpening: false,
        pageStatus: const ReaderPageStatus(),
      );
    } on ReaderDocumentOpenException catch (error) {
      state = state.copyWith(errorMessage: error.userMessage, isOpening: false);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Could not open that PDF.',
        isOpening: false,
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(errorMessage: null);
  }

  void setReaderMode(ReaderMode mode) {
    if (state.readerMode == mode) return;
    state = state.copyWith(readerMode: mode);
  }

  void setPageStatus(ReaderPageStatus pageStatus) {
    if (state.pageStatus == pageStatus) return;
    state = state.copyWith(pageStatus: pageStatus);
  }

  void setCurrentPage(int pageNumber) {
    setPageStatus(state.pageStatus.withCurrentPage(pageNumber));
  }
}
