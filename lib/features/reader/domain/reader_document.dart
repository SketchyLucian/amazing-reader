import 'dart:typed_data';

class ReaderDocument {
  const ReaderDocument._({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    this.bytes,
    this.path,
  }) : assert(bytes != null || path != null);

  factory ReaderDocument.memory({
    required String id,
    required String name,
    required Uint8List bytes,
  }) {
    return ReaderDocument._(
      id: id,
      name: name,
      sizeInBytes: bytes.lengthInBytes,
      bytes: bytes,
    );
  }

  const factory ReaderDocument.file({
    required String id,
    required String name,
    required String path,
    required int sizeInBytes,
  }) = ReaderDocument._;

  final String id;
  final String name;
  final int sizeInBytes;
  final Uint8List? bytes;
  final String? path;

  String get sourceName => '$id-$name';
}
