// Traductions françaises pour l'application ZIBENE SECURITY
class AppTranslations {
  // ============= AUTHENTICATION =============
  static const Map<String, String> auth = {
    // Welcome Screen
    'sign_up': 'Inscription',
    'log_in': 'Connexion',

    // Login Screen
    'welcome_back': 'Bienvenue',
    'please_fill_all_fields': 'Veuillez remplir tous les champs',
    'email_address': 'Adresse e-mail',
    'password': 'Mot de passe',
    'sign_in': 'Se connecter',
    'dont_have_account': "Pas encore de compte ? ",
    'forgot_password': 'Mot de passe oublié ?',

    // Sign Up Screen
    'create_account': 'Créer un compte',
    'please_accept_terms': 'Veuillez accepter les conditions générales',
    'full_name': 'Nom complet',
    'phone_number': 'Numéro de téléphone',
    'confirm_password': 'Confirmer le mot de passe',
    'privacy_policy': 'Politique de confidentialité',

    // Forgot Password
    'reset_password': 'Réinitialiser le mot de passe',
    'send_reset_link': 'Envoyer le lien de réinitialisation',
    'remember_password': 'Vous vous souvenez de votre mot de passe ? Se connecter',

    // Verify Email
    'verify_email': 'Vérifier l\'e-mail',
    'verification_resent': 'E-mail de vérification renvoyé avec succès',
    'verify_your_email': 'Vérifiez votre adresse e-mail',
    'email_sent': 'E-mail envoyé !',
    'resend_email': 'Renvoyer l\'e-mail',
    'already_verified': 'Déjà vérifié ? Se connecter',
  };

  // ============= NAVIGATION =============
  static const Map<String, String> navigation = {
    // Bottom Navigation
    'home': 'Accueil',
    'agents': 'Agents',
    'bookings': 'Réservations',
    'profile': 'Profil',
    'admin': 'Admin',
    'dashboard': 'Tableau de bord',
    'users': 'Utilisateurs',
    'reports': 'Rapports',

    // Admin Drawer
    'admin_tools': 'Outils d\'administration',
    'alerts': 'Alertes',
    'system_monitor': 'Moniteur système',
    'roles_permissions': 'Rôles et permissions',
    'send_notification': 'Envoyer notification',
    'activity_log': 'Journal d\'activité',
  };

  // ============= USER PROFILE =============
  static const Map<String, String> profile = {
    'my_profile': 'Mon Profil',
    'notifications': 'Notifications',
    'manage_notification_prefs': 'Gérer les préférences de notification',
    'payment_methods': 'Méthodes de paiement',
    'manage_payment_options': 'Gérer vos options de paiement',
    'security': 'Sécurité',
    'two_factor_auth': 'Authentification à deux facteurs, mot de passe',
    'help_support': 'Aide et support',
    'about_us': 'À propos de nous',
    'terms_of_service': 'Conditions d\'utilisation',
    'privacy_policy': 'Politique de confidentialité',
    'sign_out': 'Se déconnecter',
    'completed': 'Terminé',
    'spent': 'Dépensé',
  };

  // ============= BOOKING SYSTEM =============
  static const Map<String, String> booking = {
    // Booking Confirmation
    'book_security_agent': 'Réserver un agent de sécurité',
    'booking_details': 'Détails de la réservation',
    'date': 'Date',
    'select_date': 'Sélectionner une date',
    'start_time': 'Heure de début',
    'select_time': 'Sélectionner une heure',
    'end_time': 'Heure de fin',
    'duration': 'Durée',
    'location': 'Lieu',
    'enter_address': 'Entrez l\'adresse ou le lieu',
    'special_requirements': 'Exigences spéciales ou instructions...',
    'hourly_rate': 'Taux horaire',
    'total_cost': 'Coût total',
    'confirm_booking': 'Confirmer la réservation',
    'cancel': 'Annuler',
    'booking_confirmed': 'Réservation confirmée avec succès !',

    // Booking Details
    'schedule': 'Horaire',
    'timeline': 'Chronologie',
    'created': 'Créée',
    'confirmed': 'Confirmée',
    'in_progress': 'En cours',
    'cancel_booking': 'Annuler la réservation',
    'contact_agent': 'Contacter l\'agent',
    'rate_review': 'Évaluer et commenter',

    // Bookings List
    'my_bookings': 'Mes réservations',
    'upcoming': 'À venir',
    'completed': 'Terminées',
    'cancelled': 'Annulées',
    'no_upcoming_bookings': 'Aucune réservation à venir',
    'no_completed_bookings': 'Aucune réservation terminée',
    'no_cancelled_bookings': 'Aucune réservation annulée',
  };

