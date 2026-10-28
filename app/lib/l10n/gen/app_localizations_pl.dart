// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Hit10';

  @override
  String get tagline => 'Dotknij dokładnie w 10.00';

  @override
  String get tikiLabel => 'Tiki';

  @override
  String get tierPerfect => 'PERFEKT!';

  @override
  String get tierGreat => 'ŚWIETNIE!';

  @override
  String get tierGood => 'DOBRZE';

  @override
  String get missEarly => 'ZA WCZEŚNIE';

  @override
  String get missLate => 'ZA PÓŹNO';

  @override
  String get tapToStart => 'Dotknij, aby zacząć';

  @override
  String get decimalSeparator => ',';

  @override
  String get gen_grandpa => 'Dziadek z zegarkiem';

  @override
  String get gen_grandpa_desc => '„Za moich czasów sekunda była dłuższa.”';

  @override
  String get gen_grandma => 'Babcia z minutnikiem';

  @override
  String get gen_grandma_desc =>
      'Jajka na miękko od 1974. Dziesięć sekund to dla niej pestka.';

  @override
  String get gen_cuckoo => 'Kukułka';

  @override
  String get gen_cuckoo_desc => 'Kuka co dziesięć sekund. Zwykle.';

  @override
  String get gen_metronome => 'Metronom';

  @override
  String get gen_metronome_desc => 'Tik. Tak. Tik. Tak. Nigdy się nie nudzi.';

  @override
  String get gen_watchmaker => 'Zegarmistrz';

  @override
  String get gen_watchmaker_desc => 'Lupa w oku, spokój w duszy.';

  @override
  String get gen_sprintJudge => 'Sędzia sprintu';

  @override
  String get gen_sprintJudge_desc => 'Falstart! A potem idealne 10.00.';

  @override
  String get gen_stationClock => 'Zegar dworcowy';

  @override
  String get gen_stationClock_desc =>
      'Opóźnienie może ulec zmianie. Ale prób robi mnóstwo.';

  @override
  String get gen_quartz => 'Zegar kwarcowy';

  @override
  String get gen_quartz_desc =>
      '32 768 drgań na sekundę i ani jednego za dużo.';

  @override
  String get gen_atomic => 'Zegar atomowy';

  @override
  String get gen_atomic_desc => 'Myli się o sekundę na sto milionów lat.';

  @override
  String get gen_gps => 'Satelita GPS';

  @override
  String get gen_gps_desc =>
      'Wie, gdzie jesteś. I która dokładnie jest godzina.';

  @override
  String get gen_pulsar => 'Pulsar';

  @override
  String get gen_pulsar_desc => 'Gwiazda neutronowa, która stuka jak zegarek.';

  @override
  String get gen_timeMachine => 'Maszyna czasu';

  @override
  String get gen_timeMachine_desc => 'Trafia, zanim kliknie.';

  @override
  String get gen_schrodinger => 'Kot Schrödingera';

  @override
  String get gen_schrodinger_desc =>
      'Trafił i nie trafił. Dopóki nie otworzysz pudełka.';

  @override
  String get gen_chronos => 'Chronos';

  @override
  String get gen_chronos_desc => 'Bóg czasu. Nie pudłuje. Nigdy.';

  @override
  String get syn_grandparents => 'Dziadkowie na randce';

  @override
  String get syn_birdRhythm => 'Ptasi rytm';

  @override
  String get syn_craftsmanship => 'Rzemiosło i kwarc';

  @override
  String get syn_photoFinish => 'Fotokomórka';

  @override
  String get syn_cosmicBeat => 'Kosmiczny rytm';

  @override
  String get syn_delayedTrain => 'Pociąg z przyszłości';

  @override
  String perSecond(String value) {
    return '$value/s';
  }

  @override
  String get tabClocks => 'Zegary';

  @override
  String get tabSkills => 'Umiejętności';

  @override
  String get buyAmountMax => 'MAX';

  @override
  String ownedCount(int count) {
    return '×$count';
  }

  @override
  String unitRate(String value) {
    return '$value/s każdy';
  }

  @override
  String incomeShare(String percent) {
    return '$percent% dochodu';
  }

  @override
  String windowBonus(String value) {
    return 'okna ×$value';
  }

  @override
  String get lockedName => '???';

  @override
  String get lockedHint => 'Kup poprzedni zegar, aby odkryć';

  @override
  String get upgradesTitle => 'Ulepszenia';

  @override
  String upgradeName(String generator, String level) {
    return '$generator $level';
  }

  @override
  String upgradeEffect(String generator) {
    return '$generator zarabia ×2';
  }

  @override
  String upgradeRequires(int count) {
    return 'Wymaga $count sztuk';
  }

  @override
  String synergyEffect(String a, String b, String aPct, String bPct) {
    return '$a +$aPct% za każdego: $b · $b +$bPct% za każdego: $a';
  }

  @override
  String get buy => 'Kup';

  @override
  String cost(String value) {
    return 'Cena: $value';
  }

  @override
  String get offlineTitle => 'Gdy cię nie było…';

  @override
  String offlineBody(String duration) {
    return 'Twoje zegary tykały przez $duration.';
  }

  @override
  String offlineCapped(String duration) {
    return '(policzone do $duration)';
  }

  @override
  String get collect => 'Odbierz';

  @override
  String durationHm(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationM(int minutes) {
    return '$minutes min';
  }

  @override
  String get saveCorrupt =>
      'Nie udało się odczytać zapisu, więc gra zaczęła się od nowa.';

  @override
  String get comingSoon => 'Wkrótce';

  @override
  String get skill_power => 'Siła trafienia';

  @override
  String get skill_power_desc => 'Każde trafienie płaci więcej.';

  @override
  String get skill_power_label => 'Nagroda za trafienie';

  @override
  String get skill_fastForward => 'Przewijanie';

  @override
  String get skill_fastForward_desc =>
      'Początek rundy leci szybciej. Więcej rund na minutę.';

  @override
  String get skill_fastForward_label => 'Tempo do 9.00';

  @override
  String get skill_ticking => 'Tykanie';

  @override
  String get skill_ticking_desc =>
      'Tik w ostatniej sekundzie pomaga złapać rytm.';

  @override
  String get skill_ticking_label => 'Tykanie';

  @override
  String get skill_wideEye => 'Sokole oko';

  @override
  String get skill_wideEye_desc =>
      'Szersze okna ŚWIETNIE i DOBRZE. Dla ciebie i dla zegarów.';

  @override
  String get skill_wideEye_label => 'Okno ŚWIETNIE';

  @override
  String get skill_combo => 'Combo';

  @override
  String get skill_combo_desc =>
      'Wyższy limit serii, a seria mnoży całą wypłatę.';

  @override
  String get skill_combo_label => 'Limit serii';

  @override
  String get skill_magnet => 'Magnes';

  @override
  String get skill_magnet_desc =>
      'Szersze okno PERFEKT. Cyfry same lgną do 10.00.';

  @override
  String get skill_magnet_label => 'Okno PERFEKT';

  @override
  String get skill_echo => 'Echo';

  @override
  String get skill_echo_desc => 'Trafienie płaci też sekundy dochodu zegarów.';

  @override
  String get skill_echo_label => 'Echo';

  @override
  String get skill_bulletTime => 'Bullet time';

  @override
  String get skill_bulletTime_desc =>
      'Czas zwalnia przy 10.00. Łatwiej trafić.';

  @override
  String get skill_bulletTime_label => 'Tempo przy 10.00';

  @override
  String get skill_luck => 'Szczęście';

  @override
  String get skill_luck_desc => 'Szansa, że trafienie podskoczy o próg w górę.';

  @override
  String get skill_luck_label => 'Szansa';

  @override
  String get skill_shield => 'Tarcza';

  @override
  String get skill_shield_desc => 'Pudło zużywa ładunek zamiast zerować serię.';

  @override
  String get skill_shield_label => 'Ładunki';

  @override
  String get skill_goldenTouch => 'Złoty dotyk';

  @override
  String get skill_goldenTouch_desc => 'Złota Sekunda częściej i mocniej.';

  @override
  String get skill_goldenTouch_label => 'Odstęp';

  @override
  String skillLevel(int level, int max) {
    return 'Poziom $level/$max';
  }

  @override
  String skillEffect(String label, String now, String next) {
    return '$label: $now → $next';
  }

  @override
  String skillEffectMax(String label, String now) {
    return '$label: $now';
  }

  @override
  String get skillMaxed => 'MAX';

  @override
  String skillLockedHint(String price) {
    return 'Odkryjesz przy $price Tikach';
  }

  @override
  String get on => 'wł.';

  @override
  String get off => 'wył.';

  @override
  String get goldenRound => 'ZŁOTA RUNDA!';

  @override
  String get goldenEscaped => 'Uciekła!';

  @override
  String goldenFrenzy(String mult) {
    return 'SZAŁ ×$mult!';
  }

  @override
  String goldenLucky(String amount) {
    return 'FART! +$amount';
  }

  @override
  String get goldenHotHand => 'GORĄCA RĘKA!';

  @override
  String chipFrenzy(String mult) {
    return 'Szał ×$mult';
  }

  @override
  String get chipHotHand => 'Gorąca ręka';

  @override
  String get comboLabel => 'COMBO';

  @override
  String streakLabel(int count) {
    return 'seria $count';
  }

  @override
  String get luckyBump => 'FART!';

  @override
  String get shieldSaved => 'TARCZA!';
}
