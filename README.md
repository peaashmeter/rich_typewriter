

A widget that makes underlying Text.rich or RichText animate like a typewriter.
![Preview](rich_typewriter_preview.webp)

## Motivation
I was creating a [visual novel engine](https://pub.dev/packages/npdart),
so I needed a convenient way to animate RichTexts (with styles and WidgetSpans).
Actually there *are* some packages which do the thing, but they do not work with existant
RichTexts and/or do not support WidgetSpans.

In addition, it's also a kind of proof of concept in terms of interaction with the element tree. 

## Features

- Wrap a Text.rich or a RichText to animate.
- Supports trees of InlineSpan with arbitrary depth.
- Can print both text characters and widgets.
- Allows to set up different delays for different symbols.

## Limitations

- Does not currently support hot reload to see changes. Use hot restart instead.
- - Hot reload only restarts the animation.

## Usage

```dart
RichTypewriter(
        child: const Text.rich(TextSpan(text: "some text", children: [
      WidgetSpan(
          child: FlutterLogo(
        size: 100,
      ))
    ])));
```
