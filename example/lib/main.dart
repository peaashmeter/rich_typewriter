import 'package:flutter/material.dart';
import 'package:rich_typewriter/rich_typewriter.dart';

void main() {
  runApp(const RichTypewriterExample());
}

class RichTypewriterExample extends StatelessWidget {
  const RichTypewriterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: RichTypewriter(
                symbolDelay: (symbol) =>
                    switch (symbol) { TextSpan(text: ' ') => 200, _ => 100 },
                child: const Center(
                    child: Text.rich(TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.red,
                        ),
                        text: 'You ',
                        children: [
                      TextSpan(
                        text: 'can ',
                        style: TextStyle(color: Colors.orange),
                      ),
                      TextSpan(
                        text: 'animate ',
                        style: TextStyle(color: Colors.yellow),
                      ),
                      TextSpan(
                        text: 'both ',
                        style: TextStyle(
                            color: Colors.green,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'text ',
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextSpan(
                        text: 'and ',
                        style: TextStyle(color: Colors.indigo),
                      ),
                      TextSpan(
                        text: 'widgets! ',
                        style: TextStyle(color: Colors.purple),
                      ),
                      WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: AnimatedLogo())
                    ]))))));
  }
}

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> {
  bool didAnimate = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!didAnimate && mounted) {
          setState(() {
            didAnimate = !didAnimate;
          });
        }
      },
    );
    return FlutterLogo(size: didAnimate ? 100 : 0);
  }
}
