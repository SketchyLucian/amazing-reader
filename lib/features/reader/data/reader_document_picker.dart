import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../domain/reader_document.dart';

const _pdfTypeGroup = XTypeGroup(
  label: 'PDF',
  extensions: <String>['pdf'],
  mimeTypes: <String>['application/pdf'],
  uniformTypeIdentifiers: <String>['com.adobe.pdf'],
);

const _emptyPdfMessage = 'The selected PDF is empty.';
const _genericOpenMessage = 'Could not open that PDF.';

abstract interface class ReaderDocumentPicker {
  Future<ReaderDocument?> pickPdf();
}

class FileSelectorReaderDocumentPicker implements ReaderDocumentPicker {
  const FileSelectorReaderDocumentPicker();

  @override
  Future<ReaderDocument?> pickPdf() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[_pdfTypeGroup],
      );
      if (file == null) return null;

      final sizeInBytes = await file.length();
      if (sizeInBytes <= 0) {
        throw const ReaderDocumentOpenException(_emptyPdfMessage);
      }

      return _createReaderDocument(file, sizeInBytes);
    } on ReaderDocumentOpenException {
      rethrow;
    } catch (error, stackTrace) {
      throw ReaderDocumentOpenException(
        _genericOpenMessage,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ReaderDocument> _createReaderDocument(
    XFile file,
    int sizeInBytes,
  ) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final path = file.path.trim();

    if (!kIsWeb && path.isNotEmpty) {
      return ReaderDocument.file(
        id: id,
        name: file.name,
        path: path,
        sizeInBytes: sizeInBytes,
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const ReaderDocumentOpenException(_emptyPdfMessage);
    }

    return ReaderDocument.memory(id: id, name: file.name, bytes: bytes);
  }
}

class ReaderDocumentOpenException implements Exception {
  const ReaderDocumentOpenException(
    this.userMessage, {
    this.cause,
    this.stackTrace,
  });

  final String userMessage;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => userMessage;
}