  // ============= AGENT MANAGEMENT =============
  static const Map<String, String> agent = {
    // Agent Search
    'find_agent': 'Trouver un agent',
    'search_by_name_location': 'Rechercher par nom, lieu...',
    'all_filters': 'Tous les filtres',

    // Agent Profile
    'agent_profile': 'Profil de l\'agent',
    'response_time': 'Temps de réponse',
    'book_now': 'Réserver maintenant',

    // Rate & Review
    'rate_review': 'Évaluer et commenter',
    'your_rating': 'Votre évaluation',
    'leave_comment': 'Laisser un commentaire',
    'share_experience': 'Partagez votre expérience...',
    'review_submitted': 'Commentaire soumis',
    'submit_review': 'Soumettre l\'évaluation',
  };

  // ============= HELP & SUPPORT =============
  static const Map<String, String> help = {
    'help_support': 'Aide et Support',
    'quick_help': 'Aide rapide',
    'user_guide': 'Guide utilisateur',
    'video_tutorials': 'Tutoriels vidéo',
    'search_help_topics': 'Rechercher des sujets d\'aide...',
    'frequently_asked_questions': 'Questions fréquentes',
    'faq_booking_instructions': 'Pour réserver un agent de sécurité, allez dans l\'onglet "Trouver des agents", parcourez les agents disponibles, sélectionnez votre agent préféré, choisissez votre date et heure, et confirmez votre réservation.',
    'contact_support': 'Contacter le support',
    'your_email': 'Votre e-mail',
    'subject': 'Sujet',
    'describe_issue': 'Décrivez votre problème...',
    'send_message': 'Envoyer le message',
    'legal_information': 'Informations légales',
    'cookie_policy': 'Politique de cookies',
    'call_now': 'Appeler maintenant',
  };

  // ============= PAYMENT SYSTEM =============
  static const Map<String, String> payment = {
    'payment_methods': 'Méthodes de paiement',
    'manage_all': 'Gérer tout',
    'billing_history': 'Historique des factures',
    'view_past_transactions': 'Voir les transactions et factures passées',
    'billing_address': 'Adresse de facturation',
    'remove_all_payment_methods': 'Supprimer toutes les méthodes de paiement',
    'edit': 'Modifier',
    'set_as_default': 'Définir par défaut',
    'daily_rate': 'Taux journalier',
  };

