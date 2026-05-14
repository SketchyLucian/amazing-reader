import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minimal_book_reader/app/book_reader_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches to the reading dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    expect(find.text('Reading Dashboard'), findsWidgets);
    expect(find.text('Start reading project'), findsOneWidget);
  });
}
