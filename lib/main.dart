import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget
{
  final words = <WordSpan>[];

  MyApp()
  {
    for (int i = 0; i < 1000000; i++)
    {
      words.add
      (
        WordSpan
        (
          'Hello$i',
          TextStyle
          (
            color: Colors.black,
            fontSize: 5,
          )
        )
      );
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp
    (
      title: 'Flutter Custom Painter',
      theme: ThemeData
      (
        primarySwatch: Colors.blueGrey,
      ),
      home: MyPainter(words),
    );
  }
}

class MyPainter extends StatefulWidget
{
  List<WordSpan> words;

  MyPainter(this.words);

  @override
  _MyPainterState createState() => _MyPainterState();
}

class _MyPainterState extends State<MyPainter>
{
  var _sides = 3.0;
  var _radius = 100.0;
  var _radians = 0.0;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('Polygons'),
      ),
      body: SafeArea
      (
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>
          [
            Expanded
            (
              child: CustomPaint
              (
                painter: ShapePainter(_sides, _radius, _radians, widget.words),
                child: Container(),
              ),
            ),
            Padding
            (
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Sides'),
            ),
            Slider
            (
              value: _sides,
              min: 3.0,
              max: 10.0,
              label: _sides.toInt().toString(),
              divisions: 7,
              onChanged: (value)
              {
                setState
                (
                  ()
                  {
                    _sides = value;
                  }
                );
              },
            ),
            Padding
            (
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Size'),
            ),
            Slider
            (
              value: _radius,
              min: 10.0,
              max: MediaQuery.of(context).size.width / 2,
              onChanged: (value)
              {
                setState
                (
                  ()
                  {
                    _radius = value;
                  }
                );
              },
            ),
            Padding
            (
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Rotation'),
            ),
            Slider
            (
              value: _radians,
              min: 0.0,
              max: math.pi,
              onChanged: (value)
              {
                setState
                (
                  ()
                  {
                    _radians = value;
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// FOR PAINTING POLYGONS
class ShapePainter extends CustomPainter
{
  final double sides;
  final double radius;
  final double radians;
  List<WordSpan> words;

  ShapePainter(this.sides, this.radius, this.radians, this.words);

  @override
  void paint(Canvas canvas, Size size)
  {
    var paint = Paint()
    ..color = Colors.teal
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

    var path = Path();

    var angle = (math.pi * 2) / sides;

    Offset center = Offset(size.width / 2, size.height / 2);
    Offset startPoint = Offset(radius * math.cos(radians), radius * math.sin(radians));

    path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

    for (int i = 1; i <= sides; i++)
    {
      double x = radius * math.cos(radians + angle * i) + center.dx;
      double y = radius * math.sin(radians + angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    paintText(canvas, size);
  }

  void paintText(Canvas canvas, Size size)
  {
    final textStyle = TextStyle
    (
      color: Colors.black, fontSize: 20, shadows: [Shadow(color: Colors.blue, offset: Offset(1, 2), blurRadius: 5)]
    );
    final textSpan = TextSpan
    (
      text: 'Hello world!  ',
      style: textStyle,
    );
    final textPainter = TextPainter
    (
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout
    (
      minWidth: 0,
      maxWidth: size.width,
    );

    //final xCenter = (size.width - textPainter.width) / 2;
    //final yCenter = (size.height - textPainter.height) / 2;
    final xStart = size.width / 20;
    final yStart = size.height / 10;
    int i = 0;
    for (double y = yStart; y < size.height;)
    {
      double h = 1;

      for (double x = xStart; (x + textPainter.width) < 0.95 * size.width;)
      {
        final offset = Offset(x, y);
        //textPainter.paint(canvas, offset);
        final painter = words[i++].painter;
        painter.paint(canvas, offset);
        x += painter.width + 1;
        if (painter.height > h) h = painter.height;
      }

      y += h;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate)
  {
    return true;
  }
}

class WordSpan
{
  TextPainter? _painter;
  late String text;
  late TextStyle style;

  WordSpan(this.text, this.style);

  TextPainter get painter
  {
    if (_painter != null)
    {
      return _painter!;
    }
    else
    {
      final p = TextPainter
      (
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      );

      p.layout(minWidth: 0.0, maxWidth: 10000.0);
      _painter = p;

      return p;
    }
  }
}