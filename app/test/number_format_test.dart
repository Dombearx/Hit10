import 'package:hit10/model/number_format.dart';
import 'package:test/test.dart';

void main() {
  test('small numbers (U-16)', () {
    expect(formatNumber(0), '0');
    expect(formatNumber(0.1), '0.1');
    expect(formatNumber(12.5), '12.5');
    expect(formatNumber(12), '12');
    expect(formatNumber(999), '999');
    expect(formatNumber(999.96), '1.00K');
  });

  test('suffixes', () {
    expect(formatNumber(1000), '1.00K');
    expect(formatNumber(1234), '1.23K');
    expect(formatNumber(45600), '45.6K');
    expect(formatNumber(789000), '789K');
    expect(formatNumber(999999), '1.00M');
    expect(formatNumber(1e9), '1.00B');
    expect(formatNumber(1e12), '1.00T');
    expect(formatNumber(1e15), '1.00aa');
    expect(formatNumber(2.5e18), '2.50ab');
    expect(formatNumber(1e93), '1.00ba');
    expect(formatNumber(1e300), isNot(contains('Infinity')));
  });

  test('suffix sequence', () {
    expect(suffixFor(1), 'K');
    expect(suffixFor(4), 'T');
    expect(suffixFor(5), 'aa');
    expect(suffixFor(30), 'az');
    expect(suffixFor(31), 'ba');
  });

  test('decimal separator per language', () {
    expect(formatNumber(12400000, decimalSeparator: ','), '12,4M');
    expect(formatNumber(0.1, decimalSeparator: ','), '0,1');
  });

  test('scientific', () {
    expect(formatNumber(12400000, notation: Notation.scientific), '1.24e7');
    expect(formatNumber(9999, notation: Notation.scientific), '1.00e4');
    expect(formatNumber(12, notation: Notation.scientific), '12');
  });

  test('stopwatch shows rounded hundredths (U-17)', () {
    expect(formatStopwatch(0), '00.00');
    expect(formatStopwatch(9.87), '09.87');
    expect(formatStopwatch(9.9951), '10.00');
    expect(formatStopwatch(10.0049), '10.00');
    expect(formatStopwatch(10.3), '10.30');
  });

  test('error line', () {
    expect(formatError(0.017), '+0.017 s');
    expect(formatError(-0.2), '−0.200 s');
  });
}
