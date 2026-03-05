/// Predefined long verse mantras for the app.
///
/// Each verse is segmented into lines and words with syllable counts
/// for timing validation during voice tracking.

import 'models/verse_mantra.dart';

// ──────────────────────────────────────────────────────────
// Builder helper
// ──────────────────────────────────────────────────────────

/// Builds a VerseMantra from a list of (devanagari, romanized) line pairs.
/// Each line's words are split on whitespace and syllable counts are
/// estimated from romanized text.
VerseMantra _buildVerse({
  required String id,
  required String name,
  required String description,
  required String language,
  required List<({String dev, String rom})> linePairs,
}) {
  int globalIdx = 0;
  final lines = <VerseLine>[];

  for (int li = 0; li < linePairs.length; li++) {
    final pair = linePairs[li];
    final devWords = pair.dev.split(RegExp(r'\s+'));
    final romWords = pair.rom.split(RegExp(r'\s+'));

    // Pad if mismatch (romanized may have different word boundaries)
    final wordCount =
        devWords.length > romWords.length ? devWords.length : romWords.length;

    final words = <VerseWord>[];
    for (int wi = 0; wi < wordCount; wi++) {
      final dev = wi < devWords.length ? devWords[wi] : '';
      final rom = wi < romWords.length ? romWords[wi] : '';
      words.add(VerseWord(
        globalIndex: globalIdx,
        lineIndex: li,
        wordIndexInLine: wi,
        devanagari: dev,
        romanized: rom,
        syllableCount: _estimateSyllables(rom),
      ));
      globalIdx++;
    }

    lines.add(VerseLine(
      index: li,
      devanagari: pair.dev,
      romanized: pair.rom,
      words: words,
    ));
  }

  return VerseMantra(
    id: id,
    name: name,
    description: description,
    language: language,
    lines: lines,
  );
}

/// Rough syllable count from romanized text. Counts vowel clusters.
int _estimateSyllables(String romanized) {
  if (romanized.isEmpty) return 1;
  final vowels = RegExp(r'[aeiouāīūṛḷ]+', caseSensitive: false);
  final matches = vowels.allMatches(romanized.toLowerCase());
  return matches.isEmpty ? 1 : matches.length;
}

// ──────────────────────────────────────────────────────────
// Available verse mantras
// ──────────────────────────────────────────────────────────

/// All predefined verse mantras in the app.
List<VerseMantra> get allVerses => [
      gayatriMantra,
      mahamrityunjaya,
      sriSuktam,
      hanumanChalisa,
      vishnuSahasranama,
      lalithaSahasranama,
      vishwanathaAshtakam,
    ];

// ──────────────────────────────────────────────────────────
// 1. Hanuman Chalisa  (40 chaupais + dohas)
// ──────────────────────────────────────────────────────────

