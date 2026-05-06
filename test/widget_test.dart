import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_book_reader/app/book_reader_app.dart';

void main() {
  testWidgets('shows the empty reader state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    expect(find.text('Book Reader'), findsOneWidget);
    expect(find.text('Open a PDF to start reading'), findsOneWidget);
    expect(find.text('Open PDF'), findsWidgets);
    expect(find.text('No book open'), findsOneWidget);
    expect(find.text('Scroll'), findsOneWidget);
    expect(find.text('Flip'), findsOneWidget);
  });

  testWidgets('switches between reader modes', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    await tester.tap(find.text('Flip'));
    await tester.pumpAndSettle();

    expect(find.text('Flip'), findsOneWidget);
    expect(find.text('Scroll'), findsOneWidget);
  });
}
