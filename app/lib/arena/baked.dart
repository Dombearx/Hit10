import 'dart:ui' as ui;

/// Renders [paint] once into an image so per-frame fades and scales are a
/// single drawImage with an alpha paint, instead of a saveLayer (T-21).
class Baked {
  Baked(this.width, this.height, void Function(ui.Canvas canvas) paint) {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    c.scale(_scale);
    paint(c);
    final pic = rec.endRecording();
    image = pic.toImageSync(
      (width * _scale).ceil().clamp(1, 4096),
      (height * _scale).ceil().clamp(1, 4096),
    );
    pic.dispose();
  }

  /// Supersampling so the bitmap stays sharp on high-density screens.
  static double _scale = 2;
  static set devicePixelRatio(double dpr) => _scale = dpr.clamp(1, 3);

  final double width;
  final double height;
  late final ui.Image image;
  final _paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;

  /// Draws centred at the origin with [alpha].
  void draw(ui.Canvas canvas, double alpha) {
    _paint.color = ui.Color.fromRGBO(255, 255, 255, alpha.clamp(0.0, 1.0));
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromCenter(center: ui.Offset.zero, width: width, height: height),
      _paint,
    );
  }

  void dispose() => image.dispose();
}
