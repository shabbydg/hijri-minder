import '../models/reminder.dart';

/// Service for managing culturally appropriate Islamic message templates
/// for birthdays, anniversaries, and other occasions
class MessageTemplatesService {
  static final MessageTemplatesService _instance = MessageTemplatesService._internal();
  factory MessageTemplatesService() => _instance;
  MessageTemplatesService._internal();

  /// Supported languages for message templates
  static const List<String> supportedLanguages = [
    'en', // English
    'ar', // Arabic
    'id', // Indonesian
    'ur', // Urdu
    'ms', // Malay
    'tr', // Turkish
    'fa', // Persian
    'bn', // Bengali
  ];

  /// Get message templates for a specific reminder type and language
  List<String> getMessageTemplates(ReminderType type, String language) {
    switch (type) {
      case ReminderType.birthday:
        return _getBirthdayTemplates(language);
      case ReminderType.anniversary:
        return _getAnniversaryTemplates(language);
      case ReminderType.religious:
        return _getDeathAnniversaryTemplates(language);
      case ReminderType.personal:
      case ReminderType.family:
      case ReminderType.other:
        return _getBirthdayTemplates(language); // Default to birthday templates
    }
  }

  /// Generate a personalized message with recipient name and relationship
  String generatePersonalizedMessage(
    String template,
    String recipientName,
    String relationship,
    String language,
  ) {
    String personalizedMessage = template
        .replaceAll('{name}', recipientName)
        .replaceAll('{relationship}', _getLocalizedRelationship(relationship, language));
    
    return personalizedMessage;
  }

  /// Get Islamic greeting templates with Quranic verses and Hadith
  List<String> getIslamicGreetingTemplates(String language) {
    return _getIslamicGreetings(language);
  }

  /// Get specialized religious anniversary messages
  List<String> getReligiousAnniversaryTemplates(String language) {
    return _getReligiousTemplates(language);
  }

  /// Get birthday message templates by language
  List<String> _getBirthdayTemplates(String language) {
    switch (language) {
      case 'en':
        return [
          'May Allah bless you with happiness, health, and prosperity on your special day, dear {name}! 🎂✨',
          'Wishing you a blessed birthday filled with Allah\'s countless blessings, {name}! May this new year of your life bring you closer to Him. 🤲',
          'Happy Birthday, {name}! May Allah grant you a long, healthy life filled with Iman and good deeds. Barakallahu feeki! 🎉',
          'On your birthday, I pray that Allah showers you with His mercy and guides you on the straight path. Happy Birthday, dear {relationship}! 💫',
          'May this special day mark the beginning of a year filled with Allah\'s blessings and guidance. Happy Birthday, {name}! 🌟',
        ];
      case 'ar':
        return [
          'بارك الله لك في عامك الجديد وأسعدك في دنياك وآخرتك، عزيزي {name}! 🎂✨',
          'كل عام وأنت بخير، {name}! أسأل الله أن يبارك لك في عمرك ويرزقك الصحة والعافية 🤲',
          'عيد ميلاد سعيد، {name}! أدعو الله أن يطيل عمرك في طاعته ويرزقك الخير والبركة 🎉',
          'في يوم ميلادك، أدعو الله أن يحفظك ويسعدك ويبارك لك في حياتك، عزيزي {relationship}! 💫',
          'أسأل الله أن يجعل هذا العام مليئاً بالخير والبركة والسعادة، كل عام وأنت بخير {name}! 🌟',
        ];
      case 'id':
        return [
          'Selamat ulang tahun, {name}! Semoga Allah SWT memberikan keberkahan, kesehatan, dan kebahagiaan di tahun yang baru ini 🎂✨',
          'Barakallahu laki wa barakallahu alaiki, {name}! Semoga panjang umur, sehat selalu, dan semakin dekat dengan Allah SWT 🤲',
          'Happy birthday, {name}! Semoga Allah SWT melimpahkan rahmat dan hidayah-Nya dalam setiap langkah hidupmu 🎉',
          'Di hari istimewa ini, aku mendoakan semoga Allah SWT senantiasa melindungi dan memberkahi hidupmu, {relationship} tersayang! 💫',
          'Semoga tahun baru kehidupanmu dipenuhi dengan amal shaleh dan ridha Allah SWT. Selamat ulang tahun, {name}! 🌟',
        ];
      case 'ur':
        return [
          'آپ کو سالگرہ مبارک ہو، {name}! اللہ تعالیٰ آپ کو صحت، خوشی اور برکت عطا فرمائے 🎂✨',
          'جنم دن کی مبارکباد، {name}! اللہ پاک آپ کی عمر میں برکت دے اور آپ کو نیک اعمال کی توفیق عطا فرمائے 🤲',
          'سالگرہ مبارک، {name}! اللہ تعالیٰ آپ کو لمبی اور صحت مند زندگی عطا فرمائے 🎉',
          'آپ کے خصوصی دن پر، میں دعا کرتا ہوں کہ اللہ تعالیٰ آپ کو اپنی رحمت سے نوازے، پیارے {relationship}! 💫',
          'اللہ تعالیٰ آپ کا یہ نیا سال خیر و برکت سے بھر دے۔ سالگرہ مبارک، {name}! 🌟',
          'بارک اللہ فیک، {name}! اللہ تعالیٰ آپ کو ہمیشہ خوش رکھے اور آپ کی دعائیں قبول فرمائے 🌙',
        ];
      default:
        return _getBirthdayTemplates('en');
    }
  }

