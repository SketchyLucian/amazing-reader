import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_book_reader/features/reader/data/reader_document_picker.dart';
import 'package:minimal_book_reader/features/reader/domain/reader_document.dart';
import 'package:minimal_book_reader/features/reader/presentation/reader_controller.dart';
import 'package:minimal_book_reader/features/reader/presentation/reader_state.dart';

void main() {
  test('opens the selected reader document', () async {
    final document = ReaderDocument.memory(
      id: 'doc-1',
      name: 'Book.pdf',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
    );
    final container = _createContainer(
      _FakeReaderDocumentPicker(() async => document),
    );

    await container.read(readerControllerProvider.notifier).openPdf();

    final state = container.read(readerControllerProvider);
    expect(state.document, same(document));
    expect(state.errorMessage, isNull);
    expect(state.isOpening, isFalse);
    expect(state.pageStatus, const ReaderPageStatus());
  });

  test(
    'leaves the current state usable when file selection is canceled',
    () async {
      final container = _createContainer(
        _FakeReaderDocumentPicker(() async => null),
      );

      await container.read(readerControllerProvider.notifier).openPdf();

      final state = container.read(readerControllerProvider);
      expect(state.document, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isOpening, isFalse);
    },
  );

  test('translates expected open failures to user-safe messages', () async {
    final container = _createContainer(
      _FakeReaderDocumentPicker(
        () async => throw const ReaderDocumentOpenException(
          'The selected PDF is empty.',
        ),
      ),
    );

    await container.read(readerControllerProvider.notifier).openPdf();

    final state = container.read(readerControllerProvider);
    expect(state.document, isNull);
    expect(state.errorMessage, 'The selected PDF is empty.');
    expect(state.isOpening, isFalse);
  });
}

ProviderContainer _createContainer(ReaderDocumentPicker picker) {
  final container = ProviderContainer(
    overrides: [readerDocumentPickerProvider.overrideWith((ref) => picker)],
  );
  addTearDown(container.dispose);
  return container;
}

class _FakeReaderDocumentPicker implements ReaderDocumentPicker {
  const _FakeReaderDocumentPicker(this.pick);

  final Future<ReaderDocument?> Function() pick;

  @override
  Future<ReaderDocument?> pickPdf() => pick();
}
