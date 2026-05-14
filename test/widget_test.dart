import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_book_reader/app/book_reader_app.dart';
import 'package:minimal_book_reader/features/reader/presentation/reader_screen.dart';
import 'package:minimal_book_reader/features/reading_workflow/presentation/reading_workflow_panel.dart';

void main() {
  testWidgets('shows the empty reading dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    expect(find.text('Reading Dashboard'), findsWidgets);
    expect(find.text('Start reading project'), findsOneWidget);
    expect(find.text('No review prompts are due.'), findsOneWidget);
    expect(
      find.text('Create a project to plan a full, hybrid, or selective read.'),
      findsOneWidget,
    );
  });

  testWidgets('creates a reading project and opens the workspace', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: BookReaderApp()));

    await tester.tap(find.text('Start reading project'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Book or document title'),
      'Attention Handbook',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reading goal'),
      'Prepare a team discussion',
    );

    final createProjectButton = find.byKey(
      const ValueKey('create-reading-project-button'),
    );
    await tester.tap(createProjectButton.first);
    await tester.pumpAndSettle();

    expect(find.text('Attention Handbook'), findsOneWidget);
    expect(find.text('Open a PDF to start reading'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Synthesis'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });

  testWidgets('shows the standalone empty reader state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReaderScreen())),
    );

    expect(find.text('Book Reader'), findsOneWidget);
    expect(find.text('Open a PDF to start reading'), findsOneWidget);
    expect(find.text('Open PDF'), findsWidgets);
    expect(find.text('No book open'), findsOneWidget);
    expect(find.text('Scroll'), findsOneWidget);
    expect(find.text('Flip'), findsOneWidget);
  });

  testWidgets('switches between reader modes', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReaderScreen())),
    );

    await tester.tap(find.text('Flip'));
    await tester.pumpAndSettle();

    expect(find.text('Flip'), findsOneWidget);
    expect(find.text('Scroll'), findsOneWidget);
  });

  testWidgets('uses a wide workflow panel layout on desktop widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReaderScreen(
            workflowPanel: ReadingWorkflowPanel(projectId: 'missing'),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('reader-workspace-wide')), findsOneWidget);
    expect(find.text('Project not found.'), findsOneWidget);
  });

  testWidgets('uses a compact workflow panel layout on phone widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReaderScreen(
            workflowPanel: ReadingWorkflowPanel(projectId: 'missing'),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('reader-workspace-compact')),
      findsOneWidget,
    );
    expect(find.text('Project not found.'), findsOneWidget);
  });
}
