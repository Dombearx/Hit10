import 'dart:math' as math;

/// Number display rules from docs/04 U-16. Logic never rounds money (E-1);
/// only these functions do, and only for display.
enum Notation { short, scientific }

/// Suffix for the n-th power of 1000: K, M, B, T, then aa, ab, … az, ba, …
String suffixFor(int thousands) {
  const named = ['', 'K', 'M', 'B', 'T'];
  if (thousands < named.length) return named[thousands];
  final n = thousands - named.length; // 0 → aa
  const a = 97; // 'a'
  return String.fromCharCodes([a + n ~/ 26, a + n % 26]);
}

/// "0.1", "12.5", "999", "1.23K", "45.6M", "789aa"; scientific "1.24e7".
String formatNumber(
  double v, {
  String decimalSeparator = '.',
  Notation notation = Notation.short,
}) {
  if (v.isNaN) return '0';
  if (v.isInfinite) return '∞';
  final neg = v < 0;
  final x = v.abs();
  String body;
  if (x < 1000) {
    // Whole numbers stay whole; fractions get one decimal (0.1/s).
    final r = (x * 10).round() / 10;
    if (r >= 1000) {
      body = _short(r, notation);
    } else if (r == r.truncateToDouble()) {
      body = r.toStringAsFixed(0);
    } else {
      body = r.toStringAsFixed(1);
    }
  } else {
    body = _short(x, notation);
  }
  if (decimalSeparator != '.') body = body.replaceAll('.', decimalSeparator);
  return neg ? '-$body' : body;
}

String _short(double x, Notation notation) {
  var exp = (math.log(x) / math.ln10).floor();
  // log10 can land one off right at powers of ten.
  if (math.pow(10.0, exp + 1) <= x) exp++;
  if (math.pow(10.0, exp) > x) exp--;
  if (notation == Notation.scientific) {
    var m = x / math.pow(10.0, exp);
    var s = m.toStringAsFixed(2);
    if (s.startsWith('10')) {
      exp++;
      m /= 10;
      s = m.toStringAsFixed(2);
    }
    return '${s}e$exp';
  }
  var t = exp ~/ 3;
  var m = x / math.pow(1000.0, t);
  var s = _threeSignificant(m);
  if (double.parse(s) >= 1000) {
    t++;
    m = x / math.pow(1000.0, t);
    s = _threeSignificant(m);
  }
  return '$s${suffixFor(t)}';
}

String _threeSignificant(double m) {
  if (m < 10) return m.toStringAsFixed(2);
  if (m < 100) return m.toStringAsFixed(1);
  return m.toStringAsFixed(0);
}

/// The stopwatch always shows two decimals and a dot (U-17), rounded to the
/// hundredth, so a perfect hit (|e| < 0.005) reads "10.00".
String formatStopwatch(double seconds) {
  final hundredths = (seconds * 100).round().clamp(0, 9999);
  final whole = hundredths ~/ 100;
  final frac = hundredths % 100;
  return '${whole.toString().padLeft(2, '0')}.${frac.toString().padLeft(2, '0')}';
}

/// Signed error with three decimals for the result line: "+0.017 s".
String formatError(double e) {
  final s = e.abs().toStringAsFixed(3);
  return '${e < 0 ? '−' : '+'}$s s';
}
