import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minimal_book_reader/app/book_reader_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches to the empty reader screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    expect(find.text('Book Reader'), findsOneWidget);
    expect(find.text('Open a PDF to start reading'), findsOneWidget);
  });
}
