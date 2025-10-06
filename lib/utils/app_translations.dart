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
    'password_required': 'Le mot de passe est requis',
    'sign_in': 'Se connecter',
    'dont_have_account': "Pas encore de compte ? ",
    'forgot_password': 'Mot de passe oublié ?',
    'email_required': 'L\'adresse e-mail est requise',
    'enter_valid_email': 'Veuillez entrer une adresse e-mail valide',
    'failed_send_reset_email': 'Échec de l\'envoi de l\'e-mail de réinitialisation',

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
    'enter_email_reset_password': 'Saisissez votre adresse e-mail pour réinitialiser votre mot de passe',
    'password_reset_sent': 'Le lien de réinitialisation a été envoyé à',
    'check_email_instructions': 'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe',
    'back_to_login': 'Retour à la connexion',
    'remember_password_sign_in': 'Vous vous souvenez de votre mot de passe ? Se connecter',
    'remember_password': 'Vous vous souvenez de votre mot de passe ? Se connecter',
    'name_required': 'Le nom complet est requis',
    'name_too_short': 'Le nom doit contenir au moins 2 caractères',
    'phone_required': 'Le numéro de téléphone est requis',
    'enter_valid_phone': 'Veuillez entrer un numéro de téléphone valide',
    'password_too_short': 'Le mot de passe doit contenir au moins 6 caractères',
    'password_requirements': 'Le mot de passe doit contenir majuscules, minuscules et chiffres',
    'confirm_password_required': 'Veuillez confirmer votre mot de passe',
    'passwords_not_match': 'Les mots de passe ne correspondent pas',
    'registration_failed': 'Échec de l\'inscription',
    'already_have_account': 'Déjà un compte ? ',

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

  // ============= HOME =============
  static const Map<String, String> home = {
    'need_security_now': 'Besoin de sécurité maintenant ?',
    'book_certified_agent_minutes': 'Réservez un agent certifié en quelques minutes',
    'quick_stats': 'Statistiques rapides',
    'active_agents': 'Agents actifs',
    'upcoming': 'À venir',
    'quick_actions': 'Actions rapides',
    'find_agents': 'Trouver des agents',
    'my_bookings': 'Mes réservations',
    'book_now': 'Réserver maintenant',
  };

  // ============= USER PROFILE =============
  static const Map<String, String> profile = {
    'my_profile': 'Mon Profil',
    'notifications': 'Notifications',
    'manage_notification_preferences': 'Gérer les préférences de notification',
    'payment_methods': 'Méthodes de paiement',
    'manage_your_payment_options': 'Gérer vos options de paiement',
    'security': 'Sécurité',
    'two_factor_authentication_password': 'Authentification à deux facteurs, mot de passe',
    'help_support': 'Aide et support',
    'about_us': 'À propos de nous',
    'terms_of_service': 'Conditions d\'utilisation',
    'privacy_policy': 'Politique de confidentialité',
    'cookie_policy': 'Politique de cookies',
    'sign_out': 'Se déconnecter',
    'completed': 'Terminé',
    'spent': 'Dépensé',
    'bookings': 'Réservations',
    'administrator': 'Administrateur',
    'premium_member': 'Membre Premium',
    'personal_information': 'Informations personnelles',
    'email': 'E-mail',
    'phone': 'Téléphone',
    'address': 'Adresse',
    'password': 'Mot de passe',
    'quick_actions': 'Actions rapides',
    'booking_history': 'Historique des réservations',
    'reviews': 'Avis',
    'settings_preferences': 'Paramètres et préférences',
    'support_legal': 'Support et mentions légales',
    'total_bookings': 'Total des réservations',
    'completed_bookings': 'Réservations terminées',
    'total_spent': 'Total dépensé',
    'member_since': 'Membre depuis',
    'currency_symbol': 'FCFA',
    'sign_out_confirmation': 'Êtes-vous sûr de vouloir vous déconnecter ?',
    'sign_out_confirm': 'Se déconnecter',
    'cancel': 'Annuler',

    // App Exit Confirmation
    'exit_app_confirmation': 'Êtes-vous sûr de vouloir quitter l\'application ?',
    'exit_app_title': 'Quitter l\'application',
    'exit_app_confirm': 'Quitter',
    'exit_app_message': 'Toutes vos données non sauvegardées seront perdues.',
    'app_exit_double_tap': 'Appuyez à nouveau pour quitter',

    // Profile Update
    'edit_profile': 'Modifier le profil',
    'update_profile': 'Mettre à jour le profil',
    'profile_updated_successfully': 'Profil mis à jour avec succès',
    'profile_update_error': 'Erreur lors de la mise à jour du profil',
    'save_changes': 'Enregistrer les modifications',
    'save': 'Enregistrer',
    'remove_photo': 'Supprimer la photo',
    'select_photo_source': 'Sélectionner la source de la photo',
    'camera': 'Caméra',
    'gallery': 'Galerie',
    'error_picking_image': 'Erreur lors de la sélection de l\'image',
    'address_information': 'Informations d\'adresse',
    'city': 'Ville',
    'country': 'Pays',
    'account_information': 'Informations du compte',
    'account_type': 'Type de compte',
    'please_enter_name': 'Veuillez entrer votre nom',
    'name_too_short': 'Le nom doit contenir au moins 2 caractères',
    'invalid_phone_number': 'Numéro de téléphone invalide',
    'enter_address_location': 'Entrez l\'adresse complète',
    'full_name': 'Nom complet',
    'phone_number': 'Numéro de téléphone',
  };

  // ============= LEGAL =============
  static const Map<String, String> legal = {
    'terms_of_service': 'Conditions d\'utilisation',
    'privacy_policy': 'Politique de confidentialité',
    'cookie_policy': 'Politique de cookies',
    'last_updated': 'Dernière mise à jour',
    'introduction': 'Introduction',
    'terms_intro': 'Bienvenue sur ZIBENE SECURITY. Ces conditions d\'utilisation régissent votre utilisation de notre application de services de sécurité.',
    'privacy_intro': 'Chez ZIBENE SECURITY, nous nous engageons à protéger votre vie privée. Cette politique explique comment nous collectons, utilisons et protégeons vos informations.',
    'cookie_intro': 'Cette politique explique comment nous utilisons les cookies pour améliorer votre expérience sur notre application.',
    'acceptance_terms': 'Acceptation des conditions',
    'user_responsibilities': 'Responsabilités de l\'utilisateur',
    'service_description': 'Description du service',
    'booking_terms': 'Conditions de réservation',
    'payment_terms': 'Conditions de paiement',
    'cancellation_policy': 'Politique d\'annulation',
    'limitation_liability': 'Limitation de responsabilité',
    'dispute_resolution': 'Résolution des litiges',
    'intellectual_property': 'Propriété intellectuelle',
    'privacy_commitment': 'Notre engagement vie privée',
    'information_collection': 'Collecte d\'informations',
    'information_usage': 'Utilisation des informations',
    'information_sharing': 'Partage d\'informations',
    'data_security': 'Sécurité des données',
    'user_rights': 'Droits de l\'utilisateur',
    'cookie_types': 'Types de cookies',
    'cookie_purpose': 'Objectif des cookies',
    'cookie_management': 'Gestion des cookies',
    'third_party_cookies': 'Cookies tiers',
    'analytics_cookies': 'Cookies d\'analyse',
    'functional_cookies': 'Cookies fonctionnels',
    'advertising_cookies': 'Cookies publicitaires',
    'contact_us': 'Nous contacter',
    'legal_changes': 'Modifications légales',
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
    'error': 'Erreur',
    'retry': 'Réessayer',
  };

  // ============= AGENT MANAGEMENT =============
  static const Map<String, String> agent = {
    // Agent Search
    'find_an_agent': 'Trouver un agent',
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

    // Help Screen translations
    'how_can_help_you': 'Comment pouvons-nous vous aider ?',
    'support_team_available_24_7': 'Notre équipe de support est disponible 24/7',
    'learn_how_to_use_app': 'Apprendre à utiliser l\'application',
    'watch_step_by_step_guides': 'Regarder les guides pas à pas',
    'search_faqs': 'Rechercher les FAQs',
    'search_for_help_topics': 'Rechercher des sujets d\'aide...',
    'frequently_asked_questions': 'Questions Fréquemment Posées',
    'user_guide': 'Guide Utilisateur',
    'video_tutorials': 'Tutoriels Vidéo',
    'faq_booking_title': 'Comment réserver un agent de sécurité ?',
    'faq_booking_content': 'Pour réserver un agent de sécurité, allez dans l\'onglet "Trouver des agents", parcourez les agents disponibles, sélectionnez votre agent préféré, choisissez votre date et heure, et confirmez votre réservation.',
    'faq_payment_title': 'Quelles sont les options de paiement ?',
    'faq_payment_content': 'Nous acceptons toutes les cartes de crédit majeures, les cartes de débit, PayPal, Apple Pay et les virements bancaires. Tous les paiements sont traités de manière sécurisée.',
    'faq_cancellation_title': 'Puis-je annuler ma réservation ?',
    'faq_cancellation_content': 'Oui, vous pouvez annuler votre réservation jusqu\'à 24 heures avant l\'heure prévue pour un remboursement complet. Les annulations dans les 24 heures peuvent entraîner des frais.',
    'faq_verification_title': 'Comment les agents sont-ils vérifiés ?',
    'faq_verification_content': 'Tous nos agents de sécurité subissent des vérifications d\'antécédents approfondies, une vérification des certifications et des entretiens en personne avant d\'être approuvés.',
    'support_line_24_7': 'Ligne de Support 24/7',
    'call_now': 'Appeler maintenant',
    'send_us_message': 'Envoyez-nous un message',
    'your_email': 'Votre Email',
    'subject': 'Sujet',
    'describe_your_issue': 'Décrivez votre problème...',
    'send_message': 'Envoyer le message',
    'legal_information': 'Informations Légales',
    'search_faqs_placeholder': 'Rechercher des sujets d\'aide...',
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
      case 'home':
        return home[key] ?? key;
      case 'profile':
        return profile[key] ?? key;
      case 'booking':
        return booking[key] ?? key;
      case 'legal':
        return legal[key] ?? key;
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