  // ============= ADMIN MANAGEMENT =============
  static const Map<String, String> admin = {
    // Dashboard
    'search_users': 'Rechercher des utilisateurs',
    'add_new_user': 'Ajouter un nouvel utilisateur',
    'status_all': 'Statut : Tous',
    'search_agents': 'Rechercher des agents',
    'add_new_agent': 'Ajouter un nouvel agent',
    'delete_agent': 'Supprimer l\'agent',
    'delete_agent_confirmation': 'Êtes-vous sûr de vouloir supprimer cet agent ? Cette action ne peut pas être annulée.',
    'save': 'Enregistrer',
    'delete': 'Supprimer',
    'available': 'Disponible',

    // System Monitor
    'server_status': 'Statut du serveur',
    'memory_usage': 'Utilisation de la mémoire',
    'network_latency': 'Latence réseau',
    'active_sessions': 'Sessions actives',
    'bodyguard_sessions': 'Sessions gardes du corps',
    'client_sessions': 'Sessions clients',
    'potential_issues': 'Problèmes potentiels',
    'network_alert': 'Alerte réseau',
    'network_latency_threshold': 'Latence réseau dépassant le seuil',

    // Reports
    'agent_performance': 'Performance des agents',
    'user_activity': 'Activité des utilisateurs',
    'booking_trends': 'Tendances des réservations',
    'financials': 'Financier',
    'start_date': 'Date de début',
    'end_date': 'Date de fin',
    'last_7_days': 'Derniers 7 jours',
    'last_30_days': 'Derniers 30 jours',
    'last_90_days': 'Derniers 90 jours',
    'report_generated': 'Rapport généré',
    'close': 'Fermer',
    'generate_report': 'Générer un rapport',

    // Alerts
    'dismiss': 'Ignorer',
    'investigate': 'Enquêter',
  };

  // ============= STATUS & SYSTEM MESSAGES =============
  static const Map<String, String> status = {
    // Booking Status
    'pending': 'En attente',
    'confirmed': 'Confirmée',
    'in_progress': 'En cours',
    'completed': 'Terminée',
    'cancelled': 'Annulée',
    'rejected': 'Rejetée',
    'unknown': 'Inconnue',

    // Payment Status
    'processing': 'En traitement',
    'failed': 'Échoué',
    'refunded': 'Remboursé',

    // Payment Methods
    'apple_pay': 'Apple Pay',
    'bank_transfer': 'Virement bancaire',

    // Time Display
    'today': 'Aujourd\'hui',
    'yesterday': 'Hier',

    // Notification Types
    'booking': 'Réservation',
    'payment': 'Paiement',
    'system': 'Système',
    'message': 'Message',
    'review': 'Évaluation',
    'security': 'Sécurité',

    // User Roles
    'client': 'Client',
    'agent': 'Agent',
    'admin': 'Administrateur',
  };

  // ============= ABOUT SCREEN =============
  static const Map<String, String> about = {
    'about_us': 'À propos de nous',
    'company_name': 'ZIBENE SECURITY',
    'tagline': 'Votre sécurité, notre priorité.',
    'our_mission': 'Notre Mission',
    'mission_statement': 'Fournir des services de sécurité inégalés avec le plus grand professionnalisme et discrétion. Nous assurons sécurité et tranquillité d\'esprit grâce à des gardes du corps hautement qualifiés et certifiés, disponibles à tout moment, n\'importe où.',
    'our_values': 'Nos Valeurs',
    'integrity': 'Intégrité',
    'integrity_desc': 'Nous opérons avec honnêteté et de forts principes moraux.',
    'excellence': 'Excellence',
    'excellence_desc': 'Nous visons les plus hauts standards dans tous les aspects de notre service.',
    'commitment': 'Engagement',
    'commitment_desc': 'Nous sommes dédiés à la sécurité et la satisfaction de nos clients.',
    'contact_information': 'Informations de contact',
    'contact_email': 'contact@zibenesecurity.com',
    'contact_phone': '+1 (234) 567-890',
    'contact_address': '123 Avenue de la Sécurité, Bureau 100, Métropole, ST 12345',
  };

  // ============= NOTIFICATIONS =============
  static const Map<String, String> notifications = {
    'zibene_security_notifications': 'Notifications Zibene Security',
    'security_service_notifications': 'Notifications de service de sécurité',
    'booking_reminder': 'Rappel de réservation',
    'new_booking_request': 'Nouvelle demande de réservation',
    'booking_confirmed': 'Réservation confirmée',
    'booking_cancelled': 'Réservation annulée',
    'booking_completed': 'Réservation terminée',
    'booking_update': 'Mise à jour de réservation',
    'payment_successful': 'Paiement réussi',
    'payment_failed': 'Paiement échoué',
    'account_approved': 'Compte approuvé',
    'type_a_message': 'Tapez un message...',
    'compose_message': 'Rédigez votre message ici...',
  };

