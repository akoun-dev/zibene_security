import 'package:flutter/material.dart';
import 'app_translations.dart';

class TranslationHelper {

  // Méthode principale pour obtenir une traduction
  static String translate(BuildContext context, String category, String key) {
    return AppTranslations.get(category, key);
  }

  // Méthodes raccourcies pour les catégories courantes
  static String auth(BuildContext context, String key) => translate(context, 'auth', key);
  static String nav(BuildContext context, String key) => translate(context, 'navigation', key);
  static String profile(BuildContext context, String key) => translate(context, 'profile', key);
  static String booking(BuildContext context, String key) => translate(context, 'booking', key);
  static String agent(BuildContext context, String key) => translate(context, 'agent', key);
  static String help(BuildContext context, String key) => translate(context, 'help', key);
  static String payment(BuildContext context, String key) => translate(context, 'payment', key);
  static String admin(BuildContext context, String key) => translate(context, 'admin', key);
  static String status(BuildContext context, String key) => translate(context, 'status', key);
  static String error(BuildContext context, String key) => translate(context, 'errors', key);
  static String success(BuildContext context, String key) => translate(context, 'success', key);

  // Extension pour faciliter l'utilisation dans les widgets
  static String tr(BuildContext context, String key) {
    // Essayer de trouver la clé dans toutes les catégories
    final categories = [
      'auth', 'navigation', 'home', 'profile', 'booking', 'legal',
      'agent', 'help', 'payment', 'admin', 'status', 'about',
      'notifications', 'adminComm', 'errors', 'success',
      'services', 'defaults', 'mockData'
    ];

    for (final category in categories) {
      final translated = AppTranslations.get(category, key);
      if (translated != key) {
        return translated;
      }
    }
    return key;
  }
}

// Extension String pour une utilisation plus simple
extension StringTranslation on String {
  String t(BuildContext context) {
    return TranslationHelper.tr(context, this);
  }
}