import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/book_reader_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize(dismissPdfiumWasmWarnings: true);
  runApp(const ProviderScope(child: BookReaderApp()));
}
