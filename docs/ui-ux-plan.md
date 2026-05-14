# MVP UI/UX Plan

## Summary

The MVP should evolve the current PDF reader into a manual reading workspace for
Android, Windows, and web. It should help a reader decide how deeply to read,
track the parts of a book that matter, capture page-grounded notes, write a
short synthesis, and revisit retrieval prompts.

The app must stay AI-free for MVP. The research in
[Reading effectively with AI](research/reading-effectively-with-ai.md) informs
the workflow, but no runtime AI feature, prompt surface, or API integration
should appear in the initial product experience.

## Product Principles

- Build the real reading workflow first, not a landing page.
- Keep the PDF reader stable and focused on rendering, navigation, and reading
  modes.
- Keep workflow features manual, source-grounded, and useful without external
  services.
- Make wide-screen layouts productive with persistent side panels; make phone
  layouts compact with bottom navigation or sheets.
- Preserve page, chapter, note type, and quote/evidence fields so future AI
  adapters can work from grounded user data without redesigning the product.

## Information Architecture

### Dashboard

The first screen should be a functional dashboard. It should show:

- Active reading projects with document title, selected reading mode, progress,
  and next action.
- Due review items grouped by project.
- A primary action to start a reading project or open a PDF.
- Empty state copy focused on action, not marketing.

The dashboard belongs in a new workflow feature rather than the existing reader
renderer. A likely route structure is:

- `/`: dashboard.
- `/projects/new`: reading project setup.
- `/projects/:projectId`: reading workspace.

### Reading Project Setup

Project setup should collect just enough information to recommend a reading
mode:

- Book or document title.
- Reading goal.
- Use case: academic, professional, leisure nonfiction, or literary.
- Deadline or stakes note.
- Six 0-2 scoring criteria from the research:
  - Cost of being wrong.
  - Need to quote, cite, teach, or defend interpretation.
  - Dependence on cumulative structure or pacing.
  - Importance of style, voice, or rhetoric.
  - Expected redundancy.
  - Deadline pressure.

The recommendation is deterministic local logic:

- `0-4`: selective read.
- `5-7`: hybrid read.
- `8-12`: full read.

The user can override the recommendation. Store both the recommended mode and
the selected mode so the app can preserve the original suggestion.

### Reading Workspace

The workspace should keep the current PDF reader as the center of the
experience.

On wide screens, use a split layout:

- Main region: existing scroll or flip PDF reader.
- Right panel: workflow tabs for Plan, Notes, Synthesis, and Review.

On phones and narrow browser widths:

- Main region: PDF reader.
- Workflow tools: bottom navigation, modal bottom sheet, or a compact panel that
  does not obscure page navigation.

The existing reader toolbar should remain responsible for document summary,
reader mode, and page navigation. Workflow actions should not be mixed into the
renderer unless they directly need the current page number.

## Workflow Tools

### Plan

The Plan tab tracks the user's reading route through the book. It should support:

- Chapter or section title.
- Optional page range.
- Priority: high, medium, low.
- Status: unread, reading, done, skipped.
- Notes about why the section matters.

### Notes

The Notes tab captures page-linked observations. Each note should have:

- Project id.
- Page number when available.
- Optional chapter or section.
- Note type: claim, evidence, question, quote, objection, application.
- Note text.
- Optional exact quote or evidence text.
- Created and updated timestamps.

Notes should default to the current reader page when a PDF is open. Quote fields
should be explicit so future tools can distinguish exact source wording from the
reader's interpretation.

### Synthesis

The Synthesis tab should provide a lightweight memo template:

- Three claims.
- Two objections.
- One application.
- Optional short summary or decision note.

This should remain editable plain text for MVP. Avoid complex outline builders
until the manual workflow proves useful.

### Review

The Review tab should support retrieval practice without automation complexity:

- Manual review prompts linked to a project and optional page or note.
- Suggested review intervals of 1, 7, and 30 days.
- Due, completed, and skipped states.
- A dashboard count for due review items.

## Architecture Fit

Keep the current feature boundaries intact:

- `lib/features/reader`: PDF opening, reader state, scroll/flip rendering, page
  navigation, and renderer errors.
- `lib/features/reading_workflow`: dashboard, project setup, reading-mode
  scoring, workflow panels, notes, synthesis, and reviews.
- `lib/app`: app shell, routes, theme, and top-level providers.
- `lib/core`: shared infrastructure only, such as local database setup when
  persistence is implemented.

The reader feature can expose current document and page status through Riverpod
state. The workflow feature can consume that state for defaults, but it should
not own PDF rendering.

## Data Model Direction

Add local structured storage only when workflow persistence is implemented.
Drift/SQLite is the preferred storage path because the workflow data is
structured and should work offline.

Proposed domain models:

- `ReadingProject`: title, document metadata, use case, goal, selected mode,
  recommended mode, status.
- `ReadingScore`: the six 0-2 criteria and computed total.
- `ReadingSection`: title, page range, priority, status.
- `ReadingNote`: project id, page number, note type, text, quote/evidence text,
  timestamps.
- `ReviewItem`: prompt, due date, interval, completion state.

Platform defaults:

- Android and Windows may store file paths when available.
- Web should persist metadata and workflow data, but require the user to reopen
  the PDF after refresh unless a later browser storage feature is added.

## MVP Acceptance Criteria

- A new user can create a reading project and receive a deterministic reading
  mode recommendation.
- A user can override the recommendation and still see what the app originally
  recommended.
- A user can read a PDF while viewing or editing plan, notes, synthesis, and
  review information.
- A user can create notes tied to the current page.
- A user can create review prompts and see due items on the dashboard.
- No UI copy suggests live AI features in MVP.

## Test Plan

- Unit test reading-mode scoring boundaries: `0-4`, `5-7`, and `8-12`.
- Unit test recommendation override behavior.
- Widget test dashboard empty, active-project, and due-review states.
- Widget test compact and wide reading workspace layouts.
- Controller or repository tests for project creation, notes, section status,
  synthesis memo, and review scheduling.
- Run standard Flutter checks when implementing app code:
  - `flutter pub get`
  - `dart format .`
  - `flutter analyze`
  - `flutter test`
- For platform-sensitive implementation, also verify Chrome and Windows builds;
  Android build verification depends on local Android tooling availability.