  /// Get anniversary message templates by language
  List<String> _getAnniversaryTemplates(String language) {
    switch (language) {
      case 'en':
        return [
          'May Allah continue to bless your marriage with love, understanding, and happiness. Happy Anniversary, {name}! 💕',
          'Congratulations on another year of blessed union! May Allah strengthen your bond and grant you many more years together 🤲',
          'Happy Anniversary! May your marriage continue to be a source of joy and a means of drawing closer to Allah 💫',
          'Wishing you both continued happiness and Allah\'s blessings on your special day, dear {relationship}! 🌟',
          'May Allah bless your marriage with peace, love, and prosperity. Happy Anniversary! 💖',
        ];
      case 'ar':
        return [
          'بارك الله لكما في زواجكما وأدام عليكما المحبة والوئام. كل عام وأنتما بخير، {name}! 💕',
          'مبروك على عام آخر من الزواج المبارك! أسأل الله أن يقوي رابطتكما ويرزقكما سنوات أخرى سعيدة 🤲',
          'عيد زواج سعيد! أسأل الله أن يجعل زواجكما مصدر سعادة ووسيلة للتقرب إليه سبحانه 💫',
          'أتمنى لكما السعادة المستمرة وبركات الله في يومكما الخاص، عزيزي {relationship}! 🌟',
          'بارك الله لكما في زواجكما وأسعدكما في دنياكما وآخرتكما. كل عام وأنتما بخير! 💖',
        ];
      case 'id':
        return [
          'Selamat anniversary, {name}! Semoga Allah SWT terus memberkahi pernikahan kalian dengan cinta, pengertian, dan kebahagiaan 💕',
          'Barakallahu lakuma wa baraka alaikuma! Semoga Allah SWT menguatkan ikatan kalian dan memberikan tahun-tahun indah lainnya 🤲',
          'Happy Anniversary! Semoga pernikahan kalian terus menjadi sumber kebahagiaan dan sarana mendekatkan diri kepada Allah SWT 💫',
          'Semoga kalian terus bahagia dan mendapat berkah Allah SWT di hari istimewa ini, {relationship} tersayang! 🌟',
          'Semoga Allah SWT memberkahi pernikahan kalian dengan kedamaian, cinta, dan kemakmuran. Selamat anniversary! 💖',
        ];
      case 'ur':
        return [
          'شادی کی سالگرہ مبارک، {name}! اللہ تعالیٰ آپ کی شادی کو محبت، سمجھ اور خوشی سے نوازے 💕',
          'مبارک ہو! اللہ پاک آپ کے رشتے کو مضبوط بنائے اور آپ کو مزید خوشی کے سال عطا فرمائے 🤲',
          'سالگرہ مبارک! اللہ تعالیٰ آپ کی شادی کو خوشی کا ذریعہ اور اللہ سے قریب ہونے کا وسیلہ بنائے 💫',
          'آپ کے خصوصی دن پر خوشی اور اللہ کی برکات کی دعا، پیارے {relationship}! 🌟',
          'اللہ تعالیٰ آپ کی شادی کو امن، محبت اور خوشحالی سے نوازے۔ سالگرہ مبارک! 💖',
        ];
      default:
        return _getAnniversaryTemplates('en');
    }
  }