  // ============= ADMIN COMMUNICATION =============
  static const Map<String, String> adminComm = {
    'promotional': 'Promotionnel',
    'transactional': 'Transactionnel',
    'all_users': 'Tous les utilisateurs',
    'clients': 'Clients',
    'agents': 'Agents',
    'send_immediately': 'Envoyer immédiatement',
    'schedule': 'Programmer...',
  };

  // ============= ERROR MESSAGES =============
  static const Map<String, String> errors = {
    'user_not_found': 'Utilisateur non trouvé',
    'agent_not_found': 'Agent non trouvé',
    'booking_not_found': 'Réservation non trouvée',
    'payment_not_found': 'Paiement non trouvé',
    'review_not_found': 'Évaluation non trouvée',
    'notification_not_found': 'Notification non trouvée',
    'unauthorized_access': 'Accès non autorisé',
    'invalid_data': 'Données invalides fournies',
    'database_error': 'Erreur de base de données survenue',
  };

  // ============= SUCCESS MESSAGES =============
  static const Map<String, String> success = {
    'user_created': 'Utilisateur créé avec succès',
    'user_updated': 'Utilisateur mis à jour avec succès',
    'booking_created': 'Réservation créée avec succès',
    'booking_updated': 'Réservation mise à jour avec succès',
    'payment_processed': 'Paiement traité avec succès',
    'review_submitted': 'Évaluation soumise avec succès',
    'notification_sent': 'Notification envoyée avec succès',
    'agent_approved': 'Agent approuvé avec succès',
  };

  // ============= SERVICE TYPES =============
  static const Map<String, String> services = {
    'executive_protection': 'Protection exécutive',
    'corporate_security': 'Sécurité d\'entreprise',
    'event_security': 'Sécurité d\'événement',
    'residential_security': 'Sécurité résidentielle',
    'personal_security': 'Sécurité personnelle',
  };

  // ============= DEFAULT VALUES =============
  static const Map<String, String> defaults = {
    'user': 'Utilisateur',
    'unknown': 'Inconnu',
  };

  // ============= MOCK DATA (Noms d'agents et entreprises) =============
  static const Map<String, String> mockData = {
    'marcus_cole': 'Marcus Cole',
    'elite_protection': 'Protection d\'Élite',
    'sentinel_services': 'Services Sentinel',
    'sofia_reyes': 'Sofia Reyes',
    'executive_guard': 'Garde Exécutif',
    'aegis_protection': 'Protection Égide',
    'leo_chen': 'Leo Chen',
    'corporate_security': 'Sécurité d\'Entreprise',
    'shield_guard': 'Garde Bouclier',
    'security_office_downtown': 'Bureau de sécurité Centre-ville',
  };

  // Méthode helper pour obtenir une traduction
  static String get(String category, String key) {
    switch (category) {
      case 'auth':
        return auth[key] ?? key;
      case 'navigation':
        return navigation[key] ?? key;
      case 'profile':
        return profile[key] ?? key;
      case 'booking':
        return booking[key] ?? key;
      case 'agent':
        return agent[key] ?? key;
      case 'help':
        return help[key] ?? key;
      case 'payment':
        return payment[key] ?? key;
      case 'admin':
        return admin[key] ?? key;
      case 'status':
        return status[key] ?? key;
      case 'about':
        return about[key] ?? key;
      case 'notifications':
        return notifications[key] ?? key;
      case 'adminComm':
        return adminComm[key] ?? key;
      case 'errors':
        return errors[key] ?? key;
      case 'success':
        return success[key] ?? key;
      case 'services':
        return services[key] ?? key;
      case 'defaults':
        return defaults[key] ?? key;
      case 'mockData':
        return mockData[key] ?? key;
      default:
        return key;
    }
  }
}