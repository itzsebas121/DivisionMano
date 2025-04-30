// Flutter code for drawing long division like on paper with step-by-step process including decimals
import 'package:flutter/material.dart';

void main() => runApp(LongDivisionApp());

class LongDivisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'División Larga',
      home: DivisionInputPage(),
    );
  }
}

class DivisionInputPage extends StatefulWidget {
  @override
  _DivisionInputPageState createState() => _DivisionInputPageState();
}

class _DivisionInputPageState extends State<DivisionInputPage> {
  final TextEditingController _dividendoController = TextEditingController();
  final TextEditingController _divisorController = TextEditingController();
  String? _dividendo;
  String? _divisor;

  void _startDivision() {
    setState(() {
      _dividendo = _dividendoController.text;
      _divisor = _divisorController.text;
    });
  }

  void _reset() {
    setState(() {
      _dividendoController.clear();
      _divisorController.clear();
      _dividendo = null;
      _divisor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('División Larga Manual')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _dividendoController,
              decoration: InputDecoration(labelText: 'Dividendo (A)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _divisorController,
              decoration: InputDecoration(labelText: 'Divisor (B)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _startDivision,
                  child: Text('Dividir'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _reset,
                  child: Text('Limpiar'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_dividendo != null && _divisor != null)
              Expanded(
                child: InteractiveViewer(
                  child: CustomPaint(
                    painter: LongDivisionPainter(
                      dividendo: _dividendo!,
                      divisor: _divisor!,
                    ),
                    size: Size(1500, 1000),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LongDivisionPainter extends CustomPainter {
  final String dividendo;
  final String divisor;
  final double fontSize = 22;
  final double padding = 30;

  LongDivisionPainter({required this.dividendo, required this.divisor});

  void drawText(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    try {
      BigInt a = BigInt.parse(dividendo);
      BigInt b = BigInt.parse(divisor);

      int xOffset = padding.toInt();
      int yOffset = padding.toInt();
      int cursorX = xOffset;
      int stepY = yOffset + 80;

      String cociente = '';
      String actual = '';

      int i = 0;
      bool started = false;
      while (i < dividendo.length || (actual != '0' && cociente.length < 30)) {
        if (i < dividendo.length) {
          actual += dividendo[i];
          i++;
        } else {
          if (!cociente.contains('.')) {
            cociente += '.';
          }
          actual += '0';
        }

        BigInt actualNum = BigInt.parse(actual);
        if (actualNum >= b) {
          BigInt div = actualNum ~/ b;
          BigInt mult = div * b;
          BigInt newResto = actualNum - mult;

          cociente += div.toString();

          drawText(canvas, actualNum.toString(), cursorX.toDouble(), stepY.toDouble());
          drawText(canvas, '-' + mult.toString(), cursorX.toDouble(), stepY.toDouble() + fontSize);

          canvas.drawLine(
            Offset(cursorX.toDouble(), stepY.toDouble() + fontSize * 2),
            Offset(cursorX.toDouble() + mult.toString().length * fontSize * 0.6 + 10, stepY.toDouble() + fontSize * 2),
            paintLine,
          );

          stepY += 3 * fontSize.toInt();
          actual = newResto.toString();
          if (actual == '0') actual = '';

          cursorX += (div.toString().length * fontSize * 0.6).toInt() + 10;
          started = true;
        } else {
          if (started) {
            cociente += '0';
            cursorX += (fontSize * 0.6).toInt();
          }
        }
      }

      double divisionLineX = xOffset + dividendo.length * fontSize * 0.6 + 30;

      // Draw top layout: dividend | divisor
      drawText(canvas, dividendo, xOffset.toDouble(), yOffset.toDouble());
      drawText(canvas, '', divisionLineX, yOffset.toDouble());
      drawText(canvas, divisor, divisionLineX + fontSize, yOffset.toDouble());

      // Vertical line of division
      canvas.drawLine(
        Offset(divisionLineX, yOffset.toDouble()),
        Offset(divisionLineX, yOffset + fontSize + 10),
        paintLine,
      );

      // Horizontal line under divisor and result
      canvas.drawLine(
        Offset(divisionLineX, yOffset + fontSize + 10),
        Offset(divisionLineX + cociente.length * fontSize * 0.6 + fontSize, yOffset + fontSize + 10),
        paintLine,
      );

      // Result above the division bar
      drawText(canvas, cociente, divisionLineX + fontSize, yOffset - fontSize - 10);
    } catch (e) {
      drawText(canvas, 'Error: Entrada inválida', padding, padding);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}