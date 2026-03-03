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
      hanumanChalisa,
      gayatriMantra,
      mahamrityunjaya,
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