  /// Get death anniversary message templates by language
  List<String> _getDeathAnniversaryTemplates(String language) {
    switch (language) {
      case 'en':
        return [
          'Remembering {name} with love and prayers. May Allah grant them Jannah and elevate their status. Inna lillahi wa inna ilayhi raji\'un 🤲',
          'On this day, we remember {name} and pray for their soul. May Allah forgive their sins and grant them eternal peace 💫',
          'May Allah have mercy on {name}\'s soul and grant them the highest place in Paradise. Our thoughts and prayers are with you 🌟',
          'Remembering the beautiful soul of {name}. May Allah grant them Maghfirah and make their grave a garden of Paradise 🕊️',
          'In loving memory of {name}. May Allah shower His mercy upon them and grant them Jannah-tul-Firdaus 💚',
        ];
      case 'ar':
        return [
          'نتذكر {name} بالحب والدعاء. رحمه الله وأسكنه فسيح جناته. إنا لله وإنا إليه راجعون 🤲',
          'في هذا اليوم نتذكر {name} وندعو لروحه. غفر الله له وأسكنه الجنة 💫',
          'رحم الله {name} وأسكنه أعلى درجات الجنة. أفكارنا ودعواتنا معكم 🌟',
          'نتذكر الروح الطيبة {name}. غفر الله له وجعل قبره روضة من رياض الجنة 🕊️',
          'في ذكرى {name} الحبيب. رحمه الله وأسكنه جنة الفردوس 💚',
        ];
      case 'id':
        return [
          'Mengenang {name} dengan cinta dan doa. Semoga Allah SWT mengampuni dosanya dan menempatkannya di surga. Inna lillahi wa inna ilayhi raji\'un 🤲',
          'Di hari ini, kami mengenang {name} dan mendoakan jiwanya. Semoga Allah SWT mengampuni dosanya dan memberikan ketenangan abadi 💫',
          'Semoga Allah SWT merahmati jiwa {name} dan memberikan tempat tertinggi di surga. Pikiran dan doa kami bersamamu 🌟',
          'Mengenang jiwa yang indah, {name}. Semoga Allah SWT memberikan maghfirah dan menjadikan kuburnya taman surga 🕊️',
          'Dalam kenangan penuh cinta untuk {name}. Semoga Allah SWT melimpahkan rahmat-Nya dan memberikan Jannah-tul-Firdaus 💚',
        ];
      case 'ur':
        return [
          '{name} کو محبت اور دعاؤں کے ساتھ یاد کرتے ہیں۔ اللہ تعالیٰ انہیں جنت عطا فرمائے۔ انا للہ وانا الیہ راجعون 🤲',
          'آج کے دن ہم {name} کو یاد کرتے ہیں اور ان کی روح کے لیے دعا کرتے ہیں۔ اللہ تعالیٰ انہیں بخش دے 💫',
          'اللہ تعالیٰ {name} کی روح پر رحم فرمائے اور انہیں جنت کا اعلیٰ مقام عطا فرمائے 🌟',
          '{name} کی خوبصورت روح کو یاد کرتے ہیں۔ اللہ تعالیٰ انہیں مغفرت عطا فرمائے 🕊️',
          '{name} کی محبت بھری یاد میں۔ اللہ تعالیٰ اپنی رحمت نازل فرمائے اور جنت الفردوس عطا فرمائے 💚',
        ];
      default:
        return _getDeathAnniversaryTemplates('en');
    }
  }

