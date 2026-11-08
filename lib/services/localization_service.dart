import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  String _currentLanguage = 'en';

  LocalizationService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'si': 'සිංහල (Sinhala)',
    'ta': 'தமிழ் (Tamil)',
    'hi': 'हिंदी (Hindi)',
    'fr': 'Français (French)',
    'ml': 'മലയാളം (Malayalam)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'de': 'Deutsch (German)',
    'zh': '中文 (Chinese)',
    'ja': '日本語 (Japanese)',
    'ru': 'Русский (Russian)',
  };

  String get currentLanguage => _currentLanguage;
  String get currentLanguageName =>
      supportedLanguages[_currentLanguage] ?? 'English';

  Future<void> setLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  // Translation strings
  static const Map<String, Map<String, String>> _translations = {
    'app_name': {
      'en': 'Smart City',
      'si': 'ස්මාර්ට් සිටි',
      'ta': 'ஸ்மார்ட் சிட்டி',
      'hi': 'स्मार्ट सिटी',
      'fr': 'Ville Intelligente',
      'ml': 'സ്മാർട്ട് സിറ്റി',
      'kn': 'ಸ್ಮಾರ್ಟ್ ಸಿಟಿ',
    },
    'home': {
      'en': 'Home',
      'si': 'මුල් පිටුව',
      'ta': 'முகப்பு',
      'hi': 'होम',
      'fr': 'Accueil',
      'ml': 'ഹോം',
      'kn': 'ಮುಖಪುಟ',
    },
    'explore': {
      'en': 'Explore',
      'si': 'ගවේෂණය',
      'ta': 'ஆராய்ச்சி',
      'hi': 'अन्वेषण',
      'fr': 'Explorer',
      'ml': 'പര്യവേക്ഷിക്കുക',
      'kn': 'ಅನ್ವೇಷಿಸಿ',
    },
    'profile': {
      'en': 'Profile',
      'si': 'පැතිකඩ',
      'ta': 'சுயவிவரம்',
      'hi': 'प्रोफ़ाइल',
      'fr': 'Profil',
      'ml': 'പ്രൊഫൈൽ',
      'kn': 'ಪ್ರೊಫೈಲ್',
    },
    'login': {
      'en': 'Login',
      'si': 'පිවිසුම',
      'ta': 'உள்நுழை',
      'hi': 'लॉगिन',
      'fr': 'Connexion',
      'ml': 'ലോഗിൻ',
      'kn': 'ಲಾಗಿನ್',
    },
    'register': {
      'en': 'Register',
      'si': 'ලියාපදිංචිය',
      'ta': 'பதிவு',
      'hi': 'पंजीकरण',
      'fr': "S'inscrire",
      'ml': 'രജിസ്റ്റർ',
      'kn': 'ನೋಂದಣಿ',
    },
    'username': {
      'en': 'Username',
      'si': 'පරිශීලක නම',
      'ta': 'பயனர்பெயர்',
      'hi': 'उपयोगकर्ता नाम',
      'fr': "Nom d'utilisateur",
      'ml': 'യൂസർനെയിം',
      'kn': 'ಬಳಕೆದಾರಹೆಸರು',
    },
    'password': {
      'en': 'Password',
      'si': 'මුරපදය',
      'ta': 'கடவுச்சொல்',
      'hi': 'पासवर्ड',
      'fr': 'Mot de passe',
      'ml': 'പാസ്‌വേഡ്',
      'kn': 'ಪಾಸ್ವರ್ಡ್',
    },
    'book_now': {
      'en': 'Book Now',
      'si': 'දැන් වෙන් කරන්න',
      'ta': 'இப்போது புக் செய்',
      'hi': 'अभी बुक करें',
      'fr': 'Réserver',
      'ml': 'ഇപ്പോൾ ബുക്ക് ചെയ്യുക',
      'kn': 'ಈಗ ಬುಕ್ ಮಾಡಿ',
    },
    'sim_recommendation': {
      'en': 'SIM Recommendation',
      'si': 'SIM නිර්දේශය',
      'ta': 'சிம் பரிந்துரை',
      'hi': 'सिम अनुशंसा',
      'fr': 'Recommandation SIM',
      'ml': 'സിം ശുപാർശ',
      'kn': 'ಸಿಮ್ ಶಿಫಾರಸು',
    },
    'hotel_booking': {
      'en': 'Hotel Booking',
      'si': 'හෝටල් වෙන්කිරීම',
      'ta': 'ஹோட்டல் முன்பதிவு',
      'hi': 'होटल बुकिंग',
      'fr': "Réservation d'hôtel",
      'ml': 'ഹോട്ടൽ ബുക്കിംഗ്',
      'kn': 'ಹೋಟೆಲ್ ಬುಕಿಂಗ್',
    },
    'ai_planner': {
      'en': 'AI Travel Planner',
      'si': 'AI සංචාරක සැලසුම්කරු',
      'ta': 'AI பயண திட்டமிடுபவர்',
      'hi': 'AI यात्रा योजनाकार',
      'fr': 'Planificateur AI',
      'ml': 'AI ട്രാവൽ പ്ലാനർ',
      'kn': 'AI ಪ್ರಯಾಣ ಯೋಜಕ',
    },
    'language': {
      'en': 'Language',
      'si': 'භාෂාව',
      'ta': 'மொழி',
      'hi': 'भाषा',
      'fr': 'Langue',
      'ml': 'ഭാഷ',
      'kn': 'ಭಾಷೆ',
    },
    'settings': {
      'en': 'Settings',
      'si': 'සැකසුම්',
      'ta': 'அமைப்புகள்',
      'hi': 'सेटिंग्स',
      'fr': 'Paramètres',
      'ml': 'ക്രമീകരണങ്ങൾ',
      'kn': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    },
    'days': {
      'en': 'Days',
      'si': 'දින',
      'ta': 'நாட்கள்',
      'hi': 'दिन',
      'fr': 'Jours',
      'ml': 'ദിവസങ്ങൾ',
      'kn': 'ದಿನಗಳು',
    },
    'budget': {
      'en': 'Budget',
      'si': 'අයවැය',
      'ta': 'பட்ஜெட்',
      'hi': 'बजट',
      'fr': 'Budget',
      'ml': 'ബജറ്റ്',
      'kn': 'ಬಜೆಟ್',
    },
    'guides': {
      'en': 'Guides',
      'si': 'මාර්ගෝපදේශකයින්',
      'ta': 'வழிகாட்டிகள்',
      'hi': 'गाइड',
      'fr': 'Guides',
      'ml': 'ഗൈഡുകൾ',
      'kn': 'ಮಾರ್ಗದರ್ಶಿಗಳು',
    },
  };

  String translate(String key) {
    final translations = _translations[key];
    if (translations == null) return key;
    return translations[_currentLanguage] ?? translations['en'] ?? key;
  }
}
