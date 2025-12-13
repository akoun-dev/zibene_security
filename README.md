# 🛡️ ZIBENE SECURITY

**Application mobile Flutter pour la réservation de services de sécurité certifiés**

Une plateforme moderne et intuitive qui connecte les clients avec des services de sécurité professionnels, gérée par une interface d'administration complète.

## ✨ Fonctionnalités

### 👤 Pour les Clients
- **Recherche et Réservation** : Trouvez et réservez facilement des agents de sécurité
- **Suivi des Réservations** : Consultez vos réservations en cours, passées et annulées
- **Profils Personnalisés** : Gérez vos informations personnelles
- **Système d'Avis** : Évaluez les services reçus
- **Paiements Sécurisés** : Intégration Stripe pour les transactions

### ⚙️ Pour les Administrateurs
- **Dashboard Complet** : Vue d'ensemble des statistiques et activités
- **Gestion des Utilisateurs** : Activation, désactivation et gestion des comptes
- **Gestion des Réservations** : Supervision de toutes les réservations du système
- **Rapports et Analytics** : Suivi des performances et tendances
- **Notifications Système** : Envoi d'alertes et communications
- **Monitoring en Temps Réel** : Surveillance de l'état du système

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter 3.x** installé
- **Node.js** (pour les outils de développement)
- **IDE** : VS Code, Android Studio ou IntelliJ IDEA

### Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/votre-username/zibene-security.git
   cd zibene-security
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer Firebase**
   ```bash
   flutterfire configure
   ```

4. **Lancer l'application**
   ```bash
   # Sans clé Stripe (développement)
   flutter run

   # Avec clé Stripe (production)
   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=VOTRE_CLE_STRIPE
   ```

## 🏗️ Architecture Technique

### Structure du Projet
```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   ├── user_unified.dart     # Modèle utilisateur unifié
│   ├── booking_model.dart    # Modèle de réservation
│   └── ...
├── providers/                # Gestion d'état (Provider)
│   ├── auth_provider.dart    # Authentification
│   ├── user_provider.dart    # Gestion utilisateurs
│   ├── booking_provider.dart # Gestion réservations
│   └── ...
├── screens/                  # Écrans de l'application
│   ├── auth/                 # Connexion, inscription
│   ├── user/                 # Interface client
│   ├── admin/                # Interface admin
│   └── shells/               # Navigation principale
├── services/                 # Services métier
│   ├── firebase_service.dart # Service Firebase
│   ├── auth_service.dart     # Service authentification
│   └── ...
├── utils/                    # Utilitaires
│   ├── theme.dart            # Thème et couleurs
│   ├── translations.dart     # Internationalisation
│   └── ...
└── widgets/                  # Composants réutilisables
```

### Architecture Backend
- **Firebase Firestore** : Base de données NoSQL
- **Firebase Authentication** : Authentification sécurisée
- **Firebase Storage** : Stockage des fichiers
- **Stripe** : Traitement des paiements

### Base de Données
Les collections Firestore :
- `users` : Comptes utilisateurs (clients/admins)
- `bookings` : Réservations avec statuts
- `payments` : Transactions et paiements
- `reviews` : Avis et évaluations
- `notifications` : Notifications système

## 🎨 Thème et Design

### Palette de Couleurs
- **Background** : `#121212` (Dark theme)
- **Primary** : `#FFC107` (Jaune)
- **Secondary** : `#FFD740` (Jaune clair)
- **Success** : `#4CAF50` (Vert)
- **Warning** : `#FF9800` (Orange)
- **Error** : `#F44336` (Rouge)

### Composants UI
- **Design Material 3** avec thème sombre par défaut
- **Responsive** : Support mobile, tablette et bureau
- **Animations fluides** pour une meilleure expérience utilisateur
- **Accessibilité** : Support sémantique et lecteurs d'écran

## 🔐 Sécurité

### Authentification
- **Firebase Auth** avec email/mot de passe
- **Validation côté client et serveur**
- **Jetons sécurisés** avec expiration
- **Rôles basés sur les permissions**

### Protection des Données
- **Règles de sécurité Firestore** pour l'accès aux données
- **Communication HTTPS** pour toutes les requêtes
- **Chiffrement** des données sensibles
- **Audit logs** pour les actions administrateur

## 🧪 Tests

### Lancer les tests
```bash
# Tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Tests spécifiques
flutter test test/widget_test.dart
```

### Types de tests
- **Tests unitaires** : Logique métier et utilitaires
- **Tests widget** : Composants UI
- **Tests intégration** : Flux utilisateur complets

## 📱 Build et Déploiement

### Build pour production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Configuration de production
1. **Clés API** : Configurer les clés Stripe et Firebase
2. **Variables d'environnement** : Définir les variables nécessaires
3. **Optimisation** : Activer les optimisations de build
4. **Signature** : Signer les applications pour la distribution

## 🌍 Internationalisation

L'application supporte :
- 🇫🇷 **Français** (langue par défaut)
- 🇬🇧 **Anglais**
- 🇪🇸 **Espagnol**
- 🇩🇪 **Allemand**

Ajouter une langue :
1. Modifier `lib/utils/app_translations.dart`
2. Ajouter les traductions manquantes
3. Mettre à jour les fichiers de langue

## 🤝 Contribuer

### Guide de contribution
1. **Forker** le projet
2. **Créer une branche** : `git checkout -b feature/nouvelle-fonctionnalite`
3. **Committer** les changements : `git commit -m 'Ajout nouvelle fonctionnalité'`
4. **Pusher** la branche : `git push origin feature/nouvelle-fonctionnalite`
5. **Ouvrir une Pull Request**

### Normes de code
- **Dart Style Guide** respecté
- **Commentaires** pour le code complexe
- **Tests** pour chaque nouvelle fonctionnalité
- **Documentation** mise à jour

## 📝 Journal des Modifications

### v1.0.0 (En développement)
- ✅ Architecture client/admin
- ✅ Authentification Firebase
- ✅ Gestion des réservations
- ✅ Thème sombre Material Design
- ✅ Support multi-plateforme
- ✅ Documentation complète

### Roadmap
- 🔄 Notifications push en temps réel
- 🔄 Chat intégré client-admin
- 🔄 Tableau de bord avancé
- 🔄 API REST pour intégrations
- 🔄 Support multilingue étendu

## 🐛 Signalement de Bugs

Pour signaler un bug :
1. **Vérifier** si le bug existe déjà
2. **Créer une issue** détaillée
3. **Ajouter** des captures d'écran
4. **Décrire** les étapes pour reproduire

## 👥 Équipe de Développement

- **Développeur Principal** : [Votre Nom]
- **Designer UI/UX** : [Nom du Designer]
- **Chef de Projet** : [Nom du Chef de Projet]

## 📄 Licence

Ce projet est sous licence **MIT License** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Contact

- **Email** : contact@zibene-security.com
- **Site Web** : https://zibene-security.com
- **Support** : support@zibene-security.com

## 🙏 Remerciements

- **Flutter Team** pour le framework exceptionnel
- **Firebase** pour les services backend
- **Material Design** pour les guidelines UI
- La communauté open-source pour les outils et librairies

---

**ZIBENE SECURITY** - *La sécurité professionnelle à portée de main* 🛡️

*Made with ❤️ using Flutter*