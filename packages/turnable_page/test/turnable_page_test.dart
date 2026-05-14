import 'package:flutter_test/flutter_test.dart';
import 'package:turnable_page/src/collection/page_collection_impl.dart';
import 'package:turnable_page/src/enums/animation_process.dart';
import 'package:turnable_page/src/enums/book_orientation.dart';
import 'package:turnable_page/src/enums/flip_direction.dart';
import 'package:turnable_page/src/flip/flip_settings.dart';
import 'package:turnable_page/src/model/page_rect.dart';
import 'package:turnable_page/src/model/point.dart' as model;
import 'package:turnable_page/src/model/rect_points.dart';
import 'package:turnable_page/src/page/book_page.dart';
import 'package:turnable_page/src/page/page_flip.dart';
import 'package:turnable_page/src/render/render_page.dart';

void main() {
  group('drag release completion', () {
    test(
      'turns the page once drag progress reaches the configured threshold',
      () {
        final pageFlip = _buildPageFlip(
          FlipSettings(enableInertia: false, completionProgressThreshold: 0.35),
        );

        pageFlip.startUserTouch(model.Point(200, 10));
        pageFlip.userMove(model.Point(125, 10), true);
        pageFlip.userStop(model.Point(125, 10));

        expect(pageFlip.getCurrentPageIndex(), 1);
      },
    );

    test('snaps back when drag progress is below the configured threshold', () {
      final pageFlip = _buildPageFlip(
        FlipSettings(enableInertia: false, completionProgressThreshold: 0.35),
      );

      pageFlip.startUserTouch(model.Point(200, 10));
      pageFlip.userMove(model.Point(150, 10), true);
      pageFlip.userStop(model.Point(150, 10));

      expect(pageFlip.getCurrentPageIndex(), 0);
    });
  });
}

PageFlip _buildPageFlip(FlipSettings settings) {
  final render = _TestRenderPage(settings);
  final pageFlip = PageFlip(settings, customRender: render);
  final pages = PageCollectionImpl(pageFlip, render, 3);
  pageFlip.pages = pages;
  pages.loadBookPages();
  pages.show(0);
  return pageFlip;
}

class _TestRenderPage implements RenderPage {
  _TestRenderPage(this.settings);

  final FlipSettings settings;
  final PageRect rect = const PageRect(
    left: 0,
    top: 0,
    width: 200,
    height: 150,
    pageWidth: 100,
  );

  FlipDirection? direction;

  @override
  BookOrientation calculateBoundsRect() => BookOrientation.portrait;

  @override
  void clearShadow() {}

  @override
  RectPoints convertRectToGlobal(RectPoints rect, [FlipDirection? direction]) {
    return RectPoints(
      topLeft: convertToGlobal(rect.topLeft, direction)!,
      topRight: convertToGlobal(rect.topRight, direction)!,
      bottomLeft: convertToGlobal(rect.bottomLeft, direction)!,
      bottomRight: convertToGlobal(rect.bottomRight, direction)!,
    );
  }

  @override
  model.Point convertToBook(model.Point pos) {
    return model.Point(pos.x - rect.left, pos.y - rect.top);
  }

  @override
  model.Point? convertToGlobal(model.Point? pos, [FlipDirection? direction]) {
    if (pos == null) return null;
    final effectiveDirection = direction ?? this.direction;
    final x = effectiveDirection == FlipDirection.forward
        ? pos.x + rect.left + rect.width / 2
        : rect.width / 2 - pos.x + rect.left;
    return model.Point(x, pos.y + rect.top);
  }

  @override
  model.Point convertToPage(model.Point pos, [FlipDirection? direction]) {
    final effectiveDirection = direction ?? this.direction;
    final x = effectiveDirection == FlipDirection.forward
        ? pos.x - rect.left - rect.width / 2
        : rect.width / 2 - pos.x + rect.left;
    return model.Point(x, pos.y - rect.top);
  }

  @override
  void finishAnimation() {}

  @override
  double getBlockHeight() => rect.height;

  @override
  double getBlockWidth() => rect.width;

  @override
  FlipDirection? getDirection() => direction;

  @override
  BookOrientation? getOrientation() => BookOrientation.portrait;

  @override
  PageRect getRect() => rect;

  @override
  FlipSettings getSettings() => settings;

  @override
  void render(double timer) {}

  @override
  void setBottomPage(BookPage? page) {}

  @override
  void setDirection(FlipDirection direction) {
    this.direction = direction;
  }

  @override
  void setFlippingPage(BookPage? page) {}

  @override
  void setLeftPage(BookPage? page) {}

  @override
  void setPageRect(RectPoints pageRect) {}

  @override
  void setRightPage(BookPage? page) {}

  @override
  void setShadowData(
    model.Point pos,
    double angle,
    double progress,
    FlipDirection direction,
  ) {}

  @override
  void startAnimation(
    List<FrameAction> frames,
    double duration,
    AnimationSuccessAction onAnimateEnd,
  ) {
    for (final frame in frames) {
      frame();
    }
    onAnimateEnd();
  }

  @override
  void updateApp(PageFlip app) {}
}
