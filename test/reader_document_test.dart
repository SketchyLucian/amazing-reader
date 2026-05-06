import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_book_reader/features/reader/domain/reader_document.dart';

void main() {
  test('creates a memory-backed reader document', () {
    final bytes = Uint8List.fromList(<int>[1, 2, 3]);

    final document = ReaderDocument.memory(
      id: 'memory-doc',
      name: 'Example.pdf',
      bytes: bytes,
    );

    expect(document.bytes, same(bytes));
    expect(document.path, isNull);
    expect(document.sizeInBytes, 3);
    expect(document.sourceName, 'memory-doc-Example.pdf');
  });

  test('creates a file-backed reader document', () {
    const document = ReaderDocument.file(
      id: 'file-doc',
      name: 'Book.pdf',
      path: r'C:\books\Book.pdf',
      sizeInBytes: 4096,
    );

    expect(document.bytes, isNull);
    expect(document.path, r'C:\books\Book.pdf');
    expect(document.sizeInBytes, 4096);
    expect(document.sourceName, 'file-doc-Book.pdf');
  });
}
