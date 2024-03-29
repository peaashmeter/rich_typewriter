library rich_typewriter;

import 'package:flutter/widgets.dart';

///A widget that makes its child animate like a typewriter.
///
///There must be a descendant [RichText] or [Text.rich] widget for this to work.
///
///Either [delay] or [symbolDelay] must be not null.
class RichTypewriter extends ProxyWidget {
  ///Time in milliseconds to wait before printing the next symbol.
  final int? delay;

  ///Time in milliseconds to wait before printing the next symbol,
  ///depending on current one.
  ///
  ///The [symbol] is a minimum printable element of given text,
  ///i.e. an [InlineSpan] with exactly one character, or a [WidgetSpan].
  final int Function(InlineSpan symbol)? symbolDelay;

  ///A callback to call when the animation is finished.
  final Function()? onCompleted;

  const RichTypewriter(
      {super.key,
      required super.child,
      this.delay,
      this.symbolDelay,
      this.onCompleted})
      : assert(
            (delay == null && symbolDelay != null) ||
                (delay != null && symbolDelay == null),
            "Either this.delay or this.symbolDelay must be defined.");

  @override
  Element createElement() => _RichTypewriterElement(this,
      delay: delay, symbolDelay: symbolDelay, onCompleted: onCompleted);
}

class _RichTypewriterElement extends ProxyElement {
  ///An [Element] to animate by sequential reconfigurations.
  Element? _animatable;

  ///Here we store a reference to the original [RichText] widget.
  ///That allows us to restart the animation after a hot reload.
  RichText? _originalWidget;

  final int? delay;
  final int Function(InlineSpan symbol)? symbolDelay;
  final Function()? onCompleted;

  _RichTypewriterElement(widget,
      {this.delay, this.symbolDelay, this.onCompleted})
      : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    _animatable ??= _findAnimatable();
    assert(
      _animatable!.widget is RichText,
    );
    _originalWidget ??= _animatable!.widget as RichText;
    _animate(_animatable!, _originalWidget!).then((_) => onCompleted?.call());
  }

  @override
  void notifyClients(covariant ProxyWidget oldWidget) {
    _animate(_animatable!, _originalWidget!).then((_) => onCompleted?.call());
  }

  @override
  void reassemble() {
    super.reassemble();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animatable = _findAnimatable();
      assert(
        _animatable!.widget is RichText,
      );
      _originalWidget = _animatable!.widget as RichText;
    });
  }

  ///Animates a [RichText].
  ///
  ///Essentially, a widget is just a configuration for some [Element].
  ///This sequentially updates [el] from scratch until its configuration
  ///is [reference].
  Future<void> _animate(Element el, RichText reference) async {
    final spans = [reference.text];

    visitor(InlineSpan childSpan, InlineSpan parentSpan) {
      spans.add(_cloneSpanWithParentStyle(childSpan, parentSpan.style));
      return childSpan.visitDirectChildren((span) => visitor(span, childSpan));
    }

    reference.text
        .visitDirectChildren((childSpan) => visitor(childSpan, reference.text));

    List<InlineSpan> displayed = [];

    update(RichText newRichText) {
      WidgetsBinding.instance.buildOwner?.lockState(() {
        el.update(newRichText);
      });
    }

    for (final span in _iterateSpans(spans)) {
      if (!mounted) return;

      displayed.add(span);
      final newRichText = RichText(
          key: reference.key, text: TextSpan(children: List.from(displayed)));
      update(newRichText);

      await Future.delayed(_getNextDelay(span));
    }

    if (!mounted) return;
    update(reference);
  }

  InlineSpan _cloneSpanWithParentStyle(
      InlineSpan span, TextStyle? parentStyle) {
    if (span is TextSpan) {
      return TextSpan(
        text: span.text,
        style: parentStyle?.merge(span.style),
      );
    } else if (span is WidgetSpan) {
      return WidgetSpan(
        child: span.child,
        alignment: span.alignment,
        style: parentStyle?.merge(span.style),
      );
    } else {
      return span;
    }
  }

  ///Looks for a suitable descendant
  ///(i.e an element configured with [RichText] or [Text.rich]) to animate.
  Element _findAnimatable() {
    Element? animatable;

    visitor(Element el) {
      if (el.widget is RichText) {
        animatable = el;
      } else if (el.widget is RichTypewriter) {
        throw Exception(
            'A RichTypewriter must not be a descendant of the other RichTypewriter.');
      }
      el.visitChildren(visitor);
    }

    visitChildren(visitor);
    if (animatable != null) return animatable!;

    throw Exception(
        'A RichTypewriter must be a parent of RichText or Text.rich to work.');
  }

  Duration _getNextDelay(InlineSpan span) {
    if (delay != null) return Duration(milliseconds: delay!);
    return Duration(milliseconds: symbolDelay!.call(span));
  }

  Iterable<InlineSpan> _iterateSpans(List<InlineSpan> spans) sync* {
    for (final span in spans) {
      if (span is TextSpan) {
        for (var i = 0; i < (span.text?.length ?? 0); i++) {
          yield TextSpan(
            text: span.text![i],
            style: span.style,
          );
        }
      } else {
        yield span;
      }
    }
  }
}
