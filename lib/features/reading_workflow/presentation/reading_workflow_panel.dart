import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reader/presentation/reader_controller.dart';
import '../domain/reading_workflow_models.dart';
import 'reading_workflow_controller.dart';
import 'reading_workflow_labels.dart';

class ReadingWorkflowPanel extends ConsumerWidget {
  const ReadingWorkflowPanel({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingWorkflowControllerProvider);
    final project = state.projectById(projectId);
    if (project == null) {
      return const Center(child: Text('Project not found.'));
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.route), text: 'Plan'),
                Tab(icon: Icon(Icons.note_add), text: 'Notes'),
                Tab(icon: Icon(Icons.edit_note), text: 'Synthesis'),
                Tab(icon: Icon(Icons.quiz), text: 'Review'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PlanTab(projectId: projectId),
                _NotesTab(projectId: projectId),
                _SynthesisTab(projectId: projectId),
                _ReviewTab(projectId: projectId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelSection extends StatelessWidget {
  const _PanelSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: children);
  }
}

class _PlanTab extends ConsumerStatefulWidget {
  const _PlanTab({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends ConsumerState<_PlanTab> {
  final _titleController = TextEditingController();
  final _startPageController = TextEditingController();
  final _endPageController = TextEditingController();
  ReadingSectionPriority _priority = ReadingSectionPriority.high;

  @override
  void dispose() {
    _titleController.dispose();
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  void _addSection() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    ref
        .read(readingWorkflowControllerProvider.notifier)
        .addSection(
          projectId: widget.projectId,
          title: title,
          startPage: int.tryParse(_startPageController.text),
          endPage: int.tryParse(_endPageController.text),
          priority: _priority,
        );

    _titleController.clear();
    _startPageController.clear();
    _endPageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingWorkflowControllerProvider);
    final sections = state.sectionsForProject(widget.projectId);

    return _PanelSection(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Chapter or section',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startPageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Start page',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _endPageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'End page',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReadingSectionPriority>(
          initialValue: _priority,
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
          ),
          items: ReadingSectionPriority.values
              .map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.label),
                ),
              )
              .toList(growable: false),
          onChanged: (priority) {
            if (priority == null) return;
            setState(() => _priority = priority);
          },
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _addSection,
          icon: const Icon(Icons.add),
          label: const Text('Add section'),
        ),
        const SizedBox(height: 16),
        if (sections.isEmpty)
          const Text('No sections planned yet.')
        else
          ...sections.map((section) => _SectionTile(section: section)),
      ],
    );
  }
}

class _SectionTile extends ConsumerWidget {
  const _SectionTile({required this.section});

