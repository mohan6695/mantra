/// Rich metadata for each mantra — deity, meaning, benefits, category.
///
/// This data lives in Dart (not DB) because it's static reference content.
/// The DB [MantraConfigTable] stores per-user settings (target, sensitivity).
/// This model enriches display with spiritual context.

// ──────────────────────────────────────────────────────────
// Enums
// ──────────────────────────────────────────────────────────

/// Whether a mantra is short (repetitive counting) or long (verse tracking).
enum MantraCategory {
  /// Short mantras: 1-10 words, chanted repetitively (e.g., 108 times).
  /// Uses EnsembleDetector for counting.
  short,

  /// Long mantras/stotrams: multi-line, chanted once or few times.
  /// Uses VerseTracker for word-by-word following.
  long,
}

/// The Hindu deity or tradition this mantra belongs to.
enum MantraDeity {
  universal, // Om, Gayatri
  shiva,
  vishnu,
  krishna,
  hanuman,
  ganesha,
  devi,
  surya,
}

// ──────────────────────────────────────────────────────────
// Metadata model
// ──────────────────────────────────────────────────────────

class MantraMetadata {
  /// Matches either [MantraConfigTable.id] (for short) or
  /// [VerseMantra.id] (for long).
  final String key;

  /// Display name (English).
  final String name;

  /// Devanagari text (first line or full text for short mantras).
  final String devanagari;

  /// Romanized/IAST transliteration.
  final String romanized;

  /// Short / long classification.
  final MantraCategory category;

  /// Associated deity.
  final MantraDeity deity;

  /// One-line English meaning.
  final String meaning;

  /// Spiritual benefit (shown in mantra details).
  final String benefit;

  /// Approximate duration of one chant in seconds.
  final double durationSeconds;

  /// Traditional count per session (108, 1008, etc.)
  final int traditionalCount;

  /// Recommended refractory period (ms) for short mantras.
  final int recommendedRefractoryMs;

  /// Telugu script text.
  final String telugu;

  /// Icon/emoji for quick visual identification.
  final String icon;

  /// Number of words (for short mantras) or lines (for long mantras).
  final int wordOrLineCount;

  const MantraMetadata({
    required this.key,
    required this.name,
    required this.devanagari,
    required this.romanized,
    required this.category,
    required this.deity,
    required this.meaning,
    required this.benefit,
    required this.durationSeconds,
    required this.traditionalCount,
    this.telugu = '',
    this.recommendedRefractoryMs = 800,
    this.icon = '🙏',
    this.wordOrLineCount = 1,
  });

  bool get isShort => category == MantraCategory.short;
  bool get isLong => category == MantraCategory.long;
}

// ──────────────────────────────────────────────────────────
// Top 10 Hindu Mantras — metadata registry
// ──────────────────────────────────────────────────────────

/// All 10 mantras indexed by key.
final Map<String, MantraMetadata> mantraMetadataRegistry = {
  for (final m in allMantraMetadata) m.key: m,
};

/// Ordered list of all 10 mantras.
final List<MantraMetadata> allMantraMetadata = [
  // ── 4 SHORT MANTRAS (repetitive counting) ──────────────
  omPranava,
  omNamahShivaya,
  hareKrishna,
  omNamoNarayanaya,

  // ── 6 LONG MANTRAS (verse tracking) ────────────────────
  gayatriMantraMeta,
  mahamrityunjayaMeta,
  hanumanChalisaMeta,
  sriSuktamMeta,
  vishnuSahasranamaMeta,
  lalithaSahasranamaMeta,
];

List<MantraMetadata> get shortMantras =>
    allMantraMetadata.where((m) => m.isShort).toList();

List<MantraMetadata> get longMantras =>
    allMantraMetadata.where((m) => m.isLong).toList();

// ──────────────────────────────────────────────────────────
// 4 SHORT MANTRAS
// ──────────────────────────────────────────────────────────

/// 1. Om (Pranava Mantra) — the primordial sound
const omPranava = MantraMetadata(
  key: '1', // DB id
  name: 'Om (Pranava)',
  devanagari: 'ॐ',
  romanized: 'Om',
  telugu: 'ఓం',
  category: MantraCategory.short,
  deity: MantraDeity.universal,
  meaning: 'The primordial sound of the universe — the source of all creation.',
  benefit: 'Calms the mind, raises consciousness, connects to the cosmic vibration.',
  durationSeconds: 1.5,
  traditionalCount: 108,
  recommendedRefractoryMs: 600,
  icon: '🕉️',
  wordOrLineCount: 1,
);