  /// Get Islamic greeting templates with Quranic verses and Hadith
  List<String> _getIslamicGreetings(String language) {
    switch (language) {
      case 'en':
        return [
          'Assalamu Alaikum wa Rahmatullahi wa Barakatuh! May Allah\'s peace and blessings be upon you always 🌙',
          '"And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose." (Quran 65:3) 📖',
          'Barakallahu feeki! May Allah bless you in all your endeavors 🤲',
          '"The best of people are those who benefit others." - Prophet Muhammad (PBUH) ✨',
          'May Allah grant you success in this life and the hereafter. Ameen 🌟',
          'Subhanallahi wa bihamdihi, Subhanallahil Azeem. Glory be to Allah and praise be to Him 💫',
        ];
      case 'ar':
        return [
          'السلام عليكم ورحمة الله وبركاته! أسأل الله أن يبارك لك في كل أمورك 🌙',
          '"ومن يتوكل على الله فهو حسبه إن الله بالغ أمره" (الطلاق: 3) 📖',
          'بارك الله فيك! أسأل الله أن يوفقك في جميع أعمالك 🤲',
          '"خير الناس أنفعهم للناس" - الرسول صلى الله عليه وسلم ✨',
          'أسأل الله أن يوفقك في الدنيا والآخرة. آمين 🌟',
          'سبحان الله وبحمده، سبحان الله العظيم 💫',
        ];
      case 'id':
        return [
          'Assalamu\'alaikum wa rahmatullahi wa barakatuh! Semoga kedamaian dan berkah Allah SWT selalu menyertaimu 🌙',
          '"Dan barangsiapa bertawakal kepada Allah, maka Allah akan mencukupkan (keperluan)nya." (QS. At-Talaq: 3) 📖',
          'Barakallahu fiiki! Semoga Allah SWT memberkahi semua usahamu 🤲',
          '"Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lainnya." - Rasulullah SAW ✨',
          'Semoga Allah SWT memberikan kesuksesan di dunia dan akhirat. Aamiin 🌟',
          'Subhanallahi wa bihamdihi, Subhanallahil Azhiim. Maha Suci Allah dan segala puji bagi-Nya 💫',
        ];
      case 'ur':
        return [
          'السلام علیکم ورحمۃ اللہ وبرکاتہ! اللہ تعالیٰ کی رحمت اور برکت آپ پر ہمیشہ رہے 🌙',
          '"اور جو اللہ پر بھروسہ کرے تو وہ اس کے لیے کافی ہے۔" (القرآن 65:3) 📖',
          'اللہ تعالیٰ آپ کو برکت عطا فرمائے! آپ کے تمام کاموں میں کامیابی دے 🤲',
          '"بہترین لوگ وہ ہیں جو دوسروں کے کام آتے ہیں۔" - رسول اللہ ﷺ ✨',
          'اللہ تعالیٰ آپ کو دنیا اور آخرت میں کامیابی عطا فرمائے۔ آمین 🌟',
          'سبحان اللہ وبحمدہ، سبحان اللہ العظیم 💫',
        ];
      default:
        return _getIslamicGreetings('en');
    }
  }

