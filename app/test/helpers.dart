import 'dart:io';

import 'package:hit10/balance/balance.dart';

Balance loadBalance() =>
    Balance.fromJsonString(File('assets/balance.json').readAsStringSync());
