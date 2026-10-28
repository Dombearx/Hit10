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

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSound => 'Efekty dźwiękowe';

  @override
  String get settingsMusic => 'Muzyka';

  @override
  String get settingsHaptics => 'Wibracje';

  @override
  String get settingsNotifications => 'Powiadom, gdy zegary uzbierają limit';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get settingsNotation => 'Zapis liczb';

  @override
  String get notationShort => 'Skrócony (12,4M)';

  @override
  String get notationScientific => 'Naukowy (1,24e7)';

  @override
  String get settingsReduceMotion => 'Ogranicz ruch';

  @override
  String get settingsReduceMotionHint =>
      'Bez wstrząsów i błysków, mniej cząsteczek';

  @override
  String get settingsSave => 'Zapis gry';

  @override
  String get settingsExport => 'Eksportuj';

  @override
  String get settingsExportDone =>
      'Zapis skopiowany do schowka. Schowaj go gdzieś bezpiecznie.';

  @override
  String get settingsImport => 'Importuj';

  @override
  String get settingsImportHint => 'Wklej tutaj tekst zapisu';

  @override
  String get settingsImportConfirm => 'Nadpisać obecną grę tym zapisem?';

  @override
  String get settingsImportBad => 'To nie wygląda na zapis Hit10.';

  @override
  String get settingsReset => 'Zacznij od nowa';

  @override
  String get settingsResetConfirm1 =>
      'Na pewno? Stracisz wszystko: Tiki, zegary, Chronony i osiągnięcia. Ustawienia zostaną.';

  @override
  String settingsResetConfirm2(String word) {
    return 'Wpisz $word, aby potwierdzić.';
  }

  @override
  String get resetWord => 'RESET';

  @override
  String get settingsCredits => 'Autorzy i licencje';

  @override
  String get creditsLegalese =>
      'Grafika: Microsoft Fluent Emoji (MIT).\nCzcionki: Paytone One i Nunito (SIL Open Font License 1.1).\nDźwięki i muzyka: własne, syntezowane w kodzie.';

  @override
  String get settingsOther => 'Inne';

  @override
  String get upg_grandpa_1 => 'Okulary do czytania';

  @override
  String get upg_grandpa_1_desc => 'Wreszcie widzi wskazówki.';

  @override
  String get upg_grandpa_2 => 'Nowa bateria';

  @override
  String get upg_grandpa_2_desc => 'Pierwsza od czasów kasety magnetofonowej.';

  @override
  String get upg_grandpa_3 => 'Kapcie antypoślizgowe';

  @override
  String get upg_grandpa_3_desc => 'Stabilne stopy, stabilny kciuk.';

  @override
  String get upg_grandpa_4 => 'Krzyżówka z hasłem „CZAS”';

  @override
  String get upg_grandpa_4_desc => 'Rozwiązana w równe 10,00 s.';

  @override
  String get upg_grandpa_5 => 'Sanatorium';

  @override
  String get upg_grandpa_5_desc => 'Wraca wypoczęty i dwa razy celniejszy.';

  @override
  String get upg_grandpa_6 => 'Wnuk informatyk';

  @override
  String get upg_grandpa_6_desc =>
      'Zsynchronizował mu zegarek z serwerem atomowym.';

  @override
  String get upg_grandpa_7 => 'Medal za punktualność';

  @override
  String get upg_grandpa_7_desc => 'Przypięty dumnie do kamizelki.';

  @override
  String get upg_grandpa_8 => 'Zegarek po pradziadku';

  @override
  String get upg_grandpa_8_desc => 'Tyka w rodzinie od trzech pokoleń.';

  @override
  String get upg_grandma_1 => 'Jajka od szczęśliwych kur';

  @override
  String get upg_grandma_1_desc => 'Szczęśliwe kury, szczęśliwe minutniki.';

  @override
  String get upg_grandma_2 => 'Fartuch w kropki';

  @override
  String get upg_grandma_2_desc => 'Aerodynamiczny.';

  @override
  String get upg_grandma_3 => 'Drugi minutnik';

  @override
  String get upg_grandma_3_desc => 'Jeden do jajek, drugi do rosołu.';

  @override
  String get upg_grandma_4 => 'Koło gospodyń';

  @override
  String get upg_grandma_4_desc => 'Szkolenie z kuchennej precyzji. Z ciastem.';

  @override
  String get upg_grandma_5 => 'Książka „Dania w 10 sekund”';

  @override
  String get upg_grandma_5_desc => 'Same szybkie przepisy.';

  @override
  String get upg_grandma_6 => 'Kuchenka indukcyjna';

  @override
  String get upg_grandma_6_desc => 'Woda wrze, zanim pomyślisz.';

  @override
  String get upg_grandma_7 => 'Wnuczka influencerka';

  @override
  String get upg_grandma_7_desc => 'Nagrywa każde idealne 10,00.';

  @override
  String get upg_grandma_8 => 'Złoty wałek';

  @override
  String get upg_grandma_8_desc => 'Legenda całego osiedla.';

  @override
  String get upg_cuckoo_1 => 'Kurs dykcji';

  @override
  String get upg_cuckoo_1_desc => 'Ku-ku. Wyraźnie i na czas.';

  @override
  String get upg_cuckoo_2 => 'Nowe sprężynki';

  @override
  String get upg_cuckoo_2_desc => 'Wyskakuje jak z procy.';

  @override
  String get upg_cuckoo_3 => 'Gniazdo z widokiem';

  @override
  String get upg_cuckoo_3_desc => 'Lepszy widok, lepsze kukanie.';

  @override
  String get upg_cuckoo_4 => 'Chór kukułek';

  @override
  String get upg_cuckoo_4_desc => 'Kukają w kanonie.';

  @override
  String get upg_cuckoo_5 => 'Lekcje u szwajcarskiego mistrza';

  @override
  String get upg_cuckoo_5_desc => 'Precyzja prosto z Alp.';

  @override
  String get upg_cuckoo_6 => 'Ziarna espresso';

  @override
  String get upg_cuckoo_6_desc => 'Kuka szybciej, niż chce.';

  @override
  String get upg_cuckoo_7 => 'Własny agent';

  @override
  String get upg_cuckoo_7_desc => 'Podpisała kontrakt na trasę koncertową.';

  @override
  String get upg_cuckoo_8 => 'Oryginał ze Schwarzwaldu';

  @override
  String get upg_cuckoo_8_desc => 'Z certyfikatem i rodowodem.';

  @override
  String get upg_metronome_1 => 'Nowy obciążnik';

  @override
  String get upg_metronome_1_desc => 'Mniej się waha, więcej trafia.';

  @override
  String get upg_metronome_2 => 'Smar do wahadła';

  @override
  String get upg_metronome_2_desc => 'Cisza. Tylko tik-tak.';

  @override
  String get upg_metronome_3 => 'Takt na sześć ósmych';

  @override
  String get upg_metronome_3_desc => 'Dla odmiany.';

  @override
  String get upg_metronome_4 => 'Posada w filharmonii';

  @override
  String get upg_metronome_4_desc => 'Sto skrzypiec patrzy tylko na niego.';

  @override
  String get upg_metronome_5 => 'Tryb techno';

  @override
  String get upg_metronome_5_desc =>
      '140 uderzeń na minutę i ani jednego obok.';

  @override
  String get upg_metronome_6 => 'Cyfrowy bliźniak';

  @override
  String get upg_metronome_6_desc => 'Rodzinna rywalizacja.';

  @override
  String get upg_metronome_7 => 'Trasa z kwartetem jazzowym';

  @override
  String get upg_metronome_7_desc => 'Swinguje, ale się nie spóźnia.';

  @override
  String get upg_metronome_8 => 'Złote wahadło';

  @override
  String get upg_metronome_8_desc => 'Rytm doskonały.';

  @override
  String get upg_watchmaker_1 => 'Nowa lupa';

  @override
  String get upg_watchmaker_1_desc => 'Widzi każdą zębatkę. Nawet w myślach.';

  @override
  String get upg_watchmaker_2 => 'Zestaw śrubokrętów';

  @override
  String get upg_watchmaker_2_desc => '48 rozmiarów, wszystkie mikro.';

  @override
  String get upg_watchmaker_3 => 'Czeladnik';

  @override
  String get upg_watchmaker_3_desc => 'Uczy się na Twoich Tikach.';

  @override
  String get upg_watchmaker_4 => 'Warsztat przy oknie';

  @override
  String get upg_watchmaker_4_desc => 'Dzienne światło, dzienna precyzja.';

  @override
  String get upg_watchmaker_5 => 'Mechanizm szwajcarski';

  @override
  String get upg_watchmaker_5_desc => 'Przywieziony w walizce na kłódkę.';

  @override
  String get upg_watchmaker_6 => 'Tourbillon';

  @override
  String get upg_watchmaker_6_desc => 'Kręci się, żeby nigdy się nie mylić.';

  @override
  String get upg_watchmaker_7 => 'Cech zegarmistrzów';

  @override
  String get upg_watchmaker_7_desc => 'Tajemna wiedza przekazywana szeptem.';

  @override
  String get upg_watchmaker_8 => 'Wielka komplikacja';

  @override
  String get upg_watchmaker_8_desc => 'Nikt nie wie, co robi. Ale działa.';

  @override
  String get upg_sprintJudge_1 => 'Nowy gwizdek';

  @override
  String get upg_sprintJudge_1_desc => 'Fiuuu! Dokładnie na czas.';

  @override
  String get upg_sprintJudge_2 => 'Fotokomórka';

  @override
  String get upg_sprintJudge_2_desc => 'Widzi różnicę jednej setnej.';

  @override
  String get upg_sprintJudge_3 => 'Pistolet startowy';

  @override
  String get upg_sprintJudge_3_desc => 'Bez naboi, za to z wyczuciem.';

  @override
  String get upg_sprintJudge_4 => 'Wysokie krzesło';

  @override
  String get upg_sprintJudge_4_desc => 'Z widokiem prosto na metę.';

  @override
  String get upg_sprintJudge_5 => 'Licencja olimpijska';

  @override
  String get upg_sprintJudge_5_desc => 'Teraz to już oficjalne.';

  @override
  String get upg_sprintJudge_6 => 'Powtórka wideo';

  @override
  String get upg_sprintJudge_6_desc => 'Klatka po klatce.';

  @override
  String get upg_sprintJudge_7 => 'Rekord świata w sędziowaniu';

  @override
  String get upg_sprintJudge_7_desc => '9,58 s? Za wolno.';

  @override
  String get upg_sprintJudge_8 => 'Złoty stoper';

  @override
  String get upg_sprintJudge_8_desc => 'Mierzy czas, jakby go wymyślił.';

  @override
  String get upg_stationClock_1 => 'Nowy rozkład jazdy';

  @override
  String get upg_stationClock_1_desc => 'Teraz uwzględnia rzeczywistość.';

  @override
  String get upg_stationClock_2 => 'Umyta tarcza';

  @override
  String get upg_stationClock_2_desc => 'Widać ją z peronu piątego.';

  @override
  String get upg_stationClock_3 => 'Komunikat z megafonu';

  @override
  String get upg_stationClock_3_desc =>
      '„Pociąg o 10,00 przyjedzie punktualnie.”';

  @override
  String get upg_stationClock_4 => 'Zawiadowca stacji';

  @override
  String get upg_stationClock_4_desc =>
      'Czapka z daszkiem i śmiertelna powaga.';

  @override
  String get upg_stationClock_5 => 'Kolej dużych prędkości';

  @override
  String get upg_stationClock_5_desc => 'Mniej opóźnień, więcej trafień.';

  @override
  String get upg_stationClock_6 => 'Zegar sterowany radiowo';

  @override
  String get upg_stationClock_6_desc => 'Radio wie, która godzina.';

  @override
  String get upg_stationClock_7 => 'Dworzec centralny';

  @override
  String get upg_stationClock_7_desc =>
      'Tysiąc pasażerów patrzy na jeden zegar.';

  @override
  String get upg_stationClock_8 => 'Punktualny pociąg';

  @override
  String get upg_stationClock_8_desc => 'Legenda, w którą nikt nie wierzył.';

  @override
  String get upg_quartz_1 => 'Świeży kryształ';

  @override
  String get upg_quartz_1_desc => 'Drga jak nowy.';

  @override
  String get upg_quartz_2 => 'Porządne lutowanie';

  @override
  String get upg_quartz_2_desc => 'Bez zimnych lutów, bez wymówek.';

  @override
  String get upg_quartz_3 => 'Wyświetlacz LCD';

  @override
  String get upg_quartz_3_desc => 'Cyferki jak z lat 80.';

  @override
  String get upg_quartz_4 => 'Kompensacja temperatury';

  @override
  String get upg_quartz_4_desc => 'Pogoda go nie obchodzi.';

  @override
  String get upg_quartz_5 => 'Podwójny oscylator';

  @override
  String get upg_quartz_5_desc => 'Dwa razy 32 768.';

  @override
  String get upg_quartz_6 => 'Fabryka w Szwajcarii';

  @override
  String get upg_quartz_6_desc => 'Ironia losu.';

  @override
  String get upg_quartz_7 => 'Kalkulator w zestawie';

  @override
  String get upg_quartz_7_desc => 'Liczy Tiki w locie.';

  @override
  String get upg_quartz_8 => 'Kryształ górski';

  @override
  String get upg_quartz_8_desc => 'Ten z legend.';

  @override
  String get upg_atomic_1 => 'Chłodzenie laserowe';

  @override
  String get upg_atomic_1_desc => 'Atomy prawie stoją. Prawie.';

  @override
  String get upg_atomic_2 => 'Czystszy cez';

  @override
  String get upg_atomic_2_desc => 'Cez 133, bez dodatków.';

  @override
  String get upg_atomic_3 => 'Fontanna atomowa';

  @override
  String get upg_atomic_3_desc => 'Atomy podskakują w rytm.';

  @override
  String get upg_atomic_4 => 'Zegar optyczny';

  @override
  String get upg_atomic_4_desc => 'Mierzy czas światłem.';

  @override
  String get upg_atomic_5 => 'Pułapka jonowa';

  @override
  String get upg_atomic_5_desc => 'Jeden jon, zero wymówek.';

  @override
  String get upg_atomic_6 => 'Sieć laboratoriów';

  @override
  String get upg_atomic_6_desc => 'Każda sekunda przechodzi głosowanie.';

  @override
  String get upg_atomic_7 => 'Sekunda przestępna';

  @override
  String get upg_atomic_7_desc => 'Dodana, gdy nikt nie patrzył.';

  @override
  String get upg_atomic_8 => 'Zegar jądrowy';

  @override
  String get upg_atomic_8_desc => 'Tor-229 nie zna żartów.';

  @override
  String get upg_gps_1 => 'Lepsza antena';

  @override
  String get upg_gps_1_desc => 'Słyszy Ziemię wyraźniej.';

  @override
  String get upg_gps_2 => 'Poprawka relatywistyczna';

  @override
  String get upg_gps_2_desc => 'Einstein byłby dumny.';

  @override
  String get upg_gps_3 => 'Większy panel słoneczny';

  @override
  String get upg_gps_3_desc => 'Więcej mocy, więcej tików.';

  @override
  String get upg_gps_4 => 'Konstelacja';

  @override
  String get upg_gps_4_desc => '31 przyjaciół na orbicie.';

  @override
  String get upg_gps_5 => 'Poprawka jonosferyczna';

  @override
  String get upg_gps_5_desc => 'Przez chmury i burze.';

  @override
  String get upg_gps_6 => 'Stacja naziemna';

  @override
  String get upg_gps_6_desc => 'Ktoś pilnuje z dołu.';

  @override
  String get upg_gps_7 => 'Łącze laserowe';

  @override
  String get upg_gps_7_desc => 'Satelity szepczą do siebie światłem.';

  @override
  String get upg_gps_8 => 'Orbita geostacjonarna';

  @override
  String get upg_gps_8_desc => 'Zawsze w tym samym miejscu. Zawsze na czas.';

  @override
  String get upg_pulsar_1 => 'Większy radioteleskop';

  @override
  String get upg_pulsar_1_desc => 'Słyszy każde stuknięcie.';

  @override
  String get upg_pulsar_2 => 'Pulsar milisekundowy';

  @override
  String get upg_pulsar_2_desc => '700 obrotów na sekundę.';

  @override
  String get upg_pulsar_3 => 'Mapa nieba';

  @override
  String get upg_pulsar_3_desc => 'Wreszcie wiadomo, gdzie patrzeć.';

  @override
  String get upg_pulsar_4 => 'Sieć pulsarów';

  @override
  String get upg_pulsar_4_desc => 'Kosmiczny chór metronomów.';

  @override
  String get upg_pulsar_5 => 'Fale grawitacyjne';

  @override
  String get upg_pulsar_5_desc => 'Czasoprzestrzeń drży w takt.';

  @override
  String get upg_pulsar_6 => 'Magnetar';

  @override
  String get upg_pulsar_6_desc => 'Pulsar, ale z charakterem.';

  @override
  String get upg_pulsar_7 => 'Kosmiczna latarnia';

  @override
  String get upg_pulsar_7_desc => 'Prowadzi statki do domu. Na czas.';

  @override
  String get upg_pulsar_8 => 'Serce galaktyki';

  @override
  String get upg_pulsar_8_desc => 'Cała Droga Mleczna tyka razem z nim.';

  @override
  String get upg_timeMachine_1 => 'Kondensator strumienia';

  @override
  String get upg_timeMachine_1_desc => '1,21 gigawata, ani wata mniej.';

  @override
  String get upg_timeMachine_2 => 'Pasy bezpieczeństwa';

  @override
  String get upg_timeMachine_2_desc => 'Na wypadek paradoksu.';

  @override
  String get upg_timeMachine_3 => 'Liścik z przyszłości';

  @override
  String get upg_timeMachine_3_desc => '„Kliknij teraz.”';

  @override
  String get upg_timeMachine_4 => 'Pętla czasowa';

  @override
  String get upg_timeMachine_4_desc => 'Ćwiczy te same 10 sekund w kółko.';

  @override
  String get upg_timeMachine_5 => 'Zapasowa linia czasu';

  @override
  String get upg_timeMachine_5_desc => 'Tak na wszelki wypadek.';

  @override
  String get upg_timeMachine_6 => 'Wycieczki do 10,00';

  @override
  String get upg_timeMachine_6_desc => 'Z przewodnikiem.';

  @override
  String get upg_timeMachine_7 => 'Spotkanie z samym sobą';

  @override
  String get upg_timeMachine_7_desc => 'Uprzejme, ale dziwne.';

  @override
  String get upg_timeMachine_8 => 'Koniec czasu';

  @override
  String get upg_timeMachine_8_desc => 'Bilet w jedną stronę.';

  @override
  String get upg_schrodinger_1 => 'Większe pudełko';

  @override
  String get upg_schrodinger_1_desc => 'Więcej miejsca na niepewność.';

  @override
  String get upg_schrodinger_2 => 'Karma kwantowa';

  @override
  String get upg_schrodinger_2_desc => 'Zjedzona i niezjedzona.';

  @override
  String get upg_schrodinger_3 => 'Splątany kłębek';

  @override
  String get upg_schrodinger_3_desc => 'Splątanie na życzenie.';

  @override
  String get upg_schrodinger_4 => 'Kocimiętka superpozycji';

  @override
  String get upg_schrodinger_4_desc => 'Mruczy w dwóch stanach naraz.';

  @override
  String get upg_schrodinger_5 => 'Obserwator na urlopie';

  @override
  String get upg_schrodinger_5_desc => 'Nikt nie patrzy, wszystko trafia.';

  @override
  String get upg_schrodinger_6 => 'Druga kotka';

  @override
  String get upg_schrodinger_6_desc => 'Teraz stany są cztery.';

  @override
  String get upg_schrodinger_7 => 'Wiele światów';

  @override
  String get upg_schrodinger_7_desc => 'W którymś zawsze jest 10,00.';

  @override
  String get upg_schrodinger_8 => 'Otwarte pudełko';

  @override
  String get upg_schrodinger_8_desc => 'Trafił. Zdecydowanie trafił.';

  @override
  String get upg_chronos_1 => 'Naostrzona kosa';

  @override
  String get upg_chronos_1_desc => 'Tnie sekundy na setne.';

  @override
  String get upg_chronos_2 => 'Klepsydra z Olimpu';

  @override
  String get upg_chronos_2_desc => 'Piasek prosto od bogów.';

  @override
  String get upg_chronos_3 => 'Świątynia';

  @override
  String get upg_chronos_3_desc => 'Wierni przynoszą zegarki.';

  @override
  String get upg_chronos_4 => 'Rozmowa z Kairosem';

  @override
  String get upg_chronos_4_desc => 'O właściwym momencie.';

  @override
  String get upg_chronos_5 => 'Tron z zębatek';

  @override
  String get upg_chronos_5_desc => 'Wygodny, choć tyka.';

  @override
  String get upg_chronos_6 => 'Panteon punktualnych';

  @override
  String get upg_chronos_6_desc => 'Bogowie, którzy zawsze zdążą.';

  @override
  String get upg_chronos_7 => 'Wieczność';

  @override
  String get upg_chronos_7_desc => 'Ma czas. Dosłownie.';

  @override
  String get upg_chronos_8 => 'Sekunda absolutna';

  @override
  String get upg_chronos_8_desc => '10,00. Od zawsze i na zawsze.';
}