/// 2. Om Namah Shivaya — the five-syllable mantra of Lord Shiva
const omNamahShivaya = MantraMetadata(
  key: '2', // DB id
  name: 'Om Namah Shivaya',
  devanagari: 'ॐ नमः शिवाय',
  romanized: 'Om Na-mah Shi-vaa-ya',
  telugu: 'ఓం నమః శివాయ',
  category: MantraCategory.short,
  deity: MantraDeity.shiva,
  meaning: 'I bow to Lord Shiva — the auspicious one, the transformer.',
  benefit: 'Destroys negativity, purifies the five elements, grants inner peace.',
  durationSeconds: 2.5,
  traditionalCount: 108,
  recommendedRefractoryMs: 800,
  icon: '🔱',
  wordOrLineCount: 3,
);

/// 3. Hare Krishna Mahamantra — the great mantra for deliverance
const hareKrishna = MantraMetadata(
  key: '3', // DB id
  name: 'Hare Krishna Mahamantra',
  devanagari: 'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे\nहरे राम हरे राम राम राम हरे हरे',
  romanized: 'Hare Krishna Hare Krishna Krishna Krishna Hare Hare\nHare Rama Hare Rama Rama Rama Hare Hare',
  telugu: 'హరే కృష్ణ హరే కృష్ణ కృష్ణ కృష్ణ హరే హరే\nహరే రామ హరే రామ రామ రామ హరే హరే',
  category: MantraCategory.short,
  deity: MantraDeity.krishna,
  meaning: 'O Lord Krishna, O Lord Rama — please engage me in Your devotional service.',
  benefit: 'Cleanses the heart, awakens divine love, grants liberation in Kali Yuga.',
  durationSeconds: 6.0,
  traditionalCount: 108,
  recommendedRefractoryMs: 1500,
  icon: '🦚',
  wordOrLineCount: 16,
);

/// 4. Om Namo Narayanaya — the eight-syllable mantra of Lord Vishnu
const omNamoNarayanaya = MantraMetadata(
  key: '4', // DB id
  name: 'Om Namo Narayanaya',
  devanagari: 'ॐ नमो नारायणाय',
  romanized: 'Om Na-mo Naa-raa-ya-naa-ya',
  telugu: 'ఓం నమో నారాయణాయ',
  category: MantraCategory.short,
  deity: MantraDeity.vishnu,
  meaning: 'I bow to Lord Narayana — the supreme refuge of all beings.',
  benefit: 'Grants protection, dissolves karma, leads to Vaikuntha (liberation).',
  durationSeconds: 3.0,
  traditionalCount: 108,
  recommendedRefractoryMs: 900,
  icon: '🔵',
  wordOrLineCount: 3,
);

// ──────────────────────────────────────────────────────────
// 6 LONG MANTRAS (verse-tracked)
// ──────────────────────────────────────────────────────────

/// 5. Gayatri Mantra — the mother of all Vedas
const gayatriMantraMeta = MantraMetadata(
  key: 'gayatri',
  name: 'Gayatri Mantra',
  devanagari: 'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्',
  romanized: 'Om Bhur Bhuvah Svah\nTat Savitur Varenyam\nBhargo Devasya Dhimahi\nDhiyo Yo Nah Prachodayat',
  telugu: 'ఓం భూర్భువః స్వః\nతత్సవితుర్వరేణ్యం\nభర్గో దేవస్య ధీమహి\nధియో యో నః ప్రచోదయాత్',
  category: MantraCategory.long,
  deity: MantraDeity.surya,
  meaning: 'We meditate on the divine light of the Sun God; may it illuminate our intellect.',
  benefit: 'Sharpens intellect, purifies the mind, bestows spiritual wisdom.',
  durationSeconds: 12.0,
  traditionalCount: 108,
  icon: '☀️',
  wordOrLineCount: 4,
);