  final ReadingSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageRange = switch ((section.startPage, section.endPage)) {
      (final int start, final int end) => 'Pages $start-$end',
      (final int start, null) => 'Page $start',
      _ => 'No page range',
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.segment),
      title: Text(section.title),
      subtitle: Text('${section.priority.label} - $pageRange'),
      trailing: DropdownButton<ReadingSectionStatus>(
        value: section.status,
        underline: const SizedBox.shrink(),
        items: ReadingSectionStatus.values
            .map(
              (status) =>
                  DropdownMenuItem(value: status, child: Text(status.label)),
            )
            .toList(growable: false),
        onChanged: (status) {
          if (status == null) return;
          ref
              .read(readingWorkflowControllerProvider.notifier)
              .setSectionStatus(section.id, status);
        },
      ),
    );
  }
}

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final _noteController = TextEditingController();
  final _quoteController = TextEditingController();
  ReadingNoteType _type = ReadingNoteType.claim;

  @override
  void dispose() {
    _noteController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final pageNumber = ref
        .read(readerControllerProvider)
        .pageStatus
        .currentPage;
    ref
        .read(readingWorkflowControllerProvider.notifier)
        .addNote(
          projectId: widget.projectId,
          type: _type,
          text: text,
          quoteOrEvidence: _quoteController.text.trim(),
          pageNumber: pageNumber,
        );

    _noteController.clear();
    _quoteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingWorkflowControllerProvider);
    final notes = state.notesForProject(widget.projectId);
    final pageNumber = ref.watch(
      readerControllerProvider.select(
        (reader) => reader.pageStatus.currentPage,
      ),
    );

    return _PanelSection(
      children: [
        DropdownButtonFormField<ReadingNoteType>(
          initialValue: _type,
          decoration: const InputDecoration(
            labelText: 'Note type',
            border: OutlineInputBorder(),
          ),
          items: ReadingNoteType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(growable: false),
          onChanged: (type) {
            if (type == null) return;
            setState(() => _type = type);
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: pageNumber == null
                ? 'Note'
                : 'Note for page $pageNumber',
            border: const OutlineInputBorder(),
          ),
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _quoteController,
          decoration: const InputDecoration(
            labelText: 'Quote or evidence',
            border: OutlineInputBorder(),
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _addNote,
          icon: const Icon(Icons.add),
          label: const Text('Add note'),
        ),
        const SizedBox(height: 16),
        if (notes.isEmpty)
          const Text('No notes yet.')
        else
          ...notes.map((note) => _NoteTile(note: note)),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final ReadingNote note;

  @override
  Widget build(BuildContext context) {
    final pageLabel = note.pageNumber == null
        ? 'No page'
        : 'Page ${note.pageNumber}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.sticky_note_2),
      title: Text(note.text, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${note.type.label} - $pageLabel'),
    );
  }
}

class _SynthesisTab extends ConsumerStatefulWidget {
  const _SynthesisTab({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_SynthesisTab> createState() => _SynthesisTabState();
}

class _SynthesisTabState extends ConsumerState<_SynthesisTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(readingWorkflowControllerProvider.notifier)
        .updateSynthesis(widget.projectId, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final project = ref
        .watch(readingWorkflowControllerProvider)
        .projectById(widget.projectId);

    if (project != null && _controller.text.isEmpty) {
      _controller.text = project.synthesisText;
    }

    return _PanelSection(
      children: [
        const Text('Memo template: 3 claims, 2 objections, 1 application.'),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Synthesis memo',
            border: OutlineInputBorder(),
          ),
          minLines: 8,
          maxLines: 12,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save synthesis'),
        ),
      ],
    );
  }
}

class _ReviewTab extends ConsumerStatefulWidget {
  const _ReviewTab({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends ConsumerState<_ReviewTab> {
  final _promptController = TextEditingController();
  int _intervalDays = 1;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _addReviewItem() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final pageNumber = ref
        .read(readerControllerProvider)
        .pageStatus
        .currentPage;
    ref
        .read(readingWorkflowControllerProvider.notifier)
        .addReviewItem(
          projectId: widget.projectId,
          prompt: prompt,
          intervalDays: _intervalDays,
          pageNumber: pageNumber,
        );

    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingWorkflowControllerProvider);
    final reviewItems = state.reviewItemsForProject(widget.projectId);

    return _PanelSection(
      children: [
        TextField(
          controller: _promptController,
          decoration: const InputDecoration(
            labelText: 'Retrieval prompt',
            border: OutlineInputBorder(),
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _intervalDays,
          decoration: const InputDecoration(
            labelText: 'Review interval',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 day')),
            DropdownMenuItem(value: 7, child: Text('7 days')),
            DropdownMenuItem(value: 30, child: Text('30 days')),
          ],
          onChanged: (intervalDays) {
            if (intervalDays == null) return;
            setState(() => _intervalDays = intervalDays);
          },
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _addReviewItem,
          icon: const Icon(Icons.add),
          label: const Text('Add review prompt'),
        ),
        const SizedBox(height: 16),
        if (reviewItems.isEmpty)
          const Text('No review prompts yet.')
        else
          ...reviewItems.map((item) => _ReviewTile(item: item)),
      ],
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.item});

  final ReviewItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageLabel = item.pageNumber == null
        ? 'No page'
        : 'Page ${item.pageNumber}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.quiz),
      title: Text(item.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('$pageLabel - due in ${item.intervalDays} days'),
      trailing: item.status == ReviewItemStatus.pending
          ? IconButton(
              tooltip: 'Mark complete',
              onPressed: () {
                ref
                    .read(readingWorkflowControllerProvider.notifier)
                    .setReviewItemStatus(item.id, ReviewItemStatus.completed);
              },
              icon: const Icon(Icons.check),
            )
          : const Icon(Icons.check_circle),
    );
  }
}