  /// Get religious anniversary templates with Quranic verses
  List<String> _getReligiousTemplates(String language) {
    switch (language) {
      case 'en':
        return [
          'On this blessed occasion, may Allah accept our prayers and grant us His mercy. "And it is He who accepts repentance from his servants." (Quran 42:25) 🤲',
          'May this sacred day bring us closer to Allah and increase our faith. Barakallahu feekum 🌙',
          '"Indeed, in the remembrance of Allah do hearts find rest." (Quran 13:28) May your heart find peace on this holy day 💫',
          'As we commemorate this blessed event, may Allah shower His blessings upon us all. Ameen 🌟',
          'May the barakah of this sacred occasion fill your life with light and guidance ✨',
        ];
      case 'ar':
        return [
          'في هذه المناسبة المباركة، أسأل الله أن يتقبل دعاءنا ويرحمنا. "وهو الذي يقبل التوبة عن عباده" (الشورى: 25) 🤲',
          'أسأل الله أن يقربنا هذا اليوم المقدس إليه ويزيد إيماننا. بارك الله فيكم 🌙',
          '"ألا بذكر الله تطمئن القلوب" (الرعد: 28) أسأل الله أن يطمئن قلبك في هذا اليوم المقدس 💫',
          'ونحن نحيي هذا الحدث المبارك، أسأل الله أن يبارك لنا جميعاً. آمين 🌟',
          'أسأل الله أن تملأ بركة هذه المناسبة المقدسة حياتك بالنور والهداية ✨',
        ];
      case 'id':
        return [
          'Di kesempatan yang diberkahi ini, semoga Allah SWT menerima doa kita dan memberikan rahmat-Nya. "Dan Dialah yang menerima taubat dari hamba-hamba-Nya." (QS. Asy-Syura: 25) 🤲',
          'Semoga hari suci ini mendekatkan kita kepada Allah SWT dan menambah keimanan kita. Barakallahu fiikum 🌙',
          '"Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram." (QS. Ar-Ra\'d: 28) Semoga hatimu tenteram di hari suci ini 💫',
          'Saat kita memperingati peristiwa yang diberkahi ini, semoga Allah SWT melimpahkan berkah kepada kita semua. Aamiin 🌟',
          'Semoga barakah dari kesempatan suci ini memenuhi hidupmu dengan cahaya dan petunjuk ✨',
        ];
      case 'ur':
        return [
          'اس مبارک موقع پر، اللہ تعالیٰ ہماری دعائیں قبول فرمائے اور اپنی رحمت نازل فرمائے۔ "اور وہی اپنے بندوں کی توبہ قبول کرتا ہے۔" (القرآن 42:25) 🤲',
          'یہ مقدس دن ہمیں اللہ تعالیٰ کے قریب لے آئے اور ہمارا ایمان بڑھائے۔ اللہ تعالیٰ آپ کو برکت دے 🌙',
          '"سن لو! اللہ کے ذکر سے دل اطمینان پاتے ہیں۔" (القرآن 13:28) اس مقدس دن آپ کے دل کو سکون ملے 💫',
          'جب ہم اس مبارک واقعے کو یاد کرتے ہیں، اللہ تعالیٰ ہم سب پر اپنی برکتیں نازل فرمائے۔ آمین 🌟',
          'اس مقدس موقع کی برکت آپ کی زندگی کو نور اور ہدایت سے بھر دے ✨',
        ];
      default:
        return _getReligiousTemplates('en');
    }
  }

  /// Get localized relationship terms
  String _getLocalizedRelationship(String relationship, String language) {
    final relationshipMap = {
      'en': {
        'mother': 'mother',
        'father': 'father',
        'brother': 'brother',
        'sister': 'sister',
        'son': 'son',
        'daughter': 'daughter',
        'husband': 'husband',
        'wife': 'wife',
        'friend': 'friend',
        'cousin': 'cousin',
        'uncle': 'uncle',
        'aunt': 'aunt',
        'grandmother': 'grandmother',
        'grandfather': 'grandfather',
      },
      'ar': {
        'mother': 'أمي',
        'father': 'أبي',
        'brother': 'أخي',
        'sister': 'أختي',
        'son': 'ابني',
        'daughter': 'ابنتي',
        'husband': 'زوجي',
        'wife': 'زوجتي',
        'friend': 'صديقي',
        'cousin': 'ابن عمي',
        'uncle': 'عمي',
        'aunt': 'عمتي',
        'grandmother': 'جدتي',
        'grandfather': 'جدي',
      },
      'id': {
        'mother': 'ibu',
        'father': 'ayah',
        'brother': 'saudara',
        'sister': 'saudari',
        'son': 'anak laki-laki',
        'daughter': 'anak perempuan',
        'husband': 'suami',
        'wife': 'istri',
        'friend': 'teman',
        'cousin': 'sepupu',
        'uncle': 'paman',
        'aunt': 'bibi',
        'grandmother': 'nenek',
        'grandfather': 'kakek',
      },
      'ur': {
        'mother': 'امی',
        'father': 'ابو',
        'brother': 'بھائی',
        'sister': 'بہن',
        'son': 'بیٹا',
        'daughter': 'بیٹی',
        'husband': 'شوہر',
        'wife': 'بیوی',
        'friend': 'دوست',
        'cousin': 'کزن',
        'uncle': 'چچا',
        'aunt': 'پھوپھی',
        'grandmother': 'نانی',
        'grandfather': 'نانا',
      },
    };

    return relationshipMap[language]?[relationship.toLowerCase()] ?? relationship;
  }

  /// Check if a language is supported
  bool isLanguageSupported(String language) {
    return supportedLanguages.contains(language);
  }

  /// Get default language if requested language is not supported
  String getDefaultLanguage() {
    return 'en';
  }
}