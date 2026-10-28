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

  @override
  String ach_earned(String amount) {
    return 'Zarobione: $amount';
  }

  @override
  String ach_earned_desc(String amount) {
    return 'Zarób łącznie $amount Tików';
  }

  @override
  String ach_owned(String generator, String count) {
    return '$generator ×$count';
  }

  @override
  String ach_owned_desc(String generator, String count) {
    return 'Miej $count × $generator';
  }

  @override
  String ach_perfects(String count) {
    return 'Perfekcjonista $count';
  }

  @override
  String ach_perfects_desc(String count) {
    return 'Traf PERFEKT $count razy';
  }

  @override
  String ach_perfectStreak(String count) {
    return 'Bez skazy $count';
  }

  @override
  String ach_perfectStreak_desc(String count) {
    return '$count PERFEKTY z rzędu';
  }

  @override
  String ach_combo(String count) {
    return 'Combo $count';
  }

  @override
  String ach_combo_desc(String count) {
    return 'Osiągnij serię $count';
  }

  @override
  String ach_golden(String count) {
    return 'Łowca złota $count';
  }

  @override
  String ach_golden_desc(String count) {
    return 'Złap $count Złotych Sekund';
  }

  @override
  String ach_prestige(String count) {
    return 'Podróżnik w czasie $count';
  }

  @override
  String ach_prestige_desc(String count) {
    return 'Zrób prestiż $count razy';
  }

  @override
  String get ach_mode_blind => 'Na ślepo';

  @override
  String get ach_mode_blind_desc => 'PERFEKT w trybie na ślepo';

  @override
  String get ach_mode_fast => 'Szybkie ręce';

  @override
  String get ach_mode_fast_desc => 'PERFEKT w szybkim zegarze';

  @override
  String get ach_mode_both => 'Szaleniec';

  @override
  String get ach_mode_both_desc => 'PERFEKT w obu trybach naraz';

  @override
  String get ach_hidden_impatient => 'Niecierpliwy';

  @override
  String get ach_hidden_impatient_desc => '100 razy ZA WCZEŚNIE';

  @override
  String get ach_hidden_nap => 'Drzemka';

  @override
  String get ach_hidden_nap_desc => '10 rund z rzędu bez dotknięcia';

  @override
  String get ach_hidden_almost => 'Prawie';

  @override
  String get ach_hidden_almost_desc => '9.99, a potem 10.01';

  @override
  String get ach_hidden_punctual => 'Punktualny';

  @override
  String get ach_hidden_punctual_desc => 'PERFEKT o 10:00 rano';

  @override
  String get ach_hidden_tenth => 'Dziesiątka';

  @override
  String get ach_hidden_tenth_desc => '10 PERFEKTÓW 10. dnia miesiąca';

  @override
  String get ach_hidden_fullCollection => 'Pełna kolekcja';

  @override
  String get ach_hidden_fullCollection_desc => 'Wszystkie umiejętności na max';

  @override
  String get ach_hidden_museum => 'Muzeum';

  @override
  String get ach_hidden_museum_desc => 'Po jednym z każdego zegara';

  @override
  String get ach_hidden_boiledEgg => 'Jajko na miękko';

  @override
  String get ach_hidden_boiledEgg_desc => '100 babć';

  @override
  String get perk_headStart => 'Szybki start';

  @override
  String get perk_headStart_desc =>
      'Każdy run zaczynasz z 10 dziadkami i 1K Tików';

  @override
  String get perk_muscleMemory1 => 'Pamięć mięśniowa I';

  @override
  String get perk_muscleMemory1_desc => 'Przewijanie zostaje po paradoksie';

  @override
  String get perk_muscleMemory2 => 'Pamięć mięśniowa II';

  @override
  String get perk_muscleMemory2_desc => 'Sokole oko i Magnes też zostają';

  @override
  String get perk_muscleMemory3 => 'Pamięć mięśniowa III';

  @override
  String get perk_muscleMemory3_desc =>
      'Pozostałe umiejętności zostają na połowie';

  @override
  String get perk_longNap1 => 'Długa drzemka I';

  @override
  String get perk_longNap1_desc => 'Limit offline 12 h';

  @override
  String get perk_longNap2 => 'Długa drzemka II';

  @override
  String get perk_longNap2_desc => 'Limit offline 24 h';

  @override
  String get perk_deepSleep1 => 'Głęboki sen I';

  @override
  String get perk_deepSleep1_desc => 'Offline 75% wydajności';

  @override
  String get perk_deepSleep2 => 'Głęboki sen II';

  @override
  String get perk_deepSleep2_desc => 'Offline 100% wydajności';

  @override
  String get perk_goldRush => 'Gorączka złota';

  @override
  String get perk_goldRush_desc => 'Złota Sekunda o 15% częściej';

  @override
  String get perk_startShield => 'Tarcza na start';

  @override
  String get perk_startShield_desc =>
      'Jeden ładunek tarczy, nawet bez umiejętności';

  @override
  String get perk_comboFloor => 'Twarde lądowanie';

  @override
  String get perk_comboFloor_desc => 'Pudło zrzuca serię do 5, nie do 0';

  @override
  String get perk_autoBuyer => 'Automatyczny kupiec';

  @override
  String get perk_autoBuyer_desc =>
      'Przełącznik: kupuje najtańszy zegar co 5 s';

  @override
  String get perk_earlyModes => 'Śmiałek';

  @override
  String get perk_earlyModes_desc => 'Tryby ryzyka odblokowane od razu';

  @override
  String get perk_unlockSchrodinger => 'Pudełko z kotem';

  @override
  String get perk_unlockSchrodinger_desc => 'Odblokowuje Kota Schrödingera';

  @override
  String get perk_secondClock => 'Drugi zegar';

  @override
  String get perk_secondClock_desc => 'Graj na dwóch stoperach naraz';

  @override
  String get perk_unlockChronos => 'Ołtarz Chronosa';

  @override
  String get perk_unlockChronos_desc => 'Odblokowuje Chronosa';

  @override
  String get achievementsTitle => 'Osiągnięcia';

  @override
  String achievementsSummary(int count, int total, String percent) {
    return '$count/$total · +$percent% dochodu';
  }

  @override
  String achievementsUnlocked(int count) {
    return '$count nowych osiągnięć!';
  }

  @override
  String get achievementUnlocked => 'Nowe osiągnięcie!';

  @override
  String get hiddenAchievement => 'Ukryte osiągnięcie';

  @override
  String get statsTitle => 'Statystyki';

  @override
  String get statEarnedRun => 'Zarobione w tym runie';

  @override
  String get statEarnedTotal => 'Zarobione łącznie';

  @override
  String get statRounds => 'Rundy';

  @override
  String get statTiers => 'Trafienia';

  @override
  String get statMeanError => 'Średni błąd';

  @override
  String get statSpread => 'Rozrzut';

  @override
  String get statMeanHint => 'ujemny = klikasz za wcześnie';

  @override
  String get statBestStreak => 'Najlepsza seria PERFEKT';

  @override
  String get statBestCombo => 'Najwyższe combo';

  @override
  String get statGolden => 'Złapane Złote Sekundy';

  @override
  String get statPlayTime => 'Czas gry';

  @override
  String get statPrestiges => 'Prestiże';

  @override
  String get statChronons => 'Chronony';

  @override
  String ms(String value) {
    return '$value ms';
  }

  @override
  String get prestigeTitle => 'Paradoks czasowy';

  @override
  String prestigeChronons(int count, String percent) {
    return 'Chronony: $count (+$percent% na zawsze)';
  }

  @override
  String prestigeShards(int count) {
    return 'Okruchy czasu: $count';
  }

  @override
  String prestigeGain(int count) {
    return 'Cofnij czas teraz: +$count Chrononów';
  }

  @override
  String prestigeNext(String amount) {
    return 'Jeszcze $amount Tików do następnego Chrononu';
  }

  @override
  String get prestigeButton => 'Cofnij czas';

  @override
  String get prestigeConfirm1 =>
      'Stracisz zegary, umiejętności i Tiki. Chronony, perki i osiągnięcia zostają. Dalej?';

  @override
  String get prestigeConfirm2 => 'Na pewno? Czas zostanie cofnięty.';

  @override
  String get perksTitle => 'Perki';

  @override
  String perkRequires(String name) {
    return 'Wymaga: $name';
  }

  @override
  String get perkOwned => 'Masz';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get cancel => 'Anuluj';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Pomiń';

  @override
  String get modeBlind => 'Na ślepo ×3';

  @override
  String get modeFast => 'Szybki zegar ×2';

  @override
  String get modeSecond => 'Drugi zegar';

  @override
  String get modeAuto => 'Auto-kupiec';

  @override
  String get adTurbo => 'Turbo ×2';

  @override
  String adTurboLeft(String time) {
    return '×2 · $time';
  }

  @override
  String get adGolden => 'Złota Sekunda';

  @override
  String adBag(int minutes) {
    return '+$minutes min';
  }

  @override
  String adRescue(int count) {
    return 'Seria $count przepadła! Przywróć';
  }

  @override
  String get adDouble => 'Podwój';

  @override
  String get adUnavailable => 'Reklama niedostępna';

  @override
  String adCooldown(String time) {
    return 'za $time';
  }

  @override
  String get adFull => 'Pełne';

  @override
  String get tutorialAim => 'Dotknij, gdy będzie dokładnie 10.00';

  @override
  String get tutorialBuy => 'Kup dziadka — będzie trafiał za ciebie!';

  @override
  String get tutorialInfo =>
      'Dziadek próbuje co 10 sekund. Im więcej zegarów, tym więcej Tików!';

  @override
  String get tutorialGotIt => 'Super!';

  @override
  String get tip_skills =>
      'Nowa umiejętność! Zajrzyj do zakładki Umiejętności.';

  @override
  String get tip_golden =>
      'Złota Sekunda! Złap latający zegarek: następna runda będzie złota.';

  @override
  String get tip_combo =>
      'Seria! Kolejne ŚWIETNIE i PERFEKT podbijają mnożnik.';

  @override
  String get tip_prestige =>
      'Możesz cofnąć czas: prestiż daje Chronony, czyli stały bonus.';

  @override
  String notificationTitle(String amount) {
    return 'Twoje zegary uzbierały $amount Tików! Wracaj po więcej.';
  }

  @override
  String get notificationAsk => 'Dać znać, gdy zegary uzbierają limit?';
}
