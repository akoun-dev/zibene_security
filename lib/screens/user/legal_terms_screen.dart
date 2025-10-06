import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'terms_of_service'.t(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('terms_of_service'.t(context), context),
            const SizedBox(height: 24),
            _buildSection('last_updated'.t(context), '15 Novembre 2024', context),
            _buildSection('introduction'.t(context), 'terms_intro'.t(context), context),
            _buildSection('acceptance_terms'.t(context),
              'En utilisant ZIBENE SECURITY, vous acceptez ces conditions. Si vous n\'acceptez pas ces conditions, n\'utilisez pas notre application.', context),
            _buildSection('service_description'.t(context),
              'ZIBENE SECURITY est une application mobile qui connecte les clients avec des agents de sécurité certifiés pour des services de protection professionnelle et personnelle.', context),
            _buildSection('user_responsibilities'.t(context),
              '• Fournir des informations exactes et véridiques\n• Respecter les agents de sécurité\n• Annuler les réservations raisonnablement à l\'avance\n• Respecter les lois locales et nationales', context),
            _buildSection('booking_terms'.t(context),
              '• Les réservations sont sujettes à disponibilité des agents\n• Les tarifs sont affichés clairement avant confirmation\n• Les heures supplémentaires doivent être approuvées au préalable', context),
            _buildSection('payment_terms'.t(context),
              '• Les paiements sont traités via notre partenaire de paiement sécurisé\n• Les agents sont payés après completion du service\n• Les frais de service sont inclus dans le prix affiché', context),
            _buildSection('cancellation_policy'.t(context),
              '• Annulation 24h avant : Remboursement complet\n• Annulation 12-24h avant : Remboursement de 50%\n• Annulation moins de 12h avant : Aucun remboursement', context),
            _buildSection('limitation_liability'.t(context),
              'ZIBENE SECURITY n\'est pas responsable des dommages indirects, consécutifs ou spéciaux découlant de l\'utilisation de nos services.', context),
            _buildSection('dispute_resolution'.t(context),
              'Tout litige sera réglé par arbitrage conformément aux lois du pays où le service a été fourni.', context),
            _buildSection('legal_changes'.t(context),
              'Nous nous réservons le droit de modifier ces conditions. Les modifications prendront effet dès leur publication sur l\'application.', context),
            const SizedBox(height: 32),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'privacy_policy'.t(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('privacy_policy'.t(context), context),
            const SizedBox(height: 24),
            _buildSection('last_updated'.t(context), '15 Novembre 2024', context),
            _buildSection('privacy_commitment'.t(context), 'privacy_intro'.t(context), context),
            _buildSection('information_collection'.t(context),
              '• Informations personnelles (nom, email, téléphone)\n• Informations de localisation (pour le service)\n• Historique des réservations\n• Données de paiement sécurisées\n• Préférences utilisateur', context),
            _buildSection('information_usage'.t(context),
              '• Fournir et améliorer nos services\n• Communiquer avec les utilisateurs\n• Traiter les paiements\n• Assurer la sécurité des transactions\n• Personnaliser l\'expérience utilisateur', context),
            _buildSection('information_sharing'.t(context),
              '• Nous ne vendons pas vos données personnelles\n• Informations partagées uniquement avec les agents concernés\n• Données anonymisées pour l\'analyse statistique\n• Conformité avec les lois applicables', context),
            _buildSection('data_security'.t(context),
              '• Chiffrement des données de bout en bout\n• Serveurs sécurisés et authentifiés\n• Accès limité au personnel autorisé\n• Audits de sécurité réguliers\n• Conformité RGPD', context),
            _buildSection('user_rights'.t(context),
              '• Accès à vos données personnelles\n• Correction d\'informations inexactes\n• Suppression de votre compte et données\n• Refus du marketing personnalisé\n• Portabilité des données', context),
            _buildSection('legal_changes'.t(context),
              'Cette politique peut être mise à jour. Les modifications seront communiquées aux utilisateurs via l\'application.', context),
            const SizedBox(height: 32),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }
}

class CookieScreen extends StatelessWidget {
  const CookieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'cookie_policy'.t(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('cookie_policy'.t(context), context),
            const SizedBox(height: 24),
            _buildSection('last_updated'.t(context), '15 Novembre 2024', context),
            _buildSection('cookie_intro'.t(context),
              'Les cookies sont de petits fichiers texte stockés sur votre appareil pour améliorer votre expérience utilisateur.', context),
            _buildSection('cookie_types'.t(context),
              '• **Cookies fonctionnels** : Essentiels au fonctionnement de l\'application\n• **Cookies d\'analyse** : Pour comprendre comment vous utilisez l\'app\n• **Cookies publicitaires** : Pour des publicités pertinentes\n• **Cookies tiers** : De partenaires de confiance', context),
            _buildSection('cookie_purpose'.t(context),
              '• Maintenir votre session active\n• Se souvenir de vos préférences\n• Améliorer les performances\n• Analyser l\'utilisation pour l\'optimisation\n• Assurer la sécurité', context),
            _buildSection('functional_cookies'.t(context),
              'Nécessaires au fonctionnement de base de l\'application : authentification, panier, préférences de base.', context),
            _buildSection('analytics_cookies'.t(context),
              'Nous aident à comprendre comment les utilisateurs interagissent avec l\'application pour l\'améliorer.', context),
            _buildSection('advertising_cookies'.t(context),
              'Utilisés pour vous montrer des publicités pertinentes basées sur vos intérêts et votre comportement.', context),
            _buildSection('third_party_cookies'.t(context),
              'Nous utilisons des cookies de partenaires de confiance pour les paiements, l\'analyse et la sécurité.', context),
            _buildSection('cookie_management'.t(context),
              '• Vous pouvez contrôler les cookies via les paramètres de votre appareil\n• Bloquer les cookies peut affecter certaines fonctionnalités\n• Vous pouvez supprimer les cookies stockés à tout moment', context),
            _buildSection('legal_changes'.t(context),
              'Cette politique peut être mise à jour pour refléter les changements dans nos pratiques.', context),
            const SizedBox(height: 32),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader(String title, BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.yellow.withValues(alpha: 0.2),
          AppColors.yellow.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.yellow.withValues(alpha: 0.3),
      ),
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildSection(String title, String content, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.yellow,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

Widget _buildContactSection(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.yellow.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.yellow.withValues(alpha: 0.3),
      ),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.contact_support,
          size: 48,
          color: AppColors.yellow,
        ),
        const SizedBox(height: 16),
        Text(
          'contact_us'.t(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pour toute question concernant nos conditions, notre politique de confidentialité ou cette politique de cookies, contactez-nous :',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Email: legal@zibene-security.com\nTéléphone: +33 1 23 45 67 89',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.yellow,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

