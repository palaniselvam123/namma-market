import 'package:flutter/material.dart';

/// The Namma MahaRaja crown, drawn as a path so it stays crisp at any size
/// and can be tinted per surface. The centre diamond is punched out with an
/// even-odd fill, so whatever sits behind the mark shows through it.
class CrownPainter extends CustomPainter {
  final Color color;

  const CrownPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double x(double t) => t * w;
    double y(double t) => t * h;

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final body = Path()..fillType = PathFillType.evenOdd;
    body.moveTo(x(.135), y(.70));
    body.quadraticBezierTo(x(.015), y(.54), x(.035), y(.20));
    body.quadraticBezierTo(x(.135), y(.42), x(.225), y(.60));
    body.quadraticBezierTo(x(.283), y(.50), x(.335), y(.31));
    body.quadraticBezierTo(x(.390), y(.50), x(.437), y(.585));
    body.quadraticBezierTo(x(.470), y(.42), x(.500), y(.145));
    body.quadraticBezierTo(x(.530), y(.42), x(.563), y(.585));
    body.quadraticBezierTo(x(.610), y(.50), x(.665), y(.31));
    body.quadraticBezierTo(x(.717), y(.50), x(.775), y(.60));
    body.quadraticBezierTo(x(.865), y(.42), x(.965), y(.20));
    body.quadraticBezierTo(x(.985), y(.54), x(.865), y(.70));
    body.close();

    // Centre gem, cut out of the crown body.
    final gem = Path()
      ..moveTo(x(.50), y(.455))
      ..lineTo(x(.535), y(.545))
      ..lineTo(x(.50), y(.635))
      ..lineTo(x(.465), y(.545))
      ..close();
    body.addPath(gem, Offset.zero);

    canvas.drawPath(body, paint);

    // Finials on the three inner peaks.
    canvas.drawCircle(Offset(x(.335), y(.245)), w * .052, paint);
    canvas.drawCircle(Offset(x(.500), y(.078)), w * .058, paint);
    canvas.drawCircle(Offset(x(.665), y(.245)), w * .052, paint);

    // Band, separated by a hairline gap so it reads as a second element.
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(x(.115), y(.775), x(.885), y(.945)),
      Radius.circular(w * .022),
    );
    canvas.drawRRect(band, paint);
  }

  @override
  bool shouldRepaint(CrownPainter old) => old.color != color;
}

/// Crown over an interlocked MR monogram.
class BrandMark extends StatelessWidget {
  final double height;
  final Color color;

  const BrandMark({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    final crownH = height * .46;
    return SizedBox(
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: crownH,
            width: crownH * 1.5,
            child: CustomPaint(painter: CrownPainter(color)),
          ),
          SizedBox(height: height * .04),
          Text(
            'MR',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontFamilyFallback: const ['Times New Roman', 'serif'],
              fontSize: height * .52,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -height * .07,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Crown + wordmark, laid out horizontally for app headers.
class BrandLockup extends StatelessWidget {
  final Color color;
  final Color subColor;

  const BrandLockup({super.key, required this.color, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          width: 42,
          child: CustomPaint(painter: CrownPainter(color)),
        ),
        const SizedBox(width: 9),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Namma MahaRaja',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: const ['Times New Roman', 'serif'],
                fontSize: 16,
                height: 1.05,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
                color: color,
              ),
            ),
            Text(
              'SUPER MARKET',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: subColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
