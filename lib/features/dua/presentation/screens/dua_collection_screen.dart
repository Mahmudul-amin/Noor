import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DuaCollectionScreen extends StatefulWidget {
  const DuaCollectionScreen({super.key});

  @override
  State<DuaCollectionScreen> createState() => _DuaCollectionScreenState();
}

class _DuaCollectionScreenState extends State<DuaCollectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _bookmarks = {'Morning Dua', 'Forgiveness Dua'};
  final Set<String> _expanded = {};
  String _activeCategory = 'Morning Dua';
  String _query = '';
  bool _isSearchFocused = false;

  static const List<_DuaCategory> _categories = [
    _DuaCategory('Morning Dua', Icons.wb_twilight_rounded),
    _DuaCategory('Evening Dua', Icons.nights_stay_rounded),
    _DuaCategory('Sleeping Dua', Icons.bedtime_rounded),
    _DuaCategory('Waking Up Dua', Icons.wb_sunny_rounded),
    _DuaCategory('Travel Dua', Icons.flight_takeoff_rounded),
    _DuaCategory('Eating Dua', Icons.restaurant_rounded),
    _DuaCategory('Prayer Dua', Icons.mosque_rounded),
    _DuaCategory('Forgiveness Dua', Icons.favorite_border_rounded),
    _DuaCategory('Protection Dua', Icons.shield_outlined),
    _DuaCategory('Anxiety Dua', Icons.spa_rounded),
    _DuaCategory('Parents Dua', Icons.diversity_1_rounded),
    _DuaCategory('Rizq Dua', Icons.auto_awesome_rounded),
    _DuaCategory('Ramadan Dua', Icons.dark_mode_rounded),
    _DuaCategory('Knowledge Dua', Icons.school_rounded),
    _DuaCategory('Guidance Dua', Icons.explore_rounded),
    _DuaCategory('Gratitude Dua', Icons.volunteer_activism_rounded),
    _DuaCategory('Patience Dua', Icons.self_improvement_rounded),
    _DuaCategory('Health Dua', Icons.health_and_safety_rounded),
    _DuaCategory('Illness Dua', Icons.healing_rounded),
    _DuaCategory('Rain Dua', Icons.water_drop_rounded),
    _DuaCategory('Marriage Dua', Icons.favorite_rounded),
    _DuaCategory('Children Dua', Icons.child_care_rounded),
    _DuaCategory('Hajj & Umrah Dua', Icons.account_balance_rounded),
    _DuaCategory('Istikhara Dua', Icons.lightbulb_outline_rounded),
    _DuaCategory('Death Dua', Icons.nights_stay_outlined),
  ];

  static const List<_DuaItem> _duas = [
    _DuaItem(
      title: 'Morning Azkar 1',
      subtitle: 'Surah Al-Fatihah',
      category: 'Morning Dua',
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      transliteration:
          '1:1 Bismillaahir rahmaa-nir raheem.\n\n1:2 Alhamdu lillaahi rabbil aa\'lameen.\n1:3 Ar-rahmaa-nir-raheem.\n1:4 Maaliki yawmid-deen.\n1:5 Iyyaaka na\'budu wa iyyaaka nasta\'een.\n1:6 Ihdinas siraa\'tal mustaqeem.\n1:7 Siraatal-lazeena an\'amta \'alaihim ghayril maghdoo bi\'alaihim wa lad-daalleen.',
      translation:
          'In the name of Allah, the Most Merciful. All praise is for Allah, Lord of all worlds. You alone we worship and You alone we ask for help. Guide us to the straight path.',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 2',
      subtitle: 'Ayatul Kursi',
      category: 'Morning Dua',
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n\n255: Allahu laa ilaaha illaa Huwa, Al-Hayyul-Qayyoom;\nLaa ta\'khuzuhoo sinatun wa laa nawm;\nLahoo maa fis-samaawaati wa maa fil ard;\nMan zal-lazee yashfa\'u indahoo illaa bi iznih;\nYa\'lamu maa baina aydeehim wa maa khalfahum;\nWa laa yuheetoona bi shai-im min ilmihi illaa bimaa shaa;\nWasi\'a kursiyyuhus samaawaati wal ard;\nWa laa ya\'ooduhu hifzuhumaa wa Huwal Aliyyul Azeem.',
      translation:
          'Allah, there is no deity except Him, the Ever-Living, the Sustainer. Neither drowsiness nor sleep overtakes Him. To Him belongs all that is in the heavens and earth.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Morning Azkar 3',
      subtitle: 'Surah Al-Ikhlas',
      category: 'Morning Dua',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n\n112:1 Qul Huwallaahu Ahad.\n112:2 Allahus-Samad.\n112:3 Lam yalid wa lam yoolad.\n112:4 Wa lam yakun lahu kufuwan ahad.',
      translation:
          'Say: He is Allah, One. Allah, the Eternal Refuge. He neither begets nor is born, and there is none comparable to Him.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 4',
      subtitle: 'Surah Al-Falaq',
      category: 'Morning Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِن شَرِّ مَا خَلَقَ\nوَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\nوَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n\n113:1 Qul a\'oozu bi Rabbil-falaq.\n113:2 Min sharri maa khalaq.\n113:3 Wa min sharri ghaasiqin izaa waqab.\n113:4 Wa min sharrin-naffaasaati fil uqad.\n113:5 Wa min sharri haasidin izaa hasad.',
      translation:
          'Say: I seek refuge in the Lord of daybreak from the evil of what He created, from darkness when it settles, from those who blow on knots, and from the envier when he envies.',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 5',
      subtitle: 'Surah An-Nas',
      category: 'Morning Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ\nمِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\nالَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\nمِنَ الْجِنَّةِ وَالنَّاسِ',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n\n114:1 Qul a\'oozu bi Rabbin-naas.\n114:2 Malikin-naas.\n114:3 Ilaahin-naas.\n114:4 Min sharril waswaasil khannaas.\n114:5 Allazee yuwaswisu fee sudoorin-naas.\n114:6 Minal jinnati wan-naas.',
      translation:
          'Say: I seek refuge in the Lord of mankind, the King of mankind, the God of mankind, from the evil of the retreating whisperer who whispers into hearts.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 6',
      subtitle: 'Sayyidul Istighfar',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Allahumma Anta Rabbi laa ilaaha illaa Anta;\nKhalaqtani wa ana abduka;\nWa ana alaa ahdika wa wa\'dika mastata\'t;\nA\'oozu bika min sharri maa sana\'t;\nAboo\'u laka bini\'matika alayya;\nWa aboo\'u bizanbee;\nFaghfir lee fa innahu laa yaghfiruz-zunooba illaa Anta.',
      translation:
          'O Allah, You are my Lord. None has the right to be worshiped except You. You created me and I am Your servant, holding to Your covenant as much as I can.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 7',
      subtitle: 'Allah is Sufficient',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Hasbiyallahu la ilaha illa Huwa, `alayhi tawakkaltu, wa Huwa Rabbul-`Arshil-`Azim.',
      translation:
          'Allah is sufficient for me. None has the right to be worshiped except Him. Upon Him I rely, and He is the Lord of the mighty Throne.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 8',
      subtitle: 'Seeking wellbeing',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Allahumma innee as-alukal afwa wal-aafiyah;\nFid-dunya wal-aakhirah;\nAllahumma innee as-alukal afwa wal-aafiyah;\nFee deenee wa dunyaaya;\nWa ahlee wa maalee;\nAllahummas-tur awraatee;\nWa aamin raw-aatee;\nWahfaznee min bayni yadayya;\nWa min khalfee;\nWa an yameenee;\nWa an shimaalee;\nWa min fawqee;\nWa a\'oozu bi azamatika an ughtaala min tahtee.',
      translation:
          'O Allah, I ask You for wellbeing in this world and in the Hereafter.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 9',
      subtitle: 'Blessings and covering',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Allahumma inni asbahtu minka fee ni\'matin;\nWa aafiyatin;\nWa sitr;\nFa atimma alayya ni\'matak;\nWa aafiyatak;\nWa sitraka fid-dunya wal-aakhirah.',
      translation:
          'O Allah, I have entered the morning in Your blessing, wellbeing, and covering, so complete Your blessing, wellbeing, and covering upon me.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 10',
      subtitle: 'Protection from harm',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Bismillahil-ladhi la yadurru ma`a ismihi shay\'un fil-ardi wa la fis-sama\', wa Huwas-Sami`ul-`Alim.',
      translation:
          'In the name of Allah, with whose name nothing in the earth or heaven can cause harm, and He is the All-Hearing, All-Knowing.',
      icon: Icons.shield_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 11',
      subtitle: 'Contentment with Allah',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Radeetu billahi Rabbah;\nWa bil-Islami deenah;\nWa bi Muhammadin sallallahu alayhi wa sallama nabiyya wa rasoolah.',
      translation:
          'I am pleased with Allah as Lord, with Islam as religion, and with Muhammad ﷺ as Prophet.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 12',
      subtitle: 'Glorifying Allah',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'SubhanAllahi wa bihamdih;\nAdada khalqih;\nWa rida nafsih;\nWa zinata arshih;\nWa midaada kalimatih.',
      translation: 'Glory is to Allah and praise is to Him.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 13',
      subtitle: 'Morning sovereignty',
      category: 'Morning Dua',
      arabic:
          '??????????? ?????????? ????????? ??????? ??????????? ??????? ??? ??????? ?????? ??????? ???????? ??? ??????? ????',
      transliteration:
          'Asbahna wa-asbahal mulku lillah;\nWal-hamdu lillah;\nLa ilaha illal-lah;\nWah-da�hoo la-sharee kalah;\nLahul-mulku wa�lahul-hamd;\nYuh-ee wa yu�meeto wa�huwa ala kulli shayin qadeer;\nRabbi ass-aaluka khay�ra mafee haa-zaal yaw�m;\nWa-khayra ma ba�daha;\nWa-aa�ozu-bika min sharri ma fee haa-zaal yaw�m;\nWa sharri ma ba�daha;\nRabbi aa�ozu-bika minal-kasali, wa-soo-il kibar;\nRabbi aa�ozubika min aa�zaa-bin fin�nari wa aa�zaa-bin fil�qabr.',
      translation:
          'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshiped except Allah, alone, without partner. My Lord, I ask You for the good of this day and what follows it, and I seek refuge in You from its evil and what follows it. My Lord, I seek refuge in You from laziness, senility, torment in the Fire, and punishment in the grave.',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 14',
      subtitle: 'Fitrah of Islam',
      category: 'Morning Dua',
      arabic:
          '??????????? ?????? ???????? ???????????? ???????? ???????? ???????????? ???????? ????? ?????????? ????????? ?',
      transliteration:
          'Asbahna ala fitratil-islam;\nWa�ala kalimatil-ikhlas;\nWa�ala deeni nabi�yyina Muhammadin sallalla-hu alai�hi wasallam;\nWa�ala millati abeena Ibrahima hanee�faan muslimah;\nWaama kana minal-mushrikeen.',
      translation:
          'We have risen in the morning upon the fitrah of Islam, the word of pure faith, the religion of our Prophet Muhammad ?, and the religion of our forefather Ibrahim, who was a Muslim of true faith and was not among those who associate partners with Allah.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 15',
      subtitle: 'By You we reached morning',
      category: 'Morning Dua',
      arabic:
          '?????????? ???? ??????????? ?????? ??????????? ?????? ??????? ?????? ??????? ?????????? ??????????',
      transliteration:
          'Allahumma bika asbahna;\nWa�bika amsaina;\nWa�bika nahya;\nWa�bika namooth;\nWa�ilay�kaal nushoor.',
      translation:
          'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening; by Your leave we live and die, and unto You is our return.',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 16',
      subtitle: 'Blessing and concealment',
      category: 'Morning Dua',
      arabic:
          '?????????? ?????? ?????????? ?????? ??? ???????? ??????????? ???????? ????????? ??????? ?????????? ????????????? ??????????',
      transliteration:
          'Allahumma inni asbahtu minka fee-ni�matee�ou wa�aa fee-yatee�ou wa sitr;\nFa aa�timma alayya ni�matak;\nWa�aa fee�yatak;\nWa sit�raka fid-dunya wal akhira.',
      translation:
          'O Allah, I have reached the morning with blessings, strength, and concealment of my shortcomings from You. So complete Your blessings, strength, and concealment for me in this life and the Hereafter.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 17',
      subtitle: 'All blessings are from Allah',
      category: 'Morning Dua',
      arabic:
          '?????????? ??? ???????? ??? ???? ???????? ???? ???????? ???? ???????? ???????? ???????? ??? ??????? ???? ?????? ????????? ?????? ?????????',
      transliteration:
          'Allahumma ma asbahah bee�min nia�mah;\nAw�bee a�haa-deem min khal�qik;\nFa�minka wah-dhaka la-sharee kalak;\nFa-lakal hamdu wa-lakash shukr.',
      translation:
          'O Allah, whatever blessing I or any of Your creation have risen upon is from You alone, without partner, so for You is all praise and thanks.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 18',
      subtitle: 'Praise befitting Allah',
      category: 'Morning Dua',
      arabic:
          '??? ????? ???? ????????? ????? ????????? ????????? ???????? ????????? ???????????',
      transliteration:
          'Ya Rabbi lakal hamdu kama yam-baghi�li jalali waj�hika wa�azimi sultanik.',
      translation:
          'O my Lord, all praise belongs to You as befits the majesty of Your Face and the greatness of Your authority.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 19',
      subtitle: 'Contentment with faith',
      category: 'Morning Dua',
      arabic:
          '??????? ????????? ?????? ???????????????? ?????? ????????????? ? ???????? ??????????',
      transliteration:
          'Radeetu billahi Rabbah;\nWa�bil-islami dee�nah;\nWa�bee Muhammadin sal-lallahu alai�hi wa�sallama nabiy�ya wa rasulaah.',
      translation:
          'I have accepted Allah as my Lord, Islam as my way of life, and Muhammad ? as Allah�s Prophet and Messenger.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 20',
      subtitle: 'Pardon and wellbeing',
      category: 'Morning Dua',
      arabic:
          '?????????? ?????? ?????????? ????????? ?????????????? ??? ?????????? ????????????',
      transliteration:
          'Allahumma innee as-aalukal aaf�wa wal-aa�fiyah;\nFid-dunya wal-akhirah;\nAllahumma innee as�alukal aa�fwa wal-aa�fiyah;\nFee dee�nee wa�dunya-ya;\nWa�ahlee wama-lee;\nAllah hummas-tur aaw-ra�tee;\nWa aa�mir raw-aa�tee;\nWah fiz�nee min bai�nee ya-dai�yaa;\nWa-min khal�fee;\nWa�aai ya�mee-nee;\nWa�aai shee�malee,\nWa-min faw�qee;\nWa�aa-oozubi aa�zaa-matika aan oogh-tala min tahtee.',
      translation:
          'O Allah, I ask You for pardon and wellbeing in this life and the next, in my religion, worldly affairs, family, and wealth. Veil my weaknesses, set at ease my dismay, preserve me from every direction, and I seek refuge in Your greatness lest I be swallowed from beneath.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 21',
      subtitle: 'Perfect praise',
      category: 'Morning Dua',
      arabic:
          '????????? ??????? ???????????? ?????? ???????? ??????? ???????? ???????? ???????? ????????? ???????????',
      transliteration:
          'SubhanAllahi wa-bihamdih;\nAa�dada khal�qi;\nWa�rida nafsih;\nWa�zinata aa�rshih;\nWa�midada kalimatih.',
      translation:
          'How perfect Allah is, and I praise Him by the number of His creation, His pleasure, the weight of His Throne, and the ink of His words.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 22',
      subtitle: 'Nothing can harm',
      category: 'Morning Dua',
      arabic:
          '?????? ??????? ??????? ??? ??????? ???? ??????? ?????? ??? ????????? ????? ??? ?????????? ?????? ?????????? ??????????',
      transliteration:
          'Bismillah hil�lazee la yadur�oo ma�aas-mihi shai-oon fil-ardi wa�laa fis-samaa;\nWa�hu�waas samee�ool aa�leem.',
      translation:
          'In the name of Allah, with whose name nothing is harmed on earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
      icon: Icons.shield_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 23',
      subtitle: 'Protection from shirk',
      category: 'Morning Dua',
      arabic:
          '?????????? ?????? ??????? ???? ???? ???????? ???? ??????? ?????????? ???????????????? ????? ??? ????????',
      transliteration:
          'Allahumma inni a�oozu-bika min aan ush�rika bika shai�an aa�lam;\nWa aas�tagfiruka le ma la a�alam.',
      translation:
          'O Allah, I take refuge in You lest I knowingly associate anything with You, and I seek Your forgiveness for what I do unknowingly.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Morning Azkar 24',
      subtitle: 'Perfect words of Allah',
      category: 'Morning Dua',
      arabic:
          '??????? ??????????? ??????? ???????????? ???? ????? ??? ??????',
      transliteration:
          'Aa�oozu-bi kalima-tillah heet-taam�mati min sharri ma khalaq.',
      translation:
          'I seek protection in the perfect words of Allah from every evil that He has created.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Morning Azkar 25',
      subtitle: 'Knower of unseen',
      category: 'Morning Dua',
      arabic:
          '?????????? ??????? ????????? ?????????????? ??????? ????????????? ??????????? ????? ????? ?????? ???????????',
      transliteration:
          'Allahumma aa�limal-ghaybi wash-shahadah;\nFati�ras samawati wal�ard;\nRabba kulli shay�in wa�ma leekah;\nAsh�hadu al�laa ilaha illa anth;\nAa�ozu-bika min shar�ri nafsee;\nWa�min shar�rish shay�tani wa-shirki;\nWa�an aq-tarifa ala nafsee soo�an aw aa�joor-rahoo ila Muslim.',
      translation:
          'O Allah, Knower of the unseen and seen, Creator of the heavens and earth, Lord and Sovereign of all things, I bear witness that none has the right to be worshipped except You. I seek refuge in You from the evil of my soul, the devil and his shirk, and from committing wrong against myself or another Muslim.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 26',
      subtitle: 'Rectify my affairs',
      category: 'Morning Dua',
      arabic:
          '??? ????? ??? ???????? ???????????? ??????????? ???????? ??? ??????? ??????? ????? ????????? ?????? ??????? ???????? ??????',
      transliteration:
          'Ya hayyu ya qay�yum;\nBi-rah�matika asta�gis;\nAs�lih li sha�ni kullah;\nWa�la takil�ni ila nafsi tarfata ayn.',
      translation:
          'O Ever-Living, O Sustainer, by Your mercy I seek assistance. Rectify all of my affairs and do not leave me to myself, even for the blink of an eye.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 27',
      subtitle: 'Sayyidul Istighfar',
      category: 'Morning Dua',
      arabic:
          '?????????? ?????? ?????? ??? ??????? ?????? ?????? ??????????? ??????? ????????',
      transliteration:
          'Allahumma anta rab�bee la ilaha illa anta Khalaq-tanee;\nWa�ana aab�duk;\nWa�ana ala aah�dika wa-wa�dika mas�ta-taat;\nAa�ozu-bika min sharri ma�sanath;\nAa�boo�u laka bini�matika aalai�yaa;\nWa�aboo�u bi-zan�bee;\nFagh�fir lee;\nFa-inna�hu la yagh�firuz zunu�ba illa ant.',
      translation:
          'O Allah, You are my Lord. None has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have committed. I acknowledge Your favour upon me and my sin, so forgive me, for none forgives sins except You.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 28',
      subtitle: 'Witness of Tawheed',
      category: 'Morning Dua',
      arabic:
          '?????????? ?????? ?????????? ?????????? ?????????? ???????? ???????? ??????????????? ????????? ???????? ??????? ?????? ???????',
      transliteration:
          'Allahumma innee asbah�at;\nOsh�hiduka wa-oshhidu hamalata aar�shik;\nWa�malaa ika�tak;\nWa-jamee�aa khalqik;\nAnn�naka antal-lahu;\nLa ilaha illa ant;\nWah�daka laa sharee kalak;\nWa�anna Muhammadan aabdu�ka wa�rasooluk.',
      translation:
          'O Allah, I have reached the morning and call You, the bearers of Your Throne, Your angels, and all Your creation to witness that You are Allah. None has the right to be worshipped except You alone, without partner, and Muhammad ? is Your servant and Messenger.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 29',
      subtitle: 'Health in body and senses',
      category: 'Morning Dua',
      arabic:
          '?????????? ???????? ??? ??????? ?????????? ???????? ??? ??????? ?????????? ???????? ??? ??????? ??? ??????? ?????? ??????',
      transliteration:
          'Allahumma aa�fi-nee fee bada�nee;\nAllahumma aa�fi-nee fee sam�ee;\nAllahumma aa�fi-nee fee basa�ree;\nLa ilaha illa-ant;\nAllahumma innee aa�oozu-bika minal-kufri wal-faqr;\nWa�aa�oo-zu-bika min aa�zaa-bil-qabr;\nLa ilaha illa-ant.',
      translation:
          'O Allah, grant health to my body, my hearing, and my sight. None has the right to be worshipped except You. O Allah, I seek refuge in You from disbelief and poverty, and from the punishment of the grave.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 30',
      subtitle: 'Allah is sufficient',
      category: 'Morning Dua',
      arabic:
          '???????? ??????? ??? ??????? ?????? ???? ???????? ??????????? ?????? ????? ????????? ??????????',
      transliteration:
          'Hasbi-yallahu la ilaha illa huwa aa�layhi tawak-kalth;\nWa�huwa rabbul aar�shil aa�zeem.',
      translation:
          'Allah is sufficient for me. None has the right to be worshipped except Him. Upon Him I rely, and He is Lord of the exalted Throne.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 31',
      subtitle: 'Good of this day',
      category: 'Morning Dua',
      arabic:
          '??????????? ?????????? ????????? ??????? ????? ????????????? ?????????? ?????? ?????????? ?????? ?????? ?????????',
      transliteration:
          'Asbahna wa-asbahal mulku lillahi, rabbil aa�la-meen;\nAllahumma innee as-aluka khayra ha�zal-yawm;\nFath�hahoo wa nas�rahoo;\nWa noo�-rahoo, wa baraka�tahoo, wa hudah;\nWa aa�oozu-bika min shar-ri�ma feeh;\nWa shar-ri�ma baa�dah.',
      translation:
          'We have reached the morning and all sovereignty belongs to Allah, Lord of the worlds. O Allah, I ask You for the good of this day: its triumphs, victories, light, blessings, and guidance, and I seek refuge in You from its evil and the evil that follows it.',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Morning Azkar 32',
      subtitle: 'Tawheed and Tasbih',
      category: 'Morning Dua',
      arabic: '',
      transliteration:
          'Laa ilaaha illallaahu wahdahu laa sha’ree kalah;\nLahul-mulku wa lahul-hamd;\nWa’huwa aa’laa kulli shay’in qadeer.\n\nSubhanAllahi wa bi’hamdihi;\nSubhanAllah-hil aa’zim.',
      translation:
          'None has the right to be worshipped except Allah alone, without partner. To Him belongs all sovereignty and praise, and He is over all things omnipotent. Glory is to Allah and praise is to Him; glorified is Allah the Great.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 1',
      subtitle: 'Surah Al-Fatihah',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          '1:1 Bismillaahir rahmaa-nir raheem.\n\n1:2 Alhamdu lillaahi rabbil aa�lameen.\n1:3 Ar-rahmaa-nir-raheem.\n1:4 Maaliki yawmid-deen.\n1:5 Iyyaaka na�budu wa lyyaaka nasta�een.\n1:6 Ihdinas siraa�tal mustaqeem.\n1:7 Siraatal-lazeena an�amta �alaihim ghayril maghdoo bi�alai�him wa lad-daalleen.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 2',
      subtitle: 'Al-Baqarah 1-5',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n2:1 Alif Laam Meem.\n2:2 Zaalikal kitaabu-laa raiba feehi hudal-lil muttaqeen.\n2:3 Allazeena yu�minoona bilghaibi wa yu�qee-moonas salata wa mim�maa razaqna�hum yun�fiqoon.\n2:4 Wal�lazeena yu�minoona bimaa un�zila ilaika wa-maa unzila min qablika wa bil aa�khirati hum yu�qinoon.\n2:5 Ulaa�ika aa�laa hudam-mir rabbihim; wa ulaa�ika humul muflihoon.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 3',
      subtitle: 'Ayatul Kursi',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n255: Allahu laa ilaaha illaa�hu wal haiyul qai-yoom;\nLaa taa�khuzuhoo sinatu�oo walaa na�woom;\nLahoo maa fis�samaawaati wa-maa fil ard;\nMan zal�lazee yashfa�oo in�dahoo illa be iznih;\nYa�lamu maa baina ai�deehim wa�maa khal-fahum;\nWa�laa yuhee�toona bee�shai-im�min il�mihee illa be-maa shaa;\nWasi�aa kursi�yuhus samaa-waati wal arda;\nWa�laa yaoo�duhoo hif�zuhumaa wa huwal ali�yyul azeem.',
      translation: '',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Evening Azkar 4',
      subtitle: 'Al-Baqarah 256',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          '2:256 Laa ik�raaha fid-deen;\nQat-tabiya�nar rushdu minal ghayy;\nFamai �yakfur bit taa�ghooti wa yu�mim billaahi faqadis tamsaka bil�urwatil wusqaa lan-fisaama lahaa;\nWallaahu samee�un aleem.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 5',
      subtitle: 'Al-Baqarah 257',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          '2:257 Allaahu waliyyul lazeena aa�manoo yukh�rijuhum minaz-zulumaati ilan noor;\nWal�lazeena kafaroo awliyaa uo�humut taa�ghootu yukh�rijoo-nahum minan noori ilaz-zulumaat;\nUlaa�ika as�haabun naari hum fee�haa khaa�lidoon.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 6',
      subtitle: 'Al-Baqarah 284',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n2:284 Lillaahi maa fis-samaawaati wa-maa fil ard;\nWa in�tubdoo maa feee an�fusikum aw tukh-foohu yuhaa-sibkum bihil-laa;\nFayagh�firuli maiya-shaa�u wa yu�azzibu maiya-shaa;\nWallaahu aa�laa kulli shai in qadeer.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 7',
      subtitle: 'Al-Baqarah 285',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          '2:285 Aa�manar-rasoolu bimaa un�zila ilaihi mir-Rabbihee walmu�minoon;\nKul�lun aa�mana billaahi wa malaa�ikathihee wa kutubhihee wa rusulihee;\nLaa nufar�riqu baina ahadim-mir-rusulih;\nWa qaaloo sami�naa wa aata�naa;\nGhufra-naka rabbana wa ilaikal maser.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 8',
      subtitle: 'Al-Baqarah 286',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          '2:286 Laa yukalliful-laahu nafsan illaa wus�ahaa;\nLahaa maa kasabat wa aa�laihaa mak-tasabat;\nRabbana laa tu�aakhiznaa in�naa-seenaa aw-akhtaa�naa;\nRabbana wa laa tahmil-alainaa isran kamaa hamaltahoo alal-lazeena min qablinaa;\nRabbana wa laa tuham-milnaa maa laa taa�qata lanaa bih;\nWa�fu annaa waghfir lanaa war�hamnaa;\nAnta mawlana fansur-naa alal qawmil kaafireen.',
      translation: '',
      icon: Icons.menu_book_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 9',
      subtitle: 'Surah Al-Ikhlas',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n112:1 Qul hu�wallaa-hu ahad.\n112:2 Allah hus-samad.\n112:3 Lam yalid wa-lam yoou�lad.\n112:4 Wa lam�ya kul-lahu kufu�wan ahad.',
      translation: '',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 10',
      subtitle: 'Surah Al-Falaq',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n113:1 Qul a�uzoo-bi rabbil-falaq.\n113:2 Min sharri ma khalaq.\n113:3 Wa min sharri gha�siqin iza waqab.\n113:4 Wa min shar�rin naf�faa saati�fil uqad.\n113:5 Wa min shar�ri haa�sidin iza hasad.',
      translation: '',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 11',
      subtitle: 'Surah An-Nas',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillaahir Rahmaanir Raheem\n114:1 Qul a�uzu-bi rab�binn naas.\n114:2 Malik�inn naas.\n114:3 Ilaa hin�naas.\n114:4 Min shar�ril waas-wa-asil khan�naas.\n114:5 Allazee yuwaswisu fee sudoorin-naas.\n114:6 Minal jinnati wan-naas.',
      translation: '',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 12',
      subtitle: 'Evening sovereignty',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Amsaina wa-amsal mulku lillah;\nWal-hamdu lillah;\nLa ilaha illal-lah;\nWah-da�hoo la-sharee kalah;\nLahul-mulku wa�lahul-hamd;\nYuh-ee wa yu�meeto wa�huwa ala kulli shayin qadeer;\nRabbi ass-aaluka khay�ra mafee haa-zee�hil lai�lah;\nWa-khayra ma ba�daha;\nWa-aa�ozu-bika min sharri ma fee haa-zee�hil lai�lah;\nWa sharri ma ba�daha;\nRabbi aa�ozu-bika minal-kasali, wa-soo-il kibar;\nRabbi aa�ozubika min aa�zaa-bin fin�nari wa aa�zaa-bin fil�qabr.',
      translation: '',
      icon: Icons.nights_stay_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 13',
      subtitle: 'Fitrah of Islam',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Aamsaina ala fitratil-islam;\nWa�ala kalimatil-ikhlas;\nWa�ala deeni nabi�yyina Muhammadin sallalla-hu alai�hi wasallam;\nWa�ala millati abeena Ibrahima hanee�faan muslimah;\nWaama kana minal-mushrikeen.',
      translation: '',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 14',
      subtitle: 'By You we reached evening',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma bika amsaina;\nWa�bika asbahna;\nWa�bika nahya;\nWa�bika namooth;\nWa�ilay�kaal maser.',
      translation: '',
      icon: Icons.nights_stay_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 15',
      subtitle: 'Blessing and concealment',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma inni aam�saitu minka fee-ni�matee�ou wa�aa fee-yatee�ou wa sitr;\nFa aa�timma alayya ni�matak;\nWa�aa fee�yatak;\nWa sit�raka fid-dunya wal akhira.',
      translation: '',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 16',
      subtitle: 'All blessings are from Allah',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma ma aamsa bee�min nia�mah;\nAw�bee a�haa-deem min khal�qik;\nFa�minka wah-dhaka la-sharee kalak;\nFa-lakal hamdu wa-lakash shukr.',
      translation: '',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 17',
      subtitle: 'Praise befitting Allah',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Ya Rabbi lakal hamdu kama yam-baghi�li jalali waj�hika wa�azimi sultanik.',
      translation: '',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 18',
      subtitle: 'Contentment with faith',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Radeetu billahi Rabbah;\nWa�bil-islami dee�nah;\nWa�bee Muhammadin sal-lallahu alai�hi wa�sallama nabiy�ya wa rasulaah.',
      translation: '',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 19',
      subtitle: 'Pardon and wellbeing',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma innee as-aalukal aaf�wa wal-aa�fiyah;\nFid-dunya wal-akhirah;\nAllahumma innee as�alukal aa�fwa wal-aa�fiyah;\nFee dee�nee wa�dunya-ya;\nWa�ahlee wama-lee;\nAllah hummas-tur aaw-ra�tee;\nWa aa�mir raw-aa�tee;\nWah fiz�nee min bai�nee ya-dai�yaa;\nWa-min khal�fee;\nWa�aai ya�mee-nee;\nWa�aai shee�malee;\nWa-min faw�qee;\nWa�aa-oozubi aa�zaa-matika aan oogh-tala min tahtee.',
      translation: '',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 20',
      subtitle: 'Perfect praise',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'SubhanAllahi wa-bihamdih;\nAa�dada khal�qi;\nWa�rida nafsih;\nWa�zinata aa�rshih;\nWa�midada kalimatih.',
      translation: '',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 21',
      subtitle: 'Nothing can harm',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Bismillah hil�lazee la yadur�oo ma�aas-mihi shai-oon fil-ardi wa�laa fis-samaa;\nWa�hu�waas samee�ool aa�leem.',
      translation: '',
      icon: Icons.shield_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 22',
      subtitle: 'Protection from shirk',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma inni a�oozu-bika min aan ush�rika bika shai�an aa�lam;\nWa aas�tagfiruka le ma la a�alam.',
      translation: '',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Evening Azkar 23',
      subtitle: 'Perfect words of Allah',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Aa�oozu-bi kalima-tillah heet-taam�mati min sharri ma khalaq.',
      translation: '',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Evening Azkar 24',
      subtitle: 'Knower of unseen',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma aa�limal-ghaybi wash-shahadah;\nFati�ras samawati wal�ard;\nRabba kulli shay�in wa�ma leekah;\nAsh�hadu al�laa ilaha illa anth;\nAa�ozu-bika min shar�ri nafsee;\nWa�min shar�rish shay�tani wa-shirki;\nWa�an aq-tarifa ala nafsee soo�an aw aa�joor-rahoo ila Muslim.',
      translation: '',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 25',
      subtitle: 'Rectify my affairs',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Ya hayyu ya qay�yum;\nBi-rah�matika asta�gis;\nAs�lih li sha�ni kullah;\nWa�la takil�ni ila nafsi tarfata ayn.',
      translation: '',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 26',
      subtitle: 'Sayyidul Istighfar',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma anta rab�bee la ilaha illa anta Khalaq-tanee;\nWa�ana aab�duk;\nWa�ana ala aah�dika wa-wa�dika mas�ta-taat;\nAa�ozu-bika min sharri ma�sanath;\nAa�boo�u laka bini�matika aalai�yaa;\nWa�aboo�u bi-zan�bee;\nFagh�fir lee;\nFa-inna�hu la yagh�firuz zunu�ba illa ant.',
      translation: '',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 27',
      subtitle: 'Witness of Tawheed',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma innee aam�sait;\nOsh�hiduka wa-oshhidu hamalata aar�shik;\nWa�malaa ika�tak;\nWa-jamee�aa khalqik;\nAnn�naka antal-lahu;\nLa ilaha illa ant;\nWah�daka laa sharee kalak;\nWa�anna Muhammadan aabdu�ka wa�rasooluk.',
      translation: '',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 28',
      subtitle: 'Health in body and senses',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Allahumma aa�fi-nee fee bada�nee;\nAllahumma aa�fi-nee fee sam�ee;\nAllahumma aa�fi-nee fee basa�ree;\nLa ilaha illa-ant;\nAllahumma innee aa�oozu-bika minal-kufri wal-faqr;\nWa�aa�oo-zu-bika min aa�zaa-bil-qabr;\nLa ilaha illa-ant.',
      translation: '',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 29',
      subtitle: 'Allah is sufficient',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Hasbi-yallahu la ilaha illa huwa aa�layhi tawak-kalth;\nWa�huwa rabbul aar�shil aa�zeem.',
      translation: '',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 30',
      subtitle: 'Tawheed',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'Laa ilaaha illallaahu wahdahu laa sha�ree kalah;\nLahul-mulku wa lahul-hamd;\nWa�huwa aa�laa kulli shay�in qadeer.',
      translation: '',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Evening Azkar 31',
      subtitle: 'Tasbih',
      category: 'Evening Dua',
      arabic: '',
      transliteration:
          'SubhanAllahi wa bi�hamdihi;\nSubhanAllah-hil aa�zim.',
      translation: '',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 1',
      subtitle: 'Lie down in Allah\'s name',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Bismika rabbee wadaAtu janbee wabika arfaAAuh, fa-in amsakta nafsee farhamha, wa-in arsaltaha fahfathha bima tahfathu bihi ibadakas-saliheen.',
      translation:
          'In Your name my Lord, I lie down and in Your name I rise. If You take my soul, have mercy upon it, and if You return it, protect it as You protect Your righteous servants.',
      icon: Icons.bedtime_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 2',
      subtitle: 'Soul and wellbeing',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Allahumma innaka khalaqta nafsee wa-anta tawaffaha, laka mamatuha wamahyaha. In ahyaytaha fahfathha, wa-in amattaha faghfir laha. Allahumma innee as-alukal-afiyah.',
      translation:
          'O Allah, You created my soul and You take its life. To You belongs its life and death. If You keep it alive, protect it, and if You take it, forgive it. O Allah, I ask You for wellbeing.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 3',
      subtitle: 'Protection from punishment',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Allahumma qinee athabaka yawma tabathu ibadak.',
      translation:
          'O Allah, protect me from Your punishment on the day You resurrect Your servants.',
      icon: Icons.shield_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 4',
      subtitle: 'In Your name I live and die',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration: 'Bismikal-lahumma amootu wa-ahya.',
      translation: 'In Your name, O Allah, I live and die.',
      icon: Icons.nights_stay_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 5',
      subtitle: 'Praise after provision',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Alhamdu lillahil-lathee atamana wasaqana, wakafana, wa-awana, fakam mimman la kafiya lahu wala muwee.',
      translation:
          'All praise is for Allah, Who fed us, gave us drink, was sufficient for us, and sheltered us. How many have none to suffice them or shelter them.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 6',
      subtitle: 'Protection from the soul and Shaytan',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Allahumma alimal-ghaybi wash-shahadah, fatiras-samawati wal-ard, rabba kulli shayin wamaleekah. Ashhadu an la ilaha illa ant. Aootu bika min sharri nafsee wamin sharrish-shaytani washirkih, wa-an aqtarifa ala nafsee soo-an aw ajurrahu ila muslim.',
      translation:
          'O Allah, Knower of the unseen and the seen, Creator of the heavens and earth, Lord and Sovereign of all things, I bear witness that none has the right to be worshipped except You. I seek refuge in You from the evil of my soul, from the evil and shirk of Shaytan, and from committing wrong against myself or bringing it upon another Muslim.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Sleeping Dua 7',
      subtitle: 'Complete trust before sleep',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Allahumma aslamtu nafsee ilayk, wafawwadtu amree ilayk, wawajjahtu wajhee ilayk, wa-aljatu thahree ilayk, raghbatan warahbatan ilayk. La maljaa wala manja minka illa ilayk. Amantu bikitabikal-lathee anzalt, wabinabiyyikal-lathee arsalt.',
      translation:
          'O Allah, I submit my soul to You, entrust my affairs to You, turn my face toward You, and rely completely upon You in hope and fear. There is no refuge or safety from You except with You. I believe in Your Book which You revealed and in Your Prophet whom You sent.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Sleeping Dua 8',
      subtitle: 'Ayatul Kursi',
      category: 'Sleeping Dua',
      arabic: '',
      transliteration:
          'Allahu la ilaha illa Huwal-Hayyul-Qayyoom, la takhuthuhu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard. Man thal-lathee yashfau indahu illa bi-ithnih. Yalamu ma bayna aydeehim wa ma khalfahum, wa la yuheetoona bishay-im min ilmihi illa bima shaa. Wasia kursiyyuhus-samawati wal-ard, wa la yaooduhu hifdhuhuma, wa Huwal-Aliyyul-Adheem.',
      translation:
          'Allah, there is none worthy of worship except Him, the Ever-Living, the Sustainer. Neither slumber nor sleep overtakes Him. To Him belongs whatever is in the heavens and the earth. His Kursi extends over the heavens and the earth, and preserving them does not tire Him. He is the Most High, the Most Great.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Waking Up Dua 1',
      subtitle: 'Health, soul, and remembrance',
      category: 'Waking Up Dua',
      arabic: '',
      transliteration:
          'Alhamdu lillahil-lathee afanee fee jasadee waradda alayya roohee wa-athina lee bithikrih.',
      translation:
          'All praise is for Allah who restored my health, returned my soul to me, and allowed me to remember Him.',
      icon: Icons.wb_sunny_rounded,
    ),
    _DuaItem(
      title: 'Waking Up Dua 2',
      subtitle: 'Dhikr after waking at night',
      category: 'Waking Up Dua',
      arabic: '',
      transliteration:
          'La ilaha illal-lahu wahdahu la shareeka lah, lahul-mulku walahul-hamd, wahuwa ala kulli shay-in qadeer. Subhanal-lah, walhamdu lillah, wa la ilaha illal-lah wallahu akbar, wa la hawla wa la quwwata illa billahil-Aliyyil-Adheem. Rabbigh-fir lee.',
      translation:
          'None has the right to be worshipped except Allah alone, without partner. To Him belongs sovereignty and praise, and He is over all things capable. Glory is to Allah, all praise is for Allah, none has the right to be worshipped except Allah, Allah is the Greatest, and there is no power nor might except with Allah, the Most High, the Supreme. My Lord, forgive me.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Waking Up Dua 3',
      subtitle: 'Life after sleep',
      category: 'Waking Up Dua',
      arabic: '',
      transliteration:
          'Alhamdu lillahil-lathee ahyana bada ma amatana wa-ilayhin-nushoor.',
      translation:
          'All praise is for Allah who gave us life after taking it from us, and to Him is the resurrection.',
      icon: Icons.wb_twilight_rounded,
    ),
    _DuaItem(
      title: 'Eating Dua 1',
      subtitle: 'After finishing a meal',
      category: 'Eating Dua',
      arabic: '',
      transliteration:
          'Alhamdulilahil ladhi atamana, wasaqana, wajalna min-al Muslimeen.',
      translation:
          'Praise be to Allah Who has fed us and given us drink and made us Muslims.',
      icon: Icons.restaurant_rounded,
    ),
    _DuaItem(
      title: 'After Prayer Dua',
      subtitle: 'Seek more rewards after Salah',
      category: 'Prayer Dua',
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      transliteration:
          'Allahumma antas-salamu wa minkas-salam, tabarakta ya dhal-jalali wal-ikram.',
      translation:
          'O Allah, You are As-Salam and from You is peace. Blessed are You, Owner of majesty and honor.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 1',
      subtitle: 'After Salah Tasbeeh',
      category: 'Prayer Dua',
      arabic:
          'سُبْحَانَ اللَّهِ ٣٣ مَرَّةً\nالْحَمْدُ لِلَّهِ ٣٣ مَرَّةً\nاللَّهُ أَكْبَرُ ٣٤ مَرَّةً',
      transliteration:
          'Subhana-Allah thirty-three times, Alhamdulillah thirty-three times, Allahu Akbar thirty-four times.',
      translation:
          'Glory be to Allah thirty-three times, praise be to Allah thirty-three times, and Allah is the Greatest thirty-four times.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 2',
      subtitle: 'After Salah Tasbeeh',
      category: 'Prayer Dua',
      arabic:
          'سُبْحَانَ اللَّهِ ٣٣ مَرَّةً\nالْحَمْدُ لِلَّهِ ٣٣ مَرَّةً\nاللَّهُ أَكْبَرُ ٣٤ مَرَّةً',
      transliteration:
          'Subhana-Allah thirty-three times, Alhamdulillah thirty-three times, Allahu Akbar thirty-four times.',
      translation:
          'Glory be to Allah thirty-three times, praise be to Allah thirty-three times, and Allah is the Greatest thirty-four times.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 3',
      subtitle: 'After Takbeer at the start of prayer',
      category: 'Prayer Dua',
      arabic:
          'وَجَّهْتُ وَجْهِيَ لِلَّذِي فَطَرَ السَّمَاوَاتِ وَالْأَرْضَ حَنِيفًا وَمَا أَنَا مِنَ الْمُشْرِكِينَ، إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي لِلَّهِ رَبِّ الْعَالَمِينَ، لَا شَرِيكَ لَهُ وَبِذَلِكَ أُمِرْتُ وَأَنَا مِنَ الْمُسْلِمِينَ.\nاللَّهُمَّ أَنْتَ الْمَلِكُ لَا إِلَهَ إِلَّا أَنْتَ، أَنْتَ رَبِّي وَأَنَا عَبْدُكَ، ظَلَمْتُ نَفْسِي وَاعْتَرَفْتُ بِذَنْبِي فَاغْفِرْ لِي ذُنُوبِي جَمِيعًا، إِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، وَاهْدِنِي لِأَحْسَنِ الْأَخْلَاقِ لَا يَهْدِي لِأَحْسَنِهَا إِلَّا أَنْتَ، وَاصْرِفْ عَنِّي سَيِّئَهَا لَا يَصْرِفُ عَنِّي سَيِّئَهَا إِلَّا أَنْتَ، لَبَّيْكَ وَسَعْدَيْكَ، وَالْخَيْرُ كُلُّهُ بِيَدَيْكَ، وَالشَّرُّ لَيْسَ إِلَيْكَ، أَنَا بِكَ وَإِلَيْكَ، تَبَارَكْتَ وَتَعَالَيْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
      transliteration:
          'Wajjahtu wajhiya lillathee fataras-samawati wal-arda haneefan wama ana minal-mushrikeen, inna salatee wanusukee wamahyaya wamamatee lillahi rabbil-alameen, la shareeka lahu wabithalika omirtu wa-ana minal-muslimeen. Allahumma antal-maliku la ilaha illa ant, anta rabbee wa-ana abduk, thalamtu nafsee wataraftu bithanbee faghfir lee thunoobee jameean innahu la yaghfiruth-thunooba illa ant. Wahdinee li-ahsanil-akhlaqi la yahdee li-ahsaniha illa ant, wasrif annee sayyi-aha la yasrifu annee sayyi-aha illa ant, labbayka wasadayk, walkhayru kulluhu biyadayk, washsharru laysa ilayk, ana bika wa-ilayk, tabarakta wataalayt, astaghfiruka wa-atoobu ilayk.',
      translation:
          'I turn my face sincerely to the One who created the heavens and the earth, and I am not among those who associate partners with Allah. My prayer, sacrifice, life, and death are for Allah, Lord of the worlds, with no partner. O Allah, You are the King and there is no deity but You. You are my Lord and I am Your servant. I have wronged myself and admitted my sin, so forgive all my sins, guide me to the finest character, turn away my bad character, and accept my repentance.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 4',
      subtitle: 'After Takbeer at the start of prayer',
      category: 'Prayer Dua',
      arabic:
          'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ، اللَّهُمَّ نَقِّنِي مِنْ خَطَايَايَ كَمَا يُنَقَّى الثَّوْبُ الْأَبْيَضُ مِنَ الدَّنَسِ، اللَّهُمَّ اغْسِلْنِي مِنْ خَطَايَايَ بِالثَّلْجِ وَالْمَاءِ وَالْبَرَدِ',
      transliteration:
          'Allahumma baid baynee wa bayna khataayaaya kama baadta baynal-mashriqi walmaghribi, Allahumma naqqinee min khataayaaya kama yunaqqath-thawbul-abyadhu minad-danasi, Allahum-maghsilnee min khataayaaya bith-thalji walmaa-i walbarad.',
      translation:
          'O Allah, distance me from my sins as You have distanced the east from the west. Purify me from my sins as a white garment is purified from stains, and wash my sins away with snow, water, and hail.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 5',
      subtitle: 'After Takbeer at the start of prayer',
      category: 'Prayer Dua',
      arabic:
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ',
      transliteration:
          'Subhaanaka Allahumma wa bihamdika, wa tabaarakasmuka, wa taaalaa jadduka, wa laa ilaaha ghayruka.',
      translation:
          'Glory and praise are Yours, O Allah. Blessed is Your name, exalted is Your majesty, and there is no deity besides You.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 6',
      subtitle: 'After Tashahhud',
      category: 'Prayer Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْمَأْثَمِ وَالْمَغْرَمِ',
      transliteration:
          'Allahumma innee aoothu bika min athaabil-qabri, wa aoothu bika min fitnatil-maseehid-dajjaali, wa aoothu bika min fitnatil-mahyaa walmamaati. Allahumma innee aoothu bika minal-mathami walmaghrami.',
      translation:
          'O Allah, I seek refuge in You from the punishment of the grave, from the trial of the False Messiah, from the trials of life and death, and from sin and debt.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 7',
      subtitle: 'After Tashahhud',
      category: 'Prayer Dua',
      arabic:
          'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
      transliteration:
          'Allahumma innee dhalamtu nafsee dhulman katheeran, wa laa yaghfiruth-thunooba illa Anta, faghfir lee maghfiratan min indika warhamnee innaka Antal-Ghafoorur-Raheem.',
      translation:
          'O Allah, I have wronged myself greatly, and no one forgives sins except You. Grant me forgiveness from Yourself and have mercy on me, for You are the Most Forgiving, the Most Merciful.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Prayer Dua 8',
      subtitle: 'After Tashahhud',
      category: 'Prayer Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ وَمَا أَخَّرْتُ، وَمَا أَسْرَرْتُ، وَمَا أَعْلَنْتُ، وَمَا أَسْرَفْتُ، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي. أَنْتَ الْمُقَدِّمُ، وَأَنْتَ الْمُؤَخِّرُ، لَا إِلَهَ إِلَّا أَنْتَ',
      transliteration:
          'Allahum-maghfir lee maa qaddamtu, wa maa akhkhartu, wa maa asrartu, wa maa alantu, wa maa asraftu, wa maa Anta alamu bihi minnee. Antal-Muqaddimu, wa Antal-Muakhkhiru, laa ilaaha illaa Anta.',
      translation:
          'O Allah, forgive what I have done before and what I will do later, what I have hidden and what I have made open, what I have done excessively, and what You know better than me. You bring forward and You delay. There is no deity except You.',
      icon: Icons.mosque_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua',
      subtitle: 'Ask Allah for forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      transliteration:
          'Astaghfirullahal-azim alladhi la ilaha illa huwal-hayyul-qayyum wa atubu ilayh.',
      translation:
          'I seek forgiveness from Allah, the Mighty, whom there is none worthy of worship except Him, the Ever-Living, the Sustainer, and I turn to Him in repentance.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 1',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'رَبِّ اِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ وَإِلَّا تَغْفِرْ لِي وَتَرْحَمْنِي أَكُنْ مِنَ الْخَاسِرِينَ',
      transliteration:
          "Rabbi innee a'oothu bika an as'alaka ma laysa lee bihi ilm, wa illa taghfir lee watarhamnee akum minal-khasireen.",
      translation:
          'O my Lord, I seek refuge with You from asking You that of which I have no knowledge. Unless You forgive me and have mercy on me, I would indeed be among the losers.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 2',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic: 'رَبِّ اغْفِرْ لِي رَبِّ اغْفِرْ لِي',
      transliteration: 'Rabbighfir lee, Rabbighfir lee.',
      translation: 'Lord, forgive me. My Lord, forgive me.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 3',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِي، وَارْحَمْنِي، وَاهْدِنِي، وَاجْبُرْنِي، وَعَافِنِي، وَارْزُقْنِي، وَارْفَعْنِي',
      transliteration:
          "Allaahum-maghfir lee, warhamnee, wahdinee, wajburnee, wa 'aafinee, warzuqnee, warfa'nee.",
      translation:
          'O Allah, forgive me, have mercy on me, guide me, support me, protect me, provide for me, and elevate me.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 4',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ، دِقَّهُ وَجِلَّهُ، وَأَوَّلَهُ وَآخِرَهُ وَعَلَانِيَتَهُ وَسِرَّهُ',
      transliteration:
          "Allaahum-maghfir lee thanbee kullahu, diqqahu wa jillahu, wa awwalahu wa aakhirahu wa alaaniyatahu wa sirrahu.",
      translation:
          'O Allah, forgive me all my sins, great and small, the first and the last, those that are apparent and those that are hidden.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 5',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِرِضَاكَ مِنْ سَخَطِكَ، وَبِمُعَافَاتِكَ مِنْ عُقُوبَتِكَ، وَأَعُوذُ بِكَ مِنْكَ، لَا أُحْصِي ثَنَاءً عَلَيْكَ، أَنْتَ كَمَا أَثْنَيْتَ عَلَى نَفْسِكَ',
      transliteration:
          "Allaahumma innee a'oothu biridhaaka min sakhatika, wa bimu'aafaatika min uqoobatika, wa a'oothu bika minka, laa uhsee thanaa'an alayka, Anta kamaa athnayta alaa nafsika.",
      translation:
          'O Allah, I seek protection in Your pleasure from Your anger, and in Your forgiveness from Your punishment. I seek protection in You from You. I cannot count Your praises. You are as You have praised Yourself.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 6',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      transliteration:
          "Astaghfirullaah, Astaghfirullaah, Astaghfirullaaha wa atoobu ilayhi.",
      translation: 'I seek the forgiveness of Allah and repent to Him.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 7',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
      transliteration:
          "Allaahumma innee dhalamtu nafsee dhulman katheeran, wa laa yaghfiruth-thunooba illaa Anta, faghfir lee maghfiratan min indika warhamnee innaka Antal-Ghafoorur-Raheem.",
      translation:
          'O Allah, I have greatly wronged myself and no one forgives sins but You. Grant me forgiveness and have mercy on me. Surely, You are Forgiving, Merciful.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 8',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      transliteration:
          'Allahumma anta rabbee la ilaha illa Ant, khalaqtanee wa ana abduk, wa ana ala ahdika wa wadika mastatat, aoothu bika min sharri ma sanat, aboo laka binimatika alay, wa aboo bithanbee, faghfir lee fa innahu la yaghfiruth-thunooba illa Ant.',
      translation:
          'O Allah, You are my Lord. None has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have committed. I acknowledge Your favour and my sin, so forgive me, for none forgives sins except You.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 9',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ، أَنْ تَغْفِرَ لِي',
      transliteration:
          "Allaahumma innee as'aluka birahmatikal-latee wasiat kulla shayin an taghfira lee.",
      translation:
          'O Allah, I ask You by Your mercy, which encompasses all things, that You forgive me.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Forgiveness Dua 10',
      subtitle: 'For forgiveness',
      category: 'Forgiveness Dua',
      arabic:
          'رَبِّ اغْفِرْ لِي، وَتُبْ عَلَيَّ، إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ',
      transliteration:
          "Rabbighfir lee wa tub alayya innaka Antat-Tawwaabul-Ghafoor.",
      translation:
          'My Lord, forgive me and accept my repentance. You are the Ever-Relenting, the All-Forgiving.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 1',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic:
          'أَنْتَ وَلِيُّنَا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الْغَافِرِينَ، وَاكْتُبْ لَنَا فِي هَذِهِ الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ إِنَّا هُدْنَا إِلَيْكَ',
      transliteration:
          'Anta waliyyuna faghfir lana warhamna wa Anta khayrul-ghafireen. Waktub lana fee hathihid-dunya hasanatan wa fil-akhirati inna hudna ilayk.',
      translation:
          'You are our Protector, so forgive us and have mercy upon us; You are the best of forgivers. Ordain for us good in this world and in the Hereafter. Certainly, we have turned unto You.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 2',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic: 'رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
      transliteration: "Rabbighfir warham wa Anta khayrur-Rahimeen.",
      translation:
          'My Lord, forgive and have mercy, for You are the Best of those who show mercy.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 3',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic:
          'أَنْتَ وَلِيُّنَا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الْغَافِرِينَ، وَاكْتُبْ لَنَا فِي هَذِهِ الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ إِنَّا هُدْنَا إِلَيْكَ',
      transliteration:
          'Anta waliyyuna faghfir lana warhamna wa Anta khayrul-ghafireen. Waktub lana fee hathihid-dunya hasanatan wa fil-akhirati inna hudna ilayk.',
      translation:
          'You are our Protector, so forgive us and have mercy upon us; You are the best of forgivers. Ordain for us good in this world and in the Hereafter. Certainly, we have turned unto You.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 4',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic:
          'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      transliteration:
          'Rabbana zalamna anfusana wa il lam taghfir lana wa tarhamna lanakoonanna minal-khasireen.',
      translation:
          'Our Lord, we have wronged ourselves. If You do not forgive us and have mercy on us, we shall certainly be among the losers.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 5',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic:
          'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      transliteration:
          "Rabbana atina mil-ladunka rahmatan wa hayyi lana min amrina rashada.",
      translation:
          'Our Lord, bestow upon us mercy from Yourself and arrange our affair for us in the right way.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Mercy Dua 6',
      subtitle: "For forgiveness and Allah's mercy",
      category: 'Forgiveness Dua',
      arabic:
          'رَبَّنَا آمَنَّا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
      transliteration:
          "Rabbana amanna faghfir lana warhamna wa Anta khayrur-Rahimeen.",
      translation:
          'Our Lord, we believe, so forgive us and have mercy on us, for You are the Best of those who show mercy.',
      icon: Icons.favorite_border_rounded,
    ),
    _DuaItem(
      title: 'Travel Dua 1',
      subtitle: 'Dua when starting travel',
      category: 'Travel Dua',
      arabic:
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      transliteration:
          'Subhana-alladhi sakh-khara lana hadha wa ma kunna lahu muqrinin. Wa inna ila Rabbina la munqalibun.',
      translation:
          'Glory is to Him who subjected this transportation for us, though we were unable to do so on our own. And to our Lord we shall return.',
      icon: Icons.flight_takeoff_rounded,
    ),
    _DuaItem(
      title: 'Travel Dua 2',
      subtitle: 'Good entry and good exit',
      category: 'Travel Dua',
      arabic: '',
      transliteration:
          'Rabbi adkhilnee mudkhala sidqin wa akhrijnee mukhraja sidqin wajal lee mil ladunka sultanan naseera.',
      translation:
          'My Lord, let my entry be good and let my exit be good, and grant me from Yourself a supporting authority.',
      icon: Icons.flight_takeoff_rounded,
    ),
    _DuaItem(
      title: 'Protection Dua 1',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ مُنْزِلَ الْكِتَابِ، سَرِيعَ الْحِسَابِ، اهْزِمِ الْأَحْزَابَ، اللَّهُمَّ اهْزِمْهُمْ وَزَلْزِلْهُمْ',
      transliteration:
          'Allaahumma munzilal-kitaabi, sareeal-hisaabi, ihzimil-ahzaaba, Allaahumma ihzimhum wa zalzilhum.',
      translation:
          'O Allah, Revealer of the Book, Swift to account, defeat the groups. O Allah, defeat them and shake them.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 2',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul Huwallaahu Ahad. Allaahus-Samad. Lam yalid wa lam yoolad. Wa lam yakun lahu kufuwan ahad.',
      translation:
          'He is Allah, the One. Allah, the Self-Sufficient Master. He begets not, nor was He begotten, and there is none equal to Him.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 3',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ، مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      transliteration:
          'Allaahu laa ilaaha illaa Huwal-Hayyul-Qayyoom, laa takhuthuhu sinatun wa laa nawm, lahu maa fis-samaawaati wa maa fil-ardh, man thal-lathee yashfau indahu illaa bi-ithnih, yalamu maa bayna aydeehim wa maa khalfahum, wa laa yuheetoona bishay-im min ilmihi illaa bimaa shaa, wasia kursiyyuhus-samaawaati wal-ardh, wa laa yaooduhu hifdhuhumaa, wa Huwal-Aliyyul-Adheem.',
      translation:
          'Allah, there is none worthy of worship but Him, the Ever-Living, the Sustainer. Neither slumber nor sleep overtakes Him. To Him belongs whatever is in the heavens and the earth. His Throne extends over the heavens and the earth, and He is the Most High, the Most Great.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 4',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul Huwallaahu Ahad. Allaahus-Samad. Lam yalid wa lam yoolad. Wa lam yakun lahu kufuwan ahad.',
      translation:
          'He is Allah, the One. Allah, the Self-Sufficient Master. He begets not, nor was He begotten, and there is none equal to Him.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 5',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul aoothu birabbil-falaq. Min sharri maa khalaq. Wa min sharri ghaasiqin ithaa waqab. Wa min sharrin-naffaathaati fil-uqad. Wa min sharri haasidin ithaa hasad.',
      translation:
          'I seek refuge with the Lord of daybreak from the evil of what He created, from the evil of darkness when it settles, from those who blow in knots, and from the envier when he envies.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 6',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، إِلَهِ النَّاسِ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَالنَّاسِ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul aoothu birabbin-naas. Malikin-naas. Ilaahin-naas. Min sharril-waswaasil-khannaas. Allathee yuwaswisu fee sudoorin-naas. Minal-jinnati wan-naas.',
      translation:
          'I seek refuge with the Lord of mankind, the King of mankind, the God of mankind, from the evil of the whisperer who withdraws, who whispers in the hearts of mankind, from jinn and people.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 7',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْمَأْثَمِ وَالْمَغْرَمِ',
      transliteration:
          'Allaahumma innee aoothu bika min athaabil-qabri, wa aoothu bika min fitnatil-maseehid-dajjaali, wa aoothu bika min fitnatil-mahyaa wal-mamaati. Allaahumma innee aoothu bika minal-mathami wal-maghrami.',
      translation:
          'O Allah, I seek refuge in You from the punishment of the grave, the trial of the False Messiah, the trials of life and death, and from sin and debt.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 8',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      transliteration: 'Allaahumma qinee athaabaka yawma tabathu ibaadaka.',
      translation:
          'O Allah, save me from Your punishment on the Day that You resurrect Your slaves.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 9',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا، أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ',
      transliteration:
          'Allaahumma Aalimal-ghaybi wash-shahaadati faatiras-samaawaati wal-ardhi, Rabba kulli shayin wa maleekahu, ash-hadu an laa ilaaha illaa Anta, aoothu bika min sharri nafsee, wa min sharrish-shaytaani wa shirkihi, wa an aqtarifa alaa nafsee sooan, aw ajurrahu ilaa Muslim.',
      translation:
          'O Allah, Knower of the unseen and the seen, Creator of the heavens and earth, Lord and Owner of everything, I seek refuge in You from the evil of my soul, Satan and his shirk, and from harming myself or any Muslim.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 10',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
      transliteration:
          'Allaahumma innee asalukal-afwa wal-aafiyata fid-dunyaa wal-aakhirati, Allaahumma innee asalukal-afwa wal-aafiyata fee deenee wa dunyaaya wa ahlee wa maalee, Allaahum-mastur awraatee, wa aamin rawaatee, Allaahum-mahfadhnee min bayni yadayya, wa min khalfee, wa an yameenee, wa an shimaalee, wa min fawqee, wa aoothu bi-adhamatika an ughtaala min tahtee.',
      translation:
          'O Allah, I ask You for forgiveness and wellbeing in this world and the next, in my religion, worldly affairs, family and wealth. Conceal my faults, calm my fears, guard me from every side, and protect me by Your greatness from being struck from beneath me.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 11',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      transliteration:
          'Asbahnaa wa asbahal-mulku lillaahi walhamdu lillaahi, laa ilaaha illallaahu wahdahu laa shareeka lahu, lahul-mulku wa lahul-hamdu wa Huwa alaa kulli shayin Qadeer. Rabbi asaluka khayra maa fee haathal-yawmi wa khayra maa badahu, wa aoothu bika min sharri maa fee haathal-yawmi wa sharri maa badahu, Rabbi aoothu bika minal-kasali wa sooil-kibari, Rabbi aoothu bika min athaabin fin-naari wa athaabin fil-qabri.',
      translation:
          'We have entered a new day and all dominion belongs to Allah. My Lord, I ask You for the good of this day and what follows it, and I seek refuge in You from its evil and what follows it, from laziness, helpless old age, Hellfire and the grave.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 12',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic: 'أَنَّ اللَّهَ مَوْلَاكُمْ نِعْمَ الْمَوْلَىٰ وَنِعْمَ النَّصِيرُ',
      transliteration: "Anna Allaha mawlakum nimal mawla wa nimal naseer.",
      translation:
          'Know that Allah is your Protector. Excellent is the Protector, and excellent is the Helper.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 13',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ، مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      transliteration:
          'Allaahu laa ilaaha illaa Huwal-Hayyul-Qayyoom, laa takhuthuhu sinatun wa laa nawm, lahu maa fis-samaawaati wa maa fil-ardh, man thal-lathee yashfau indahu illaa bi-ithnih, yalamu maa bayna aydeehim wa maa khalfahum, wa laa yuheetoona bishay-im min ilmihi illaa bimaa shaa, wasia kursiyyuhus-samaawaati wal-ardh, wa laa yaooduhu hifdhuhumaa, wa Huwal-Aliyyul-Adheem.',
      translation:
          'Allah, there is none worthy of worship but Him, the Ever-Living, the Sustainer. His Throne extends over the heavens and the earth, and He is the Most High, the Most Great.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 14',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul Huwallaahu Ahad. Allaahus-Samad. Lam yalid wa lam yoolad. Wa lam yakun lahu kufuwan ahad.',
      translation:
          'He is Allah, the One. Allah, the Self-Sufficient Master. He begets not, nor was He begotten, and there is none equal to Him.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 15',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul aoothu birabbil-falaq. Min sharri maa khalaq. Wa min sharri ghaasiqin ithaa waqab. Wa min sharrin-naffaathaati fil-uqad. Wa min sharri haasidin ithaa hasad.',
      translation:
          'I seek refuge with the Lord of daybreak from the evil of what He created, from darkness, witchcraft, and envy.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 16',
      subtitle: 'Protection and help from Allah',
      category: 'Protection Dua',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، إِلَهِ النَّاسِ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَالنَّاسِ',
      transliteration:
          'Bismillaahir-Rahmaanir-Raheem. Qul aoothu birabbin-naas. Malikin-naas. Ilaahin-naas. Min sharril-waswaasil-khannaas. Allathee yuwaswisu fee sudoorin-naas. Minal-jinnati wan-naas.',
      translation:
          'I seek refuge with the Lord, King, and God of mankind from the evil whisperer who withdraws, from jinn and people.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 17',
      subtitle: 'Protection from ignorance',
      category: 'Protection Dua',
      arabic: 'أَعُوذُ بِاللَّهِ أَنْ أَكُونَ مِنَ الْجَاهِلِينَ',
      transliteration: 'Aoothu billahi an akoona minal jahileen.',
      translation: 'I seek refuge in Allah from being among the ignorant.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 18',
      subtitle: 'Protection from oppressors',
      category: 'Protection Dua',
      arabic:
          'رَبَّنَا أَخْرِجْنَا مِنْ هَذِهِ الْقَرْيَةِ الظَّالِمِ أَهْلُهَا، وَاجْعَلْ لَنَا مِنْ لَدُنْكَ وَلِيًّا، وَاجْعَلْ لَنَا مِنْ لَدُنْكَ نَصِيرًا',
      transliteration:
          'Rabbana akhrijna min hathihil-qaryati ath-thalimi ahluha, wajal lana min ladunka waliyyan, wajal lana min ladunka naseera.',
      translation:
          'Our Lord, rescue us from this town whose people are oppressors, and appoint for us from Yourself a protector and a helper.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 19',
      subtitle: 'Protection from oppressors',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ أَنْتَ عَضُدِي، وَأَنْتَ نَصِيرِي، بِكَ أَجُولُ، وَبِكَ أَصُولُ، وَبِكَ أُقَاتِلُ',
      transliteration:
          'Allaahumma Anta adudee, wa Anta naseeree, bika ajoolu, wa bika asoolu, wa bika uqaatilu.',
      translation:
          'O Allah, You are my strength and my support. For Your sake I go forth, advance, and fight.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 20',
      subtitle: 'Protection from Satan/Shaytan',
      category: 'Protection Dua',
      arabic:
          'وَقُلْ رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ، وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
      transliteration:
          'Rabbi aoothu bika min hamazaatish-shayaateen, wa aoothu bika Rabbi an yahdhuroon.',
      translation:
          'My Lord, I seek refuge with You from the whisperings of devils, and I seek refuge with You, my Lord, lest they come near me.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 21',
      subtitle: 'Protection from Satan/Shaytan',
      category: 'Protection Dua',
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      transliteration: 'Aoothu billaahi minash-Shaytaanir-rajeem.',
      translation: 'I seek refuge with Allah from Satan, the outcast.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 22',
      subtitle: 'Protection from Satan/Shaytan',
      category: 'Protection Dua',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration: 'Aoothu bikalimaatil-laahit-taammaati min sharri maa khalaqa.',
      translation:
          'I seek refuge in the Perfect Words of Allah from the evil of what He has created.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 23',
      subtitle: 'Protection from wrongdoers',
      category: 'Protection Dua',
      arabic:
          'عَلَى اللَّهِ تَوَكَّلْنَا، رَبَّنَا لَا تَجْعَلْنَا فِتْنَةً لِلْقَوْمِ الظَّالِمِينَ، وَنَجِّنَا بِرَحْمَتِكَ مِنَ الْقَوْمِ الْكَافِرِينَ',
      transliteration:
          'Alal Allahi tawakkalna, Rabbana la tajalna fitnatal lil-qawmidh-dhalimeen, wa najjina bi-rahmatika minal-qawmil-kafireen.',
      translation:
          'Upon Allah do we rely. Our Lord, do not make us a trial for wrongdoing people, and save us by Your mercy from the disbelieving people.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 24',
      subtitle: 'Protection from wrongdoers',
      category: 'Protection Dua',
      arabic:
          'رَبَّنَا إِنَّكَ تَعْلَمُ مَا نُخْفِي وَمَا نُعْلِنُ، وَمَا يَخْفَى عَلَى اللَّهِ مِنْ شَيْءٍ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
      transliteration:
          'Rabbana innaka talamu ma nukhfi wa ma nulin, wa ma yakhfa alal-lahi min shayin fil-ardi wa la fis-samaa.',
      translation:
          'Our Lord, You know what we conceal and what we reveal, and nothing is hidden from Allah on earth or in heaven.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 25',
      subtitle: 'Protection from wrongdoers',
      category: 'Protection Dua',
      arabic: 'رَبَّنَا إِنَّنَا نَخَافُ أَنْ يَفْرُطَ عَلَيْنَا أَوْ أَنْ يَطْغَى',
      transliteration: 'Rabbana innana nakhafu an yafruta alayna aw an yatgha.',
      translation:
          'Our Lord, we fear that he may hasten against us or transgress all bounds.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 26',
      subtitle: 'Protection from wrongdoers',
      category: 'Protection Dua',
      arabic:
          'عَلَى اللَّهِ تَوَكَّلْنَا، رَبَّنَا لَا تَجْعَلْنَا فِتْنَةً لِلْقَوْمِ الظَّالِمِينَ، وَنَجِّنَا بِرَحْمَتِكَ مِنَ الْقَوْمِ الْكَافِرِينَ',
      transliteration:
          'Alal Allahi tawakkalna, Rabbana la tajalna fitnatal lil-qawmidh-dhalimeen, wa najjina bi-rahmatika minal-qawmil-kafireen.',
      translation:
          'Upon Allah do we rely. Our Lord, do not make us a trial for wrongdoing people, and save us by Your mercy from the disbelieving people.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 27',
      subtitle: 'Protection from foolishness',
      category: 'Protection Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ، أَوْ أُضَلَّ، أَوْ أَزِلَّ، أَوْ أُزَلَّ، أَوْ أَظْلِمَ، أَوْ أُظْلَمَ، أَوْ أَجْهَلَ، أَوْ يُجْهَلَ عَلَيَّ',
      transliteration:
          "Allaahumma innee aoothu bika an adhilla, aw udhalla, aw azilla, aw uzalla, aw adhlima, aw udhlama, aw ajhala aw yujhala alayya.",
      translation:
          'O Allah, I seek refuge in You lest I misguide others or am misguided, lest I cause others to err or am caused to err, lest I wrong others or am wronged, and lest I behave foolishly or am treated foolishly.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Protection Dua 28',
      subtitle: 'Seek protection from culprits',
      category: 'Protection Dua',
      arabic:
          'رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي فَغَفَرَ لَهُ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ، رَبِّ بِمَا أَنْعَمْتَ عَلَيَّ فَلَنْ أَكُونَ ظَهِيرًا لِلْمُجْرِمِينَ، رَبِّ نَجِّنِي مِنَ الْقَوْمِ الظَّالِمِينَ',
      transliteration:
          'Rabbi innee thalamtu nafsee faghfir lee faghafara lahu innahu Huwal-Ghafoorur-Raheem. Rabbi bima anamta alayya falan akoona thaheeran lil-mujrimeen. Rabbi najjinee minal-qawmidh-dhalimeen.',
      translation:
          'My Lord, indeed I have wronged myself, so forgive me. My Lord, because of the favor You have bestowed upon me, I will never support the criminals. My Lord, save me from the wrongdoing people.',
      icon: Icons.shield_outlined,
    ),
    _DuaItem(
      title: 'Anxiety Dua 1',
      subtitle: 'Fear of committing shirk',
      category: 'Anxiety Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ، وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ',
      transliteration:
          "Allaahumma innee aoothu bika an ushrika bika wa ana alamu, wa astaghfiruka limaa laa alamu.",
      translation:
          'O Allah, I seek refuge in You lest I associate anything with You knowingly, and I seek Your forgiveness for what I do not know.',
      icon: Icons.spa_rounded,
    ),
    _DuaItem(
      title: 'Anxiety Dua 2',
      subtitle: 'For curbing fear',
      category: 'Anxiety Dua',
      arabic: 'اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ',
      transliteration: "Allaahummak-fineehim bimaa shita.",
      translation: 'O Allah, suffice me against them however You wish.',
      icon: Icons.spa_rounded,
    ),
    _DuaItem(
      title: 'Parents Dua 1',
      subtitle: 'For parents and offspring',
      category: 'Parents Dua',
      arabic:
          'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي، رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      transliteration:
          "Rabbij-alnee muqeemas-salaati wa min dhurriyyatee, Rabbanaa wa taqabbal duaa.",
      translation:
          'O my Lord, make me one who establishes prayer, and also from my offspring. Our Lord, accept my invocation.',
      icon: Icons.diversity_1_rounded,
    ),
    _DuaItem(
      title: 'Parents Dua 2',
      subtitle: 'Mercy for parents',
      category: 'Parents Dua',
      arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration: 'Rabbi irhamhuma kama rabbayani sagheera.',
      translation:
          'My Lord, have mercy upon them as they brought me up when I was small.',
      icon: Icons.diversity_1_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 1',
      subtitle: 'Halal provision and sufficiency',
      category: 'Rizq Dua',
      arabic:
          'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      transliteration:
          'Allahumma ikfinee bihalalika an haramika, wa aghninee bifadlika amman siwak.',
      translation:
          'O Allah, suffice me with what You have made lawful instead of what You have made unlawful, and make me independent through Your bounty from needing anyone besides You.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 2',
      subtitle: 'Allah\'s bounty and mercy',
      category: 'Rizq Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ وَرَحْمَتِكَ، فَإِنَّهُ لَا يَمْلِكُهَا إِلَّا أَنْتَ',
      transliteration:
          'Allahumma innee asaluka min fadlika wa rahmatika, fa innahu la yamlikuha illa Ant.',
      translation:
          'O Allah, I ask You of Your bounty and Your mercy, for none possesses them except You.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 3',
      subtitle: 'Need for every good',
      category: 'Rizq Dua',
      arabic: 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      transliteration: 'Rabbi innee lima anzalta ilayya min khayrin faqeer.',
      translation:
          'My Lord, indeed I am in need of whatever good You send down to me.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 4',
      subtitle: 'Provision with safety and faith',
      category: 'Rizq Dua',
      arabic:
          'رَبِّ اجْعَلْ هَٰذَا بَلَدًا آمِنًا وَارْزُقْ أَهْلَهُ مِنَ الثَّمَرَاتِ مَنْ آمَنَ مِنْهُمْ بِاللَّهِ وَالْيَوْمِ الْآخِرِ',
      transliteration:
          "Rabbij-al hatha baladan aminan warzuq ahlahu minath-thamarati man amana minhum billahi wal-yawmil-akhir.",
      translation:
          'My Lord, make this a secure land and provide its people with fruits, those of them who believe in Allah and the Last Day.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 5',
      subtitle: 'Barakah in measures and provision',
      category: 'Rizq Dua',
      arabic: 'اللَّهُمَّ بَارِكْ لَهُمْ فِي مِكْيَالِهِمْ وَصَاعِهِمْ وَمُدِّهِمْ',
      transliteration:
          'Allahumma barik lahum fee mikyalihim wa saihim wa muddihim.',
      translation:
          'O Allah, bless them in their measures, their Sa, and their Mudd.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 6',
      subtitle: 'Increase and barakah',
      category: 'Rizq Dua',
      arabic:
          'اللَّهُمَّ أَكْثِرْ مَالِي وَوَلَدِي وَبَارِكْ لِي فِيمَا أَعْطَيْتَنِي',
      transliteration:
          "Allahumma akthir malee wa waladee wa barik lee feema ataytanee.",
      translation:
          'O Allah, increase my wealth and my children, and bless me in what You have given me.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Rizq Dua 7',
      subtitle: 'Complete wellbeing and sustenance',
      category: 'Rizq Dua',
      arabic: 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
      transliteration:
          'Allahummaghfir lee, warhamnee, wahdinee, wa afinee, warzuqnee.',
      translation:
          'O Allah, forgive me, have mercy on me, guide me, grant me wellbeing, and grant me sustenance.',
      icon: Icons.auto_awesome_rounded,
    ),
    _DuaItem(
      title: 'Knowledge Dua 1',
      subtitle: 'Increase in knowledge',
      category: 'Knowledge Dua',
      arabic: 'رَبِّ زِدْنِي عِلْمًا',
      transliteration: 'Rabbi zidni ilma.',
      translation: 'My Lord, increase me in knowledge.',
      icon: Icons.school_rounded,
    ),
    _DuaItem(
      title: 'Knowledge Dua 2',
      subtitle: 'Beneficial knowledge',
      category: 'Knowledge Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
      transliteration:
          'Allahumma innee asaluka ilman nafian, wa rizqan tayyiban, wa amalan mutaqabbala.',
      translation:
          'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
      icon: Icons.school_rounded,
    ),
    _DuaItem(
      title: 'Knowledge Dua 3',
      subtitle: 'Benefit from what is learned',
      category: 'Knowledge Dua',
      arabic:
          'اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي، وَعَلِّمْنِي مَا يَنْفَعُنِي، وَزِدْنِي عِلْمًا',
      transliteration:
          'Allahumman-fanee bima allamtanee, wa allimnee ma yanfaunee, wa zidnee ilma.',
      translation:
          'O Allah, benefit me with what You have taught me, teach me what will benefit me, and increase me in knowledge.',
      icon: Icons.school_rounded,
    ),
    _DuaItem(
      title: 'Knowledge Dua 4',
      subtitle: 'Wisdom and right understanding',
      category: 'Knowledge Dua',
      arabic:
          'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      transliteration:
          'Rabbana atina mil-ladunka rahmatan wa hayyi lana min amrina rashada.',
      translation:
          'Our Lord, grant us mercy from Yourself and guide our affair for us in the right way.',
      icon: Icons.school_rounded,
    ),
    _DuaItem(
      title: 'Knowledge Dua 5',
      subtitle: 'Clarity in speech and learning',
      category: 'Knowledge Dua',
      arabic:
          'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي، وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي، يَفْقَهُوا قَوْلِي',
      transliteration:
          'Rabbish-rah lee sadree, wa yassir lee amree, wahlul uqdatan min lisanee, yafqahoo qawlee.',
      translation:
          'My Lord, expand my chest, ease my task for me, untie the knot from my tongue, so they may understand my speech.',
      icon: Icons.school_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 1',
      subtitle: 'The straight path',
      category: 'Guidance Dua',
      arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      transliteration: 'Ihdinas-siratal-mustaqeem.',
      translation: 'Guide us to the straight path.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 2',
      subtitle: 'Protection after guidance',
      category: 'Guidance Dua',
      arabic:
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
      transliteration:
          'Rabbana la tuzigh quloobana bada ith hadaytana wa hab lana mil-ladunka rahmah, innaka Antal-Wahhab.',
      translation:
          'Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from Yourself. Surely, You are the Bestower.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 3',
      subtitle: 'Guidance, piety, and contentment',
      category: 'Guidance Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      transliteration:
          'Allahumma innee asalukal-huda wat-tuqa wal-afafa wal-ghina.',
      translation:
          'O Allah, I ask You for guidance, piety, chastity, and contentment.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 4',
      subtitle: 'Guidance and correctness',
      category: 'Guidance Dua',
      arabic: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
      transliteration: 'Allahummah-dinee wa saddidnee.',
      translation: 'O Allah, guide me and keep me correct.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 5',
      subtitle: 'Steadfast guidance',
      category: 'Guidance Dua',
      arabic:
          'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      transliteration:
          'Rabbana afrigh alayna sabran wa thabbit aqdamana wansurna alal-qawmil-kafireen.',
      translation:
          'Our Lord, pour patience upon us, make our feet firm, and grant us victory over the disbelieving people.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Guidance Dua 6',
      subtitle: 'Guidance in decisions',
      category: 'Guidance Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ',
      transliteration:
          'Allahumma innee astakheeruka bi ilmika, wa astaqdiruka bi qudratika, wa asaluka min fadlikal-adheem.',
      translation:
          'O Allah, I seek Your guidance through Your knowledge, seek ability through Your power, and ask You from Your great bounty.',
      icon: Icons.explore_rounded,
    ),
    _DuaItem(
      title: 'Gratitude Dua 1',
      subtitle: 'Gratitude for Allah\'s favors',
      category: 'Gratitude Dua',
      arabic:
          'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَصْلِحْ لِي فِي ذُرِّيَّتِي إِنِّي تُبْتُ إِلَيْكَ وَإِنِّي مِنَ الْمُسْلِمِينَ',
      transliteration:
          'Rabbi awzinee an ashkura nimataka allatee anamta alayya wa ala walidayya, wa an amala salihan tardahu, wa aslih lee fee dhurriyyatee, innee tubtu ilayka wa innee minal-muslimeen.',
      translation:
          'My Lord, inspire me to be grateful for Your favor which You have bestowed upon me and my parents, to do righteous deeds that please You, and make my offspring righteous. I repent to You, and I am among the Muslims.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Gratitude Dua 2',
      subtitle: 'Praise for every blessing',
      category: 'Gratitude Dua',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ',
      transliteration:
          'Alhamdu lillaahil-lathee bini-matihi tatimmus-saalihaat.',
      translation:
          'All praise is for Allah, by whose blessing righteous deeds are completed.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Gratitude Dua 3',
      subtitle: 'Remembering and thanking Allah',
      category: 'Gratitude Dua',
      arabic:
          'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      transliteration:
          'Allahumma a-innee ala dhikrika wa shukrika wa husni ibadatik.',
      translation:
          'O Allah, help me to remember You, thank You, and worship You in the best manner.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Gratitude Dua 4',
      subtitle: 'Food, shelter, and sufficiency',
      category: 'Gratitude Dua',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ',
      transliteration:
          'Alhamdu lillaahil-lathee atamana wa saqana wa kafana wa awana, fakam mimman la kafiya lahu wa la muwi.',
      translation:
          'All praise is for Allah, who fed us, gave us drink, sufficed us, and sheltered us. How many are there who have none to suffice them or shelter them.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Gratitude Dua 5',
      subtitle: 'Morning gratitude',
      category: 'Gratitude Dua',
      arabic:
          'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
      transliteration:
          'Allahumma ma asbaha bee min nimatin aw bi-ahadin min khalqika faminka wahdaka la shareeka lak, falakal-hamdu wa lakash-shukr.',
      translation:
          'O Allah, whatever blessing has come to me or to any of Your creation this morning is from You alone, without partner. To You belongs all praise and thanks.',
      icon: Icons.volunteer_activism_rounded,
    ),
    _DuaItem(
      title: 'Patience Dua 1',
      subtitle: 'Patience and steadfastness',
      category: 'Patience Dua',
      arabic:
          'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      transliteration:
          'Rabbana afrigh alayna sabran wa thabbit aqdamana wansurna alal-qawmil-kafireen.',
      translation:
          'Our Lord, pour patience upon us, make our feet firm, and grant us victory over the disbelieving people.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Patience Dua 2',
      subtitle: 'Patience and submission',
      category: 'Patience Dua',
      arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
      transliteration:
          'Rabbana afrigh alayna sabran wa tawaffana muslimeen.',
      translation:
          'Our Lord, pour patience upon us and let us die as Muslims in submission to You.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Patience Dua 3',
      subtitle: 'Beautiful patience',
      category: 'Patience Dua',
      arabic: 'فَصَبْرٌ جَمِيلٌ وَاللَّهُ الْمُسْتَعَانُ عَلَىٰ مَا تَصِفُونَ',
      transliteration:
          'Fa sabrun jameel, wallahul-musta-anu ala ma tasifoon.',
      translation:
          'So beautiful patience is most fitting, and Allah is the One whose help is sought against what you describe.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Patience Dua 4',
      subtitle: 'Help through patience and prayer',
      category: 'Patience Dua',
      arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا',
      transliteration: 'Rabbana afrigh alayna sabra.',
      translation: 'Our Lord, pour patience upon us.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Patience Dua 5',
      subtitle: 'Relief with trust in Allah',
      category: 'Patience Dua',
      arabic: 'إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ',
      transliteration: 'Innama ashkoo baththee wa huznee ilallah.',
      translation:
          'I only complain of my suffering and my grief to Allah.',
      icon: Icons.self_improvement_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 1',
      subtitle: 'Complete healing',
      category: 'Health Dua',
      arabic:
          'اللَّهُمَّ رَبَّ النَّاسِ مُذْهِبَ الْبَاسِ اشْفِ أَنْتَ الشَّافِي، لَا شَافِيَ إِلَّا أَنْتَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      transliteration:
          'Allahumma Rabban-nasi, mudhhibal-bas, ishfi Antash-Shafi, la shafiya illa Ant, shifaan la yughadiru saqama.',
      translation:
          'O Allah, Lord of mankind, remover of suffering, heal, for You are the Healer. There is no healing except Your healing, a healing that leaves no illness.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 2',
      subtitle: 'Afiyah in this life and the next',
      category: 'Health Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      transliteration:
          'Allahumma innee asalukal-afwa wal-afiyah fid-dunya wal-akhirah.',
      translation:
          'O Allah, I ask You for forgiveness and wellbeing in this world and in the Hereafter.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 3',
      subtitle: 'Wellbeing in body, hearing, and sight',
      category: 'Health Dua',
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
      transliteration:
          'Allahumma afinee fee badanee, Allahumma afinee fee samee, Allahumma afinee fee basaree, la ilaha illa Ant.',
      translation:
          'O Allah, grant wellbeing to my body. O Allah, grant wellbeing to my hearing. O Allah, grant wellbeing to my sight. There is no deity except You.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 4',
      subtitle: 'Relief from pain',
      category: 'Health Dua',
      arabic:
          'بِسْمِ اللَّهِ، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
      transliteration:
          'Bismillah. Aoothu billahi wa qudratihi min sharri ma ajidu wa uhadhir.',
      translation:
          'In the name of Allah. I seek refuge in Allah and His power from the evil of what I feel and fear.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 5',
      subtitle: 'Protection from losing wellbeing',
      category: 'Health Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
      transliteration:
          'Allahumma innee aoothu bika min zawali nimatika, wa tahawwuli afiyatika, wa fujaati niqmatika, wa jamee-i sakhatik.',
      translation:
          'O Allah, I seek refuge in You from the withdrawal of Your blessing, the loss of Your wellbeing, the suddenness of Your punishment, and all that displeases You.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Health Dua 6',
      subtitle: 'Wellbeing, provision, and accepted deeds',
      category: 'Health Dua',
      arabic: 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
      transliteration:
          'Allahummaghfir lee, warhamnee, wahdinee, wa afinee, warzuqnee.',
      translation:
          'O Allah, forgive me, have mercy on me, guide me, grant me wellbeing, and grant me sustenance.',
      icon: Icons.health_and_safety_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 1',
      subtitle: 'Complete shifa from sickness',
      category: 'Illness Dua',
      arabic:
          'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      transliteration:
          'Allahumma Rabban-nasi, adh-hibil-bas, ishfi Antash-Shafi, la shifaa illa shifa-uk, shifaan la yughadiru saqama.',
      translation:
          'O Allah, Lord of mankind, remove the harm and heal, for You are the Healer. There is no healing except Your healing, a healing that leaves no sickness.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 2',
      subtitle: 'Pain relief',
      category: 'Illness Dua',
      arabic:
          'بِسْمِ اللَّهِ، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
      transliteration:
          'Bismillah. Aoothu billahi wa qudratihi min sharri ma ajidu wa uhadhir.',
      translation:
          'In the name of Allah. I seek refuge in Allah and His power from the evil of what I feel and fear.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 3',
      subtitle: 'For someone who is sick',
      category: 'Illness Dua',
      arabic: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
      transliteration:
          'Asalullahal-Adheema Rabbal-Arshil-Adheemi an yashfiyak.',
      translation:
          'I ask Allah, the Magnificent, Lord of the Magnificent Throne, to cure you.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 4',
      subtitle: 'Purification through illness',
      category: 'Illness Dua',
      arabic: 'لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
      transliteration: 'La basa tahoorun in sha Allah.',
      translation:
          'Do not worry; it will be a purification, if Allah wills.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 5',
      subtitle: 'Ayyub عليه السلام dua',
      category: 'Illness Dua',
      arabic: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ',
      transliteration: 'Annee massaniyad-durru wa Anta arhamur-rahimeen.',
      translation:
          'Indeed, adversity has touched me, and You are the Most Merciful of the merciful.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Illness Dua 6',
      subtitle: 'Protection from severe diseases',
      category: 'Illness Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْبَرَصِ، وَالْجُنُونِ، وَالْجُذَامِ، وَمِنْ سَيِّئِ الْأَسْقَامِ',
      transliteration:
          'Allahumma innee aoothu bika minal-barasi, wal-junooni, wal-judhami, wa min sayyi-il-asqam.',
      translation:
          'O Allah, I seek refuge in You from leprosy, madness, mutilating disease, and from evil illnesses.',
      icon: Icons.healing_rounded,
    ),
    _DuaItem(
      title: 'Rain Dua 1',
      subtitle: 'Asking Allah for rain',
      category: 'Rain Dua',
      arabic:
          'اللَّهُمَّ اسْقِنَا غَيْثًا مُغِيثًا، مَرِيعًا، نَافِعًا غَيْرَ ضَارٍّ، عَاجِلًا غَيْرَ آجِلٍ',
      transliteration:
          'Allahumma isqina ghaythan mugheethan, mareean, nafian ghayra darrin, ajilan ghayra ajil.',
      translation:
          'O Allah, give us rain that is helpful, abundant, beneficial, not harmful, soon and not delayed.',
      icon: Icons.water_drop_rounded,
    ),
    _DuaItem(
      title: 'Rain Dua 2',
      subtitle: 'When rain falls',
      category: 'Rain Dua',
      arabic: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
      transliteration: 'Allahumma sayyiban nafian.',
      translation: 'O Allah, make it a beneficial downpour.',
      icon: Icons.water_drop_rounded,
    ),
    _DuaItem(
      title: 'Rain Dua 3',
      subtitle: 'After it rains',
      category: 'Rain Dua',
      arabic: 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
      transliteration: 'Mutirna bifadlillahi wa rahmatih.',
      translation:
          'We have been given rain by the bounty of Allah and His mercy.',
      icon: Icons.water_drop_rounded,
    ),
    _DuaItem(
      title: 'Rain Dua 4',
      subtitle: 'When rain becomes excessive',
      category: 'Rain Dua',
      arabic:
          'اللَّهُمَّ حَوَالَيْنَا وَلَا عَلَيْنَا، اللَّهُمَّ عَلَى الْآكَامِ وَالظِّرَابِ، وَبُطُونِ الْأَوْدِيَةِ، وَمَنَابِتِ الشَّجَرِ',
      transliteration:
          'Allahumma hawalayna wa la alayna. Allahumma alal-akami wadh-dhirabi, wa butunil-awdiyati, wa manabitish-shajar.',
      translation:
          'O Allah, let the rain fall around us and not upon us. O Allah, let it fall on the hills, small mountains, valley bottoms, and places where trees grow.',
      icon: Icons.water_drop_rounded,
    ),
    _DuaItem(
      title: 'Rain Dua 5',
      subtitle: 'Good of rain and wind',
      category: 'Rain Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا فِيهَا وَخَيْرَ مَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ مَا فِيهَا وَشَرِّ مَا أُرْسِلَتْ بِهِ',
      transliteration:
          'Allahumma innee asaluka khayraha wa khayra ma feeha wa khayra ma ursilat bihi, wa aoothu bika min sharriha wa sharri ma feeha wa sharri ma ursilat bihi.',
      translation:
          'O Allah, I ask You for its good, the good within it, and the good it was sent with. I seek refuge in You from its evil, the evil within it, and the evil it was sent with.',
      icon: Icons.water_drop_rounded,
    ),
    _DuaItem(
      title: 'Marriage Dua 1',
      subtitle: 'Righteous spouse and family',
      category: 'Marriage Dua',
      arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      transliteration:
          'Rabbana hab lana min azwajina wa dhurriyyatina qurrata ayunin wajalna lil-muttaqeena imama.',
      translation:
          'Our Lord, grant us from among our spouses and offspring comfort to our eyes, and make us leaders for the righteous.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Marriage Dua 2',
      subtitle: 'Need for good from Allah',
      category: 'Marriage Dua',
      arabic: 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      transliteration: 'Rabbi innee lima anzalta ilayya min khayrin faqeer.',
      translation:
          'My Lord, indeed I am in need of whatever good You send down to me.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Marriage Dua 3',
      subtitle: 'Blessing for a marriage',
      category: 'Marriage Dua',
      arabic: 'بَارَكَ اللَّهُ لَكَ، وَبَارَكَ عَلَيْكَ، وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ',
      transliteration:
          'Barakallahu laka, wa baraka alayka, wa jamaa baynakuma fee khayr.',
      translation:
          'May Allah bless for you, bless upon you, and unite you both in goodness.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Marriage Dua 4',
      subtitle: 'Good in this world and the next',
      category: 'Marriage Dua',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar.',
      translation:
          'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      icon: Icons.favorite_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 1',
      subtitle: 'Righteous children',
      category: 'Children Dua',
      arabic: 'رَبِّ هَبْ لِي مِنَ الصَّالِحِينَ',
      transliteration: 'Rabbi hab lee minas-saliheen.',
      translation: 'My Lord, grant me offspring from among the righteous.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 2',
      subtitle: 'Pure offspring',
      category: 'Children Dua',
      arabic:
          'رَبِّ هَبْ لِي مِنْ لَدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاءِ',
      transliteration:
          'Rabbi hab lee mil-ladunka dhurriyyatan tayyibah, innaka Sameeud-dua.',
      translation:
          'My Lord, grant me from Yourself good offspring. Surely, You are the Hearer of supplication.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 3',
      subtitle: 'Children who establish prayer',
      category: 'Children Dua',
      arabic:
          'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      transliteration:
          'Rabbij-alnee muqeemas-salati wa min dhurriyyatee, Rabbana wa taqabbal dua.',
      translation:
          'My Lord, make me one who establishes prayer, and also from my offspring. Our Lord, accept my supplication.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 4',
      subtitle: 'Family comfort and righteousness',
      category: 'Children Dua',
      arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      transliteration:
          'Rabbana hab lana min azwajina wa dhurriyyatina qurrata ayunin wajalna lil-muttaqeena imama.',
      translation:
          'Our Lord, grant us from among our spouses and offspring comfort to our eyes, and make us leaders for the righteous.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 5',
      subtitle: 'Protection for children',
      category: 'Children Dua',
      arabic:
          'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      transliteration:
          'Ueedhukuma bikalimatillahit-tammati min kulli shaytanin wa hammah, wa min kulli aynin lammah.',
      translation:
          'I seek protection for you both in the perfect words of Allah from every devil and poisonous creature, and from every harmful eye.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 6',
      subtitle: 'Prophet Zakariyya dua for children',
      category: 'Children Dua',
      arabic:
          'رَبِّ هَبْ لِي مِنْ لَدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاءِ',
      transliteration:
          'Rabbi hab lee mil-ladunka dhurriyyatan tayyibah, innaka Sameeud-dua.',
      translation:
          'My Lord, grant me from Yourself good offspring. Surely, You are the Hearer of supplication.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 7',
      subtitle: 'Prophet Ibrahim dua for a righteous child',
      category: 'Children Dua',
      arabic: 'رَبِّ هَبْ لِي مِنَ الصَّالِحِينَ',
      transliteration: 'Rabbi hab lee minas-saliheen.',
      translation: 'My Lord, grant me offspring from among the righteous.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 8',
      subtitle: 'No heir except Allah',
      category: 'Children Dua',
      arabic: 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنْتَ خَيْرُ الْوَارِثِينَ',
      transliteration: 'Rabbi la tadharnee fardan wa Anta khayrul-waritheen.',
      translation:
          'My Lord, do not leave me alone without offspring, though You are the best of inheritors.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Children Dua 9',
      subtitle: 'Righteous family and offspring',
      category: 'Children Dua',
      arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      transliteration:
          'Rabbana hab lana min azwajina wa dhurriyyatina qurrata ayunin wajalna lil-muttaqeena imama.',
      translation:
          'Our Lord, grant us from among our spouses and offspring comfort to our eyes, and make us leaders for the righteous.',
      icon: Icons.child_care_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 1',
      subtitle: 'Talbiyah',
      category: 'Hajj & Umrah Dua',
      arabic:
          'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
      transliteration:
          'Labbayka Allahumma labbayk, labbayka la shareeka laka labbayk, innal-hamda wan-nimata laka wal-mulk, la shareeka lak.',
      translation:
          'Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Surely all praise, blessing, and dominion belong to You. You have no partner.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 2',
      subtitle: 'Intention for Umrah',
      category: 'Hajj & Umrah Dua',
      arabic: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
      transliteration: 'Labbayka Allahumma umrah.',
      translation: 'Here I am, O Allah, for Umrah.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 3',
      subtitle: 'Intention for Hajj',
      category: 'Hajj & Umrah Dua',
      arabic: 'لَبَّيْكَ اللَّهُمَّ حَجًّا',
      transliteration: 'Labbayka Allahumma hajjan.',
      translation: 'Here I am, O Allah, for Hajj.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 4',
      subtitle: 'Entering the sacred mosque',
      category: 'Hajj & Umrah Dua',
      arabic:
          'بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      transliteration:
          'Bismillah, was-salatu was-salamu ala Rasoolillah. Allahummaftah lee abwaba rahmatik.',
      translation:
          'In the name of Allah, and prayers and peace be upon the Messenger of Allah. O Allah, open for me the gates of Your mercy.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 5',
      subtitle: 'Beginning Tawaf',
      category: 'Hajj & Umrah Dua',
      arabic: 'بِسْمِ اللَّهِ، اللَّهُ أَكْبَرُ',
      transliteration: 'Bismillah, Allahu Akbar.',
      translation: 'In the name of Allah. Allah is the Greatest.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 6',
      subtitle: 'Between Rukn Yamani and the Black Stone',
      category: 'Hajj & Umrah Dua',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar.',
      translation:
          'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 7',
      subtitle: 'At Maqam Ibrahim',
      category: 'Hajj & Umrah Dua',
      arabic: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
      transliteration: 'Wattakhidhoo min maqami Ibraheema musalla.',
      translation: 'Take the station of Ibrahim as a place of prayer.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 8',
      subtitle: 'Before Sa’i at Safa and Marwa',
      category: 'Hajj & Umrah Dua',
      arabic:
          'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
      transliteration: 'Innas-Safa wal-Marwata min shaairillah.',
      translation:
          'Indeed, Safa and Marwa are among the symbols of Allah.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 9',
      subtitle: 'Dhikr on Safa and Marwa',
      category: 'Hajj & Umrah Dua',
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      transliteration:
          'La ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamd, wa Huwa ala kulli shayin qadeer.',
      translation:
          'There is no deity except Allah alone, without partner. To Him belongs the dominion and praise, and He has power over all things.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 10',
      subtitle: 'Day of Arafah',
      category: 'Hajj & Umrah Dua',
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      transliteration:
          'La ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamd, wa Huwa ala kulli shayin qadeer.',
      translation:
          'There is no deity except Allah alone, without partner. To Him belongs the dominion and praise, and He has power over all things.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 11',
      subtitle: 'Drinking Zamzam',
      category: 'Hajj & Umrah Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا وَاسِعًا، وَشِفَاءً مِنْ كُلِّ دَاءٍ',
      transliteration:
          'Allahumma innee asaluka ilman nafian, wa rizqan wasian, wa shifaan min kulli da.',
      translation:
          'O Allah, I ask You for beneficial knowledge, abundant provision, and cure from every illness.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Hajj & Umrah Dua 12',
      subtitle: 'Forgiveness after pilgrimage',
      category: 'Hajj & Umrah Dua',
      arabic:
          'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ، وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      transliteration:
          'Rabbana taqabbal minna innaka Antas-Sameeul-Aleem, wa tub alayna innaka Antat-Tawwabur-Raheem.',
      translation:
          'Our Lord, accept from us. Surely You are the All-Hearing, the All-Knowing. Accept our repentance, for You are the Ever-Relenting, the Most Merciful.',
      icon: Icons.account_balance_rounded,
    ),
    _DuaItem(
      title: 'Istikhara Dua 1',
      subtitle: 'Full Salat al-Istikhara dua',
      category: 'Istikhara Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ. اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ. وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ، وَاقْدُرْ لِيَ الْخَيْرَ حَيْثُ كَانَ ثُمَّ أَرْضِنِي',
      transliteration:
          'Allahumma innee astakheeruka bi ilmika, wa astaqdiruka bi qudratika, wa asaluka min fadlikal-adheem. Fa innaka taqdiru wa la aqdir, wa talamu wa la alam, wa Anta Allamul-ghuyoob. Allahumma in kunta talamu anna hathal-amra khayrun lee fee deenee wa maashee wa aqibati amree, faqdurhu lee wa yassirhu lee thumma barik lee feeh. Wa in kunta talamu anna hathal-amra sharrun lee fee deenee wa maashee wa aqibati amree, fasrifhu annee wasrifnee anh, waqdur liyal-khayra haythu kana thumma ardinee.',
      translation:
          'O Allah, I seek Your choice by Your knowledge, seek ability by Your power, and ask You from Your great bounty. If You know this matter is good for my religion, livelihood, and outcome, decree it for me, make it easy, and bless it for me. If You know it is bad for me, turn it away from me and turn me away from it, decree good for me wherever it is, then make me pleased with it.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Istikhara Dua 2',
      subtitle: 'Guidance and correctness',
      category: 'Istikhara Dua',
      arabic: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
      transliteration: 'Allahummah-dinee wa saddidnee.',
      translation: 'O Allah, guide me and keep me correct.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Istikhara Dua 3',
      subtitle: 'Ease in decisions',
      category: 'Istikhara Dua',
      arabic:
          'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي',
      transliteration: 'Rabbish-rah lee sadree, wa yassir lee amree.',
      translation: 'My Lord, expand my chest and ease my affair for me.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Istikhara Dua 4',
      subtitle: 'Ask for the best outcome',
      category: 'Istikhara Dua',
      arabic:
          'رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَلْ لِي مِنْ لَدُنْكَ سُلْطَانًا نَصِيرًا',
      transliteration:
          'Rabbi adkhilnee mudkhala sidqin wa akhrijnee mukhraja sidqin wajal lee mil-ladunka sultanan naseera.',
      translation:
          'My Lord, let my entry be truthful, let my exit be truthful, and grant me from Yourself a supporting authority.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Istikhara Dua 5',
      subtitle: 'Good in this world and the next',
      category: 'Istikhara Dua',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar.',
      translation:
          'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    _DuaItem(
      title: 'Death Dua 1',
      subtitle: 'For the deceased',
      category: 'Death Dua',
      arabic: 'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ',
      transliteration:
          'Allahummaghfir lahu warhamhu, wa afihi wafu anhu.',
      translation:
          'O Allah, forgive him, have mercy on him, grant him wellbeing, and pardon him.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 2',
      subtitle: 'For a deceased woman',
      category: 'Death Dua',
      arabic: 'اللَّهُمَّ اغْفِرْ لَهَا وَارْحَمْهَا، وَعَافِهَا وَاعْفُ عَنْهَا',
      transliteration:
          'Allahummaghfir laha warhamha, wa afiha wafu anha.',
      translation:
          'O Allah, forgive her, have mercy on her, grant her wellbeing, and pardon her.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 3',
      subtitle: 'Janazah dua',
      category: 'Death Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ، وَنَقِّهِ مِنَ الْخَطَايَا كَمَا نَقَّيْتَ الثَّوْبَ الْأَبْيَضَ مِنَ الدَّنَسِ، وَأَبْدِلْهُ دَارًا خَيْرًا مِنْ دَارِهِ، وَأَهْلًا خَيْرًا مِنْ أَهْلِهِ، وَزَوْجًا خَيْرًا مِنْ زَوْجِهِ، وَأَدْخِلْهُ الْجَنَّةَ، وَأَعِذْهُ مِنْ عَذَابِ الْقَبْرِ وَعَذَابِ النَّارِ',
      transliteration:
          'Allahummaghfir lahu warhamhu, wa afihi wafu anhu, wa akrim nuzulahu, wa wassi mudkhalahu, waghsilhu bil-mai wath-thalji wal-barad, wa naqqihi minal-khataya kama naqqaytath-thawbal-abyada minad-danas, wa abdilhu daran khayran min darihi, wa ahlan khayran min ahlihi, wa zawjan khayran min zawjihi, wa adkhilhul-jannah, wa aidhhu min adh abil-qabri wa adh abin-nar.',
      translation:
          'O Allah, forgive him, have mercy on him, pardon him, honor his arrival, expand his entrance, wash him with water, snow, and hail, purify him from sins, replace his home and family with better, admit him to Paradise, and protect him from the punishment of the grave and Fire.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 4',
      subtitle: 'For the living and the dead',
      category: 'Death Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا، وَشَاهِدِنَا وَغَائِبِنَا، وَصَغِيرِنَا وَكَبِيرِنَا، وَذَكَرِنَا وَأُنْثَانَا، اللَّهُمَّ مَنْ أَحْيَيْتَهُ مِنَّا فَأَحْيِهِ عَلَى الْإِسْلَامِ، وَمَنْ تَوَفَّيْتَهُ مِنَّا فَتَوَفَّهُ عَلَى الْإِيمَانِ',
      transliteration:
          'Allahummaghfir lihayyina wa mayyitina, wa shahidina wa ghaibina, wa sagheerina wa kabeerina, wa dhakarina wa unthana. Allahumma man ahyaytahu minna fa ahyihi alal-Islam, wa man tawaffaytahu minna fatawaffahu alal-iman.',
      translation:
          'O Allah, forgive our living and our dead, those present and absent, young and old, male and female. Whoever You keep alive among us, keep alive upon Islam, and whoever You take from us, take upon faith.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 5',
      subtitle: 'When hearing of death',
      category: 'Death Dua',
      arabic: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
      transliteration: 'Inna lillahi wa inna ilayhi rajiun.',
      translation: 'Indeed we belong to Allah, and indeed to Him we will return.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 6',
      subtitle: 'Visiting graves',
      category: 'Death Dua',
      arabic:
          'السَّلَامُ عَلَيْكُمْ أَهْلَ الدِّيَارِ مِنَ الْمُؤْمِنِينَ وَالْمُسْلِمِينَ، وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَلَاحِقُونَ، أَسْأَلُ اللَّهَ لَنَا وَلَكُمُ الْعَافِيَةَ',
      transliteration:
          'As-salamu alaykum ahlad-diyari minal-mumineena wal-muslimeen, wa inna in sha Allahu bikum lala h iqoon, asalullaha lana wa lakumul-afiyah.',
      translation:
          'Peace be upon you, inhabitants of these dwellings, among the believers and Muslims. We will, if Allah wills, join you. I ask Allah for wellbeing for us and for you.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 7',
      subtitle: 'Light and spaciousness in the grave',
      category: 'Death Dua',
      arabic:
          'اللَّهُمَّ اغْفِرْ لَهُ، وَارْفَعْ دَرَجَتَهُ فِي الْمَهْدِيِّينَ، وَاخْلُفْهُ فِي عَقِبِهِ فِي الْغَابِرِينَ، وَاغْفِرْ لَنَا وَلَهُ يَا رَبَّ الْعَالَمِينَ، وَافْسَحْ لَهُ فِي قَبْرِهِ، وَنَوِّرْ لَهُ فِيهِ',
      transliteration:
          'Allahummaghfir lahu, warfa darajatahu fil-mahdiyyeen, wakhlufhu fee aqibihi fil-ghabireen, waghfir lana wa lahu ya Rabbal-alameen, wafsah lahu fee qabrihi, wa nawwir lahu feeh.',
      translation:
          'O Allah, forgive him, raise his rank among the guided, care for those he leaves behind, forgive us and him, O Lord of the worlds, expand his grave for him, and illuminate it for him.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 8',
      subtitle: 'For deceased parents',
      category: 'Death Dua',
      arabic: 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration:
          'Rabbighfir lee wa liwalidayya warhamhuma kama rabbayanee sagheera.',
      translation:
          'My Lord, forgive me and my parents, and have mercy on them as they raised me when I was small.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 9',
      subtitle: 'Protection from grave punishment',
      category: 'Death Dua',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَمِنْ عَذَابِ النَّارِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ',
      transliteration:
          'Allahumma innee aoothu bika min adh abil-qabri, wa min adh abin-nar, wa min fitnatil-mahya wal-mamat, wa min fitnatil-maseehid-dajjal.',
      translation:
          'O Allah, I seek refuge in You from the punishment of the grave, the punishment of the Fire, the trials of life and death, and the trial of the False Messiah.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Death Dua 10',
      subtitle: 'A good ending upon faith',
      category: 'Death Dua',
      arabic:
          'رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ',
      transliteration:
          'Rabbana faghfir lana dhunoobana wa kaffir anna sayyiatina wa tawaffana maal-abrar.',
      translation:
          'Our Lord, forgive us our sins, remove from us our misdeeds, and cause us to die among the righteous.',
      icon: Icons.nights_stay_outlined,
    ),
    _DuaItem(
      title: 'Ramadan Dua 1',
      subtitle: 'Beginning Ramadan with faith',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْيُمْنِ وَالْإِيمَانِ، وَالسَّلَامَةِ وَالْإِسْلَامِ',
      transliteration: 'Allahumma ahillahu alayna bil-yumni wal-iman, was-salamati wal-Islam.',
      translation: 'O Allah, bring this month upon us with blessing, faith, safety, and Islam.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 2',
      subtitle: 'Intention to fast',
      category: 'Ramadan Dua',
      arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ أَدَاءِ فَرْضِ شَهْرِ رَمَضَانَ لِلَّهِ تَعَالَى',
      transliteration: 'Nawaytu sawma ghadin an adai fardi shahri Ramadan lillahi taala.',
      translation: 'I intend to fast tomorrow to fulfill the obligation of Ramadan for Allah Most High.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 3',
      subtitle: 'Suhoor blessing',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ بَارِكْ لَنَا فِي سُحُورِنَا وَقَوِّنَا عَلَى الصِّيَامِ',
      transliteration: 'Allahumma barik lana fee suhoorina wa qawwina alas-siyam.',
      translation: 'O Allah, bless our suhoor and strengthen us for fasting.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 4',
      subtitle: 'Breaking the fast',
      category: 'Ramadan Dua',
      arabic: 'ذَهَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      transliteration: 'Dhahabadh-dhama, wabtallatil-urooq, wa thabatal-ajru in sha Allah.',
      translation: 'The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 5',
      subtitle: 'Iftar gratitude',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ لَكَ صُمْتُ، وَعَلَى رِزْقِكَ أَفْطَرْتُ',
      transliteration: 'Allahumma laka sumtu, wa ala rizqika aftartu.',
      translation: 'O Allah, for You I fasted, and with Your provision I broke my fast.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 6',
      subtitle: 'Laylatul Qadr',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      transliteration: 'Allahumma innaka Afuwwun tuhibbul-afwa fafu annee.',
      translation: 'O Allah, You are Pardoning and love pardon, so pardon me.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 7',
      subtitle: 'Forgiveness in Ramadan',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا',
      transliteration: 'Rabbana faghfir lana dhunoobana wa kaffir anna sayyiatina.',
      translation: 'Our Lord, forgive our sins and remove from us our misdeeds.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 8',
      subtitle: 'Mercy in Ramadan',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا آمَنَّا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
      transliteration: 'Rabbana amanna faghfir lana warhamna wa Anta khayrur-rahimeen.',
      translation: 'Our Lord, we believe, so forgive us and have mercy on us; You are the best of those who show mercy.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 9',
      subtitle: 'Protection from Hellfire',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا اصْرِفْ عَنَّا عَذَابَ جَهَنَّمَ إِنَّ عَذَابَهَا كَانَ غَرَامًا',
      transliteration: 'Rabbana isrif anna adhaba jahannam, inna adh abaha kana gharama.',
      translation: 'Our Lord, avert from us the punishment of Hell; indeed, its punishment is clinging.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 10',
      subtitle: 'Good in both worlds',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration: 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar.',
      translation: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 11',
      subtitle: 'Accepted worship',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
      transliteration: 'Rabbana taqabbal minna innaka Antas-Sameeul-Aleem.',
      translation: 'Our Lord, accept from us. Surely, You are the All-Hearing, the All-Knowing.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 12',
      subtitle: 'Accepted repentance',
      category: 'Ramadan Dua',
      arabic: 'وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      transliteration: 'Wa tub alayna innaka Antat-Tawwabur-Raheem.',
      translation: 'Accept our repentance. Surely, You are the Ever-Relenting, the Most Merciful.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 13',
      subtitle: 'Beneficial knowledge',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
      transliteration: 'Allahumma innee asaluka ilman nafian, wa rizqan tayyiban, wa amalan mutaqabbala.',
      translation: 'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 14',
      subtitle: 'Help with worship',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      transliteration: 'Allahumma a-innee ala dhikrika wa shukrika wa husni ibadatik.',
      translation: 'O Allah, help me remember You, thank You, and worship You beautifully.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 15',
      subtitle: 'Guidance and piety',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      transliteration: 'Allahumma innee asalukal-huda wat-tuqa wal-afafa wal-ghina.',
      translation: 'O Allah, I ask You for guidance, piety, chastity, and contentment.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 16',
      subtitle: 'A sound heart',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
      transliteration: 'Rabbana la tuzigh quloobana bada ith hadaytana.',
      translation: 'Our Lord, do not let our hearts deviate after You have guided us.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 17',
      subtitle: 'Gift of mercy',
      category: 'Ramadan Dua',
      arabic: 'وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
      transliteration: 'Wa hab lana mil-ladunka rahmah, innaka Antal-Wahhab.',
      translation: 'Grant us mercy from Yourself. Surely, You are the Bestower.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 18',
      subtitle: 'Patience in fasting',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
      transliteration: 'Rabbana afrigh alayna sabran wa tawaffana muslimeen.',
      translation: 'Our Lord, pour patience upon us and let us die as Muslims.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 19',
      subtitle: 'Quran reflection',
      category: 'Ramadan Dua',
      arabic: 'رَبِّ زِدْنِي عِلْمًا',
      transliteration: 'Rabbi zidni ilma.',
      translation: 'My Lord, increase me in knowledge.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 20',
      subtitle: 'Need for every good',
      category: 'Ramadan Dua',
      arabic: 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      transliteration: 'Rabbi innee lima anzalta ilayya min khayrin faqeer.',
      translation: 'My Lord, I am truly in need of whatever good You send down to me.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 21',
      subtitle: 'Protection from shirk',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ، وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ',
      transliteration: 'Allahumma innee aoothu bika an ushrika bika wa ana alam, wa astaghfiruka lima la alam.',
      translation: 'O Allah, I seek refuge in You from knowingly associating partners with You, and I seek Your forgiveness for what I do not know.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 22',
      subtitle: 'Seeking Allah’s pleasure',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِرِضَاكَ مِنْ سَخَطِكَ',
      transliteration: 'Allahumma innee aoothu biridaka min sakhatik.',
      translation: 'O Allah, I seek refuge in Your pleasure from Your anger.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 23',
      subtitle: 'Seeking pardon',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ',
      transliteration: 'Allahumma innee asalukal-afwa wal-afiyah.',
      translation: 'O Allah, I ask You for pardon and wellbeing.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 24',
      subtitle: 'Freedom from Hellfire',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
      transliteration: 'Allahumma ajirnee minan-nar.',
      translation: 'O Allah, save me from the Fire.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 25',
      subtitle: 'Paradise in Ramadan',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ',
      transliteration: 'Allahumma innee asalukal-jannah.',
      translation: 'O Allah, I ask You for Paradise.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 26',
      subtitle: 'Protection from the Fire',
      category: 'Ramadan Dua',
      arabic: 'وَأَعُوذُ بِكَ مِنَ النَّارِ',
      transliteration: 'Wa aoothu bika minan-nar.',
      translation: 'And I seek refuge in You from the Fire.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 27',
      subtitle: 'Forgive all sins',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ، دِقَّهُ وَجِلَّهُ، وَأَوَّلَهُ وَآخِرَهُ، وَعَلَانِيَتَهُ وَسِرَّهُ',
      transliteration: 'Allahummaghfir lee dhanbee kullahu, diqqahu wa jillahu, wa awwalahu wa akhirahu, wa alaniyatahu wa sirrahu.',
      translation: 'O Allah, forgive all my sins: small and great, first and last, public and private.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 28',
      subtitle: 'Master of forgiveness',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      transliteration: 'Allahumma Anta Rabbee la ilaha illa Ant, khalaqtanee wa ana abduk, faghfir lee fa innahu la yaghfiruth-thunooba illa Ant.',
      translation: 'O Allah, You are my Lord; none has the right to be worshipped but You. You created me and I am Your servant, so forgive me, for none forgives sins except You.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 29',
      subtitle: 'Taraweeh sincerity',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اجْعَلْ عَمَلِي كُلَّهُ صَالِحًا، وَاجْعَلْهُ لِوَجْهِكَ خَالِصًا',
      transliteration: 'Allahummaj-al amalee kullahu salihan, wajalhu liwajhika khalisa.',
      translation: 'O Allah, make all my deeds righteous and make them sincerely for Your face.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 30',
      subtitle: 'Qiyam and night prayer',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ نُورُ السَّمَاوَاتِ وَالْأَرْضِ',
      transliteration: 'Allahumma lakal-hamd, Anta noorus-samawati wal-ard.',
      translation: 'O Allah, all praise is Yours; You are the Light of the heavens and the earth.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 31',
      subtitle: 'Steadfast prayer',
      category: 'Ramadan Dua',
      arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      transliteration: 'Rabbij-alnee muqeemas-salati wa min dhurriyyatee, Rabbana wa taqabbal dua.',
      translation: 'My Lord, make me one who establishes prayer, and also from my offspring. Our Lord, accept my supplication.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 32',
      subtitle: 'Family righteousness',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
      transliteration: 'Rabbana hab lana min azwajina wa dhurriyyatina qurrata ayun.',
      translation: 'Our Lord, grant us from our spouses and offspring comfort to our eyes.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 33',
      subtitle: 'Parents in Ramadan',
      category: 'Ramadan Dua',
      arabic: 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration: 'Rabbighfir lee wa liwalidayya warhamhuma kama rabbayanee sagheera.',
      translation: 'My Lord, forgive me and my parents, and have mercy on them as they raised me when I was small.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 34',
      subtitle: 'Charity and provision',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ أَنْفِقْ عَلَيَّ وَلَا تُنْفِقْ مِنِّي',
      transliteration: 'Allahumma anfiq alayya wa la tunfiq minnee.',
      translation: 'O Allah, spend upon me and do not take away from me.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 35',
      subtitle: 'Halal provision',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      transliteration: 'Allahumma ikfinee bihalalika an haramika, wa aghninee bifadlika amman siwak.',
      translation: 'O Allah, suffice me with what You made lawful instead of unlawful, and enrich me by Your bounty from needing anyone besides You.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 36',
      subtitle: 'Good character while fasting',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اهْدِنِي لِأَحْسَنِ الْأَخْلَاقِ، لَا يَهْدِي لِأَحْسَنِهَا إِلَّا أَنْتَ',
      transliteration: 'Allahummah-dinee li-ahsanil-akhlaq, la yahdee li-ahsaniha illa Ant.',
      translation: 'O Allah, guide me to the best character; none guides to the best of it except You.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 37',
      subtitle: 'Guarding the tongue',
      category: 'Ramadan Dua',
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي، وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي',
      transliteration: 'Rabbish-rah lee sadree, wa yassir lee amree, wahlul uqdatan min lisanee.',
      translation: 'My Lord, expand my chest, ease my task, and untie the knot from my tongue.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 38',
      subtitle: 'Protection from laziness',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      transliteration: 'Allahumma innee aoothu bika minal-ajzi wal-kasal.',
      translation: 'O Allah, I seek refuge in You from helplessness and laziness.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 39',
      subtitle: 'Health for worship',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      transliteration: 'Allahumma afinee fee badanee, Allahumma afinee fee samee, Allahumma afinee fee basaree.',
      translation: 'O Allah, grant wellbeing to my body, hearing, and sight.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 40',
      subtitle: 'Healing and strength',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي',
      transliteration: 'Allahumma Rabban-nasi adh-hibil-bas, ishfi Antash-Shafi.',
      translation: 'O Allah, Lord of mankind, remove harm and heal, for You are the Healer.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 41',
      subtitle: 'Protection from Shaytan',
      category: 'Ramadan Dua',
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      transliteration: 'Aoothu billahi minash-shaytanir-rajeem.',
      translation: 'I seek refuge in Allah from Satan, the outcast.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 42',
      subtitle: 'Protection from evil',
      category: 'Ramadan Dua',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration: 'Aoothu bikalimatillahit-tammati min sharri ma khalaq.',
      translation: 'I seek refuge in the perfect words of Allah from the evil of what He created.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 43',
      subtitle: 'Light of Quran',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اجْعَلِ الْقُرْآنَ رَبِيعَ قَلْبِي وَنُورَ صَدْرِي',
      transliteration: 'Allahummaj-alil-Qurana rabeea qalbee wa noora sadree.',
      translation: 'O Allah, make the Quran the spring of my heart and the light of my chest.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 44',
      subtitle: 'Ease after hardship',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      transliteration: 'Rabbana atina mil-ladunka rahmatan wa hayyi lana min amrina rashada.',
      translation: 'Our Lord, grant us mercy from Yourself and guide our affair in the right way.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 45',
      subtitle: 'Sincere repentance',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      transliteration: 'Rabbana zalamna anfusana wa il lam taghfir lana wa tarhamna lanakoonanna minal-khasireen.',
      translation: 'Our Lord, we have wronged ourselves. If You do not forgive us and have mercy on us, we will surely be among the losers.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 46',
      subtitle: 'Last ten nights',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ بَلِّغْنَا لَيْلَةَ الْقَدْرِ وَاجْعَلْنَا فِيهَا مِنَ الْمَقْبُولِينَ',
      transliteration: 'Allahumma ballighna Laylat al-Qadr wajalna feeha minal-maqboolin.',
      translation: 'O Allah, let us reach Laylatul Qadr and make us among those accepted in it.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 47',
      subtitle: 'Accepted fasting',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ تَقَبَّلْ صِيَامَنَا وَقِيَامَنَا وَصَالِحَ أَعْمَالِنَا',
      transliteration: 'Allahumma taqabbal siyamana wa qiyamana wa saliha amalina.',
      translation: 'O Allah, accept our fasting, our night prayer, and our righteous deeds.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 48',
      subtitle: 'End Ramadan forgiven',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ اجْعَلْنَا مِمَّنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا فَغُفِرَ لَهُ',
      transliteration: 'Allahummaj-alna mimman sama Ramadan imanan wa ihtisaban faghufira lah.',
      translation: 'O Allah, make us among those who fast Ramadan with faith and hope for reward, and are forgiven.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 49',
      subtitle: 'Consistent worship after Ramadan',
      category: 'Ramadan Dua',
      arabic: 'اللَّهُمَّ ثَبِّتْنَا عَلَى طَاعَتِكَ بَعْدَ رَمَضَانَ',
      transliteration: 'Allahumma thabbitna ala taatika bada Ramadan.',
      translation: 'O Allah, keep us firm upon Your obedience after Ramadan.',
      icon: Icons.dark_mode_rounded,
    ),
    _DuaItem(
      title: 'Ramadan Dua 50',
      subtitle: 'A blessed ending',
      category: 'Ramadan Dua',
      arabic: 'رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا إِنَّكَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      transliteration: 'Rabbana atmim lana noorana waghfir lana innaka ala kulli shayin qadeer.',
      translation: 'Our Lord, perfect our light for us and forgive us. Surely, You are over all things capable.',
      icon: Icons.dark_mode_rounded,
    ),
  ];

  static List<_DuaItem> _withoutDuplicateTransliterations(
    List<_DuaItem> duas,
  ) {
    final seen = <String>{};
    final uniqueDuas = <_DuaItem>[];

    for (final dua in duas) {
      final shouldDedupe =
          dua.category == 'Morning Dua' || dua.category == 'Evening Dua';
      if (!shouldDedupe) {
        uniqueDuas.add(dua);
        continue;
      }

      final key = dua.displayTransliteration.trim();
      if (key.isEmpty || seen.add(key)) {
        uniqueDuas.add(dua);
      }
    }

    return uniqueDuas;
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat(reverse: true);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleDuas = _withoutDuplicateTransliterations(_duas).where((dua) {
      final normalizedQuery = _normalizeSearch(_query);
      final matchesCategory = _query.isNotEmpty ||
          _activeCategory.isEmpty ||
          dua.category == _activeCategory;
      final searchText = _normalizeSearch(
        [
          dua.title,
          dua.subtitle,
          dua.category,
          dua.displayArabic,
          dua.displayTransliteration,
          dua.polishedTranslation,
        ].join(' '),
      );
      final matchesSearch =
          normalizedQuery.isEmpty || searchText.contains(normalizedQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glow = _glowController.value;
        return Scaffold(
          backgroundColor: _DuaColors.background,
          body: Stack(
            children: [
              Positioned.fill(child: _DuaAtmosphere(glow: glow)),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 118),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _TopBar(
                            onBack: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                          ).animate().fadeIn(duration: 380.ms).slideY(begin: -0.08),
                          const SizedBox(height: 18),
                          _HeroCard(glow: glow)
                              .animate()
                              .fadeIn(delay: 70.ms)
                              .slideY(begin: 0.06),
                          const SizedBox(height: 18),
                          _SearchBar(
                            controller: _searchController,
                            focused: _isSearchFocused,
                            hasQuery: _query.isNotEmpty,
                            onClear: () {
                              HapticFeedback.selectionClick();
                              _searchController.clear();
                            },
                            onFilterTap: _showAllCategoriesPanel,
                            onFocusChange: (focused) {
                              setState(() => _isSearchFocused = focused);
                            },
                          ).animate().fadeIn(delay: 130.ms).slideY(begin: 0.05),
                          const SizedBox(height: 22),
                          _SectionHeader(
                            title: 'Categories',
                            action: 'View All',
                            onAction: _showAllCategoriesPanel,
                          ),
                          const SizedBox(height: 14),
                          _CategoryRail(
                            categories: _categories,
                            activeCategory: _activeCategory,
                            onSelected: (category) {
                              setState(() => _activeCategory = category);
                            },
                          ).animate().fadeIn(delay: 180.ms),
                          const SizedBox(height: 26),
                          _FavoritesStrip(
                            bookmarks: _bookmarks.length,
                            continueTitle:
                                _expanded.isNotEmpty ? _expanded.first : 'Morning Dua',
                          ).animate().fadeIn(delay: 230.ms).slideY(begin: 0.05),
                          const SizedBox(height: 26),
                          _SectionHeader(
                            title: _query.isNotEmpty
                                ? 'Search Results'
                                : (_activeCategory.isEmpty
                                    ? 'Popular Dua\'s'
                                    : _activeCategory),
                            action: _query.isNotEmpty
                                ? '${visibleDuas.length} found'
                                : 'View All',
                            onAction: () {
                              if (_query.isNotEmpty) return;
                              setState(() {
                                _activeCategory =
                                    _activeCategory.isEmpty ? 'Morning Dua' : _activeCategory;
                              });
                            },
                          ),
                          if (_query.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _SearchSummary(
                              query: _searchController.text.trim(),
                              onClear: _searchController.clear,
                            ),
                          ],
                          const SizedBox(height: 14),
                          for (var i = 0; i < visibleDuas.length; i++) ...[
                            _DuaCard(
                              dua: visibleDuas[i],
                              bookmarked: _bookmarks.contains(visibleDuas[i].title),
                              expanded: _expanded.contains(visibleDuas[i].title),
                              onBookmark: () => _toggleBookmark(visibleDuas[i].title),
                              onToggleExpanded: () =>
                                  _toggleExpanded(visibleDuas[i].title),
                            ).animate().fadeIn(delay: (260 + i * 70).ms).slideY(begin: 0.06),
                            const SizedBox(height: 10),
                          ],
                          if (visibleDuas.isEmpty)
                            const _EmptyDuaState()
                                .animate()
                                .fadeIn(delay: 260.ms)
                                .slideY(begin: 0.05),
                          const SizedBox(height: 8),
                          _ClosingBanner(glow: glow)
                              .animate()
                              .fadeIn(delay: 320.ms)
                              .slideY(begin: 0.06),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _normalizeSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), ' ')
        .trim();
  }

  void _showAllCategoriesPanel() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (sheetContext) {
        return _AllCategoriesSheet(
          categories: _categories,
          activeCategory: _activeCategory,
          onSelected: (category) {
            Navigator.of(sheetContext).pop();
            setState(() => _activeCategory = category);
          },
          onShowAll: () {
            Navigator.of(sheetContext).pop();
            setState(() => _activeCategory = '');
          },
        );
      },
    );
  }

  void _toggleBookmark(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_bookmarks.contains(title)) {
        _bookmarks.remove(title);
      } else {
        _bookmarks.add(title);
      }
    });
  }

  void _toggleExpanded(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expanded.contains(title)) {
        _expanded.remove(title);
      } else {
        _expanded.add(title);
      }
    });
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconGlassButton(icon: Icons.chevron_left_rounded, onTap: onBack),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Dua\'s',
                  style: GoogleFonts.cinzel(
                    color: _DuaColors.ivory,
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _MiniOrnament(),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Supplications for every moment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _DuaColors.secondary,
                        fontSize: 13,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  _MiniOrnament(reverse: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _IconGlassButton(icon: Icons.bookmark_border_rounded, onTap: () {}),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double glow;
  const _HeroCard({required this.glow});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: 30,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/dua_premium_hero.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _DuaColors.card,
                        _DuaColors.card.withValues(alpha: 0.92),
                        _DuaColors.card.withValues(alpha: 0.38),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 22,
                bottom: 22,
                right: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _DuaColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _DuaColors.gold.withValues(alpha: 0.32),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: _DuaColors.gold.withValues(alpha: 0.95),
                            size: 15,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Today\'s Reflection',
                            style: GoogleFonts.inter(
                              color: _DuaColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Daily Duas',
                      style: GoogleFonts.cinzel(
                        color: _DuaColors.ivory,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Strengthen your connection with Allah',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _DuaColors.secondary,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 18 + (glow * 8),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _DuaColors.deep.withValues(alpha: 0.72),
                    border: Border.all(
                      color: _DuaColors.gold.withValues(alpha: 0.40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _DuaColors.gold.withValues(alpha: 0.16 + glow * 0.10),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.light_mode_rounded,
                    color: _DuaColors.gold,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool focused;
  final bool hasQuery;
  final VoidCallback onClear;
  final VoidCallback? onFilterTap;
  final ValueChanged<bool> onFocusChange;

  const _SearchBar({
    required this.controller,
    required this.focused,
    required this.hasQuery,
    required this.onClear,
    this.onFilterTap,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _DuaColors.rich.withValues(alpha: focused ? 0.82 : 0.64),
              _DuaColors.deep.withValues(alpha: 0.82),
            ],
          ),
          border: Border.all(
            color: focused
                ? _DuaColors.gold.withValues(alpha: 0.82)
                : _DuaColors.gold.withValues(alpha: 0.30),
          ),
          boxShadow: [
            BoxShadow(
              color: _DuaColors.gold.withValues(alpha: focused ? 0.18 : 0.06),
              blurRadius: focused ? 26 : 16,
              spreadRadius: focused ? 1 : 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: const Color(0xFFF6F0E2),
                  border: Border.all(
                    color: focused
                        ? _DuaColors.gold.withValues(alpha: 0.50)
                        : _DuaColors.gold.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: _DuaColors.gold, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        cursorColor: _DuaColors.gold,
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search Dua...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.black.withValues(alpha: 0.46),
                            fontSize: 14,
                            height: 1.0,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: hasQuery
                          ? InkWell(
                              key: const ValueKey('clear-search'),
                              onTap: onClear,
                              borderRadius: BorderRadius.circular(99),
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                              ),
                            )
                          : const SizedBox(key: ValueKey('empty-search'), width: 0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SearchIconButton(
              icon: Icons.tune_rounded,
              tooltip: 'Filter',
              onTap: onFilterTap ?? () => HapticFeedback.selectionClick(),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _SearchIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SearchIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _DuaColors.deep.withValues(alpha: 0.72),
            border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.38)),
          ),
          child: Icon(icon, color: _DuaColors.gold, size: 23),
        ),
      ),
    );
  }
}

class _SearchSummary extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _SearchSummary({
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing matches for "$query"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _DuaColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: onClear,
          style: TextButton.styleFrom(
            foregroundColor: _DuaColors.gold,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Clear',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cinzel(
              color: _DuaColors.ivory,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: _DuaColors.gold,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            action,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  final List<_DuaCategory> categories;
  final String activeCategory;
  final ValueChanged<String> onSelected;

  const _CategoryRail({
    required this.categories,
    required this.activeCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 36;
    final chipWidth = (availableWidth - 5 * 6) / 6;

    return SizedBox(
      height: 58,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category.name == activeCategory;
          return _CategoryChip(
            category: category,
            active: active,
            width: chipWidth.clamp(48.0, 78.0),
            onTap: () => onSelected(category.name),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _DuaCategory category;
  final bool active;
  final double width;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.active,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.02 : 1,
      duration: const Duration(milliseconds: 220),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: active
                  ? [
                      _DuaColors.gold.withValues(alpha: 0.20),
                      _DuaColors.rich.withValues(alpha: 0.68),
                    ]
                  : [
                      _DuaColors.rich.withValues(alpha: 0.62),
                      _DuaColors.deep.withValues(alpha: 0.70),
                    ],
            ),
            border: Border.all(
              color: active
                  ? _DuaColors.gold.withValues(alpha: 0.82)
                  : _DuaColors.gold.withValues(alpha: 0.26),
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: _DuaColors.gold.withValues(alpha: 0.18),
                  blurRadius: 12,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: _DuaColors.gold, size: 19),
              const SizedBox(height: 4),
              Text(
                category.name.replaceAll(' Dua', ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: active ? _DuaColors.ivory : _DuaColors.secondary,
                  fontSize: 9.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllCategoriesSheet extends StatelessWidget {
  final List<_DuaCategory> categories;
  final String activeCategory;
  final ValueChanged<String> onSelected;
  final VoidCallback onShowAll;

  const _AllCategoriesSheet({
    required this.categories,
    required this.activeCategory,
    required this.onSelected,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.72,
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _DuaColors.card.withValues(alpha: 0.96),
                    _DuaColors.rich.withValues(alpha: 0.90),
                    _DuaColors.deep.withValues(alpha: 0.96),
                  ],
                ),
                border: Border.all(
                  color: _DuaColors.gold.withValues(alpha: 0.36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.42),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: _DuaColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All Categories',
                          style: GoogleFonts.cinzel(
                            color: _DuaColors.ivory,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _SmallActionButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AllCategoryTile(
                    icon: Icons.apps_rounded,
                    label: 'All Duas',
                    active: activeCategory.isEmpty,
                    onTap: onShowAll,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.42,
                      ),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _AllCategoryTile(
                          icon: category.icon,
                          label: category.name.replaceAll(' Dua', ''),
                          active: category.name == activeCategory,
                          onTap: () => onSelected(category.name),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllCategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _AllCategoryTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: active
              ? _DuaColors.gold.withValues(alpha: 0.15)
              : _DuaColors.background.withValues(alpha: 0.42),
          border: Border.all(
            color: active
                ? _DuaColors.gold.withValues(alpha: 0.72)
                : _DuaColors.gold.withValues(alpha: 0.22),
          ),
          boxShadow: [
            if (active)
              BoxShadow(
                color: _DuaColors.gold.withValues(alpha: 0.12),
                blurRadius: 16,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _DuaColors.gold, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: active ? _DuaColors.ivory : _DuaColors.secondary,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesStrip extends StatelessWidget {
  final int bookmarks;
  final String continueTitle;

  const _FavoritesStrip({
    required this.bookmarks,
    required this.continueTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.bookmark_rounded,
            label: 'Saved Duas',
            value: '$bookmarks saved',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.history_rounded,
            label: 'Recently Read',
            value: continueTitle,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _DuaColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.32)),
            ),
            child: Icon(icon, color: _DuaColors.gold, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _DuaColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _DuaColors.ivory,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final _DuaItem dua;
  final bool bookmarked;
  final bool expanded;
  final VoidCallback onBookmark;
  final VoidCallback onToggleExpanded;

  const _DuaCard({
    required this.dua,
    required this.bookmarked,
    required this.expanded,
    required this.onBookmark,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final arabicText = dua.displayArabic;
    final translationText = dua.polishedTranslation;
    final expandedArabicFontSize = arabicText.length > 220 ? 21.0 : 27.0;

    return _GlassPanel(
      radius: 22,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(minHeight: expanded ? 0 : 114),
          padding: EdgeInsets.fromLTRB(12, expanded ? 16 : 10, 10, expanded ? 16 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DuaThumbnail(icon: dua.icon, compact: !expanded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dua.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cinzel(
                                  color: _DuaColors.ivory,
                                  fontSize: expanded ? 22 : 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          _SmallActionButton(
                            icon: bookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            onTap: onBookmark,
                            compact: !expanded,
                          ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dua.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _DuaColors.secondary,
                            fontSize: expanded ? 13 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: expanded ? 12 : 5),
                        if (expanded)
                          _CategoryLabel(label: dua.category)
                        else ...[
                          Text(
                            arabicText.isEmpty
                                ? dua.displayTransliteration
                                : arabicText,
                            textAlign:
                                arabicText.isEmpty ? TextAlign.left : TextAlign.right,
                            textDirection:
                                arabicText.isEmpty ? TextDirection.ltr : TextDirection.rtl,
                            textWidthBasis: TextWidthBasis.parent,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: arabicText.isEmpty
                                ? GoogleFonts.inter(
                                    color: _DuaColors.ivory.withValues(alpha: 0.88),
                                    fontSize: 12,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  )
                                : GoogleFonts.notoNaskhArabic(
                                    color: _DuaColors.gold,
                                    fontSize: 15,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                if (arabicText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      arabicText,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      textWidthBasis: TextWidthBasis.parent,
                      style: GoogleFonts.notoNaskhArabic(
                        color: _DuaColors.gold,
                        fontSize: expandedArabicFontSize,
                        height: arabicText.length > 220 ? 1.75 : 2.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _ExpandedTextSection(
                  title: 'TRANSLITERATION',
                  text: dua.displayTransliteration,
                  style: GoogleFonts.inter(
                    color: _DuaColors.ivory.withValues(alpha: 0.90),
                    fontSize: 13.5,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _ExpandedTextSection(
                  title: 'TRANSLATION',
                  text: translationText,
                  style: GoogleFonts.inter(
                    color: _DuaColors.secondary,
                    fontSize: 13,
                    height: 1.65,
                  ),
                ),
              ],
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeOutCubic,
                crossFadeState:
                    expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      _CategoryLabel(label: dua.category, compact: true),
                      const Spacer(),
                      _SmallActionButton(
                        icon: Icons.play_arrow_rounded,
                        onTap: () => HapticFeedback.selectionClick(),
                        compact: true,
                      ),
                      _SmallActionButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        onTap: onToggleExpanded,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                secondChild: _ExpandedDuaDetails(
                  dua: dua,
                  bookmarked: bookmarked,
                  onBookmark: onBookmark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedDuaDetails extends StatelessWidget {
  final _DuaItem dua;
  final bool bookmarked;
  final VoidCallback onBookmark;

  const _ExpandedDuaDetails({
    required this.dua,
    required this.bookmarked,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: _DuaColors.gold.withValues(alpha: 0.18)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionPill(
                  icon: Icons.ios_share_rounded,
                  label: 'Share',
                  onTap: () => HapticFeedback.selectionClick(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionPill(
                  icon: bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: bookmarked ? 'Saved' : 'Save',
                  onTap: onBookmark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionPill(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            '${dua.displayArabic}\n\n${dua.displayTransliteration}\n\n${dua.polishedTranslation}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandedTextSection extends StatelessWidget {
  final String title;
  final String text;
  final TextStyle style;

  const _ExpandedTextSection({
    required this.title,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: _DuaColors.gold,
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          SelectableText(
            text,
            textAlign: TextAlign.left,
            style: style,
          ),
        ],
      ),
    );
  }
}

class _ClosingBanner extends StatelessWidget {
  final double glow;
  const _ClosingBanner({required this.glow});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: 28,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 204,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/dua_premium_hero.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _DuaColors.card.withValues(alpha: 0.95),
                        _DuaColors.card.withValues(alpha: 0.78),
                        _DuaColors.deep.withValues(alpha: 0.42),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                top: 18,
                bottom: 18,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dua is the essence of worship',
                            style: GoogleFonts.cinzel(
                              color: _DuaColors.ivory,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Make Dua your habit, and see how Allah changes your life.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: _DuaColors.secondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: _DuaColors.gold.withValues(alpha: 0.10),
                              border: Border.all(
                                color: _DuaColors.gold.withValues(alpha: 0.48),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite_border_rounded,
                                  color: _DuaColors.gold.withValues(alpha: 0.96),
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'My Favorite Dua\'s',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: _DuaColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Transform.rotate(
                      angle: -0.05 + glow * 0.10,
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 60,
                        color: _DuaColors.gold.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDuaState extends StatelessWidget {
  const _EmptyDuaState();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      radius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: _DuaColors.gold.withValues(alpha: 0.8),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No duas found',
            style: GoogleFonts.cinzel(
              color: _DuaColors.ivory,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another category or search term.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: _DuaColors.secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DuaThumbnail extends StatelessWidget {
  final IconData icon;
  final bool compact;
  const _DuaThumbnail({required this.icon, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 74.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_DuaColors.rich, _DuaColors.background],
        ),
        border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: _DuaColors.gold.withValues(alpha: 0.12),
            blurRadius: compact ? 14 : 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: Image.asset(
                'assets/images/dua_premium_hero.png',
                fit: BoxFit.cover,
                color: _DuaColors.background.withValues(alpha: 0.18),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          Icon(icon, color: _DuaColors.gold, size: compact ? 23 : 30),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _DuaColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _DuaColors.gold, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _DuaColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _SmallActionButton({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: compact ? 28 : 36,
        height: compact ? 28 : 36,
        child: Icon(icon, color: _DuaColors.gold, size: compact ? 20 : 25),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final String label;
  final bool compact;
  const _CategoryLabel({required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _DuaColors.gold.withValues(alpha: 0.10),
        border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: _DuaColors.gold,
          fontSize: compact ? 9.5 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconGlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _DuaColors.deep.withValues(alpha: 0.76),
          border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.42)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Icon(icon, color: _DuaColors.gold, size: 28),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _GlassPanel({
    required this.child,
    required this.padding,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _DuaColors.card.withValues(alpha: 0.86),
                _DuaColors.rich.withValues(alpha: 0.56),
                _DuaColors.deep.withValues(alpha: 0.78),
              ],
            ),
            border: Border.all(color: _DuaColors.gold.withValues(alpha: 0.34)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: _DuaColors.gold.withValues(alpha: 0.06),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DuaAtmosphere extends StatelessWidget {
  final double glow;
  const _DuaAtmosphere({required this.glow});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DuaBackgroundPainter(glow),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.25 + glow * 0.18, -0.22),
            radius: 1.1,
            colors: [
              _DuaColors.rich.withValues(alpha: 0.62),
              _DuaColors.deep.withValues(alpha: 0.90),
              _DuaColors.background,
            ],
            stops: const [0.0, 0.46, 1],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DuaBackgroundPainter extends CustomPainter {
  final double glow;
  _DuaBackgroundPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = _DuaColors.gold.withValues(alpha: 0.030)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    const step = 42.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, patternPaint);
      }
    }

    final goldGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _DuaColors.gold.withValues(alpha: 0.13 + glow * 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.18, size.height * 0.15),
          radius: size.width * 0.75,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.15),
      size.width * 0.75,
      goldGlow,
    );

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.48),
        ],
        stops: const [0.62, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    final cornerPaint = Paint()
      ..color = _DuaColors.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const r = 44.0;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, r * 2, r * 2),
      math.pi,
      math.pi / 2,
      false,
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DuaBackgroundPainter oldDelegate) =>
      oldDelegate.glow != glow;
}

class _MiniOrnament extends StatelessWidget {
  final bool reverse;
  const _MiniOrnament({this.reverse = false});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(reverse ? -1.0 : 1.0, 1.0, 1.0),
      child: CustomPaint(
        size: const Size(28, 8),
        painter: _MiniOrnamentPainter(),
      ),
    );
  }
}

class _MiniOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _DuaColors.gold.withValues(alpha: 0.78)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    final diamond = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.62, size.height / 2)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(size.width * 0.48, size.height / 2)
      ..close();
    canvas.drawPath(diamond, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _MiniOrnamentPainter oldDelegate) => false;
}

class _DuaCategory {
  final String name;
  final IconData icon;
  const _DuaCategory(this.name, this.icon);
}

class _DuaItem {
  final String title;
  final String subtitle;
  final String category;
  final String arabic;
  final String transliteration;
  final String translation;
  final IconData icon;

  static const Map<String, String> _eveningArabic = {
    'Evening Azkar 1':
        '?????? ??????? ???????????? ??????????\n????????? ??????? ????? ?????????????\n???????????? ??????????\n??????? ?????? ????????\n???????? ???????? ?????????? ???????????\n???????? ?????????? ??????????????\n??????? ????????? ?????????? ?????????? ?????? ???????????? ?????????? ????? ????????????',
    'Evening Azkar 2':
        '?????? ??????? ???????????? ??????????\n???\n??????? ?????????? ??? ?????? ????? ????? ???????????????\n????????? ??????????? ??????????? ???????????? ?????????? ???????? ????????????? ??????????\n??????????? ??????????? ????? ??????? ???????? ????? ??????? ??? ???????? ?????????????? ???? ??????????\n?????????? ?????? ????? ???? ?????????? ???????????? ???? ??????????????',
    'Evening Azkar 3':
        '?????? ??????? ???????????? ??????????\n??????? ??? ??????? ?????? ???? ???????? ??????????? ? ??? ?????????? ?????? ????? ?????? ? ???? ??? ??? ????????????? ????? ??? ????????? ? ??? ??? ??????? ???????? ??????? ?????? ?????????? ? ???????? ??? ?????? ??????????? ????? ?????????? ? ????? ?????????? ???????? ????? ???????? ?????? ????? ????? ? ?????? ??????????? ????????????? ??????????? ? ????? ????????? ??????????? ? ?????? ?????????? ??????????',
    'Evening Azkar 4':
        '??? ????????? ??? ???????? ? ??? ?????????? ????????? ???? ???????? ? ????? ???????? ????????????? ????????? ????????? ?????? ??????????? ????????????? ??????????? ??? ????????? ????? ? ????????? ??????? ???????',
    'Evening Azkar 5':
        '??????? ??????? ????????? ??????? ??????????? ????? ???????????? ????? ???????? ? ??????????? ???????? ??????????????? ??????????? ?????????????? ????? ???????? ????? ???????????? ? ?????????? ????????? ???????? ? ???? ?????? ??????????',
    'Evening Azkar 6':
        '?????? ??????? ???????????? ??????????\n???????? ??? ??? ????????????? ????? ??? ????????? ? ????? ???????? ??? ??? ??????????? ???? ????????? ???????????? ???? ??????? ? ?????????? ????? ??????? ??????????? ??? ??????? ? ????????? ?????? ????? ?????? ???????',
    'Evening Azkar 7':
        '????? ?????????? ????? ??????? ???????? ??? ???????? ???????????????? ? ????? ????? ????????? ??????????????? ?????????? ?????????? ??? ????????? ?????? ?????? ???? ????????? ? ????????? ????????? ??????????? ? ??????????? ???????? ?????????? ??????????',
    'Evening Azkar 8':
        '??? ????????? ??????? ??????? ?????? ????????? ? ????? ??? ???????? ??????????? ??? ??????????? ? ???????? ??? ???????????? ??? ????????? ???? ??????????? ? ???????? ????? ???????? ????????? ??????? ????? ?????????? ????? ????????? ??? ????????? ? ???????? ????? ???????????? ??? ??? ??????? ????? ???? ? ??????? ?????? ????????? ????? ???????????? ? ????? ?????????? ??????????? ????? ????????? ?????????????',
    'Evening Azkar 9':
        '?????? ??????? ???????????? ??????????\n???? ???? ??????? ??????\n??????? ?????????\n???? ?????? ?????? ???????\n?????? ????? ????? ??????? ??????',
    'Evening Azkar 10':
        '?????? ??????? ???????????? ??????????\n???? ??????? ??????? ?????????\n??? ????? ??? ??????\n????? ????? ??????? ????? ??????\n????? ????? ?????????????? ??? ?????????\n????? ????? ??????? ????? ??????',
    'Evening Azkar 11':
        '?????? ??????? ???????????? ??????????\n???? ??????? ??????? ????????\n?????? ????????\n??????? ????????\n??? ????? ???????????? ???????????\n??????? ?????????? ??? ??????? ????????\n???? ?????????? ??????????',
    'Evening Azkar 12':
        '??????????? ????????? ????????? ??????? ??????????? ???????\n??? ??????? ?????? ??????? ???????? ??? ??????? ????\n???? ????????? ?????? ?????????\n??????? ????????? ?????? ?????? ????? ?????? ???????\n????? ?????????? ?????? ??? ??? ??????? ??????????? ???????? ??? ?????????\n????????? ???? ???? ????? ??? ??? ??????? ??????????? ??????? ??? ?????????\n????? ??????? ???? ???? ????????? ??????? ?????????\n????? ??????? ???? ???? ??????? ??? ???????? ????????? ??? ?????????',
    'Evening Azkar 13':
        '??????????? ?????? ???????? ????????????\n???????? ???????? ????????????\n???????? ????? ?????????? ????????? ?\n???????? ??????? ???????? ???????????? ???????? ?????????\n????? ????? ???? ??????????????',
    'Evening Azkar 14':
        '?????????? ???? ???????????\n?????? ???????????\n?????? ???????\n?????? ???????\n?????????? ??????????',
    'Evening Azkar 15':
        '?????????? ?????? ?????????? ?????? ??? ???????? ??????????? ????????\n????????? ??????? ?????????? ????????????? ?????????? ??? ?????????? ????????????',
    'Evening Azkar 16':
        '?????????? ??? ??????? ??? ???? ????????\n???? ???????? ???? ????????\n???????? ???????? ??? ??????? ????\n?????? ????????? ?????? ?????????',
    'Evening Azkar 17':
        '??? ????? ???? ????????? ????? ????????? ????????? ???????? ????????? ???????????',
    'Evening Azkar 18':
        '??????? ????????? ??????\n???????????????? ??????\n????????????? ? ???????? ??????????',
    'Evening Azkar 19':
        '?????????? ?????? ?????????? ????????? ??????????????\n??? ?????????? ????????????\n?????????? ?????? ?????????? ????????? ??????????????\n??? ?????? ??????????? ????????? ????????\n?????????? ??????? ?????????? ??????? ??????????\n?????????? ?????????? ???? ?????? ??????? ?????? ???????\n?????? ???????? ?????? ???????? ?????? ???????\n????????? ???????????? ???? ????????? ???? ???????',
    'Evening Azkar 20':
        '????????? ??????? ????????????\n?????? ????????\n??????? ????????\n???????? ????????\n????????? ???????????',
    'Evening Azkar 21':
        '?????? ??????? ??????? ??? ??????? ???? ??????? ?????? ??? ????????? ????? ??? ??????????\n?????? ?????????? ??????????',
    'Evening Azkar 22':
        '?????????? ?????? ??????? ???? ???? ???????? ???? ??????? ??????????\n???????????????? ????? ??? ??????????',
    'Evening Azkar 23':
        '??????? ??????????? ??????? ???????????? ???? ????? ??? ??????',
    'Evening Azkar 24':
        '?????????? ??????? ????????? ??????????????\n??????? ????????????? ???????????\n????? ????? ?????? ???????????\n???????? ???? ??? ??????? ?????? ??????\n??????? ???? ???? ????? ???????\n?????? ????? ???????????? ??????????\n?????? ?????????? ?????? ??????? ?????? ???? ????????? ?????? ????????',
    'Evening Azkar 25':
        '??? ????? ??? ????????\n???????????? ???????????\n???????? ??? ??????? ???????\n????? ????????? ?????? ??????? ???????? ??????',
    'Evening Azkar 26':
        '?????????? ?????? ?????? ??? ??????? ?????? ??????\n??????????? ??????? ????????\n??????? ?????? ???????? ?????????? ??? ???????????\n??????? ???? ???? ????? ??? ????????\n??????? ???? ???????????? ???????\n????????? ?????????\n????????? ???\n????????? ??? ???????? ?????????? ?????? ??????',
    'Evening Azkar 27':
        '?????????? ?????? ?????????? ??????????\n?????????? ???????? ????????\n???????????????\n????????? ????????\n??????? ?????? ???????\n??? ??????? ?????? ?????? ???????? ??? ??????? ????\n??????? ?????????? ???????? ???????????',
    'Evening Azkar 28':
        '?????????? ???????? ??? ???????\n?????????? ???????? ??? ???????\n?????????? ???????? ??? ???????\n??? ??????? ?????? ??????\n?????????? ?????? ??????? ???? ???? ????????? ???????????\n????????? ???? ???? ??????? ?????????\n??? ??????? ?????? ??????',
    'Evening Azkar 29':
        '???????? ??????? ??? ??????? ?????? ????\n???????? ???????????\n?????? ????? ????????? ??????????',
    'Evening Azkar 30':
        '??? ??????? ?????? ??????? ???????? ??? ??????? ????\n???? ????????? ?????? ?????????\n?????? ?????? ????? ?????? ???????',
    'Evening Azkar 31':
        '????????? ??????? ????????????\n????????? ??????? ??????????',
  };

  static const Map<String, String> _eveningTranslations = {
    'Evening Azkar 1':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nAll praise is due to Allah, Lord of all worlds.\nThe Most Beneficent, the Most Merciful.\nSovereign of the Day of Recompense.\nYou alone we worship, and You alone we ask for help.\nGuide us to the straight path,\nthe path of those upon whom You have bestowed favour, not of those who earned anger, nor of those who went astray.',
    'Evening Azkar 2':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nAlif-Lam-Mim. This is the Book about which there is no doubt, a guidance for those conscious of Allah: those who believe in the unseen, establish prayer, and spend from what Allah has provided; those who believe in what was revealed to you and what was revealed before you, and who are certain of the Hereafter. They are upon guidance from their Lord, and they are the successful.',
    'Evening Azkar 3':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nAllah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness nor sleep overtakes Him. To Him belongs whatever is in the heavens and whatever is on earth. None can intercede with Him except by His permission. He knows what is before them and what is behind them, and they encompass nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and preserving them does not tire Him. He is the Most High, the Most Great.',
    'Evening Azkar 4':
        'There is no compulsion in religion. Truth has become clearly distinct from error. Whoever rejects false gods and believes in Allah has held firmly to the most trustworthy handhold, which never breaks. Allah is All-Hearing, All-Knowing.',
    'Evening Azkar 5':
        'Allah is the protector of those who believe. He brings them out of darkness into light. As for those who disbelieve, their protectors are false gods, bringing them out of light into darkness. They are the companions of the Fire, abiding therein.',
    'Evening Azkar 6':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nTo Allah belongs whatever is in the heavens and whatever is on earth. Whether you reveal what is within yourselves or hide it, Allah will bring you to account for it. He forgives whom He wills and punishes whom He wills, and Allah has power over all things.',
    'Evening Azkar 7':
        'The Messenger believes in what was revealed to him from his Lord, and so do the believers. All believe in Allah, His angels, His books, and His messengers, saying: We make no distinction between any of His messengers. They say: We hear and we obey. Grant us Your forgiveness, our Lord; to You is the final return.',
    'Evening Azkar 8':
        'Allah does not burden a soul beyond its capacity. It will have what good it earned and bear what evil it earned. Our Lord, do not take us to task if we forget or make a mistake. Our Lord, do not place upon us a burden like the one You placed upon those before us. Our Lord, do not burden us with what we cannot bear. Pardon us, forgive us, and have mercy on us. You are our Protector, so grant us victory over the disbelieving people.',
    'Evening Azkar 9':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nSay: He is Allah, the One. Allah, the Self-Sufficient Master. He neither begets nor was He begotten, and there is none comparable to Him.',
    'Evening Azkar 10':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nSay: I seek refuge with the Lord of daybreak, from the evil of what He created, from the evil of darkness when it settles, from the evil of those who blow into knots, and from the evil of an envier when he envies.',
    'Evening Azkar 11':
        'In the Name of Allah, the Most Beneficent, the Most Merciful.\nSay: I seek refuge with the Lord of mankind, the King of mankind, the God of mankind, from the evil of the retreating whisperer, who whispers into the hearts of mankind, from among jinn and mankind.',
    'Evening Azkar 12':
        'We have reached the evening, and at this time all sovereignty belongs to Allah, and all praise is for Allah. None has the right to be worshipped except Allah alone, without partner. To Him belongs sovereignty and praise; He gives life and causes death, and He has power over all things. My Lord, I ask You for the good of this night and what follows it, and I seek refuge in You from the evil of this night and what follows it. My Lord, I seek refuge in You from laziness, the hardship of old age, punishment in the Fire, and punishment in the grave.',
    'Evening Azkar 13':
        'We have reached the evening upon the natural religion of Islam, the word of pure faith, the religion of our Prophet Muhammad ?, and the way of our father Ibrahim, who was upright, Muslim, and not among the polytheists.',
    'Evening Azkar 14':
        'O Allah, by You we have reached the evening, by You we reach the morning, by You we live, by You we die, and to You is the return.',
    'Evening Azkar 15':
        'O Allah, I have reached the evening from You in blessing, wellbeing, and concealment. Complete Your blessing, wellbeing, and concealment upon me in this world and the Hereafter.',
    'Evening Azkar 16':
        'O Allah, whatever blessing has come to me this evening or to any of Your creation is from You alone, without partner. To You belongs all praise and to You belongs all thanks.',
    'Evening Azkar 17':
        'O my Lord, all praise belongs to You as befits the majesty of Your Face and the greatness of Your authority.',
    'Evening Azkar 18':
        'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad ? as my Prophet and Messenger.',
    'Evening Azkar 19':
        'O Allah, I ask You for pardon and wellbeing in this world and the Hereafter. O Allah, I ask You for pardon and wellbeing in my religion, my worldly affairs, my family, and my wealth. O Allah, conceal my faults and calm my fears. Protect me from in front of me, from behind me, from my right, from my left, and from above me. I seek refuge in Your greatness from being unexpectedly destroyed from beneath me.',
    'Evening Azkar 20':
        'Glory is to Allah and praise is to Him, by the number of His creation, by His pleasure, by the weight of His Throne, and by the ink of His words.',
    'Evening Azkar 21':
        'In the Name of Allah, with whose Name nothing can cause harm on earth nor in the heaven, and He is the All-Hearing, the All-Knowing.',
    'Evening Azkar 22':
        'O Allah, I seek refuge in You from knowingly associating anything with You, and I seek Your forgiveness for what I do not know.',
    'Evening Azkar 23':
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    'Evening Azkar 24':
        'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things, I bear witness that none has the right to be worshipped except You. I seek refuge in You from the evil of my soul, from the evil and shirk of Satan, and from committing wrong against myself or bringing it upon another Muslim.',
    'Evening Azkar 25':
        'O Ever-Living, O Sustainer, by Your mercy I seek help. Rectify all of my affairs for me and do not leave me to myself even for the blink of an eye.',
    'Evening Azkar 26':
        'O Allah, You are my Lord. None has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have committed. I acknowledge Your favour upon me and I acknowledge my sin, so forgive me, for none forgives sins except You.',
    'Evening Azkar 27':
        'O Allah, I have reached the evening calling You to witness, and calling the bearers of Your Throne, Your angels, and all Your creation to witness, that You are Allah. None has the right to be worshipped except You alone, without partner, and Muhammad ? is Your servant and Messenger.',
    'Evening Azkar 28':
        'O Allah, grant wellbeing to my body. O Allah, grant wellbeing to my hearing. O Allah, grant wellbeing to my sight. None has the right to be worshipped except You. O Allah, I seek refuge in You from disbelief and poverty, and I seek refuge in You from punishment in the grave. None has the right to be worshipped except You.',
    'Evening Azkar 29':
        'Allah is sufficient for me. None has the right to be worshipped except Him. Upon Him I rely, and He is the Lord of the mighty Throne.',
    'Evening Azkar 30':
        'None has the right to be worshipped except Allah alone, without partner. To Him belongs the kingdom and to Him belongs all praise, and He has power over all things.',
    'Evening Azkar 31':
        'Glory is to Allah and praise is to Him. Glory is to Allah the Magnificent.',
  };

  static const Map<String, String> _cleanArabic = {
    'Morning Azkar 1':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    'Morning Azkar 2':
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'Morning Azkar 3':
        'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    'Morning Azkar 4':
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِن شَرِّ مَا خَلَقَ\nوَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\nوَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'Morning Azkar 5':
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ\nمِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\nالَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\nمِنَ الْجِنَّةِ وَالنَّاسِ',
    'Morning Azkar 6':
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ\nخَلَقْتَنِي وَأَنَا عَبْدُكَ\nوَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ\nأَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ\nأَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ\nوَأَبُوءُ بِذَنْبِي\nفَاغْفِرْ لِي\nفَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    'Morning Azkar 7':
        'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    'Morning Azkar 8':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ\nاللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي\nاللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي\nاللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي\nوَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
    'Morning Azkar 9':
        'اللَّهُمَّ إِنِّي أَصْبَحْتُ مِنْكَ فِي نِعْمَةٍ وَعَافِيَةٍ وَسِتْرٍ فَأَتِمَّ عَلَيَّ نِعْمَتَكَ وَعَافِيَتَكَ وَسِتْرَكَ فِي الدُّنْيَا وَالْآخِرَةِ',
    'Morning Azkar 10':
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    'Morning Azkar 11':
        'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا',
    'Morning Azkar 12':
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    'Morning Azkar 13':
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ\nلَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ\nرَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ\nوَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَٰذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ\nرَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ\nرَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
    'Morning Azkar 14':
        'أَصْبَحْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ\nوَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ\nوَعَلَىٰ دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ\nوَعَلَىٰ مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا\nوَمَا كَانَ مِنَ الْمُشْرِكِينَ',
    'Morning Azkar 15':
        'اللَّهُمَّ بِكَ أَصْبَحْنَا\nوَبِكَ أَمْسَيْنَا\nوَبِكَ نَحْيَا\nوَبِكَ نَمُوتُ\nوَإِلَيْكَ النُّشُورُ',
    'Morning Azkar 16':
        'اللَّهُمَّ إِنِّي أَصْبَحْتُ مِنْكَ فِي نِعْمَةٍ وَعَافِيَةٍ وَسِتْرٍ\nفَأَتِمَّ عَلَيَّ نِعْمَتَكَ وَعَافِيَتَكَ وَسِتْرَكَ فِي الدُّنْيَا وَالْآخِرَةِ',
    'Morning Azkar 17':
        'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ\nأَوْ بِأَحَدٍ مِنْ خَلْقِكَ\nفَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ\nفَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    'Morning Azkar 18':
        'يَا رَبِّ لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ وَعَظِيمِ سُلْطَانِكَ',
    'Morning Azkar 19':
        'رَضِيتُ بِاللَّهِ رَبًّا\nوَبِالْإِسْلَامِ دِينًا\nوَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا',
    'Morning Azkar 20':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ\nفِي الدُّنْيَا وَالْآخِرَةِ\nاللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ\nفِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي\nاللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي\nوَاحْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي\nوَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي\nوَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
    'Morning Azkar 21':
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ\nعَدَدَ خَلْقِهِ\nوَرِضَا نَفْسِهِ\nوَزِنَةَ عَرْشِهِ\nوَمِدَادَ كَلِمَاتِهِ',
    'Morning Azkar 22':
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ\nوَهُوَ السَّمِيعُ الْعَلِيمُ',
    'Morning Azkar 23':
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ شَيْئًا أَعْلَمُهُ\nوَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُهُ',
    'Morning Azkar 24':
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    'Morning Azkar 25':
        'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ\nفَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ\nرَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ\nأَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ\nأَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي\nوَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ\nوَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
    'Morning Azkar 26':
        'يَا حَيُّ يَا قَيُّومُ\nبِرَحْمَتِكَ أَسْتَغِيثُ\nأَصْلِحْ لِي شَأْنِي كُلَّهُ\nوَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    'Morning Azkar 27':
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ\nخَلَقْتَنِي وَأَنَا عَبْدُكَ\nوَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ\nأَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ\nأَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ\nوَأَبُوءُ بِذَنْبِي\nفَاغْفِرْ لِي\nفَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    'Morning Azkar 28':
        'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ\nوَأُشْهِدُ حَمَلَةَ عَرْشِكَ\nوَمَلَائِكَتَكَ\nوَجَمِيعَ خَلْقِكَ\nأَنَّكَ أَنْتَ اللَّهُ\nلَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ\nوَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
    'Morning Azkar 29':
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي\nاللَّهُمَّ عَافِنِي فِي سَمْعِي\nاللَّهُمَّ عَافِنِي فِي بَصَرِي\nلَا إِلَٰهَ إِلَّا أَنْتَ\nاللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ\nوَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ\nلَا إِلَٰهَ إِلَّا أَنْتَ',
    'Morning Azkar 30':
        'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ\nعَلَيْهِ تَوَكَّلْتُ\nوَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    'Morning Azkar 31':
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ\nاللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَٰذَا الْيَوْمِ\nفَتْحَهُ وَنَصْرَهُ\nوَنُورَهُ وَبَرَكَتَهُ وَهُدَاهُ\nوَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهِ\nوَشَرِّ مَا بَعْدَهُ',
    'Morning Azkar 32':
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ\nوَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ\n\nسُبْحَانَ اللَّهِ وَبِحَمْدِهِ\nسُبْحَانَ اللَّهِ الْعَظِيمِ',
    'After Prayer Dua':
        'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    'Forgiveness Dua':
        'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    'Travel Dua':
        'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    'Evening Azkar 1':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    'Evening Azkar 2':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالم\nذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ\nالَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ\nوَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ\nأُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
    'Evening Azkar 3':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'Evening Azkar 4':
        'لَا إِكْرَاهَ فِي الدِّينِ ۖ قَد تَّبَيَّنَ الرُّشْدُ مِنَ الْغَيِّ ۚ فَمَن يَكْفُرْ بِالطَّاغُوتِ وَيُؤْمِن بِاللَّهِ فَقَدِ اسْتَمْسَكَ بِالْعُرْوَةِ الْوُثْقَىٰ لَا انفِصَامَ لَهَا ۗ وَاللَّهُ سَمِيعٌ عَلِيمٌ',
    'Evening Azkar 5':
        'اللَّهُ وَلِيُّ الَّذِينَ آمَنُوا يُخْرِجُهُم مِّنَ الظُّلُمَاتِ إِلَى النُّورِ ۖ وَالَّذِينَ كَفَرُوا أَوْلِيَاؤُهُمُ الطَّاغُوتُ يُخْرِجُونَهُم مِّنَ النُّورِ إِلَى الظُّلُمَاتِ ۗ أُولَٰئِكَ أَصْحَابُ النَّارِ ۖ هُمْ فِيهَا خَالِدُونَ',
    'Evening Azkar 6':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nلِّلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ وَإِن تُبْدُوا مَا فِي أَنفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُم بِهِ اللَّهُ ۖ فَيَغْفِرُ لِمَن يَشَاءُ وَيُعَذِّبُ مَن يَشَاءُ ۗ وَاللَّهُ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    'Evening Azkar 7':
        'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ',
    'Evening Azkar 8':
        'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    'Evening Azkar 9':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    'Evening Azkar 10':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِن شَرِّ مَا خَلَقَ\nوَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\nوَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'Evening Azkar 11':
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ\nمِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\nالَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\nمِنَ الْجِنَّةِ وَالنَّاسِ',
    'Evening Azkar 12':
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ\nلَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ\nيُحْيِي وَيُمِيتُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ\nرَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا\nوَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا\nرَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ\nرَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
    'Evening Azkar 13':
        'أَمْسَيْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ\nوَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ\nوَعَلَىٰ دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ\nوَعَلَىٰ مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا\nوَمَا كَانَ مِنَ الْمُشْرِكِينَ',
    'Evening Azkar 14':
        'اللَّهُمَّ بِكَ أَمْسَيْنَا\nوَبِكَ أَصْبَحْنَا\nوَبِكَ نَحْيَا\nوَبِكَ نَمُوتُ\nوَإِلَيْكَ الْمَصِيرُ',
    'Evening Azkar 15':
        'اللَّهُمَّ إِنِّي أَمْسَيْتُ مِنْكَ فِي نِعْمَةٍ وَعَافِيَةٍ وَسِتْرٍ\nفَأَتِمَّ عَلَيَّ نِعْمَتَكَ وَعَافِيَتَكَ وَسِتْرَكَ فِي الدُّنْيَا وَالْآخِرَةِ',
    'Evening Azkar 16':
        'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ\nأَوْ بِأَحَدٍ مِنْ خَلْقِكَ\nفَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ\nفَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    'Evening Azkar 17':
        'يَا رَبِّ لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ وَعَظِيمِ سُلْطَانِكَ',
    'Evening Azkar 18':
        'رَضِيتُ بِاللَّهِ رَبًّا\nوَبِالْإِسْلَامِ دِينًا\nوَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا',
    'Evening Azkar 19':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ\nفِي الدُّنْيَا وَالْآخِرَةِ\nاللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ\nفِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي\nاللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي\nاللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي\nوَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي\nوَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
    'Evening Azkar 20':
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ\nعَدَدَ خَلْقِهِ\nوَرِضَا نَفْسِهِ\nوَزِنَةَ عَرْشِهِ\nوَمِدَادَ كَلِمَاتِهِ',
    'Evening Azkar 21':
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ\nوَهُوَ السَّمِيعُ الْعَلِيمُ',
    'Evening Azkar 22':
        'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ شَيْئًا أَعْلَمُهُ\nوَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُهُ',
    'Evening Azkar 23':
        'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    'Evening Azkar 24':
        'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ\nفَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ\nرَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ\nأَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ\nأَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي\nوَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ\nوَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
    'Evening Azkar 25':
        'يَا حَيُّ يَا قَيُّومُ\nبِرَحْمَتِكَ أَسْتَغِيثُ\nأَصْلِحْ لِي شَأْنِي كُلَّهُ\nوَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    'Evening Azkar 26':
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ\nخَلَقْتَنِي وَأَنَا عَبْدُكَ\nوَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ\nأَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ\nأَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ\nوَأَبُوءُ بِذَنْبِي\nفَاغْفِرْ لِي\nفَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    'Evening Azkar 27':
        'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ\nوَأُشْهِدُ حَمَلَةَ عَرْشِكَ\nوَمَلَائِكَتَكَ\nوَجَمِيعَ خَلْقِكَ\nأَنَّكَ أَنْتَ اللَّهُ\nلَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ\nوَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
    'Evening Azkar 28':
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي\nاللَّهُمَّ عَافِنِي فِي سَمْعِي\nاللَّهُمَّ عَافِنِي فِي بَصَرِي\nلَا إِلَٰهَ إِلَّا أَنْتَ\nاللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ\nوَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ\nلَا إِلَٰهَ إِلَّا أَنْتَ',
    'Evening Azkar 29':
        'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ\nعَلَيْهِ تَوَكَّلْتُ\nوَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    'Evening Azkar 30':
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ\nلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ\nوَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    'Evening Azkar 31':
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ\nسُبْحَانَ اللَّهِ الْعَظِيمِ',
    'Sleeping Dua 1':
        'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا، بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
    'Sleeping Dua 2':
        'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
    'Sleeping Dua 3':
        'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    'Sleeping Dua 4':
        'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
    'Sleeping Dua 5':
        'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا، وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِي',
    'Sleeping Dua 6':
        'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
    'Sleeping Dua 7':
        'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
    'Sleeping Dua 8':
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ، مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'Waking Up Dua 1':
        'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ',
    'Waking Up Dua 2':
        'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَٰهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ، رَبِّ اغْفِرْ لِي',
    'Waking Up Dua 3':
        'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    'Eating Dua 1':
        'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَجَعَلَنَا مُسْلِمِينَ',
    'Travel Dua 1':
        'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
    'Travel Dua 2':
        'رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَلْ لِي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا',
  };

  const _DuaItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.icon,
  });

  String get displayArabic {
    final cleanArabic = _cleanArabic[title];
    if (cleanArabic != null) {
      return _looksCorrupted(cleanArabic) ? '' : cleanArabic;
    }

    final eveningArabic = _eveningArabic[title];
    if (eveningArabic != null) {
      return _looksCorrupted(eveningArabic) ? '' : eveningArabic;
    }

    switch (title) {
      case 'Morning Dua':
        return '?????????? ???? ??????????? ?????? ??????????? ?????? ??????? ?????? ??????? ?????????? ??????????';
      case 'Morning Azkar 1':
        return '?????? ??????? ???????????? ??????????\n????????? ??????? ????? ?????????????\n???????????? ??????????\n??????? ?????? ????????\n???????? ???????? ?????????? ???????????\n???????? ?????????? ??????????????\n??????? ????????? ?????????? ?????????? ?????? ???????????? ?????????? ????? ????????????';
      case 'Morning Azkar 2':
        return '??????? ??? ??????? ?????? ???? ???????? ??????????? ? ??? ?????????? ?????? ????? ?????? ? ???? ??? ??? ????????????? ????? ??? ????????? ? ??? ??? ??????? ???????? ??????? ?????? ?????????? ? ???????? ??? ?????? ??????????? ????? ?????????? ? ????? ?????????? ???????? ????? ???????? ?????? ????? ????? ? ?????? ??????????? ????????????? ??????????? ? ????? ????????? ??????????? ? ?????? ?????????? ??????????';
      case 'Morning Azkar 3':
        return '???? ???? ??????? ??????\n??????? ?????????\n???? ?????? ?????? ???????\n?????? ????? ????? ??????? ??????';
      case 'Morning Azkar 4':
        return '???? ??????? ??????? ?????????\n??? ????? ??? ??????\n????? ????? ??????? ????? ??????\n????? ????? ?????????????? ??? ?????????\n????? ????? ??????? ????? ??????';
      case 'Morning Azkar 5':
        return '???? ??????? ??????? ????????\n?????? ????????\n??????? ????????\n??? ????? ???????????? ???????????\n??????? ?????????? ??? ??????? ????????\n???? ?????????? ??????????';
      case 'Morning Azkar 6':
        return '?????????? ?????? ?????? ??? ??????? ?????? ?????? ??????????? ??????? ???????? ??????? ?????? ???????? ?????????? ??? ??????????? ??????? ???? ???? ????? ??? ???????? ??????? ???? ???????????? ??????? ????????? ????????? ????????? ??? ????????? ??? ???????? ?????????? ?????? ??????';
      case 'Morning Azkar 7':
        return '???????? ??????? ??? ??????? ?????? ???? ???????? ??????????? ?????? ????? ????????? ??????????';
      case 'Morning Azkar 8':
        return '?????????? ?????? ?????????? ????????? ?????????????? ??? ?????????? ????????????\n?????????? ?????? ?????????? ????????? ?????????????? ??? ?????? ??????????? ????????? ????????\n?????????? ??????? ?????????? ??????? ??????????\n?????????? ?????????? ???? ?????? ??????? ?????? ??????? ?????? ???????? ?????? ???????? ?????? ???????\n????????? ???????????? ???? ????????? ???? ???????';
      case 'Morning Azkar 9':
        return '?????????? ?????? ?????????? ?????? ??? ???????? ??????????? ???????? ????????? ??????? ?????????? ????????????? ?????????? ??? ?????????? ????????????';
      case 'Morning Azkar 10':
        return '?????? ??????? ??????? ??? ??????? ???? ??????? ?????? ??? ????????? ????? ??? ?????????? ?????? ?????????? ??????????';
      case 'Morning Azkar 11':
        return '??????? ????????? ?????? ???????????????? ?????? ????????????? ? ???????? ??????????';
      case 'Morning Azkar 12':
        return '????????? ??????? ???????????? ?????? ???????? ??????? ???????? ???????? ???????? ????????? ???????????';
      case 'Morning Azkar 13':
        return '??????????? ?????????? ????????? ??????? ??????????? ???????\n??? ??????? ?????? ??????? ???????? ??? ??????? ????\n???? ????????? ?????? ????????? ?????? ?????? ????? ?????? ???????\n????? ?????????? ?????? ??? ??? ?????? ????????? ???????? ??? ????????\n????????? ???? ???? ????? ??? ??? ?????? ????????? ??????? ??? ????????\n????? ??????? ???? ???? ????????? ??????? ?????????\n????? ??????? ???? ???? ??????? ??? ???????? ????????? ??? ?????????';
      case 'Morning Azkar 14':
        return '??????????? ?????? ???????? ????????????\n???????? ???????? ????????????\n???????? ????? ?????????? ????????? ?\n???????? ??????? ???????? ???????????? ???????? ?????????\n????? ????? ???? ??????????????';
      case 'Morning Azkar 15':
        return '?????????? ???? ???????????\n?????? ???????????\n?????? ???????\n?????? ???????\n?????????? ??????????';
      case 'Morning Azkar 16':
        return '?????????? ?????? ?????????? ?????? ??? ???????? ??????????? ????????\n????????? ??????? ?????????? ????????????? ?????????? ??? ?????????? ????????????';
      case 'Morning Azkar 17':
        return '?????????? ??? ???????? ??? ???? ????????\n???? ???????? ???? ????????\n???????? ???????? ??? ??????? ????\n?????? ????????? ?????? ?????????';
      case 'Morning Azkar 18':
        return '??? ????? ???? ????????? ????? ????????? ????????? ???????? ????????? ???????????';
      case 'Morning Azkar 19':
        return '??????? ????????? ??????\n???????????????? ??????\n????????????? ? ???????? ??????????';
      case 'Morning Azkar 20':
        return '?????????? ?????? ?????????? ????????? ??????????????\n??? ?????????? ????????????\n?????????? ?????? ?????????? ????????? ??????????????\n??? ?????? ??????????? ????????? ????????\n?????????? ??????? ?????????? ??????? ??????????\n???????????? ???? ?????? ??????? ?????? ???????\n?????? ???????? ?????? ???????? ?????? ???????\n????????? ???????????? ???? ????????? ???? ???????';
      case 'Morning Azkar 21':
        return '????????? ??????? ????????????\n?????? ????????\n??????? ????????\n???????? ????????\n????????? ???????????';
      case 'Morning Azkar 22':
        return '?????? ??????? ??????? ??? ??????? ???? ??????? ?????? ??? ????????? ????? ??? ??????????\n?????? ?????????? ??????????';
      case 'Morning Azkar 23':
        return '?????????? ?????? ??????? ???? ???? ???????? ???? ??????? ??????????\n???????????????? ????? ??? ??????????';
      case 'Morning Azkar 24':
        return '??????? ??????????? ??????? ???????????? ???? ????? ??? ??????';
      case 'Morning Azkar 25':
        return '?????????? ??????? ????????? ??????????????\n??????? ????????????? ???????????\n????? ????? ?????? ???????????\n???????? ???? ??? ??????? ?????? ??????\n??????? ???? ???? ????? ???????\n?????? ????? ???????????? ??????????\n?????? ?????????? ?????? ??????? ?????? ???? ????????? ?????? ????????';
      case 'Morning Azkar 26':
        return '??? ????? ??? ????????\n???????????? ???????????\n???????? ??? ??????? ???????\n????? ????????? ?????? ??????? ???????? ??????';
      case 'Morning Azkar 27':
        return '?????????? ?????? ?????? ??? ??????? ?????? ??????\n??????????? ??????? ????????\n??????? ?????? ???????? ?????????? ??? ???????????\n??????? ???? ???? ????? ??? ????????\n??????? ???? ???????????? ???????\n????????? ?????????\n????????? ???\n????????? ??? ???????? ?????????? ?????? ??????';
      case 'Morning Azkar 28':
        return '?????????? ?????? ?????????? ??????????\n?????????? ???????? ????????\n???????????????\n????????? ????????\n??????? ?????? ???????\n??? ??????? ?????? ?????? ???????? ??? ??????? ????\n??????? ?????????? ???????? ???????????';
      case 'Morning Azkar 29':
        return '?????????? ???????? ??? ???????\n?????????? ???????? ??? ???????\n?????????? ???????? ??? ???????\n??? ??????? ?????? ??????\n?????????? ?????? ??????? ???? ???? ????????? ???????????\n????????? ???? ???? ??????? ?????????\n??? ??????? ?????? ??????';
      case 'Morning Azkar 30':
        return '???????? ??????? ??? ??????? ?????? ????\n???????? ???????????\n?????? ????? ????????? ??????????';
      case 'Morning Azkar 31':
        return '??????????? ?????????? ????????? ??????? ????? ?????????????\n?????????? ?????? ?????????? ?????? ?????? ?????????\n???????? ??????????\n????????? ???????????? ?????????\n????????? ???? ???? ????? ??? ?????\n??????? ??? ????????';
      case 'Morning Azkar 32':
        return '??? ??????? ?????? ??????? ???????? ??? ??????? ????\n???? ????????? ?????? ?????????\n?????? ?????? ????? ?????? ???????\n\n????????? ??????? ????????????\n????????? ??????? ??????????';
      case 'Evening Dua':
        return '?????????? ???? ??????????? ?????? ??????????? ?????? ??????? ?????? ??????? ?????????? ??????????';
      case 'After Prayer Dua':
        return '?????????? ?????? ?????????? ???????? ?????????? ??????????? ??? ??? ?????????? ??????????????';
      case 'Forgiveness Dua':
        return '???????????? ??????? ?????????? ??????? ??? ??????? ?????? ???? ???????? ??????????? ????????? ????????';
      case 'Travel Dua':
        return '????????? ??????? ??????? ????? ?????? ????? ?????? ???? ??????????? ???????? ?????? ???????? ??????????????';
    }
    return _looksCorrupted(arabic) ? '' : arabic;
  }

  String get displayTransliteration {
    return _cleanDisplayText(transliteration);
  }

  String get polishedTranslation {
    return _cleanDisplayText(displayTranslation)
        .replaceAll('Muhammad ?', 'Muhammad (peace be upon him)')
        .replaceAll('Allah?s', "Allah's")
        .replaceAll('Allah�s', "Allah's");
  }

  static String _cleanDisplayText(String value) {
    return value
        .replaceAll('�', "'")
        .replaceAll('ï¿½', "'")
        .replaceAll('â€™', "'")
        .replaceAll('â€˜', "'")
        .replaceAll('â€œ', '"')
        .replaceAll('â€', '"')
        .replaceAll('â€“', '-')
        .replaceAll('`', "'")
        .replaceAll(RegExp(r"\s+'"), "'")
        .replaceAll(RegExp(r"'{2,}"), "'")
        .trim();
  }

  static bool _looksCorrupted(String value) {
    final questionMarks = RegExp(r'\?').allMatches(value).length;
    final replacementMarks = RegExp('�').allMatches(value).length;
    return replacementMarks > 0 || questionMarks >= 5;
  }

  String get displayTranslation {
    final eveningTranslation = _eveningTranslations[title];
    if (eveningTranslation != null) return eveningTranslation;

    switch (title) {
      case 'Morning Azkar 1':
        return 'In the Name of Allah, the Most Beneficent, the Most Merciful.\nAll praise and thanks are Allah�s, the Lord of all that exists.\nThe Most Beneficent, the Most Merciful.\nThe Owner of the Day of Recompense.\nYou alone we worship, and You alone we ask for help.\nGuide us to the Straight Way,\nthe way of those on whom You have bestowed Your grace, not the way of those who earned Your anger, nor of those who went astray.';
      case 'Morning Azkar 2':
        return 'Allah, there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness nor sleep overtakes Him. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what is behind them, and they encompass nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and preserving them does not tire Him. And He is the Most High, the Most Great.';
      case 'Morning Azkar 3':
        return 'Say: He is Allah, the One. Allah, the Self-Sufficient Master, whom all creatures need. He neither begets nor was He begotten, and there is none comparable to Him.';
      case 'Morning Azkar 4':
        return 'Say: I seek refuge with the Lord of daybreak, from the evil of what He has created, from the evil of the darkening night as it comes with its darkness, from the evil of those who practice witchcraft when they blow into knots, and from the evil of the envier when he envies.';
      case 'Morning Azkar 5':
        return 'Say: I seek refuge with the Lord of mankind, the King of mankind, the God of mankind, from the evil of the whisperer who withdraws, who whispers in the breasts of mankind, from among jinn and mankind.';
      case 'Morning Azkar 6':
      case 'Morning Azkar 27':
        return 'O Allah, You are my Lord. None has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have committed. I acknowledge Your favour upon me and I acknowledge my sin, so forgive me, for none forgives sins except You.';
      case 'Morning Azkar 7':
      case 'Morning Azkar 30':
        return 'Allah is sufficient for me. None has the right to be worshipped except Him. Upon Him I rely, and He is the Lord of the mighty Throne.';
      case 'Morning Azkar 8':
      case 'Morning Azkar 20':
        return 'O Allah, I ask You for pardon and wellbeing in this world and in the Hereafter. O Allah, I ask You for pardon and wellbeing in my religion, my worldly affairs, my family, and my wealth. O Allah, conceal my faults and calm my fears. O Allah, protect me from in front of me, from behind me, from my right, from my left, and from above me. I seek refuge in Your greatness from being unexpectedly destroyed from beneath me.';
      case 'Morning Azkar 9':
      case 'Morning Azkar 16':
        return 'O Allah, I have entered the morning from You in blessing, wellbeing, and concealment. So complete Your blessing, Your wellbeing, and Your concealment upon me in this world and the Hereafter.';
      case 'Morning Azkar 10':
      case 'Morning Azkar 22':
        return 'In the Name of Allah, with whose Name nothing can cause harm on earth nor in the heaven, and He is the All-Hearing, the All-Knowing.';
      case 'Morning Azkar 11':
      case 'Morning Azkar 19':
        return 'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad ? as my Prophet and Messenger.';
      case 'Morning Azkar 12':
      case 'Morning Azkar 21':
        return 'Glory is to Allah and praise is to Him, by the number of His creation, by His pleasure, by the weight of His Throne, and by the ink of His words.';
      case 'Morning Azkar 13':
        return 'We have entered the morning and the kingdom has entered the morning belonging to Allah. All praise is for Allah. None has the right to be worshipped except Allah alone, without partner. To Him belongs the kingdom and to Him belongs all praise, and He has power over all things. My Lord, I ask You for the good of this day and the good of what follows it, and I seek refuge in You from the evil of this day and the evil of what follows it. My Lord, I seek refuge in You from laziness and the hardship of old age. My Lord, I seek refuge in You from punishment in the Fire and punishment in the grave.';
      case 'Morning Azkar 14':
        return 'We have entered the morning upon the natural religion of Islam, upon the word of sincerity, upon the religion of our Prophet Muhammad ?, and upon the way of our father Ibrahim, who was upright and Muslim, and he was not among the polytheists.';
      case 'Morning Azkar 15':
        return 'O Allah, by You we have entered the morning, by You we enter the evening, by You we live, by You we die, and to You is the resurrection.';
      case 'Morning Azkar 17':
        return 'O Allah, whatever blessing has come to me this morning or to any of Your creation is from You alone, without partner. So to You belongs all praise and to You belongs all thanks.';
      case 'Morning Azkar 18':
        return 'O my Lord, all praise belongs to You as befits the majesty of Your Face and the greatness of Your authority.';
      case 'Morning Azkar 23':
        return 'O Allah, I seek refuge in You from knowingly associating anything with You, and I seek Your forgiveness for what I do not know.';
      case 'Morning Azkar 24':
        return 'I seek refuge in the perfect words of Allah from the evil of what He has created.';
      case 'Morning Azkar 25':
        return 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things, I bear witness that none has the right to be worshipped except You. I seek refuge in You from the evil of my soul, from the evil of Satan and his shirk, and from committing evil against myself or bringing it upon a Muslim.';
      case 'Morning Azkar 26':
        return 'O Ever-Living, O Sustainer, by Your mercy I seek help. Rectify all of my affairs for me and do not leave me to myself even for the blink of an eye.';
      case 'Morning Azkar 28':
        return 'O Allah, I have entered the morning calling You to witness, and calling the bearers of Your Throne, Your angels, and all Your creation to witness, that You are Allah. None has the right to be worshipped except You alone, without partner, and Muhammad ? is Your servant and Messenger.';
      case 'Morning Azkar 29':
        return 'O Allah, grant wellbeing to my body. O Allah, grant wellbeing to my hearing. O Allah, grant wellbeing to my sight. None has the right to be worshipped except You. O Allah, I seek refuge in You from disbelief and poverty, and I seek refuge in You from the punishment of the grave. None has the right to be worshipped except You.';
      case 'Morning Azkar 31':
        return 'We have entered the morning and the kingdom has entered the morning belonging to Allah, Lord of all worlds. O Allah, I ask You for the good of this day: its opening, victory, light, blessing, and guidance. I seek refuge in You from the evil within it and the evil that follows it.';
      case 'Morning Azkar 32':
        return 'None has the right to be worshipped except Allah alone, without partner. To Him belongs the kingdom and to Him belongs all praise, and He has power over all things.\n\nGlory is to Allah and praise is to Him. Glory is to Allah the Magnificent.';
    }
    return translation;
  }
}

class _DuaColors {
  static const Color background = Color(0xFF031B17);
  static const Color deep = Color(0xFF031B17);
  static const Color rich = Color(0xFF0A3D2E);
  static const Color card = Color(0xFF07241F);
  static const Color gold = Color(0xFFD4A64F);
  static const Color ivory = Color(0xFFF5F1E8);
  static const Color secondary = Color.fromRGBO(245, 241, 232, 0.75);
}
