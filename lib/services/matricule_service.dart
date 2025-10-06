import 'package:flutter/foundation.dart';
import 'dart:math';

class MatriculeService {
  static const String _prefix = 'AGT'; // Agent prefix
  static const int _currentYearStart = 2025;

  // Générer un matricule unique pour un agent
  static String generateMatricule() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2); // Ex: 2025 -> 25
    final month = now.month.toString().padLeft(2, '0'); // Ex: 3 -> 03

    // Générer un nombre aléatoire entre 1000 et 9999
    final random = Random();
    final sequence = (1000 + random.nextInt(9000)).toString();

    return '$_prefix$year$month$sequence'; // Ex: AGT25031234
  }

  // Générer un matricule avec un format spécifique
  static String generateMatriculeWithFormat({
    String prefix = 'AGT',
    bool includeYear = true,
    bool includeMonth = true,
    int sequenceLength = 4,
  }) {
    final now = DateTime.now();
    String matricule = prefix;

    if (includeYear) {
      final year = now.year.toString().substring(2);
      matricule += year;
    }

    if (includeMonth) {
      final month = now.month.toString().padLeft(2, '0');
      matricule += month;
    }

    // Générer la séquence
    final random = Random();
    final minSeq = pow(10, sequenceLength - 1).toInt();
    final maxSeq = pow(10, sequenceLength).toInt() - 1;
    final sequence = (minSeq + random.nextInt(maxSeq - minSeq + 1)).toString();
    matricule += sequence;

    return matricule;
  }

  // Valider le format d'un matricule
  static bool isValidMatriculeFormat(String matricule) {
    // Format attendu: AGTYYMMXXXX (ex: AGT25031234)
    final regex = RegExp(r'^AGT\d{6}$');
    return regex.hasMatch(matricule);
  }

  // Extraire la date d'un matricule
  static DateTime? extractDateFromMatricule(String matricule) {
    if (!isValidMatriculeFormat(matricule)) return null;

    try {
      final yearPart = matricule.substring(3, 5); // YY
      final monthPart = matricule.substring(5, 7); // MM

      final year = 2000 + int.parse(yearPart); // Convertir YY en YYYY
      final month = int.parse(monthPart);

      return DateTime(year, month);
    } catch (e) {
      debugPrint('MatriculeService: Erreur extraction date: $e');
      return null;
    }
  }

  // Vérifier si un matricule est récent (moins de 6 mois)
  static bool isRecentMatricule(String matricule, {int maxMonthsAgo = 6}) {
    final date = extractDateFromMatricule(matricule);
    if (date == null) return false;

    final now = DateTime.now();
    final difference = now.difference(date);
    final monthsDifference = difference.inDays / 30;

    return monthsDifference <= maxMonthsAgo;
  }

  // Générer un matricule basé sur le nom de l'agent
  static String generateMatriculeForAgent(String name) {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');

    // Extraire les 3 premières lettres du nom (en majuscules)
    final nameCleaned = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final namePrefix = nameCleaned.length >= 3 ? nameCleaned.substring(0, 3) : nameCleaned.padRight(3, 'X');

    // Générer une séquence
    final random = Random();
    final sequence = (100 + random.nextInt(900)).toString(); // 3 chiffres

    return 'AGT$namePrefix$year$month$sequence'; // Ex: AGTMAR2503123
  }

  // Formater un matricule pour l'affichage
  static String formatMatriculeForDisplay(String matricule) {
    if (matricule.length < 11) return matricule; // AGTYYMMXXXX

    return '${matricule.substring(0, 3)}-${matricule.substring(3, 7)}-${matricule.substring(7)}';
    // Ex: AGT-2503-1234
  }
}