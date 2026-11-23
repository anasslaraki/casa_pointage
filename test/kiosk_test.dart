import 'package:flutter_test/flutter_test.dart';

import 'package:casa_pointage/app/data/models/kiosk_result.dart';
import 'package:casa_pointage/app/data/models/supervisor.dart';

Supervisor _with(String role) => Supervisor(
      matricule: '',
      name: '',
      function: '',
      login: '',
      role: role,
    );

void main() {
  test('only the supervisor roles get the supervisor interface', () {
    expect(_with('SuperviseurDepot').isKiosk, isFalse);
    expect(_with('ResponsableDepot').isKiosk, isFalse);
    expect(_with('Pointeur').isKiosk, isTrue);
    expect(_with('Autre').isKiosk, isTrue);
    // Unknown role (old session): the supervisor interface.
    expect(_with('').isKiosk, isFalse);
  });

  test('the kiosk result reads the pointage answer', () {
    final r = KioskResult.of('Arrivée pointée.', {
      'agentId': 23,
      'matricule': 'M1',
      'fullName': 'Ali Benali',
      'type': 'Entree',
      'enRetard': true,
      'retardMinutes': 12,
      'auDepot': false,
      'pointage': {'id': 1, 'datePointage': '2026-11-05T08:02:11'},
    });
    expect(r.fullName, 'Ali Benali');
    expect(r.isArrival, isTrue);
    expect(r.isLate, isTrue);
    expect(r.lateMinutes, 12);
    expect(r.atDepot, isFalse);
    expect(r.time.hour, 8);

    final out = KioskResult.of('Sortie pointée.', {'type': 'Sortie'});
    expect(out.isArrival, isFalse);
    expect(out.atDepot, isNull);
  });
}
