// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Hit5';

  @override
  String get tagline => 'Dotknij dokładnie w 5.00';

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
  String get missClose => 'BLISKO!';

  @override
  String get arenaLabel => 'Stoper. Zatrzymaj go dokładnie na 5.00.';

  @override
  String get tapToStart => 'Dotknij, aby zacząć';

  @override
  String get pausedTapToPlay => 'Pauza · dotknij, by grać';

  @override
  String get pause => 'Pauza';

  @override
  String get resume => 'Graj';

  @override
  String get decimalSeparator => ',';

  @override
  String get gen_grandpa => 'Dziadek z zegarkiem';

  @override
  String get gen_grandpa_desc =>
      'Dziadek: „Zegarek po ojcu. Chodzi jak złoto.”\nBabcia: „Złoto nie chodzi.”';

  @override
  String get gen_grandma => 'Babcia z minutnikiem';

  @override
  String get gen_grandma_desc =>
      'Babcia: „Minutnik z siedemdziesiątego czwartego. Ani razu się nie spóźnił.”\nDziadek: „Bo nie musi nigdzie chodzić.”';

  @override
  String get gen_cuckoo => 'Kukułka';

  @override
  String get gen_cuckoo_desc =>
      'Dziadek: „Kuka równo co pięć sekund.”\nBabcia: „Kukała. Zanim ją naprawiłeś.”';

  @override
  String get gen_metronome => 'Metronom';

  @override
  String get gen_metronome_desc =>
      'Dziadek: „Na nim się uczyłem tańczyć.”\nBabcia: „I się nie nauczyłeś.”';

  @override
  String get gen_watchmaker => 'Zegarmistrz';

  @override
  String get gen_watchmaker_desc =>
      'Dziadek: „Pan Henio. Naprawi każdy zegarek.”\nBabcia: „Twój oddaje bez słowa.”';

  @override
  String get gen_sprintJudge => 'Sędzia sprintu';

  @override
  String get gen_sprintJudge_desc =>
      'Dziadek: „Wie, co to setna sekundy.”\nBabcia: „A ty wiesz, co to piąta po południu?”';

  @override
  String get gen_stationClock => 'Zegar dworcowy';

  @override
  String get gen_stationClock_desc =>
      'Dziadek: „Spóźnia się, ale zawsze przyjeżdża.”\nBabcia: „Ty też. Dlatego go lubisz.”';

  @override
  String get gen_quartz => 'Zegar kwarcowy';

  @override
  String get gen_quartz_desc =>
      'Dziadek: „32 768 drgań na sekundę.”\nBabcia: „A ty drgniesz, dopiero jak zawołam na obiad.”';

  @override
  String get gen_atomic => 'Zegar atomowy';

  @override
  String get gen_atomic_desc =>
      'Dziadek: „Myli się o sekundę na sto milionów lat. Teraz zdążę.”\nBabcia: „Mówiłeś to przy kukułce.”';

  @override
  String get gen_gps => 'Satelita GPS';

  @override
  String get gen_gps_desc =>
      'Dziadek: „Wie, gdzie jestem, co do metra.”\nBabcia: „Ja też. W garażu.”';

  @override
  String get gen_pulsar => 'Pulsar';

  @override
  String get gen_pulsar_desc =>
      'Dziadek: „Gwiazda, która tyka. Pożyczona z kosmosu.”\nBabcia: „Oddasz jak moją wiertarkę.”';

  @override
  String get gen_timeMachine => 'Maszyna czasu';

  @override
  String get gen_timeMachine_desc =>
      'Dziadek: „Gdybym ją miał w siedemdziesiątym czwartym… Ale przecież zdążyłem!”\nBabcia: „Mhm.”';

  @override
  String get gen_schrodinger => 'Kot Schrödingera';

  @override
  String get gen_schrodinger_desc =>
      'Dziadek: „Trafił i nie trafił naraz.”\nBabcia: „Jak ty z kwiatami na rocznicę.”';

  @override
  String get gen_chronos => 'Chronos';

  @override
  String get gen_chronos_desc =>
      'Dziadek: „Sam Czas. Najdokładniejszy zegar na świecie.”\nBabcia: „Czasu się nie kupuje. Czas się zaprasza.”';

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
  String get lockedName => '???';

  @override
  String get lockedHint => 'Kup poprzedni zegar, aby odkryć';

  @override
  String get upgradesTitle => 'Ulepszenia';

  @override
  String upgradeRequires(int count) {
    return 'Wymaga $count sztuk';
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
  String durationH(int hours) {
    return '$hours h';
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
  String get skill_power_desc => 'Więcej Tików za każde trafienie.';

  @override
  String get skill_power_label => 'Tiki za PERFEKT';

  @override
  String get skill_fastForward => 'Start później';

  @override
  String get skill_fastForward_desc =>
      'Stoper rusza od wyższej wartości, więc runda jest krótsza.';

  @override
  String get skill_fastForward_label => 'Stoper startuje od';

  @override
  String get skill_ticking => 'Tykanie';

  @override
  String get skill_ticking_desc => 'Tykanie w ostatniej sekundzie przed celem.';

  @override
  String get skill_ticking_label => 'Tykanie';

  @override
  String get skill_wideEye => 'Sokole oko';

  @override
  String get skill_wideEye_desc =>
      'Szersze okna ŚWIETNIE i DOBRZE. Twoje i zegarów.';

  @override
  String get skill_wideEye_label => 'ŚWIETNIE / DOBRZE';

  @override
  String get skill_combo => 'Combo';

  @override
  String get skill_combo_desc => 'Wyższy limit mnożnika.';

  @override
  String get skill_combo_label => 'Mnożnik do';

  @override
  String get skill_magnet => 'Magnes';

  @override
  String get skill_magnet_desc => 'Szersze okno PERFEKT. Twoje i zegarów.';

  @override
  String get skill_magnet_label => 'Okno PERFEKT';

  @override
  String get skill_echo => 'Echo';

  @override
  String get skill_echo_desc =>
      'Trafienie dodaje Tiki, które zegary zarabiają w ułamku sekundy.';

  @override
  String get skill_echo_label => 'PERFEKT dokłada pracy zegarów';

  @override
  String get skill_bulletTime => 'Zimna krew';

  @override
  String get skill_bulletTime_desc =>
      'Szersze wszystkie twoje okna. Nie działa na zegary.';

  @override
  String get skill_bulletTime_label => 'Twoje okno DOBRZE';

  @override
  String get skill_luck => 'Szczęście';

  @override
  String get skill_luck_desc => 'Część trafień wpada o próg wyżej.';

  @override
  String get skill_luck_label => 'Trafienia o próg w górę';

  @override
  String get skill_shield => 'Tarcza';

  @override
  String get skill_shield_desc =>
      'Pudło zużywa ładunek zamiast zerować mnożnik.';

  @override
  String get skill_shield_label => 'Ładunki';

  @override
  String get skill_goldenTouch => 'Złoty dotyk';

  @override
  String get skill_goldenTouch_desc =>
      'Złota Sekunda częściej i z mocniejszym efektem.';

  @override
  String get skill_goldenTouch_label => 'Złota Sekunda co';

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
  String skillKeptInfo(String kept, String share) {
    return 'Po paradoksie zostaje $kept poz. (Pamięć mięśniowa: $share% poziomów, zaokrąglone).';
  }

  @override
  String get skillKeptNone =>
      'Po paradoksie umiejętności wracają do zera. Perk Pamięć mięśniowa zachowuje część poziomów, a Nawyk całą wybraną umiejętność — kupione dziś dadzą lepszy start następnym razem.';

  @override
  String prestigeHabitTitle(String used, String slots) {
    return 'Nawyk $used/$slots: które umiejętności zachowają wszystkie poziomy?';
  }

  @override
  String get skillKeptHabit =>
      'W slocie Nawyku: po paradoksie zostają wszystkie poziomy.';

  @override
  String get skillHabitRemove => 'Wyjmij z Nawyku';

  @override
  String skillHabitAdd(String used, String slots) {
    return 'Zachowaj w całości (Nawyk $used/$slots)';
  }

  @override
  String skillHabitMove(String skill) {
    return 'Zachowaj w całości zamiast: $skill';
  }

  @override
  String inHundred(String n) {
    return '$n%';
  }

  @override
  String get oddsPerfect => 'PERFEKTY';

  @override
  String get oddsGreatOrBetter => 'ŚWIETNIE lub lepiej';

  @override
  String get oddsHits => 'trafienia';

  @override
  String skillOdds(String tier, String now, String next) {
    return 'Twoje $tier: ok. $now% → $next% rund';
  }

  @override
  String skillOddsMax(String tier, String now) {
    return 'Twoje $tier: ok. $now% rund';
  }

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
  String streakLabel(int count, int target) {
    return 'seria $count/$target';
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
    return 'Dojdź do mnożnika $count';
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
    return 'Cofnij czas $count razy';
  }

  @override
  String get ach_mode_blind => 'Na ślepo';

  @override
  String get ach_mode_blind_desc => 'PERFEKT w trybie na ślepo';

  @override
  String get ach_mode_fast => 'Czuję rytm';

  @override
  String get ach_mode_fast_desc =>
      'PERFEKT na ślepo przy mnożniku ×1,5 lub wyższym';

  @override
  String get ach_mode_both => 'Metronom w głowie';

  @override
  String get ach_mode_both_desc => 'PERFEKT na ślepo przy pełnym mnożniku';

  @override
  String get ach_hidden_impatient => 'Niecierpliwy';

  @override
  String get ach_hidden_impatient_desc => '100 razy ZA WCZEŚNIE';

  @override
  String get ach_hidden_nap => 'Drzemka';

  @override
  String get ach_hidden_nap_desc => 'Odłóż telefon, aż stoper sam się zatrzyma';

  @override
  String get ach_hidden_almost => 'Prawie';

  @override
  String get ach_hidden_almost_desc => '4.99, a potem 5.01';

  @override
  String get ach_hidden_punctual => 'Punktualny';

  @override
  String get ach_hidden_punctual_desc => 'PERFEKT o 5:00 albo 17:00';

  @override
  String get ach_hidden_tenth => 'Piątka';

  @override
  String get ach_hidden_tenth_desc => '10 PERFEKTÓW 5. dnia miesiąca';

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
  String ach_exact(String count) {
    return 'Co do setnej $count';
  }

  @override
  String ach_exact_desc(String count) {
    return 'Zatrzymaj stoper równo na 5.00 $count razy';
  }

  @override
  String ach_rounds(String count) {
    return 'Wytrwały $count';
  }

  @override
  String ach_rounds_desc(String count) {
    return 'Zagraj $count rund';
  }

  @override
  String ach_income(String count) {
    return 'Fabryka czasu $count/s';
  }

  @override
  String ach_income_desc(String count) {
    return 'Zegary zarabiają $count Tików na sekundę (bez Szału i Turbo)';
  }

  @override
  String ach_clocks(String count) {
    return 'Zegarmistrz $count';
  }

  @override
  String ach_clocks_desc(String count) {
    return 'Miej łącznie $count zegarów';
  }

  @override
  String ach_skillLevels(String count) {
    return 'Wprawa $count';
  }

  @override
  String ach_skillLevels_desc(String count) {
    return 'Miej łącznie $count poziomów umiejętności';
  }

  @override
  String ach_blindPerfects(String count) {
    return 'Nietoperz $count';
  }

  @override
  String ach_blindPerfects_desc(String count) {
    return '$count PERFEKTÓW na ślepo';
  }

  @override
  String ach_playHours(String count) {
    return 'Stały bywalec $count h';
  }

  @override
  String ach_playHours_desc(String count) {
    return 'Graj łącznie $count h';
  }

  @override
  String ach_achievements(String count) {
    return 'Kolekcjoner $count';
  }

  @override
  String ach_achievements_desc(String count) {
    return 'Zdobądź $count osiągnięć';
  }

  @override
  String ach_daily(String count) {
    return 'Codzienny rytuał $count';
  }

  @override
  String ach_daily_desc(String count) {
    return 'Odbierz dzienną premię $count razy';
  }

  @override
  String ach_shield(String count) {
    return 'Pancerny $count';
  }

  @override
  String ach_shield_desc(String count) {
    return 'Tarcza obroniła mnożnik $count razy';
  }

  @override
  String get ach_feat_goldenFast => 'Refleks';

  @override
  String get ach_feat_goldenFast_desc =>
      'Złap Złotą Sekundę w ciągu sekundy od jej pojawienia się';

  @override
  String get ach_feat_goldenFrenzy => 'Złoto do złota';

  @override
  String get ach_feat_goldenFrenzy_desc => 'Złap Złotą Sekundę w trakcie Szału';

  @override
  String get ach_feat_dailyWeek => 'Pełny tydzień';

  @override
  String get ach_feat_dailyWeek_desc => 'Odbierz 7. dzień dziennej premii';

  @override
  String get ach_feat_offlineFull => 'Sen zimowy';

  @override
  String get ach_feat_offlineFull_desc =>
      'Wróć po przerwie dłuższej niż limit offline';

  @override
  String get ach_feat_bothClocks => 'Obie ręce';

  @override
  String get ach_feat_bothClocks_desc =>
      'PERFEKT na jednym zegarze zaraz po PERFEKCIE na drugim';

  @override
  String get ach_feat_allPerks => 'Władca czasu';

  @override
  String get ach_feat_allPerks_desc => 'Kup wszystkie perki';

  @override
  String get ach_feat_noHands => 'Bez rąk';

  @override
  String get ach_feat_noHands_desc =>
      'Zarób 1M Tików w jednym przejściu, trafiając najwyżej 15 razy';

  @override
  String get ach_hidden_midnight => 'Kopciuszek';

  @override
  String get ach_hidden_midnight_desc => 'PERFEKT o północy';

  @override
  String get ach_hidden_stubborn => 'Uparty';

  @override
  String get ach_hidden_stubborn_desc => '1000 pudeł';

  @override
  String get ach_hidden_atomic => 'Zegar atomowy';

  @override
  String get ach_hidden_atomic_desc =>
      'Połowa z ostatnich 100 trafień w granicach 15 ms';

  @override
  String get perk_headStart => 'Szybki start';

  @override
  String get perk_headStart_desc =>
      'Po każdym paradoksie zaczynasz z 10 Dziadkami i 1K Tików';

  @override
  String get perk_muscleMemory1 => 'Pamięć mięśniowa I';

  @override
  String get perk_muscleMemory1_desc =>
      'Po paradoksie każda umiejętność zachowuje 50% poziomów';

  @override
  String get perk_muscleMemory2 => 'Pamięć mięśniowa II';

  @override
  String get perk_muscleMemory2_desc => '…65% poziomów';

  @override
  String get perk_muscleMemory3 => 'Pamięć mięśniowa III';

  @override
  String get perk_muscleMemory3_desc => '…80% poziomów';

  @override
  String get perk_habit1 => 'Nawyk I';

  @override
  String get perk_habit1_desc =>
      'Wybrana umiejętność zachowuje po paradoksie wszystkie poziomy (wybór w szczegółach umiejętności)';

  @override
  String get perk_habit2 => 'Nawyk II';

  @override
  String get perk_habit2_desc => '…i druga wybrana';

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
  String get perk_shieldRecharge => 'Szybka Tarcza';

  @override
  String get perk_shieldRecharge_desc =>
      'Ładunek Tarczy co 7 trafień zamiast co 10';

  @override
  String get perk_comboFloor => 'Twarde lądowanie';

  @override
  String get perk_comboFloor_desc => 'Pudło zrzuca mnożnik do ×1,25, nie do ×1';

  @override
  String get perk_autoBuyer => 'Automatyczny kupiec';

  @override
  String get perk_autoBuyer_desc =>
      'Przełącznik: kupuje wskazany zegar do najbliższego progu';

  @override
  String get perk_daredevil => 'Śmiałek';

  @override
  String get perk_daredevil_desc => 'Tryb Na ślepo płaci ×4 zamiast ×3';

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
  String get undiscoveredAchievement =>
      'Odkryj kolejne zegary, a zobaczysz to osiągnięcie';

  @override
  String get statsTitle => 'Statystyki';

  @override
  String get statEarnedRun => 'Zarobione od ostatniego paradoksu';

  @override
  String get statEarnedTotal => 'Zarobione łącznie';

  @override
  String get statRounds => 'Rundy';

  @override
  String get statTypical => 'Typowy błąd';

  @override
  String get statTypicalHint => 'połowa twoich dotknięć jest bliżej celu';

  @override
  String get statAccidental => 'Przypadkowe dotknięcia (pominięte)';

  @override
  String get statTiers => 'Trafienia';

  @override
  String get statMeanError => 'Średni błąd';

  @override
  String get statMeanHint => 'ujemny = klikasz za wcześnie';

  @override
  String get statBestStreak => 'Najlepsza seria PERFEKT';

  @override
  String get statBestCombo => 'Najwyższy mnożnik';

  @override
  String get statGolden => 'Złapane Złote Sekundy';

  @override
  String get statPlayTime => 'Czas gry';

  @override
  String get statPrestiges => 'Paradoksy';

  @override
  String get statChronons => 'Chronony';

  @override
  String ms(String value) {
    return '$value ms';
  }

  @override
  String get prestigeTitle => 'Paradoks czasowy';

  @override
  String prestigeChronons(int count, String mult) {
    return 'Chronony: $count · dochód $mult';
  }

  @override
  String prestigeGainMult(String from, String to) {
    return 'Dochód $from → $to';
  }

  @override
  String prestigeShards(int count) {
    return 'Okruchy czasu: $count ✦';
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
  String prestigePendingTitle(int count) {
    return 'Czas cofnięty: +$count ✦';
  }

  @override
  String get prestigePendingBody =>
      'Wydaj teraz Okruchy na perki: Pamięć mięśniowa i Szybki start zadziałają już w nowej grze.';

  @override
  String get prestigeStartRun => 'Zacznij nową grę';

  @override
  String get prestigeConfirm1 =>
      'Stracisz zegary, umiejętności i Tiki. Chronony, Okruchy ✦, perki i osiągnięcia zostają. Zanim ruszy nowa gra, wydasz Okruchy na perki. Dalej?';

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
  String modeBlind(int mult) {
    return 'Na ślepo ×$mult';
  }

  @override
  String get modeNextRound => 'od następnej rundy';

  @override
  String get modeSecond => 'Drugi zegar';

  @override
  String get modeAuto => 'Auto-kupiec';

  @override
  String autoBuying(String owned, String until) {
    return '$owned/$until';
  }

  @override
  String autoDone(String until) {
    return '✓ $until · wybierz';
  }

  @override
  String get autoPick => 'Auto-kupiec: wybierz zegar';

  @override
  String autoSheetHint(String seconds) {
    return 'Kupuje wskazany zegar, jeden co $seconds s, póki starcza Tików, aż do jego najbliższego progu. Potem czeka na Twój wybór.';
  }

  @override
  String autoContinue(String clock, String until) {
    return 'Dalej: $clock → $until';
  }

  @override
  String get autoOff => 'Wyłącz';

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
  String adRescue(String count) {
    return 'Mnożnik $count przepadł! ▶ Przywróć za reklamę';
  }

  @override
  String get adDouble => '▶ ×2 za reklamę';

  @override
  String get adUnavailable => 'Reklama niedostępna';

  @override
  String adCooldown(String time) {
    return 'za $time';
  }

  @override
  String get adFull => 'Pełne';

  @override
  String get tip_golden => 'Złap złoty zegarek — będzie złota runda!';

  @override
  String get tip_combo =>
      'PERFEKT podnosi mnożnik! Równe 5.00 od razu do limitu.';

  @override
  String get tip_prestige =>
      'Możesz cofnąć czas! Zaczniesz od nowa, ale z Chrononami, które na stałe przyspieszają dochód. Za Okruchy ✦ kupisz perki — zostają po każdym resecie. Wir u góry: ty decydujesz kiedy.';

  @override
  String tip_milestone(String need) {
    return 'Pasek pod nazwą: przy $need szt. zegar zarabia ×2!';
  }

  @override
  String milestoneProgress(String owned, String next, String mult) {
    return '$owned/$next → ×$mult';
  }

  @override
  String get milestoneMax => 'Wszystkie bonusy zdobyte';

  @override
  String milestoneToast(String name) {
    return 'Nowy bonus · $name';
  }

  @override
  String milestoneTitle(String generator, String mult) {
    return '$generator ×$mult';
  }

  @override
  String get synergyToast => 'Synergia!';

  @override
  String get tutorialAim =>
      'Dotknij, gdy złoty okrąg dojdzie do zegara — na 5.00!';

  @override
  String tutorialEarned(String cost) {
    return 'To twoje Tiki. Zbierz $cost na pierwszy zegar!';
  }

  @override
  String get tutorialBuy => 'Kup Dziadka — będzie grał za ciebie!';

  @override
  String tutorialInfo(String rate) {
    return 'Dziadek sam dorzuca Tiki: +$rate na sekundę, także gdy nie grasz.';
  }

  @override
  String get tutorialEarnedReplay => 'To twoje Tiki. Wydajesz je na zegary.';

  @override
  String goalBonus(String name, String have, String need, String mult) {
    return 'Cel: $name $have/$need → ×$mult';
  }

  @override
  String goalNewClock(String name) {
    return 'Cel: nowy zegar — $name';
  }

  @override
  String get goalPrestigeDouble => 'Cel: cofnij czas — podwoisz Chronony';

  @override
  String goalPrestigePerk(String name) {
    return 'Cel: cofnij czas — starczy na perk $name';
  }

  @override
  String goalPerk(String name, String have, String need) {
    return 'Cel: perk $name — $have/$need Okruchów';
  }

  @override
  String goalPerkBuy(String name) {
    return 'Cel: kup perk — $name';
  }

  @override
  String get statMultTitle => 'Mnożniki dochodu';

  @override
  String statMultChronons(int count) {
    return 'Chronony ($count)';
  }

  @override
  String statMultAchievements(int count) {
    return 'Osiągnięcia ($count)';
  }

  @override
  String get statMultLevels => 'Mistrzostwo zegarów';

  @override
  String get statMultTurbo => 'Turbo';

  @override
  String get statMultTotal => 'Razem';

  @override
  String get tutorialGotIt => 'OK';

  @override
  String get tutorialAutoStart =>
      'Od teraz stoper startuje sam: po każdym wyniku od razu rusza kolejna runda.';

  @override
  String get tip_springs =>
      'Sprężyny! Nakręcają się same, jedna na dobę. Wydaj je na mistrzostwo zegarów — zostaje na zawsze.';

  @override
  String get tip_loop =>
      'Nowa pętla: wszystko od zera, ale Sprężyny i mistrzostwo zostają.';

  @override
  String tip_loopRule(String rule) {
    return 'Nowa pętla: wszystko od zera, ale Sprężyny i mistrzostwo zostają. Zasada Chronosa: $rule.';
  }

  @override
  String get tip_skills => 'Umiejętności wzmacniają twoje trafienia.';

  @override
  String get tip_modes => 'Nowy tryb! Dotknij, żeby włączyć.';

  @override
  String skillBuyLevel(String level) {
    return 'Kup poz. $level';
  }

  @override
  String generatorEarnsEach(String value) {
    return '+$value/s za sztukę';
  }

  @override
  String get helpTitle => 'Jak grać';

  @override
  String get helpReplay => 'Pokaż samouczek od nowa';

  @override
  String get help_goal_t => 'Cel gry';

  @override
  String get help_goal =>
      'Dziadek wiecznie spóźnia się na podwieczorek u Babci i chce zdobyć zegar, który się nie myli: Chronosa, boga czasu — ostatni i najdroższy zegar w grze. Zdobądź go, a historia potoczy się dalej.\nDroga do niego: trafiaj w 5.00, zbieraj Tiki, kupuj za nie zegary, które zarabiają za ciebie.';

  @override
  String get help_tiki_t => 'Tiki';

  @override
  String get help_tiki =>
      'Tiki to waluta gry. Na górze ekranu:\n• duża liczba — ile masz Tików\n• pod nią — ile przybywa na sekundę\n• „5.00 = +…” — ile da trafienie równo 5.00\nTiki wydajesz w sklepie na dole: na zegary i umiejętności.';

  @override
  String get help_clocks_t => 'Zegary';

  @override
  String get help_clocks =>
      'Zegary grają rundy za ciebie (ich wyniki pokazują dymki obok tarczy) i co sekundę dają Tiki — także gdy gra jest zamknięta, do limitu czasu.\n• Kupienie zegara odkrywa następny: droższy i mocniejszy.\n• Liczba na ikonie — ile ich masz.\n• Każda kolejna sztuka tego samego zegara kosztuje trochę więcej.\n• ×1, ×10, ×100, MAX — ile sztuk kupujesz naraz.';

  @override
  String get help_upgrades_t => 'Bonusy zegarów';

  @override
  String get help_upgrades =>
      'Pasek pod zegarem pokazuje, ile sztuk brakuje do progu, np. „20/40 → ×2”. Po osiągnięciu progu wszystkie zegary tego rodzaju zarabiają tyle razy więcej, na stałe.\n• Pierwsze zegary: progi 10, 20, 40… i mnożnik ×2.\n• Droższe zegary: niższe progi, mniejszy mnożnik.\nSynergia: po 25 sztuk dwóch pasujących zegarów (np. Dziadka i Babci) wzmacnia oba.';

  @override
  String get help_skills_t => 'Umiejętności';

  @override
  String get help_skills =>
      'Umiejętności wzmacniają twoje własne trafienia — nie zegary. Dają m.in. wyższą nagrodę, szersze okna ocen i wyższy mnożnik.\n• Każda ma poziomy, np. „Poziom 2/10”; kolejny poziom kosztuje więcej Tików.\n• Nowa karta pojawia się, gdy zbliżasz się do jej ceny.\n• Dotknij karty, by zobaczyć dokładny efekt.';

  @override
  String get help_combo_t => 'Mnożnik (combo)';

  @override
  String get help_combo =>
      'Mnożnik przy napisie COMBO mnoży wszystkie twoje wypłaty. PERFEKT podnosi go o 0,05, równe 5.00 od razu do limitu (limit podnosi umiejętność Combo). ŚWIETNIE i DOBRZE go nie ruszają.\nBLISKO albo pudło zeruje mnożnik. Wyjątek: ładunek Tarczy (umiejętność) pochłania jedno pudło; ładunki wracają co 10 trafień, licząc od zera od chwili zużycia.\nSeria — trafienia z rzędu — liczy się tylko przy wyzwaniu „seria”: od zera i do pierwszego pudła, także takiego, które Tarcza obroniła.';

  @override
  String get help_golden_t => 'Złota Sekunda';

  @override
  String get help_golden =>
      'Średnio co 10 minut przez ekran przelatuje złoty zegarek. Dotknięty zamienia następną rundę w złotą.\nTrafienie w złotej rundzie daje losową nagrodę:\n• Szał (45%) — cały dochód ×7 przez 77 s\n• Fart (45%) — od razu Tiki za 10 minut pracy zegarów\n• Gorąca ręka (10%) — przez 60 s każde trafienie liczy się jak PERFEKT i płaci ×10\nSiła nagrody zależy od oceny: PERFEKT 100%, ŚWIETNIE 60%, DOBRZE 30%, pudło nic.';

  @override
  String get help_modes_t => 'Przełączniki';

  @override
  String get help_modes =>
      'Przełączniki nad sklepem zmieniają zasady rundy. Każdy pojawia się dopiero po odblokowaniu:\n• Na ślepo — od 4.00 cyfry i pasek znikają; trafienia płacą ×3 (z perkiem Śmiałek ×4)\n• Drugi zegar — dwa stopery naraz; lewa i prawa połowa ekranu to osobne zegary\n• Auto-kupiec — kupuje wskazany zegar do najbliższego progu, potem robi się pomarańczowy i czeka na kolejny wybór';

  @override
  String get help_season_t => 'Wydarzenia';

  @override
  String get help_season =>
      'W czasie świąt złoty zegarek zmienia wygląd. Znaczek u góry liczy dwa cele: złapane świąteczne zegarki (np. 0/5) i trafienia (np. 0/50). Za oba dostajesz nagrodę, a świąteczny motyw zostaje na stałe.';

  @override
  String get help_prestige_t => 'Paradoks czasowy';

  @override
  String get help_prestige =>
      'Gdy zarobisz dość Tików, wir u góry się zaświeci. Cofnięcie czasu zeruje Tiki, zegary i umiejętności. W zamian dostajesz:\n• Chronony — stały mnożnik całego dochodu; ich liczba rośnie z Tikami zarobionymi w tej pętli\n• Okruchy czasu — tyle samo, co Chrononów; płacisz nimi za perki\nPerki kupujesz zaraz po cofnięciu czasu albo później na ekranie paradoksu. Chronony, Okruchy, perki i osiągnięcia zostają.';

  @override
  String get help_icons_t => 'Ikony u góry';

  @override
  String get help_icons =>
      '• Puchar — osiągnięcia (każde: +1% dochodu)\n• Wykres — statystyki\n• Tarcza — wygląd stopera\n• Znak zapytania — ta pomoc\n• Zębatka — ustawienia\n• Wir — paradoks czasowy\n• Spirala — Sprężyny';

  @override
  String notificationTitle(String amount) {
    return 'Twoje zegary uzbierały $amount Tików!';
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
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsAnalytics => 'Wysyłaj statystyki gry';

  @override
  String get settingsAnalyticsHint =>
      'Statystyki rozgrywki i raporty o awariach pomagają nam dopracować grę. Bez konta, imienia i identyfikatora reklamowego.';

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
  String get settingsReduceMotion => 'Tryb spokojny';

  @override
  String get settingsReduceMotionHint =>
      'Mniej ruchu i migania, spokojniejszy Szał';

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
  String get settingsImportBad => 'To nie wygląda na zapis Hit5.';

  @override
  String get settingsReset => 'Zacznij od nowa';

  @override
  String get settingsResetConfirm1 =>
      'Na pewno? Stracisz wszystko: Tiki, zegary, Chronony, Okruchy, perki i osiągnięcia. Ustawienia zostaną.';

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
      'Grafika: własna, wygenerowana modelem Qwen-Image (Apache 2.0).\nCzcionki: Paytone One i Nunito (SIL Open Font License 1.1).\nDźwięki i muzyka: własne, syntezowane w kodzie.';

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
  String get upg_grandpa_4_desc => 'Rozwiązana w równe 5,00 s.';

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
  String get upg_grandma_5 => 'Książka „Dania w 5 sekund”';

  @override
  String get upg_grandma_5_desc => 'Same szybkie przepisy.';

  @override
  String get upg_grandma_6 => 'Kuchenka indukcyjna';

  @override
  String get upg_grandma_6_desc => 'Woda wrze, zanim pomyślisz.';

  @override
  String get upg_grandma_7 => 'Wnuczka influencerka';

  @override
  String get upg_grandma_7_desc => 'Nagrywa każde idealne 5,00.';

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
  String get upg_watchmaker_3_desc => 'Uczy się na twoich Tikach.';

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
      '„Pociąg o 5,00 przyjedzie punktualnie.”';

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
  String get upg_timeMachine_4_desc => 'Ćwiczy te same 5 sekund w kółko.';

  @override
  String get upg_timeMachine_5 => 'Zapasowa linia czasu';

  @override
  String get upg_timeMachine_5_desc => 'Tak na wszelki wypadek.';

  @override
  String get upg_timeMachine_6 => 'Wycieczki do 5,00';

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
  String get upg_schrodinger_7_desc => 'W którymś zawsze jest 5,00.';

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
  String get upg_chronos_8_desc => '5,00. Od zawsze i na zawsze.';

  @override
  String get settingsPrivacyPolicy => 'Polityka prywatności';

  @override
  String get settingsAdPrivacy => 'Prywatność reklam';

  @override
  String get dailyTitle => 'Dzienna premia';

  @override
  String dailyDay(int day, int total) {
    return 'Dzień $day z $total';
  }

  @override
  String dailyHint(int total) {
    return 'Wracaj codziennie — przez $total dni premia rośnie. Jeden dzień przerwy w tygodniu seria wybacza.';
  }

  @override
  String get adOfferHow =>
      'Krótka reklama wideo. Nagroda po obejrzeniu do końca.';

  @override
  String get adWatch => '▶ Obejrzyj';

  @override
  String get adNotNow => 'Nie teraz';

  @override
  String get adOfferTurboTitle => 'Turbo';

  @override
  String adOfferTurboReward(int mult, int minutes) {
    return '×$mult Tików przez $minutes min';
  }

  @override
  String adOfferTurboDetail(int hours) {
    return 'Wszystkie zarobki — zegary i twoje trafienia — są podwojone. Czas Turbo płynie tylko, gdy grasz; zapas do $hours h.';
  }

  @override
  String adOfferTurboStock(String time) {
    return 'Masz jeszcze $time — reklama doda kolejne 30 min.';
  }

  @override
  String get adOfferGoldenTitle => 'Złota Sekunda';

  @override
  String get adOfferGoldenReward => 'Złoty zegarek od razu';

  @override
  String get adOfferGoldenDetail =>
      'Po reklamie przyleci złoty zegarek. Złap go, a następna runda da losową premię: Szał, Fart albo Gorącą rękę.';

  @override
  String get adOfferBagTitle => 'Worek Tików';

  @override
  String adOfferBagDetail(int minutes) {
    return 'Od razu tyle, ile twoje zegary zarabiają w $minutes min.';
  }

  @override
  String get adNoReward =>
      'Reklama nie została obejrzana do końca — bez nagrody. Możesz spróbować ponownie.';

  @override
  String adDoneTurbo(String time) {
    return 'Turbo włączone! ×2 jeszcze przez $time.';
  }

  @override
  String get adDoneGolden => 'Złoty zegarek leci — złap go!';

  @override
  String get adDoneBag => 'Worek Tików odebrany!';

  @override
  String get adDoneRescue => 'Mnożnik przywrócony!';

  @override
  String get adDoneOffline => 'Dochód offline podwojony!';

  @override
  String get season_valentine => 'Walentynki';

  @override
  String get season_valentine_items => 'Serca';

  @override
  String get season_easter => 'Wielkanoc';

  @override
  String get season_easter_items => 'Pisklęta';

  @override
  String get season_summer => 'Lato';

  @override
  String get season_summer_items => 'Słońca';

  @override
  String get season_halloween => 'Halloween';

  @override
  String get season_halloween_items => 'Dynie';

  @override
  String get season_christmas => 'Boże Narodzenie';

  @override
  String get season_christmas_items => 'Prezenty';

  @override
  String get season_newYear => 'Sylwester';

  @override
  String get season_newYear_items => 'Konfetti';

  @override
  String seasonUntil(String date) {
    return 'Wydarzenie do $date';
  }

  @override
  String get seasonHow =>
      'Złoty zegarek przybiera świąteczną postać. Łap go i trafiaj (DOBRZE lub lepiej), a zdobędziesz nagrodę.';

  @override
  String get seasonHits => 'Trafienia';

  @override
  String seasonReward(String amount, String name) {
    return 'Nagroda: +$amount Tików, motyw „$name” na zawsze i osiągnięcie (+1%).';
  }

  @override
  String seasonDone(String name) {
    return 'Ukończone! Motyw „$name” możesz wybrać w Ustawieniach.';
  }

  @override
  String seasonCompleted(String name, String amount) {
    return '$name ukończone! +$amount Tików';
  }

  @override
  String get seasonStart => 'Zaczynamy!';

  @override
  String ach_season(String name) {
    return '$name';
  }

  @override
  String ach_season_desc(String name) {
    return 'Ukończ wydarzenie „$name”';
  }

  @override
  String get themeTitle => 'Motyw';

  @override
  String get themeAuto => 'Sezonowy';

  @override
  String get themeClassic => 'Klasyczny';

  @override
  String get themeHint =>
      '„Sezonowy” zmienia się sam z wydarzeniami. Motywy z ukończonych wydarzeń zostają na zawsze.';

  @override
  String get diagSeason => 'Podgląd wydarzenia';

  @override
  String get diagSeasonNone => 'Według daty';

  @override
  String perfectNow(String amount) {
    return 'PERFEKT teraz: +$amount';
  }

  @override
  String perfectNowSeconds(String amount, String seconds) {
    return 'PERFEKT teraz: +$amount (≈ $seconds s dochodu zegarów)';
  }

  @override
  String jackpotPrice(String target, String amount) {
    return '$target = +$amount';
  }

  @override
  String generatorTotal(String perSecond) {
    return 'razem $perSecond';
  }

  @override
  String get generatorBonuses => 'Bonusy';

  @override
  String generatorBonusLine(String count, String name, String mult) {
    return '$count szt. · $name · ×$mult';
  }

  @override
  String get generatorSynergies => 'Synergie';

  @override
  String generatorSynergyOn(String name) {
    return '$name ✓ aktywna';
  }

  @override
  String generatorSynergyEffect(String pct, String other) {
    return '+$pct% za każdą sztukę: $other';
  }

  @override
  String generatorSynergyNeeds(
    String need,
    String a,
    String aOwned,
    String b,
    String bOwned,
  ) {
    return 'Włącza się przy $need szt. obu: $a $aOwned/$need, $b $bOwned/$need';
  }

  @override
  String get season_fiveDay => 'Dzień Piątki';

  @override
  String get season_fiveDay_items => 'Piątki';

  @override
  String get skill_power_info =>
      'Trafienie daje stałą liczbę Tików: PERFEKT 6, ŚWIETNIE 3, DOBRZE 1. Każdy poziom dodaje 150% tej wartości (PERFEKT: 6 → 15 → 24…).';

  @override
  String get skill_fastForward_info =>
      'Każdy poziom przesuwa start stopera o ok. 0,13 s, do 2,00 s na maksymalnym poziomie. Stoper płynie w normalnym tempie, a cel wciąż wynosi 5.00.';

  @override
  String get skill_ticking_info =>
      'Od 4.00 do 5.00 słychać tyknięcie co 0,1 s (z wibracją, jeśli jest włączona).';

  @override
  String get skill_wideEye_info =>
      'Okna ŚWIETNIE (±30 ms) i DOBRZE (±50 ms) rosną o ok. 5% na poziom, do ×1,8 na maksymalnym poziomie (±54 i ±90 ms). Działa też na zegary.';

  @override
  String get skill_combo_info =>
      'PERFEKT podnosi mnożnik o 0,05, a równe 5.00 od razu do limitu. ŚWIETNIE i DOBRZE go nie ruszają, pudło zeruje. Bez ulepszeń limit to ×1,25; każdy poziom podnosi go o 0,10. Mnoży całą wypłatę za trafienie, także 5.00 i Echo.';

  @override
  String get skill_magnet_info =>
      'Okno PERFEKT (±15 ms) rośnie o ok. 0,7 ms na poziom, do ±25 ms. Okno 5.00 (±10 ms) się nie zmienia. Działa też na zegary.';

  @override
  String get skill_echo_info =>
      'Trafienie dodaje tyle Tików, ile twoje zegary zarabiają w danym czasie. Na poziom: PERFEKT 0,2 s, ŚWIETNIE ok. 0,11 s, DOBRZE ok. 0,03 s.';

  @override
  String get skill_bulletTime_info =>
      'Okna PERFEKT, ŚWIETNIE, DOBRZE i BLISKO rosną do ×2,5 na maksymalnym poziomie (np. DOBRZE: ±50 → ±125 ms). Okno 5.00 się nie zmienia. Tuż przy celu ekran pulsuje i słychać bicie serca. Nie działa na zegary.';

  @override
  String get skill_luck_info =>
      'Na każdym poziomie 2 trafienia na 100 podskakują o próg: ŚWIETNIE → PERFEKT, DOBRZE → ŚWIETNIE. PERFEKT nie zmienia się w 5.00.';

  @override
  String get skill_shield_info =>
      'Każdy poziom to jeden ładunek. Pudło zużywa ładunek, a mnożnik zostaje. Zużyte ładunki wracają po jednym co 10 trafień; po zużyciu ładunku odliczanie zaczyna się od nowa.';

  @override
  String get skill_goldenTouch_info =>
      'Złota Sekunda pojawia się średnio co 10 minut. Każdy poziom skraca ten czas o 30 s i wzmacnia jej efekty (Szał, Fart, Gorąca ręka) o 5%.';

  @override
  String get master_grandpa_5 => 'Emerytowany zegarmistrz';

  @override
  String get master_grandpa_5_desc =>
      'Naprawia zegarki sąsiadom. Za darmo, ale z wykładem.';

  @override
  String get master_grandpa_10 => 'Dziadek wie lepiej';

  @override
  String get master_grandpa_10_desc => 'I ma rację. Niestety.';

  @override
  String get master_grandma_5 => 'Jajko idealne';

  @override
  String get master_grandma_5_desc => 'Ani sekundy za długo. Ani jednej.';

  @override
  String get master_grandma_10 => 'Babcia w trybie turbo';

  @override
  String get master_grandma_10_desc => 'Minutnik się jej boi.';

  @override
  String get master_cuckoo_5 => 'Kukułka z dyplomem';

  @override
  String get master_cuckoo_5_desc =>
      'Kuka równo. Wymaga, żeby mówić „pani magister”.';

  @override
  String get master_cuckoo_10 => 'Kukułka-celebrytka';

  @override
  String get master_cuckoo_10_desc => 'Wychodzi z domku tylko na wywiady.';

  @override
  String get master_metronome_5 => 'Wirtuoz tyknięcia';

  @override
  String get master_metronome_5_desc => 'Tik. Tak. Brawa.';

  @override
  String get master_metronome_10 => 'Metronom filharmonii';

  @override
  String get master_metronome_10_desc => 'Dyryguje dyrygentem.';

  @override
  String get master_watchmaker_5 => 'Złota lupa';

  @override
  String get master_watchmaker_5_desc => 'Widzi atomy. I kurz na nich.';

  @override
  String get master_watchmaker_10 => 'Mistrz cechu';

  @override
  String get master_watchmaker_10_desc =>
      'Nawet zegar słoneczny przychodzi do niego po radę.';

  @override
  String get master_sprintJudge_5 => 'Oko sokoła';

  @override
  String get master_sprintJudge_5_desc =>
      'Widzi falstart, zanim zawodnik o nim pomyśli.';

  @override
  String get master_sprintJudge_10 => 'Sędzia olimpijski';

  @override
  String get master_sprintJudge_10_desc =>
      'Gwizdek ma pozłacany. Cierpliwość nie.';

  @override
  String get master_stationClock_5 => 'Pociąg o czasie';

  @override
  String get master_stationClock_5_desc =>
      'Pasażerowie nie wierzą. Robią zdjęcia.';

  @override
  String get master_stationClock_10 => 'Dworzec bez opóźnień';

  @override
  String get master_stationClock_10_desc =>
      'Komunikat „może ulec zmianie” trafił do muzeum.';

  @override
  String get master_quartz_5 => 'Kryształ bez skazy';

  @override
  String get master_quartz_5_desc =>
      'Drga dokładnie 32 768 razy. Sprawdzaliśmy.';

  @override
  String get master_quartz_10 => 'Kwarc królewski';

  @override
  String get master_quartz_10_desc => 'Na dworze nosi się go zamiast korony.';

  @override
  String get master_atomic_5 => 'Atom spokoju';

  @override
  String get master_atomic_5_desc => 'Elektrony chodzą na palcach.';

  @override
  String get master_atomic_10 => 'Wzorzec sekundy';

  @override
  String get master_atomic_10_desc => 'Sekunda trwa tyle, ile on mówi.';

  @override
  String get master_gps_5 => 'Satelita bez zgubień';

  @override
  String get master_gps_5_desc => 'Nigdy nie mówi „zawróć, gdy to możliwe”.';

  @override
  String get master_gps_10 => 'Pan orbity';

  @override
  String get master_gps_10_desc => 'Inne satelity ustawiają się według niego.';

  @override
  String get master_pulsar_5 => 'Pulsar z rytmem';

  @override
  String get master_pulsar_5_desc => 'Wszechświat tupie nogą do taktu.';

  @override
  String get master_pulsar_10 => 'Latarnia galaktyki';

  @override
  String get master_pulsar_10_desc =>
      'Statki obcych synchronizują po nim zegarki.';

  @override
  String get master_timeMachine_5 => 'Bilet powrotny';

  @override
  String get master_timeMachine_5_desc =>
      'Wraca, zanim wyjedzie. Bez spóźnień.';

  @override
  String get master_timeMachine_10 => 'Pętla doskonała';

  @override
  String get master_timeMachine_10_desc =>
      'Spotkała samą siebie. Obie trafiły w 5.00.';

  @override
  String get master_schrodinger_5 => 'Kot obserwowany';

  @override
  String get master_schrodinger_5_desc =>
      'Trafia, gdy patrzysz. Gdy nie patrzysz, też.';

  @override
  String get master_schrodinger_10 => 'Kot w obu pudełkach';

  @override
  String get master_schrodinger_10_desc =>
      'Śpi i trafia jednocześnie. Mruczy w superpozycji.';

  @override
  String get master_chronos_5 => 'Chronos na urlopie';

  @override
  String get master_chronos_5_desc => 'Czas płynie sam, a i tak równo.';

  @override
  String get master_chronos_10 => 'Pan wszystkich sekund';

  @override
  String get master_chronos_10_desc =>
      'Nawet ta sekunda przed chwilą była jego.';

  @override
  String get dial_classic => 'Klasyczna';

  @override
  String get dial_classic_desc => 'Biała, czysta, niezawodna.';

  @override
  String get dial_wood => 'Drewniak';

  @override
  String get dial_wood_desc => 'Pachnie warsztatem dziadka.';

  @override
  String get dial_porcelain => 'Porcelana babci';

  @override
  String get dial_porcelain_desc => 'Z serwisu na specjalne okazje. Nie upuść.';

  @override
  String get dial_brass => 'Mosiądz';

  @override
  String get dial_brass_desc => 'Błyszczy jak klamka w ratuszu.';

  @override
  String get dial_station => 'Dworcowa';

  @override
  String get dial_station_desc => 'Duża, żeby było widać opóźnienie z daleka.';

  @override
  String get dial_swiss => 'Szwajcarka';

  @override
  String get dial_swiss_desc => 'Czerwona, precyzyjna i trochę zadufana.';

  @override
  String get dial_quartz => 'Kwarcówka';

  @override
  String get dial_quartz_desc => 'Zielone cyfry, jak w budziku z lat 80.';

  @override
  String get dial_atomic => 'Atomowa';

  @override
  String get dial_atomic_desc =>
      'Świeci lekko na niebiesko. Podobno to normalne.';

  @override
  String get dial_neon => 'Neonówka';

  @override
  String get dial_neon_desc => 'Do grania po północy.';

  @override
  String get dial_cosmic => 'Kosmiczna';

  @override
  String get dial_cosmic_desc => 'Gwiazdy w tle, sekundy na pierwszym planie.';

  @override
  String get dial_golden => 'Złota';

  @override
  String get dial_golden_desc => 'Lita. No, prawie lita.';

  @override
  String get dial_rift => 'Pęknięta czasoprzestrzeń';

  @override
  String get dial_rift_desc => 'Przez szczelinę widać wczorajsze 5.00.';

  @override
  String springWound(String minutes) {
    return 'Sprężyna +$minutes min';
  }

  @override
  String get springsTitle => 'Sprężyny';

  @override
  String springsBadgeHits(String count, int hits) {
    String _temp0 = intl.Intl.pluralLogic(
      hits,
      locale: localeName,
      other: 'Zapas na $hits trafień',
      few: 'Zapas na $hits trafienia',
      one: 'Zapas na 1 trafienie',
      zero: 'Trafienia nic nie dokręcą, aż wróci zapas',
    );
    return 'Sprężyny: $count. $_temp0';
  }

  @override
  String springsBadgeFull(String count) {
    return 'Sprężyny: $count. Pełny magazyn: trafienia nic nie dokręcają i nie zużywają zapasu';
  }

  @override
  String get springsBadgeMax => 'MAX';

  @override
  String springsIntro(String mult) {
    return 'Sprężyna nakręca się sama: jedna na dobę, także gdy nie grasz. Każde „równo 5.00” dokręca ją szybciej. Za Sprężyny kupujesz mistrzostwo zegarów: każdy stopień mnoży dochód tego zegara $mult, na zawsze — nic go nie cofa.';
  }

  @override
  String springsNext(String time) {
    return 'Następna za $time';
  }

  @override
  String springsFull(String max) {
    return 'Pełny magazyn ($max). Trafienia nie zużywają teraz zapasu. Wydaj Sprężyny, żeby nakręcać dalej.';
  }

  @override
  String get springsReserveTitle => 'Zapas dokręcania';

  @override
  String springsReserve(String left, String max) {
    return '$left z $max';
  }

  @override
  String springsReserveHow(String time, String refill) {
    return 'Każde „równo 5.00” dokręca $time z zapasu. Zapas wraca sam w $refill.';
  }

  @override
  String springsReserveEmpty(String time) {
    return 'Zapas pusty: trafienia teraz nic nie dokręcają. Pełny za $time.';
  }

  @override
  String get springEmpty => 'Zapas dokręcania pusty';

  @override
  String get adSpring => '▶ Napełnij za reklamę';

  @override
  String adSpringLeft(int left, int max) {
    return 'Reklamy na dziś: $left z $max';
  }

  @override
  String get adDoneSpring => 'Zapas pełny — traf 5.00!';

  @override
  String get springsNoClocks =>
      'Kup zegar, żeby móc podnieść jego mistrzostwo.';

  @override
  String get clockLevelTitle => 'Mistrzostwo zegara';

  @override
  String clockLevelLine(String level, String max, String mult) {
    return 'Stopień $level/$max · $mult';
  }

  @override
  String clockLevelUp(String cost) {
    return 'Podnieś · $cost';
  }

  @override
  String get clockLevelMax => 'Pełne mistrzostwo';

  @override
  String clockLevelTitleAt(String level, String title) {
    return 'Stopień $level: $title';
  }

  @override
  String get clockLevelLocked =>
      'Sprężyny pojawią się po pierwszym paradoksie.';

  @override
  String ach_mastery_desc(String generator, String level) {
    return '$generator: $level. stopień mistrzostwa';
  }

  @override
  String get dialTitle => 'Tarcza zegara';

  @override
  String get dialHint =>
      'Pierwsze tarcze odblokowujesz, zarabiając Tiki. Ostatnie sześć to trofea: po jednej za każdą ukończoną pętlę czasu.';

  @override
  String dialLocked(String amount) {
    return 'Zarób $amount';
  }

  @override
  String get dialToast => 'Nowa tarcza zegara';

  @override
  String dialProgress(String have, String need) {
    return 'Zarobione łącznie: $have z $need';
  }

  @override
  String get updateReady => 'Nowa wersja jest gotowa';

  @override
  String get updateRestart => 'Uruchom ponownie';

  @override
  String get updateInstall => 'Zainstaluj nową wersję';

  @override
  String get updateInstallHint =>
      'Gra uruchomi się ponownie, postęp zostaje. Jeśli nie klikniesz, wersja zainstaluje się sama, gdy wyjdziesz z gry.';

  @override
  String get help_springs_t => 'Sprężyny i mistrzostwo zegarów';

  @override
  String get help_springs =>
      'Sprężyny działają od pierwszego cofnięcia czasu (spirala u góry).\n• Nakręcają się same: jedna na dobę, także gdy nie grasz. Mieści się najwyżej 10.\n• Trafienie równo 5.00 dokręca 15 minut z zapasu. Zapas mieści 2 godziny i odnawia się w 4 godziny.\n• Pierwsze równo 5.00 po godzinie przerwy dokręca całą godzinę.\nSprężynami płacisz za mistrzostwo zegara: stopień 1 kosztuje 1 Sprężynę, stopień 2 — 2 i tak do stopnia 5. Każdy stopień mnoży dochód tego zegara ×1,5 na zawsze — także po cofnięciu czasu i w nowej pętli. Stopnie 3 i 5 dają tytuł mistrza.';

  @override
  String get help_dials_t => 'Tarcze zegara';

  @override
  String get help_dials =>
      'Tarcze zmieniają tylko wygląd stopera, nie wyniki. Kolejne odblokowujesz, zarabiając coraz więcej Tików; sześć ostatnich to trofea za ukończone pętle czasu. Wybierasz je przyciskiem z tarczą u góry ekranu.';

  @override
  String springsRefund(int count) {
    return 'Poziomy zegarów to teraz 5 stopni mistrzostwa, każdy wart więcej. Wydane Sprężyny ($count) wróciły do ciebie — wydaj je od nowa.';
  }

  @override
  String get dialLockedSeal => 'Trofeum pętli';

  @override
  String loopNumber(int n) {
    return 'Pętla $n';
  }

  @override
  String get loopTitle => 'Pętla czasu';

  @override
  String get loopGoal => 'Cel pętli: zdobądź Chronosa';

  @override
  String get loopGoalDone => 'Cel osiągnięty: Chronos jest twój';

  @override
  String get loopNoRule => 'Bez zmienionej zasady';

  @override
  String get loopRuleLabel => 'Zasada Chronosa';

  @override
  String get loopEndTitle => 'Czas pokonany!';

  @override
  String loopEndStats(String time, int count) {
    return 'Czas gry: $time · Paradoksy: $count';
  }

  @override
  String get loopRewardChapter => 'Nowy rozdział Kroniki';

  @override
  String get loopRewardSeal => 'Zdobyta pieczęć — działa na zawsze';

  @override
  String loopRewardDial(String name) {
    return 'Tarcza zegara: $name';
  }

  @override
  String get loopNextTitle => 'Następna pętla';

  @override
  String get loopNextSeal => 'Pieczęć za jej ukończenie: ???';

  @override
  String get loopNextFree =>
      'Historia opowiedziana. Od teraz zasady każdej pętli wybierasz sam — w Kronice.';

  @override
  String get loopStay => 'Zostaję jeszcze';

  @override
  String loopStayHint(int left) {
    return 'Każdy bonus Chronosa w tej pętli daje +1 Sprężynę (zostało $left).';
  }

  @override
  String get loopStart => 'Nowa pętla';

  @override
  String get loopConfirmTitle => 'Zacząć nową pętlę?';

  @override
  String get loopConfirmResets =>
      'Wraca do zera: Tiki, zegary, umiejętności, Chronony, Okruchy i perki.';

  @override
  String get loopConfirmKeeps =>
      'Zostaje: Sprężyny, mistrzostwo zegarów, pieczęcie, osiągnięcia, tarcze i statystyki.';

  @override
  String get loopConfirmYes => 'Zaczynam od zera';

  @override
  String get loopConfirmNo => 'Jeszcze nie';

  @override
  String get loopBonusToast => 'Bonus Chronosa';

  @override
  String loopBonusToastBody(int count) {
    return 'Sprężyny: +$count na kolejne pętle';
  }

  @override
  String get chronicleTitle => 'Kronika';

  @override
  String get chronicleOpen => 'Otwórz Kronikę';

  @override
  String get chronicleChapters => 'Rozdziały';

  @override
  String get chronicleSeals => 'Pieczęcie';

  @override
  String chronicleChapter(int n) {
    return 'Rozdział $n';
  }

  @override
  String chronicleChapterLocked(int n) {
    return 'Ukończ pętlę $n';
  }

  @override
  String get chronicleSealLocked =>
      'Ukończ pętlę z tą zasadą, żeby zdobyć pieczęć';

  @override
  String chronicleBest(String time) {
    return 'Rekord: $time gry';
  }

  @override
  String get chroniclePick => 'Zasady następnej pętli';

  @override
  String get chroniclePickHint => 'Wybierz dowolne, kilka naraz albo żadną.';

  @override
  String chronicleLoopTime(String time, int count) {
    return 'W tej pętli: $time gry, paradoksy: $count';
  }

  @override
  String goalLoopBonus(String name, String have, String need) {
    return 'Cel: $name $have/$need → +1 Sprężyna';
  }

  @override
  String get adBlockedRule => 'zasada pętli';

  @override
  String get statLoop => 'Pętla czasu';

  @override
  String get help_loop_t => 'Pętla czasu i Kronika';

  @override
  String get help_loop =>
      'Kupienie Chronosa kończy pętlę czasu: odblokowuje rozdział historii i pozwala zacząć nową pętlę.\n• Nowa pętla zeruje wszystko, także Chronony i perki.\n• Zostają Sprężyny, mistrzostwo zegarów, osiągnięcia i tarcze.\n• W każdej pętli Chronos zmienia jedną zasadę. Ukończenie takiej pętli daje pieczęć: mały stały bonus i tarczę zegara.\n• Każdy bonus Chronosa zdobyty przed wyjściem z pętli daje +1 Sprężynę.\nSiedem pętli to cała historia; potem zasady wybierasz sam. Wszystko zapisuje Kronika na ekranie paradoksu.';

  @override
  String get rule_blindfold => 'Zepsuty stoper';

  @override
  String get rule_blindfold_desc =>
      'Na ślepo jest zawsze włączone: cyfry znikają na ostatnią sekundę. Płaci jak zwykle.';

  @override
  String get rule_blindfold_quote =>
      '„Chcesz być punktualny? Naucz się czuć czas. Bez cyferek.”';

  @override
  String get seal_blindfold => 'Wyczucie';

  @override
  String get seal_blindfold_desc =>
      'Na ślepo płaci o 1 więcej (×4, ze Śmiałkiem ×5).';

  @override
  String get rule_inflation => 'Drożyzna';

  @override
  String get rule_inflation_desc =>
      'Każdy kupiony zegar podnosi cenę następnego o 20% zamiast o 15%.';

  @override
  String get rule_inflation_quote =>
      '„Czas kosztuje. Od dziś każda sekunda drożej.”';

  @override
  String get seal_inflation => 'Stały klient';

  @override
  String get seal_inflation_desc =>
      'Pierwsze 10 sztuk każdego zegara za pół ceny.';

  @override
  String get rule_noGold => 'Pochmurny dzień';

  @override
  String get rule_noGold_desc =>
      'Złota Sekunda nie przylatuje (wydarzenia sezonowe działają dalej).';

  @override
  String get rule_noGold_quote =>
      '„Słońce zostaje za chmurą. Na herbatę się nie trafia. Na herbatę się przychodzi.”';

  @override
  String get seal_noGold => 'Promyk';

  @override
  String get seal_noGold_desc =>
      'Po powrocie po co najmniej godzinie Złota Sekunda przylatuje w 30 sekund.';

  @override
  String get rule_shortFuse => 'Krótki lont';

  @override
  String get rule_shortFuse_desc =>
      'Mnożnik może urosnąć o 0,50 wyżej niż zwykle, ale zeruje go wszystko poza PERFEKTEM. Nie ma Tarczy.';

  @override
  String get rule_shortFuse_quote =>
      '„Jedno krzywe trafienie i od zera. Tak jest z randkami.”';

  @override
  String get seal_shortFuse => 'Długi lont';

  @override
  String get seal_shortFuse_desc => 'Mnożnik może urosnąć o 0,20 wyżej.';

  @override
  String get rule_precision => 'Szwajcarska precyzja';

  @override
  String get rule_precision_desc =>
      'DOBRZE nic ci nie płaci. Liczy się tylko ŚWIETNIE i PERFEKT.';

  @override
  String get rule_precision_quote => '„Byle jakie trafienie się nie liczy.”';

  @override
  String get seal_precision => 'Pewna ręka';

  @override
  String get seal_precision_desc => 'Okno PERFEKT szersze o 0,001 s.';

  @override
  String get rule_insomnia => 'Bezsenność';

  @override
  String get rule_insomnia_desc =>
      'Pod twoją nieobecność zegary zarabiają tylko 25%.';

  @override
  String get rule_insomnia_quote => '„Kto śpi, ten się spóźnia. Zegary też.”';

  @override
  String get seal_insomnia => 'Dobry sen';

  @override
  String get seal_insomnia_desc =>
      'Dochód offline liczy się o 12 godzin dłużej.';

  @override
  String get chapter_1_t => 'Wezwany';

  @override
  String get chapter_1 =>
      '*: Garaż Dziadka. Ołtarz, dym i zapach sernika.\nchronos: Kto mnie wzywa?\ngrandpa: Ja. Mam sprawę. Codziennie o piątej muszę być w kuchni.\nchronos: Wezwałeś boga czasu, żeby zdążyć na herbatę.\ngrandpa: Na podwieczorek. Jest sernik.\ngrandma (z kuchni): Ciasto stygnie!\nchronos (nieruchomieje): Kto to był?\ngrandpa: Żona.\nchronos: Cofam czas. Do tamtego podwieczorku.\ngrandpa: A zegary?\nchronos: Zegary nie będą pamiętać. Wy tak. I tym razem bez cyferek.';

  @override
  String get chapter_2_t => 'Bez cyferek';

  @override
  String get chapter_2 =>
      '*: Garaż. Ołtarz. Znowu.\nchronos: Bez cyferek, a dalej w piątkę. Czujecie czas.\ngrandpa: Czemu wtedy uciekłeś?\nchronos: Bogowie nie uciekają. Bogowie się oddalają.\ngrandpa: Babcia pyta, czy wpadniesz na podwieczorek.\nchronos: Bogowie nie wpadają.\nchronos: Następna lekcja: czas kosztuje. Od dziś każda sekunda drożej.';

  @override
  String get chapter_3_t => 'Drożyzna';

  @override
  String get chapter_3 =>
      'chronos: Drogo było?\ngrandpa: Mniej niż kwiaty na rocznicę. Zapomniałem o nich, to wyszło taniej.\nchronos (cicho): Czternastego maja.\ngrandpa: Skąd wiesz?\nchronos: Nie wiem. Zgadłem.\nchronos: Następna lekcja: słońce zostaje za chmurą. Na herbatę się nie trafia. Na herbatę się przychodzi.';

  @override
  String get chapter_4_t => 'Czwarta filiżanka';

  @override
  String get chapter_4 =>
      'chronos: Bez słońca też daliście radę.\nchronos: Dla kogo ta czwarta filiżanka?\ngrandpa: Babcia zawsze nakrywa o jedną za dużo. Nie pytam. Pięćdziesiąt lat nie pytam.\nchronos: …\nchronos: Następna lekcja: jedno krzywe trafienie i od zera. Tak jest z randkami.\ngrandpa: Z czym?\nchronos: Z niczym. Cofam czas.';

  @override
  String get chapter_5_t => 'Pięć sekund';

  @override
  String get chapter_5 =>
      'chronos: Raz w życiu zatrzymałem czas dla człowieka.\ngrandpa: Na długo?\nchronos: Na pięć sekund.\ngrandpa: Dla kogo?\nchronos: Dla spóźnialskiego. Biegł z kwiatami. Gubił płatki.\ngrandpa: Głupek.\nchronos: Mhm.\nchronos: Następna lekcja: byle jakie trafienie się nie liczy.';

  @override
  String get chapter_6_t => 'Za drzwiami';

  @override
  String get chapter_6 =>
      '*: Kuchnia. Drzwi do garażu zamknięte.\ngrandma (do drzwi): Wiem, że tam jesteś.\nchronos (zza drzwi): Nie ma mnie.\ngrandma: Pięćdziesiąt lat cię nie ma. Sernik i tak kroję na cztery.\ngrandpa (szeptem, do ciebie): Z kim ona rozmawia?\nchronos: Ostatnia lekcja. Bez spania. Kto śpi, ten się spóźnia.';

  @override
  String get chapter_7_t => 'Punkt piąta';

  @override
  String get chapter_7 =>
      '*: Kuchnia Babci. Na zegarze 16:59.\n*: Drzwi. Dziadek. Pierwszy raz przed czasem.\ngrandma: Minuta przed czasem.\ngrandpa: Sam. Bez żadnych zegarów.\n*: Ktoś puka. Równo o piątej.\nchronos: Punktualnie.\ngrandma (nalewa do czwartej filiżanki): Siadaj.\nchronos: Nie przychodzę na herbaty.\ngrandma: Wiem. Pięćdziesiąt lat nie przychodzisz.\ngrandpa: Wy się znacie?\ngrandma: Od pięciu sekund. W siedemdziesiątym czwartym.\nchronos (siada): …Sernik?';

  @override
  String get help_round_t => 'Runda';

  @override
  String get help_round =>
      'Stoper liczy od zera. Dotknij ekranu, gdy pokaże 5.00 — od tego, jak blisko trafisz, zależy ocena:\n• równo 5.00 (±0,010 s) — PERFEKT, premia: Tiki za kilka sekund pracy zegarów, i pełny mnożnik\n• PERFEKT (±0,015 s) — 6 Tików, mnożnik +0,05\n• ŚWIETNIE (±0,030 s) — 3 Tiki\n• DOBRZE (±0,050 s) — 1 Tik\n• BLISKO (±0,150 s) — drobna pociecha, mnożnik przepada\nDalej to pudło. Dotknięcie wcześniej niż sekundę przed 5.00 się nie liczy. Umiejętności poszerzają okna ocen (poza „równo 5.00”).';

  @override
  String get help_res_t => 'Zasoby';

  @override
  String get help_res_tiki => 'Tiki — waluta: zegary i umiejętności';

  @override
  String get help_res_chronon => 'Chronony — stały mnożnik dochodu z paradoksu';

  @override
  String get help_res_shard => 'Okruchy czasu — waluta perków';

  @override
  String get help_res_spring => 'Sprężyny — mistrzostwo zegarów';

  @override
  String get helpLocked => 'Graj dalej, aby odblokować nowe mechaniki';

  @override
  String get notificationAskBody =>
      'Zegary zarabiają, gdy gra jest zamknięta — ale tylko do limitu czasu. Damy znać, gdy go osiągną, i przypomnimy o dziennej premii. Najwyżej dwa powiadomienia, nigdy w nocy.';

  @override
  String get notificationAskYes => 'Tak, daj znać';

  @override
  String get notificationAskNo => 'Nie, dziękuję';

  @override
  String get prologue_t => 'Prolog: Siedem minut';

  @override
  String get prologue =>
      '*: Kuchnia Babci. Stół nakryty na cztery filiżanki.\n*: Na zegarze piąta. Krzesło Dziadka stoi puste.\ngrandma (podaje ci stoper): Zmierz mu, dziecko.\n*: Siedem minut później.\ngrandma: Siedem minut.\ngrandpa: Niemożliwe. Mój zegarek pokazuje piątą.\ngrandma: Twój zegarek pokazuje piątą od pięćdziesięciu lat.\ngrandpa (szeptem, do ciebie): Masz rękę do stopera. Po Babci.\ngrandpa: Jutro będę co do sekundy. Potrzebuję tylko lepszego zegara.\ngrandma: Zegar, który się nie myli, jest tylko jeden.\ngrandpa: Chronos. Wiem. Czytałem.\ngrandma (patrzy na czwartą filiżankę): Przy stole się o nim nie mówi.\ngrandpa (szeptem, do ciebie): Ale zdobyć go można. Zaczniemy od mniejszych zegarów.';

  @override
  String get prologueGoal => 'Cel: zdobądź Chronosa';

  @override
  String get prologueGo => 'Do dzieła!';

  @override
  String get chroniclePrologue => 'Prolog';

  @override
  String get calibTitle => 'Kalibracja';

  @override
  String get calibIntro =>
      'Każdy telefon trochę spóźnia dotyk i obraz. Dotknij 10 razy, gdy stoper pokaże 5.00: gra zmierzy, o ile zwykle się spóźniasz, i od teraz będzie to odejmować. Twoja precyzja zostaje twoja — znika tylko stałe opóźnienie.';

  @override
  String calibCurrent(String offset) {
    return 'Obecne przesunięcie: $offset';
  }

  @override
  String get calibStart => 'Zacznij';

  @override
  String get calibTapHint => 'Dotknij na 5.00';

  @override
  String get calibNoTap => 'Bez dotknięcia — jeszcze raz';

  @override
  String calibResultLate(int ms) {
    return 'Twoje dotknięcia są liczone średnio $ms ms po czasie.';
  }

  @override
  String calibResultEarly(int ms) {
    return 'Twoje dotknięcia są liczone średnio $ms ms przed czasem.';
  }

  @override
  String get calibResultZero =>
      'Twoje dotknięcia trafiają średnio w punkt — przesunięcie nie jest potrzebne.';

  @override
  String get calibUnreliable =>
      'Wyniki są mocno rozrzucone. Powtórz test spokojnie, patrząc na cyfry.';

  @override
  String calibApply(String offset) {
    return 'Zastosuj ($offset)';
  }

  @override
  String get calibRepeat => 'Powtórz';

  @override
  String get calibReset => 'Wyzeruj';

  @override
  String settingsCalibration(String offset) {
    return 'Kalibracja opóźnienia: $offset';
  }

  @override
  String settingsCalibrationHint(String offset) {
    return 'Twoje ostatnie dotknięcia to średnio $offset — kalibracja może pomóc.';
  }

  @override
  String get adShowFailed =>
      'Nie udało się wyświetlić reklamy — bez nagrody, ale oferta na ciebie czeka. Spróbuj za chwilę.';

  @override
  String get welcomeTitle => 'Witaj z powrotem!';

  @override
  String get collectAll => 'Odbierz wszystko';

  @override
  String welcomeSeason(String season) {
    return 'Trwa wydarzenie: $season! Postęp pokazuje plakietka u góry.';
  }

  @override
  String get dailyGrace =>
      'Ominął cię jeden dzień — dzień łaski tego tygodnia uratował serię.';

  @override
  String get statsAskTitle => 'Pomożesz dopracować grę?';

  @override
  String get statsAskBody =>
      'Czy gra może wysyłać anonimowe statystyki rozgrywki i raporty o awariach? Bez konta, imienia i identyfikatora reklamowego. Zmienisz to w każdej chwili w ustawieniach.';

  @override
  String get statsAskYes => 'Tak, wysyłaj';

  @override
  String get statsAskNo => 'Nie, dziękuję';

  @override
  String get buyAmountNext => 'PRÓG';

  @override
  String get notificationOfflineBody =>
      'Limit offline jest pełny: dalsze czekanie nic już nie dorzuci.';

  @override
  String notificationDailyTitle(int day, int days) {
    return 'Dzienna premia czeka — dzień $day/$days';
  }

  @override
  String get notificationDailyBody =>
      'Wpadnij ją odebrać, żeby seria trwała dalej.';

  @override
  String get notificationReserveTitle => 'Zapas dokręcania pełny';

  @override
  String notificationReserveBody(String time) {
    return 'Równe 5.00 znów nakręcają Sprężynę — każde o $time.';
  }

  @override
  String get settingsNotificationsHint =>
      'Limit offline, dzienna premia, pełny zapas dokręcania. Najwyżej dwa naraz, nigdy w nocy.';

  @override
  String get cloudOfferTitle => 'Zapis w chmurze';

  @override
  String cloudOfferBody(
    String cloudTime,
    String cloudEarned,
    String localTime,
    String localEarned,
  ) {
    return 'W Google Play Gry jest zapis z większym postępem:\n• w chmurze: $cloudTime gry, $cloudEarned Tików łącznie\n• na tym telefonie: $localTime gry, $localEarned Tików łącznie\nWczytać zapis z chmury? Postęp z tego telefonu zostanie zastąpiony.';
  }

  @override
  String get cloudLoad => 'Wczytaj z chmury';

  @override
  String get cloudKeep => 'Zostaw ten z telefonu';

  @override
  String get settingsCloud => 'Zapis w chmurze (Google Play Gry)';

  @override
  String get settingsCloudOn =>
      'Połączono: gra zapisuje się w chmurze przy każdym wyjściu.';

  @override
  String get settingsCloudOff =>
      'Zachowa postęp, gdy zmienisz albo zresetujesz telefon.';

  @override
  String get settingsCloudConnect => 'Połącz z Google Play Gry';

  @override
  String get settingsCloudRestore => 'Wczytaj z chmury';

  @override
  String get settingsCloudNothing =>
      'W chmurze nie ma zapisu z większym postępem niż na tym telefonie.';

  @override
  String get challengesTitle => 'Wyzwania';

  @override
  String get challengesToday => 'Dzisiaj';

  @override
  String get challengesWeek => 'Ten tydzień';

  @override
  String get challengesRerollHint =>
      'Któreś nie pasuje? ↻ wymienia je — raz dziennie.';

  @override
  String get challengesNewTomorrow => 'Nowe o północy.';

  @override
  String challengesDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Zostało $days dni',
      few: 'Zostały $days dni',
      one: 'Ostatni dzień',
    );
    return '$_temp0';
  }

  @override
  String chGreat(int n) {
    return 'Traf ŚWIETNIE lub lepiej $n razy';
  }

  @override
  String chStreak(int n) {
    return '$n trafień z rzędu';
  }

  @override
  String chJackpot(int n) {
    return 'Zatrzymaj stoper równo na 5.00 ($n×)';
  }

  @override
  String chPerfectWindow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n PERFEKTÓW',
      few: '$n PERFEKTY',
      one: '1 PERFEKT',
    );
    return '$_temp0 w 10 kolejnych rundach';
  }

  @override
  String chHitEarnings(String amount) {
    return 'Zarób trafieniami $amount Tików';
  }

  @override
  String chBuyClocks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n zegarów',
      few: '$n zegary',
      one: '1 zegar',
    );
    return 'Kup $_temp0';
  }

  @override
  String chMilestones(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bonusów zegarów',
      few: '$n bonusy zegarów',
      one: 'bonus zegara',
    );
    return 'Zdobądź $_temp0';
  }

  @override
  String chSkillLevels(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n poziomów',
      few: '$n poziomy',
      one: '1 poziom',
    );
    return 'Kup $_temp0 umiejętności';
  }

  @override
  String chGolden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Złotych Sekund',
      few: '$n Złote Sekundy',
      one: 'Złotą Sekundę',
    );
    return 'Złap $_temp0';
  }

  @override
  String chSpring(String hours) {
    return 'Nakręć Sprężynę o $hours h trafieniami równo w 5.00';
  }

  @override
  String get challengeClaimed => 'Odebrane';

  @override
  String get challengeReroll => 'Wylosuj inne (raz dziennie)';

  @override
  String challengeBonus(int done, int total) {
    return 'Wszystkie trzy dzisiaj: $done/$total';
  }

  @override
  String get challengeBonusDone => 'Dziś wszystkie trzy — brawo!';

  @override
  String challengeBonusPaid(String amount) {
    return 'Wszystkie trzy dzisiaj! Premia +$amount Tików';
  }

  @override
  String get challengeDone => 'Wyzwanie ukończone!';

  @override
  String get challengeOpen => 'Odbierz';

  @override
  String challengeCarry(String what) {
    return 'Nagrody za wczorajsze ukończone wyzwania: $what';
  }

  @override
  String challengeCarrySprings(int n) {
    return '+$n Sprężyna';
  }

  @override
  String get tip_challenges =>
      'Nowość: trzy wyzwania dziennie i jedno tygodniowe. Dotknij, by zobaczyć!';

  @override
  String get help_challenges_t => 'Wyzwania';

  @override
  String get help_challenges =>
      'Codziennie trzy wyzwania, co tydzień jeszcze jedno — postęp widać na plakietce u góry. Liczby biorą się z twoich ostatnich dotknięć, więc są wyzwaniem przy każdej celności, a zwykle wystarczy kilka minut gry.\n• Każde dzienne płaci 10 minut dochodu zegarów, wszystkie trzy razem jeszcze 30.\n• Tygodniowe daje 1 Sprężynę (przed pierwszym paradoksem: godzinę dochodu).\n• Któreś nie pasuje? ↻ wymienia dzienne wyzwanie, raz dziennie.\n• Ukończone, ale nieodebrane? Wypłaca się samo, gdy przychodzą nowe — nic nie przepada.';

  @override
  String chPerfect(int n) {
    return 'Traf PERFEKT $n razy';
  }

  @override
  String get story_atomic_t => 'Zegar atomowy';

  @override
  String get story_atomic =>
      'grandpa: Zegar atomowy. Myli się o sekundę na sto milionów lat.\ngrandpa: Jutro jestem w kuchni punkt piąta.\ngrandma: Mówiłeś to przy kukułce.\ngrandpa: Kukułka była z odpustu.\ngrandma: A spóźnienie?\ngrandpa: …Z przyzwyczajenia.';

  @override
  String get story_paradox_t => 'Do tyłu';

  @override
  String get story_paradox =>
      '*: Wszystkie zegary w garażu kręcą się do tyłu.\ngrandpa: Udało się! Cofnęliśmy czas!\ngrandma (z kuchni): Znowu coś przepaliłeś?\nchronos (z bardzo daleka): Kto mi grzebie w zegarach?\ngrandpa (szeptem, do ciebie): Udajemy, że nic nie było.';

  @override
  String get story_timeMachine_t => 'Siedemdziesiąty czwarty';

  @override
  String get story_timeMachine =>
      'grandpa: Maszyna czasu. Wróciłbym do siedemdziesiątego czwartego.\ngrandma: Po co?\ngrandpa: Przyjść na naszą pierwszą randkę punktualnie.\ngrandma: Przyszedłeś punktualnie.\ngrandpa: Biegłem jak głupi. Byłem pewny, że się spóźnię.\ngrandma (cicho): Ktoś ci pomógł.';

  @override
  String get story_altar_t => 'Ołtarz';

  @override
  String get story_altar =>
      'grandpa: Ołtarz gotowy. Jeszcze trochę Tików i wezwiemy Chronosa.\ngrandma: To chociaż się uczesz.\ngrandpa: Po co?\ngrandma: Przy gościach nie chodzi się rozczochranym.\ngrandpa (szeptem, do ciebie): Jakich gościach?';

  @override
  String get storyNext => 'Dalej';

  @override
  String get storySkip => 'Pomiń';

  @override
  String get storyTapHint => 'Dotknij, żeby dalej';

  @override
  String get who_grandpa => 'Dziadek';

  @override
  String get who_grandma => 'Babcia';

  @override
  String get who_chronos => 'Chronos';

  @override
  String get welcomeLine_1 =>
      'grandpa: Jesteś! Babcia już nakryła. Jak zwykle o jedną filiżankę za dużo.';

  @override
  String get welcomeLine_2 =>
      'grandma: Siadaj, dziecko. Dziadek jeszcze w garażu. „Kalibruje”.';

  @override
  String get welcomeLine_3 =>
      'grandpa: Zegary pracowały całą noc. Ja też. Babcia mówi, że to widać.';

  @override
  String get welcomeLine_4 =>
      'grandma: Sernik jest. Zegar jest. Dziadka nie ma. Zwykły dzień.';

  @override
  String get welcomeLine_5 =>
      'grandpa: Nastawiłem wszystkie zegary na piątą. Teraz biją naraz. Babcia nie jest zachwycona.';

  @override
  String get welcomeLine_6 =>
      'grandma: Tej czwartej filiżanki nie ruszaj. Ona na kogoś czeka.';

  @override
  String get welcomeLine_7 =>
      'grandpa: Babcia ani razu się nie spóźniła. Pięćdziesiąt lat. To nie jest normalne.';
}