final hanumanChalisa = _buildVerse(
  id: 'hanuman_chalisa',
  name: 'Hanuman Chalisa',
  description: '40 verses in praise of Lord Hanuman',
  language: 'hi',
  linePairs: [
    // Doha 1
    (
      dev: 'श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि',
      rom: 'Shree Guru charan saroj raj nij manu mukuru sudhaari'
    ),
    (
      dev: 'बरनउँ रघुबर बिमल जसु जो दायकु फल चारि',
      rom: 'Baranau Raghubar bimal jasu jo daayaku phal chaari'
    ),
    // Doha 2
    (
      dev: 'बुद्धिहीन तनु जानिके सुमिरौं पवन कुमार',
      rom: 'Buddhiheen tanu jaanike sumirau pavan kumaar'
    ),
    (
      dev: 'बल बुद्धि बिद्या देहु मोहिं हरहु कलेस बिकार',
      rom: 'Bal buddhi bidyaa dehu mohi harahu kalesh bikaar'
    ),
    // Chaupai 1
    (
      dev: 'जय हनुमान ज्ञान गुन सागर',
      rom: 'Jai Hanumaan gyaan gun saagar'
    ),
    (
      dev: 'जय कपीस तिहुँ लोक उजागर',
      rom: 'Jai Kapeesh tihun lok ujaagar'
    ),
    // Chaupai 2
    (
      dev: 'राम दूत अतुलित बल धामा',
      rom: 'Raam doot atulit bal dhaamaa'
    ),
    (
      dev: 'अंजनि पुत्र पवनसुत नामा',
      rom: 'Anjani putra pavansut naamaa'
    ),
    // Chaupai 3
    (
      dev: 'महाबीर बिक्रम बजरंगी',
      rom: 'Mahaabeer bikram bajrangi'
    ),
    (
      dev: 'कुमति निवार सुमति के संगी',
      rom: 'Kumati nivaar sumati ke sangi'
    ),
    // Chaupai 4
    (
      dev: 'कंचन बरन बिराज सुबेसा',
      rom: 'Kanchan baran biraaj subesaa'
    ),
    (
      dev: 'कानन कुण्डल कुंचित केसा',
      rom: 'Kaanan kundal kunchit kesaa'
    ),
    // Chaupai 5
    (
      dev: 'हाथ बज्र औ ध्वजा बिराजै',
      rom: 'Haath bajra au dhvajaa biraajai'
    ),
    (
      dev: 'काँधे मूँज जनेऊ साजै',
      rom: 'Kaandhe moonj janeu saajai'
    ),
    // Chaupai 6
    (
      dev: 'शंकर सुवन केसरी नंदन',
      rom: 'Shankar suvan Kesaree Nandan'
    ),
    (
      dev: 'तेज प्रताप महा जग बन्दन',
      rom: 'Tej prataap mahaa jag bandan'
    ),
    // Chaupai 7
    (
      dev: 'विद्यावान गुणी अति चातुर',
      rom: 'Vidyaavaan gunee ati chaatur'
    ),
    (
      dev: 'राम काज करिबे को आतुर',
      rom: 'Raam kaaj karibe ko aatur'
    ),
    // Chaupai 8
    (
      dev: 'प्रभु चरित्र सुनिबे को रसिया',
      rom: 'Prabhu charitra sunibe ko rasiyaa'
    ),
    (
      dev: 'राम लखन सीता मन बसिया',
      rom: 'Raam Lakhan Seetaa man basiyaa'
    ),
    // Chaupai 9
    (
      dev: 'सूक्ष्म रूप धरि सियहिं दिखावा',
      rom: 'Sookshma roop dhari Siyahi dikhaavaa'
    ),
    (
      dev: 'बिकट रूप धरि लंक जरावा',
      rom: 'Bikat roop dhari Lank jaraavaa'
    ),
    // Chaupai 10
    (
      dev: 'भीम रूप धरि असुर संहारे',
      rom: 'Bheem roop dhari asur sanhaare'
    ),
    (
      dev: 'रामचन्द्र के काज सँवारे',
      rom: 'Raamchandra ke kaaj sanvaare'
    ),
    // Chaupai 11
    (
      dev: 'लाय सजीवन लखन जियाये',
      rom: 'Laay Sajeevan Lakhan jiyaaye'
    ),
    (
      dev: 'श्रीरघुबीर हरषि उर लाये',
      rom: 'Shree Raghubeer harashi ur laaye'
    ),
    // Chaupai 12
    (
      dev: 'रघुपति कीन्हीं बहुत बड़ाई',
      rom: 'Raghupati keenhi bahut badaai'
    ),
    (
      dev: 'तुम मम प्रिय भरतहि सम भाई',
      rom: 'Tum mam priya Bharatahi sam bhaai'
    ),
    // Chaupai 13
    (
      dev: 'सहस बदन तुम्हरो जस गावैं',
      rom: 'Sahas badan tumharo jas gaavai'
    ),
    (
      dev: 'अस कहि श्रीपति कण्ठ लगावैं',
      rom: 'As kahi Shreepati kanth lagaavai'
    ),
    // Chaupai 14
    (
      dev: 'सनकादिक ब्रह्मादि मुनीसा',
      rom: 'Sanakaadik Brahmaadi muneesaa'
    ),
    (
      dev: 'नारद सारद सहित अहीसा',
      rom: 'Naarad Saarad sahit Aheesaa'
    ),
    // Chaupai 15
    (
      dev: 'जम कुबेर दिगपाल जहाँ ते',
      rom: 'Yam Kuber Digpaal jahaan te'
    ),
    (
      dev: 'कबि कोबिद कहि सके कहाँ ते',
      rom: 'Kabi kobid kahi sake kahaan te'
    ),
    // Chaupai 16
    (
      dev: 'तुम उपकार सुग्रीवहिं कीन्हा',
      rom: 'Tum upkaar Sugreevahi keenhaa'
    ),
    (
      dev: 'राम मिलाय राज पद दीन्हा',
      rom: 'Raam milaay raaj pad deenhaa'
    ),
    // Chaupai 17
    (
      dev: 'तुम्हरो मंत्र विभीषन माना',
      rom: 'Tumharo mantra Vibheeshan maanaa'
    ),
    (
      dev: 'लंकेश्वर भए सब जग जाना',
      rom: 'Lankeshvar bhaye sab jag jaanaa'
    ),
    // Chaupai 18
    (
      dev: 'युग सहस्र जोजन पर भानू',
      rom: 'Yug sahasra yojan par Bhaanu'
    ),
    (
      dev: 'लील्यो ताहि मधुर फल जानू',
      rom: 'Leelyo taahi madhur phal jaanu'
    ),
    // Chaupai 19
    (
      dev: 'प्रभु मुद्रिका मेलि मुख माहीं',
      rom: 'Prabhu mudrikaa meli mukh maahi'
    ),
    (
      dev: 'जलधि लाँघि गये अचरज नाहीं',
      rom: 'Jaladhi laanghi gaye achraj naahi'
    ),
    // Chaupai 20
    (
      dev: 'दुर्गम काज जगत के जेते',
      rom: 'Durgam kaaj jagat ke jete'
    ),
    (
      dev: 'सुगम अनुग्रह तुम्हरे तेते',
      rom: 'Sugam anugrah tumhare tete'
    ),
    // Chaupai 21
    (
      dev: 'राम दुआरे तुम रखवारे',
      rom: 'Raam duaare tum rakhvaare'
    ),
    (
      dev: 'होत न आज्ञा बिनु पैसारे',
      rom: 'Hot na aagyaa binu paisaare'
    ),
    // Chaupai 22
    (
      dev: 'सब सुख लहै तुम्हारी सरना',
      rom: 'Sab sukh lahai tumhaari sarnaa'
    ),
    (
      dev: 'तुम रक्षक काहू को डर ना',
      rom: 'Tum rakshak kaahu ko dar naa'
    ),
    // Chaupai 23
    (
      dev: 'आपन तेज सम्हारो आपै',
      rom: 'Aapan tej samhaaro aapai'
    ),
    (
      dev: 'तीनों लोक हाँक तें काँपै',
      rom: 'Teenon lok haank te kaanpai'
    ),
    // Chaupai 24
    (
      dev: 'भूत पिशाच निकट नहिं आवै',
      rom: 'Bhoot pishaach nikat nahi aavai'
    ),
    (
      dev: 'महाबीर जब नाम सुनावै',
      rom: 'Mahaabeer jab naam sunaavai'
    ),
    // Chaupai 25
    (
      dev: 'नासै रोग हरै सब पीरा',
      rom: 'Naasai rog harai sab peeraa'
    ),
    (
      dev: 'जपत निरंतर हनुमत बीरा',
      rom: 'Japat nirantar Hanumat beeraa'
    ),
    // Chaupai 26
    (
      dev: 'संकट तें हनुमान छुड़ावै',
      rom: 'Sankat te Hanumaan chhudaavai'
    ),
    (
      dev: 'मन क्रम बचन ध्यान जो लावै',
      rom: 'Man kram bachan dhyaan jo laavai'
    ),
    // Chaupai 27
    (
      dev: 'सब पर राम तपस्वी राजा',
      rom: 'Sab par Raam tapasvee raajaa'
    ),
    (
      dev: 'तिन के काज सकल तुम साजा',
      rom: 'Tin ke kaaj sakal tum saajaa'
    ),
    // Chaupai 28
    (
      dev: 'और मनोरथ जो कोई लावै',
      rom: 'Aur manorath jo koi laavai'
    ),
    (
      dev: 'सोइ अमित जीवन फल पावै',
      rom: 'Soi amit jeevan phal paavai'
    ),
    // Chaupai 29
    (
      dev: 'चारों जुग परताप तुम्हारा',
      rom: 'Chaaron jug prataap tumhaaraa'
    ),
    (
      dev: 'है परसिद्ध जगत उजियारा',
      rom: 'Hai parsiddh jagat ujiyaaraa'
    ),
    // Chaupai 30
    (
      dev: 'साधु संत के तुम रखवारे',
      rom: 'Saadhu sant ke tum rakhvaare'
    ),
    (
      dev: 'असुर निकंदन राम दुलारे',
      rom: 'Asur nikandan Raam dulaare'
    ),
    // Chaupai 31
    (
      dev: 'अष्ट सिद्धि नौ निधि के दाता',
      rom: 'Ashta siddhi nau nidhi ke daataa'
    ),
    (
      dev: 'अस बर दीन जानकी माता',
      rom: 'As bar deen Jaanaki maataa'
    ),
    // Chaupai 32
    (
      dev: 'राम रसायन तुम्हरे पासा',
      rom: 'Raam rasaayan tumhare paasaa'
    ),
    (
      dev: 'सदा रहो रघुपति के दासा',
      rom: 'Sadaa raho Raghupati ke daasaa'
    ),
    // Chaupai 33
    (
      dev: 'तुम्हरे भजन राम को पावै',
      rom: 'Tumhare bhajan Raam ko paavai'
    ),
    (
      dev: 'जनम जनम के दुख बिसरावै',
      rom: 'Janam janam ke dukh bisaraavai'
    ),
    // Chaupai 34
    (
      dev: 'अंत काल रघुबर पुर जाई',
      rom: 'Ant kaal Raghubar pur jaai'
    ),
    (
      dev: 'जहाँ जन्म हरि भक्त कहाई',
      rom: 'Jahaan janma Hari bhakt kahaai'
    ),
    // Chaupai 35
    (
      dev: 'और देवता चित्त न धरई',
      rom: 'Aur devataa chitt na dharai'
    ),
    (
      dev: 'हनुमत सेइ सर्ब सुख करई',
      rom: 'Hanumat sei sarb sukh karai'
    ),
    // Chaupai 36
    (
      dev: 'संकट कटै मिटै सब पीरा',
      rom: 'Sankat katai mitai sab peeraa'
    ),
    (
      dev: 'जो सुमिरै हनुमत बलबीरा',
      rom: 'Jo sumirai Hanumat balbeeraa'
    ),
    // Chaupai 37
    (
      dev: 'जै जै जै हनुमान गोसाईं',
      rom: 'Jai jai jai Hanumaan Gosaai'
    ),
    (
      dev: 'कृपा करहु गुरुदेव की नाईं',
      rom: 'Kripaa karahu Gurudev ki naai'
    ),
    // Chaupai 38
    (
      dev: 'जो सत बार पाठ कर कोई',
      rom: 'Jo sat baar paath kar koi'
    ),
    (
      dev: 'छूटहि बंदि महा सुख होई',
      rom: 'Chhootahi bandi mahaa sukh hoi'
    ),
    // Chaupai 39
    (
      dev: 'जो यह पढ़ै हनुमान चालीसा',
      rom: 'Jo yah padhai Hanumaan Chaaleesaa'
    ),
    (
      dev: 'होय सिद्धि साखी गौरीसा',
      rom: 'Hoy siddhi saakhi Gaureesaa'
    ),
    // Chaupai 40
    (
      dev: 'तुलसीदास सदा हरि चेरा',
      rom: 'Tulaseedaas sadaa Hari cheraa'
    ),
    (
      dev: 'कीजै नाथ हृदय महँ डेरा',
      rom: 'Keejai Naath hriday maha deraa'
    ),
    // Closing doha
    (
      dev: 'पवनतनय संकट हरन मंगल मूरति रूप',
      rom: 'Pavantanay sankat haran mangal moorati roop'
    ),
    (
      dev: 'राम लखन सीता सहित हृदय बसहु सुर भूप',
      rom: 'Raam Lakhan Seetaa sahit hriday basahu sur bhoop'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 2. Gayatri Mantra (single verse, word-by-word tracking)
// ──────────────────────────────────────────────────────────

final gayatriMantra = _buildVerse(
  id: 'gayatri',
  name: 'Gayatri Mantra',
  description: 'Sacred Vedic mantra to the Sun deity',
  language: 'sa',
  linePairs: [
    (
      dev: 'ॐ भूर्भुवः स्वः',
      rom: 'Om Bhur Bhuvah Svah'
    ),
    (
      dev: 'तत् सवितुर् वरेण्यं',
      rom: 'Tat Savitur Varenyam'
    ),
    (
      dev: 'भर्गो देवस्य धीमहि',
      rom: 'Bhargo Devasya Dheemahi'
    ),
    (
      dev: 'धियो यो नः प्रचोदयात्',
      rom: 'Dhiyo Yo Nah Prachodayaat'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 3. Mahamrityunjaya Mantra
// ──────────────────────────────────────────────────────────

final mahamrityunjaya = _buildVerse(
  id: 'mahamrityunjaya',
  name: 'Mahamrityunjaya Mantra',
  description: 'The great death-conquering mantra',
  language: 'sa',
  linePairs: [
    (
      dev: 'ॐ त्र्यम्बकं यजामहे',
      rom: 'Om Tryambakam Yajaamahe'
    ),
    (
      dev: 'सुगन्धिं पुष्टिवर्धनम्',
      rom: 'Sugandhim Pushtivardhanam'
    ),
    (
      dev: 'उर्वारुकमिव बन्धनात्',
      rom: 'Urvaarukamiva Bandhanaat'
    ),
    (
      dev: 'मृत्योर्मुक्षीय माऽमृतात्',
      rom: 'Mrityormuksheeya Maamritaat'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 4. Kashi Vishwanath Ashtakam (8 verses)
// ──────────────────────────────────────────────────────────

final vishwanathaAshtakam = _buildVerse(
  id: 'vishwanatha_ashtakam',
  name: 'Vishwanatha Ashtakam',
  description: '8-verse hymn to Lord Shiva at Kashi',
  language: 'sa',
  linePairs: [
    // Verse 1
    (
      dev: 'गङ्गा तरङ्ग रमणीय जटा कलापं',
      rom: 'Gangaa taranga ramaneeya jataa kalaapam'
    ),
    (
      dev: 'गौरी निरन्तर विभूषित वाम भागम्',
      rom: 'Gauree nirantara vibhooshita vaama bhaagam'
    ),
    (
      dev: 'नारायण प्रियम् अनङ्ग मदापहारं',
      rom: 'Naaraayana priyam ananga madaapahaaram'
    ),
    (
      dev: 'वाराणसी पुर पतिं भज विश्वनाथम्',
      rom: 'Vaaraanasee pura patim bhaja Vishwanaatham'
    ),
    // Verse 2
    (
      dev: 'वाचामगोचरम् अनेक गुण स्वरूपं',
      rom: 'Vaachaamagocharam aneka guna svaroopam'
    ),
    (
      dev: 'वागीश विष्णु सुर सेवित पाद पीठम्',
      rom: 'Vaageesh Vishnu sura sevita paada peetham'
    ),
    (
      dev: 'वामेन विग्रह वरेण कलत्रवन्तं',
      rom: 'Vaamena vigraha varena kalatravantam'
    ),
    (
      dev: 'वाराणसी पुर पतिं भज विश्वनाथम्',
      rom: 'Vaaraanasee pura patim bhaja Vishwanaatham'
    ),
    // Verse 3
    (
      dev: 'भूताधिपं भुजग भूषणम् उर्ध्वरेतं',
      rom: 'Bhootaadhipam bhujaga bhooshanam oordhvaretam'
    ),
    (
      dev: 'चन्द्रार्क वह्नि नयनं त्रिपुरान्तकारम्',
      rom: 'Chandraarka vahni nayanam tripuraantakaaram'
    ),
    (
      dev: 'काशी पुराधिपम् अजं त्रिलोचनाद्यं',
      rom: 'Kaashee puraadhipam ajam trilochanaadyam'
    ),
    (
      dev: 'वाराणसी पुर पतिं भज विश्वनाथम्',
      rom: 'Vaaraanasee pura patim bhaja Vishwanaatham'
    ),
    // Verse 4
    (
      dev: 'सीतांशु शोभित किरीट विराजमानं',
      rom: 'Seetaamshu shobhita kireeta viraajamaanam'
    ),
    (
      dev: 'बालेक्षणं मणि कनक विभूषणाढ्यम्',
      rom: 'Baalekshanam mani kanaka vibhooshanaadhyam'
    ),
    (
      dev: 'बन्धूक पुष्प सदृशाङ्ग वरप्रदानम्',
      rom: 'Bandhooka pushpa sadrishaanga varapradaanam'
    ),
    (
      dev: 'वाराणसी पुर पतिं भज विश्वनाथम्',
      rom: 'Vaaraanasee pura patim bhaja Vishwanaatham'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 5. Sri Suktam — Vedic hymn to Goddess Lakshmi (16 mantras)
// ──────────────────────────────────────────────────────────

final sriSuktam = _buildVerse(
  id: 'sri_suktam',
  name: 'Sri Suktam',
  description: 'Vedic hymn to Goddess Lakshmi for prosperity and abundance',
  language: 'sa',
  linePairs: [
    // Mantra 1
    (
      dev: 'हिरण्यवर्णां हरिणीं सुवर्णरजतस्रजाम्',
      rom: 'Hiranyavarnaam harineem suvarnarajatasrajaam'
    ),
    (
      dev: 'चन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आवह',
      rom: 'Chandraam hiranmayeem lakshmeem jaatavedo ma aavaha'
    ),
    // Mantra 2
    (
      dev: 'तां म आवह जातवेदो लक्ष्मीमनपगामिनीम्',
      rom: 'Taam ma aavaha jaatavedo lakshmeemanapagaamineem'
    ),
    (
      dev: 'यस्यां हिरण्यं विन्देयं गामश्वं पुरुषानहम्',
      rom: 'Yasyaam hiranyam vindeyam gaamashvam purushaanaham'
    ),
    // Mantra 3
    (
      dev: 'अश्वपूर्वां रथमध्यां हस्तिनादप्रबोधिनीम्',
      rom: 'Ashvapoorvaam rathamadhyaam hastinaadaprabodhineem'
    ),
    (
      dev: 'श्रियं देवीमुपह्वये श्रीर्मा देवीर्जुषताम्',
      rom: 'Shriyam deveemupahvaye shreermaa deveerjushataam'
    ),
    // Mantra 4
    (
      dev: 'कांसोस्मितां हिरण्यप्राकारामार्द्रां ज्वलन्तीं तृप्तां तर्पयन्तीम्',
      rom: 'Kaamsosmitaam hiranyapraakaaraamaardraam jvalanteem truptaam tarpayanteem'
    ),
    (
      dev: 'पद्मे स्थितां पद्मवर्णां तामिहोपह्वये श्रियम्',
      rom: 'Padme sthitaam padmavarnaam taamihopahvaye shriyam'
    ),
    // Mantra 5
    (
      dev: 'चन्द्रां प्रभासां यशसा ज्वलन्तीं श्रियं लोके देवजुष्टामुदाराम्',
      rom: 'Chandraam prabhaasaam yashasaa jvalanteem shriyam loke devajushtaamudaaraam'
    ),
    (
      dev: 'तां पद्मिनीमीं शरणमहं प्रपद्येऽलक्ष्मीर्मे नश्यतां त्वां वृणे',
      rom: 'Taam padmineemeem sharanamham prapadye alakshmeerme nashyataam tvaam vrune'
    ),
    // Mantra 6
    (
      dev: 'आदित्यवर्णे तपसोऽधिजातो वनस्पतिस्तव वृक्षोऽथ बिल्वः',
      rom: 'Aadityavarne tapasoadhijaato vanaspatistava vrukshoatha bilvah'
    ),
    (
      dev: 'तस्य फलानि तपसा नुदन्तु मायान्तरायाश्च बाह्या अलक्ष्मीः',
      rom: 'Tasya phalaani tapasaa nudantu maayaantaraayaashcha baahyaa alakshmeeh'
    ),
    // Mantra 7
    (
      dev: 'उपैतु मां देवसखः कीर्तिश्च मणिना सह',
      rom: 'Upaitu maam devasakhah keertishcha maninaa saha'
    ),
    (
      dev: 'प्रादुर्भूतोऽस्मि राष्ट्रेऽस्मिन् कीर्तिमृद्धिं ददातु मे',
      rom: 'Praadurbhootosmi raashtreasmin keertimruddhim dadaatu me'
    ),
    // Mantra 8
    (
      dev: 'क्षुत्पिपासामलां ज्येष्ठामलक्ष्मीं नाशयाम्यहम्',
      rom: 'Kshutpipaasaamalaam jyeshthaamalakshmeem naashayaamyaham'
    ),
    (
      dev: 'अभूतिमसमृद्धिं च सर्वां निर्णुद मे गृहात्',
      rom: 'Abhootim asamruddhim cha sarvaam nirnuda me gruhaat'
    ),
    // Mantra 9
    (
      dev: 'गन्धद्वारां दुराधर्षां नित्यपुष्टां करीषिणीम्',
      rom: 'Gandhadvaaraam duraadharshaam nityapushtaam kareeshineem'
    ),
    (
      dev: 'ईश्वरीं सर्वभूतानां तामिहोपह्वये श्रियम्',
      rom: 'Eeshvareem sarvabhootaanaam taamihopahvaye shriyam'
    ),
    // Mantra 10
    (
      dev: 'मनसः काममाकूतिं वाचः सत्यमशीमहि',
      rom: 'Manasah kaamamaakootim vaachah satyamasheemahi'
    ),
    (
      dev: 'पशूनां रूपमन्नस्य मयि श्रीः श्रयतां यशः',
      rom: 'Pashoonaam roopam annasya mayi shreeh shrayataam yashah'
    ),
    // Mantra 11
    (
      dev: 'कर्दमेन प्रजाभूता मयि संभव कर्दम',
      rom: 'Kardamena prajaabhoota mayi sambhava kardama'
    ),
    (
      dev: 'श्रियं वासय मे कुले मातरं पद्ममालिनीम्',
      rom: 'Shriyam vaasaya me kule maataram padmamalineem'
    ),
    // Mantra 12
    (
      dev: 'आपः सृजन्तु स्निग्धानि चिक्लीत वस मे गृहे',
      rom: 'Aapah srujantu snigdhaani chikleeta vasa me gruhe'
    ),
    (
      dev: 'नि च देवीं मातरं श्रियं वासय मे कुले',
      rom: 'Ni cha deveem maataram shriyam vaasaya me kule'
    ),
    // Mantra 13
    (
      dev: 'आर्द्रां पुष्करिणीं पुष्टिं पिङ्गलां पद्ममालिनीम्',
      rom: 'Aardraam pushkarineem pushteem pingalaam padmamalineem'
    ),
    (
      dev: 'चन्द्रां हिरण्मयीं लक्ष्मीं जातवेदो म आवह',
      rom: 'Chandraam hiranmayeem lakshmeem jaatavedo ma aavaha'
    ),
    // Mantra 14
    (
      dev: 'आर्द्रां यः करिणीं यष्टिं सुवर्णां हेममालिनीम्',
      rom: 'Aardraam yah karineem yashtim suvarnaam hemamalineem'
    ),
    (
      dev: 'सूर्यां हिरण्मयीं लक्ष्मीं जातवेदो म आवह',
      rom: 'Sooryaam hiranmayeem lakshmeem jaatavedo ma aavaha'
    ),
    // Mantra 15
    (
      dev: 'तां म आवह जातवेदो लक्ष्मीमनपगामिनीम्',
      rom: 'Taam ma aavaha jaatavedo lakshmeemanapagaamineem'
    ),
    (
      dev: 'यस्यां हिरण्यं प्रभूतं गावो दास्योऽश्वान् विन्देयं पुरुषानहम्',
      rom: 'Yasyaam hiranyam prabhootam gaavo daasyoashvaan vindeyam purushaanaham'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 6. Vishnu Sahasranama — Opening Dhyana Shlokas + Stotram (first 20 verses)
// ──────────────────────────────────────────────────────────

final vishnuSahasranama = _buildVerse(
  id: 'vishnu_sahasranama',
  name: 'Vishnu Sahasranama',
  description: '1000 names of Lord Vishnu — Dhyana Shlokas and opening stotram',
  language: 'sa',
  linePairs: [
    // Dhyana Shloka 1
    (
      dev: 'शुक्लाम्बरधरं विष्णुं शशिवर्णं चतुर्भुजम्',
      rom: 'Shuklambaradharam Vishnum shashivarnam chaturbhujam'
    ),
    (
      dev: 'प्रसन्नवदनं ध्यायेत् सर्वविघ्नोपशान्तये',
      rom: 'Prasannavadanam dhyaayet sarvavighnopashaantaye'
    ),
    // Dhyana Shloka 2
    (
      dev: 'यस्य द्विरदवक्त्राद्याः पारिषद्याः परः शतम्',
      rom: 'Yasya dviradavaktraadyaah paarishadyaah parah shatam'
    ),
    (
      dev: 'विघ्नं निघ्नन्ति सततं विष्वक्सेनं तमाश्रये',
      rom: 'Vighnam nighnanti satatam Vishvaksenam tamaashraye'
    ),
    // Dhyana Shloka 3
    (
      dev: 'व्यासं वसिष्ठनप्तारं शक्तेः पौत्रमकल्मषम्',
      rom: 'Vyaasam Vasishtha naptaaram shakteh pautram akalmmasham'
    ),
    (
      dev: 'पराशरात्मजं वन्दे शुकतातं तपोनिधिम्',
      rom: 'Paraasharaatmajam vande Shukataatam taponidhim'
    ),
    // Dhyana Shloka 4
    (
      dev: 'व्यासाय विष्णुरूपाय व्यासरूपाय विष्णवे',
      rom: 'Vyaasaaya Vishnuroopaaya Vyaasaroopaaya Vishnave'
    ),
    (
      dev: 'नमो वै ब्रह्मनिधये वसिष्ठाय नमो नमः',
      rom: 'Namo vai Brahmanidhaye Vasishthaaya namo namah'
    ),
    // Stotram begins — Verse 1
    (
      dev: 'विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः',
      rom: 'Vishvam Vishnur Vashatkaro Bhootabhavyabhavatprabhuh'
    ),
    (
      dev: 'भूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः',
      rom: 'Bhootakrudbhootabhrudbhaavo Bhootatmaa Bhootabhaavanah'
    ),
    // Verse 2
    (
      dev: 'पूतात्मा परमात्मा च मुक्तानां परमा गतिः',
      rom: 'Pootatmaa paramatmaa cha muktaanaam paramaa gatih'
    ),
    (
      dev: 'अव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च',
      rom: 'Avyayah Purushah Saakshee Kshetragnokshara eva cha'
    ),
    // Verse 3
    (
      dev: 'योगो योगविदां नेता प्रधानपुरुषेश्वरः',
      rom: 'Yogo yogavidaam netaa pradhaana purusheshvarah'
    ),
    (
      dev: 'नारसिंहवपुः श्रीमान् केशवः पुरुषोत्तमः',
      rom: 'Naarasimhavapuh Shreemaan Keshavah Purushottamah'
    ),
    // Verse 4
    (
      dev: 'सर्वः शर्वः शिवः स्थाणुर्भूतादिर्निधिरव्ययः',
      rom: 'Sarvah Sharvah Shivah Sthaanur Bhootaadir Nidhir Avyayah'
    ),
    (
      dev: 'सम्भवो भावनो भर्ता प्रभवः प्रभुरीश्वरः',
      rom: 'Sambhavo Bhaavano Bhartaa Prabhavah Prabhur Eeshvarah'
    ),
    // Verse 5
    (
      dev: 'स्वयम्भूः शम्भुरादित्यः पुष्कराक्षो महास्वनः',
      rom: 'Svayambhooh Shambhur Aadityah Pushkaraaksho Mahaasvanah'
    ),
    (
      dev: 'अनादिनिधनो धाता विधाता धातुरुत्तमः',
      rom: 'Anaadinidhano Dhaataa Vidhaataa Dhaaturuttamah'
    ),
    // Verse 6
    (
      dev: 'अप्रमेयो हृषीकेशः पद्मनाभोऽमरप्रभुः',
      rom: 'Aprameeyo Hrusheekeshah Padmanaabhomaraprabhuh'
    ),
    (
      dev: 'विश्वकर्मा मनुस्त्वष्टा स्थविष्ठः स्थविरो ध्रुवः',
      rom: 'Vishvakarmaa Manustvashthaa Sthavishthah Sthaviro Dhruvah'
    ),
    // Verse 7
    (
      dev: 'अग्राह्यः शाश्वतो कृष्णो लोहिताक्षः प्रतर्दनः',
      rom: 'Agraahyah Shaashvato Krishno Lohitaakshah Pratardanah'
    ),
    (
      dev: 'प्रभूतस्त्रिककुब्धाम पवित्रं मङ्गलं परम्',
      rom: 'Prabhootastrikakubdhaama Pavitram Mangalam Param'
    ),
    // Verse 8
    (
      dev: 'ईशानः प्राणदः प्राणो ज्येष्ठः श्रेष्ठः प्रजापतिः',
      rom: 'Eeshaanah Praanadah Praano Jyeshthah Shreshthah Prajaapatih'
    ),
    (
      dev: 'हिरण्यगर्भो भूगर्भो माधवो मधुसूदनः',
      rom: 'Hiranyagarbho Bhoogarbho Maadhavo Madhusoodanah'
    ),
    // Verse 9
    (
      dev: 'ईश्वरो विक्रमी धन्वी मेधावी विक्रमः क्रमः',
      rom: 'Eeshvaro Vikramee Dhanvee Medhaavee Vikramah Kramah'
    ),
    (
      dev: 'अनुत्तमो दुराधर्षः कृतज्ञः कृतिरात्मवान्',
      rom: 'Anuttamo Duraadharshah Krutagnyah Krutir Aatmavaan'
    ),
    // Verse 10
    (
      dev: 'सुरेशः शरणं शर्म विश्वरेताः प्रजाभवः',
      rom: 'Sureshah Sharanam Sharma Vishvaretaah Prajaabhavah'
    ),
    (
      dev: 'अहः संवत्सरो व्यालः प्रत्ययः सर्वदर्शनः',
      rom: 'Ahah Samvatsaro Vyaalah Pratyayah Sarvadarashanah'
    ),
  ],
);

// ──────────────────────────────────────────────────────────
// 7. Lalitha Sahasranama — Dhyana Shlokas + Opening Stotram (first 20 verses)
// ──────────────────────────────────────────────────────────

final lalithaSahasranama = _buildVerse(
  id: 'lalitha_sahasranama',
  name: 'Lalitha Sahasranama',
  description: '1000 names of Goddess Lalitha Tripurasundari',
  language: 'sa',
  linePairs: [
    // Dhyana Shloka 1
    (
      dev: 'सिन्दूरारुणविग्रहां त्रिनयनां माणिक्यमौलिस्फुरत्',
      rom: 'Sindoorarunavigraahaam trinayanaam maanikyamaulisphurat'
    ),
    (
      dev: 'तारानायकशेखरां स्मितमुखीमापीनवक्षोरुहाम्',
      rom: 'Taaraanaayakashekharaam smitamukheem aapeenavakshoruhaam'
    ),
    (
      dev: 'पाणिभ्यामलिपूर्णरत्नचषकं रक्तोत्पलं बिभ्रतीम्',
      rom: 'Paanibhyaamalipoornaratnachashakam raktotpalam bibhrateem'
    ),
    (
      dev: 'सौम्यां रत्नघटस्थरक्तचरणां ध्यायेत्परामम्बिकाम्',
      rom: 'Saumyaam ratnaghatastharak tacharanaam dhyaayet paraamambikaam'
    ),
    // Dhyana Shloka 2
    (
      dev: 'अरुणां करुणातरङ्गिताक्षीं धृतपाशाङ्कुशपुष्पबाणचापाम्',
      rom: 'Arunaam karunaatarangitaaksheem dhrutapaashaankushapushpabaanachaapaam'
    ),
    (
      dev: 'अणिमादिभिरावृतां मयूखैरहमित्येव विभावये भवानीम्',
      rom: 'Animaadibhiraavrutaam mayookhair ahamityeva vibhaavaye Bhavaaneem'
    ),
    // Stotram begins — Verse 1
    (
      dev: 'श्रीमाता श्रीमहाराज्ञी श्रीमत्सिंहासनेश्वरी',
      rom: 'Shreemaataa Shreemahaaraajnee Shreematsimhaasaneshvaree'
    ),
    (
      dev: 'चिदग्निकुण्डसम्भूता देवकार्यसमुद्यता',
      rom: 'Chidagnikundasambhootaa Devakaaryasamudyata'
    ),
    // Verse 2
    (
      dev: 'उद्यद्भानुसहस्राभा चतुर्बाहुसमन्विता',
      rom: 'Udyadbhaanusahasraabhaa Chaturbaahusamanvitaa'
    ),
    (
      dev: 'रागस्वरूपपाशाढ्या क्रोधाकाराङ्कुशोज्ज्वला',
      rom: 'Raagasvaroopapaaashaaddhyaa Krodhaakaraankushojjvalaa'
    ),
    // Verse 3
    (
      dev: 'मनोरूपेक्षुकोदण्डा पञ्चतन्मात्रसायका',
      rom: 'Manoroopekshukodandaa Panchatanmaatrasaayakaa'
    ),
    (
      dev: 'निजारुणप्रभापूरमज्जद्ब्रह्माण्डमण्डला',
      rom: 'Nijaarunaprabhaapooramajjad Brahmaandamandala'
    ),
    // Verse 4
    (
      dev: 'चम्पकाशोकपुन्नागसौगन्धिकलसत्कचा',
      rom: 'Champakaashoka Punnaaga Saugandhika Lasatkachaa'
    ),
    (
      dev: 'कुरुविन्दमणिश्रेणीकनत्कोटीरमण्डिता',
      rom: 'Kuruvindamanishrenikana Tkoteera Mandita'
    ),
    // Verse 5
    (
      dev: 'अष्टमीचन्द्रविभ्राजदलिकस्थलशोभिता',
      rom: 'Ashtameechandra Vibhraajad Alikasthala Shobhitaa'
    ),
    (
      dev: 'मुखचन्द्रकलङ्काभमृगनाभिविशेषका',
      rom: 'Muchachandra Kalankaabha Mruganabhi Visheshakaa'
    ),
    // Verse 6
    (
      dev: 'वदनस्मरमाङ्गल्यगृहतोरणचिल्लिका',
      rom: 'Vadanasmara Maangalya Gruha Torana Chillikaa'
    ),
    (
      dev: 'वक्त्रलक्ष्मीपरीवाहचलन्मीनाभलोचना',
      rom: 'Vaktralakshmee Pareevaaha Chalan Meenaabha Lochanaa'
    ),
    // Verse 7
    (
      dev: 'नवचम्पकपुष्पाभनासादण्डविराजिता',
      rom: 'Navachampaka Pushpaabha Naasaadanda Viraajitaa'
    ),
    (
      dev: 'ताराकान्तितिरस्कारिनासाभरणभासुरा',
      rom: 'Taaraakaanti Tiraskari Naasaabharana Bhaasuraa'
    ),
    // Verse 8
    (
      dev: 'कदम्बमञ्जरीक्लृप्तकर्णपूरमनोहरा',
      rom: 'Kadambamanjari Klrupta Karna Poora Manoharaa'
    ),
    (
      dev: 'ताटङ्कयुगलीभूततपनोडुपमण्डला',
      rom: 'Taatanka Yugaleebhoota Tapanodupa Mandala'
    ),
    // Verse 9
    (
      dev: 'पद्मरागशिलादर्शपरिभाविकपोलभूः',
      rom: 'Padmaraaga Shilaadarshaparibhaavi Kapolabhuh'
    ),
    (
      dev: 'नवविद्रुमबिम्बश्रीन्यक्कारिरदनच्छदा',
      rom: 'Navavidruma Bimbashree Nyakkaariradanachchadaa'
    ),
    // Verse 10
    (
      dev: 'शुद्धविद्याङ्कुराकारद्विजपङ्क्तिद्वयोज्ज्वला',
      rom: 'Shuddhavidyaankuraakaaradvijaanktidvayojjvalaa'
    ),
    (
      dev: 'कर्पूरवीटिकामोदसमाकर्षद्दिगन्तरा',
      rom: 'Karpooraveetikaamodasamaakarshaddigantaraa'
    ),
  ],
);