/// 6. Mahamrityunjaya Mantra — the great death-conquering mantra
const mahamrityunjayaMeta = MantraMetadata(
  key: 'mahamrityunjaya',
  name: 'Mahamrityunjaya Mantra',
  devanagari: 'ॐ त्र्यम्बकं यजामहे\nसुगन्धिं पुष्टिवर्धनम्\nउर्वारुकमिव बन्धनान्\nमृत्योर्मुक्षीय मामृतात्',
  romanized: 'Om Tryambakam Yajamahe\nSugandhim Pushtivardhanam\nUrvarukamiva Bandhanan\nMrityormukshiya Maamritat',
  telugu: 'ఓం త్ర్యంబకం యజామహే\nసుగంధిం పుష్టివర్ధనం\nఉర్వారుకమివ బంధనాన్\nమృత్యోర్ముక్షీయ మామృతాత్',
  category: MantraCategory.long,
  deity: MantraDeity.shiva,
  meaning: 'We worship the three-eyed Lord Shiva; may He liberate us from death.',
  benefit: 'Healing, protection from untimely death, courage in adversity.',
  durationSeconds: 15.0,
  traditionalCount: 108,
  icon: '🔱',
  wordOrLineCount: 4,
);

/// 7. Hanuman Chalisa — 40 verses in praise of Lord Hanuman
const hanumanChalisaMeta = MantraMetadata(
  key: 'hanuman_chalisa',
  name: 'Hanuman Chalisa',
  devanagari: 'श्रीगुरु चरन सरोज रज…',
  romanized: 'Shree Guru Charan Saroj Raj…',
  telugu: 'శ్రీగురు చరణ సరోజ రజ…',
  category: MantraCategory.long,
  deity: MantraDeity.hanuman,
  meaning: '40 chaupais glorifying Hanuman — the embodiment of devotion, strength, and selfless service.',
  benefit: 'Removes fear, grants courage, protects from negative energies.',
  durationSeconds: 600.0, // ~10 minutes
  traditionalCount: 1,
  icon: '🐒',
  wordOrLineCount: 84,
);

/// 8. Sri Suktam — Vedic hymn to Goddess Lakshmi
const sriSuktamMeta = MantraMetadata(
  key: 'sri_suktam',
  name: 'Sri Suktam',
  devanagari: 'हिरण्यवर्णां हरिणीं…',
  romanized: 'Hiranyavarnaam Harineem…',
  telugu: 'హిరణ్యవర్ణాం హరిణీం…',
  category: MantraCategory.long,
  deity: MantraDeity.devi,
  meaning: 'Vedic hymn praising Goddess Lakshmi — the golden one who bestows prosperity.',
  benefit: 'Attracts wealth, abundance, and spiritual prosperity.',
  durationSeconds: 300.0, // ~5 minutes
  traditionalCount: 1,
  icon: '🪷',
  wordOrLineCount: 29,
);

/// 9. Vishnu Sahasranama — 1000 names of Lord Vishnu (Dhyana + opening verses)
const vishnuSahasranamaMeta = MantraMetadata(
  key: 'vishnu_sahasranama',
  name: 'Vishnu Sahasranama',
  devanagari: 'शुक्लाम्बरधरं विष्णुं…',
  romanized: 'Shuklambaradharam Vishnum…',
  telugu: 'శుక్లాంబరధరం విష్ణుం…',
  category: MantraCategory.long,
  deity: MantraDeity.vishnu,
  meaning: 'The thousand names of Lord Vishnu — each name a meditation on the divine.',
  benefit: 'Removes all sins, grants moksha, bestows peace and prosperity.',
  durationSeconds: 1800.0, // ~30 minutes
  traditionalCount: 1,
  icon: '🔵',
  wordOrLineCount: 107,
);

/// 10. Lalitha Sahasranama — 1000 names of Goddess Lalitha Tripurasundari
const lalithaSahasranamaMeta = MantraMetadata(
  key: 'lalitha_sahasranama',
  name: 'Lalitha Sahasranama',
  devanagari: 'सिन्दूरारुणविग्रहां…',
  romanized: 'Sinduraruna Vigraham…',
  telugu: 'సిందూరారుణ విగ్రహాం…',
  category: MantraCategory.long,
  deity: MantraDeity.devi,
  meaning: 'The thousand names of Goddess Lalitha — the beautiful one who plays the cosmic game.',
  benefit: 'Fulfills all desires, grants beauty, wisdom, and ultimate liberation.',
  durationSeconds: 1800.0, // ~30 minutes
  traditionalCount: 1,
  icon: '🌺',
  wordOrLineCount: 182,
);
