import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/app_initializer.dart';
import 'services/auth_service.dart';

// Exemple d'intégration de la persistance dans l'application principale
class ExempleApplicationPersistance extends StatefulWidget {
  const ExempleApplicationPersistance({super.key});

  @override
  State<ExempleApplicationPersistance> createState() => _ExempleApplicationPersistanceState();
}

class _ExempleApplicationPersistanceState extends State<ExempleApplicationPersistance> {
  final InitialiseurApp _initialiseurApp = InitialiseurApp();
  final ServiceAuthentification _serviceAuthentification = ServiceAuthentification();
  
  bool _estEnChargement = true;
  bool _sessionRestauree = false;
  Map<String, dynamic>? _donneesUtilisateur;
  String _messageStatut = '';

  @override
  void initState() {
    super.initState();
    _initialiserApp();
  }

  // Initialisation de l'application avec gestion de la persistance
  Future<void> _initialiserApp() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Initialisation de l\'application...';
    });

    try {
      // Initialiser Firebase
      await Firebase.initializeApp();
      
      // Initialiser l'application et vérifier la persistance
      final resultat = await _initialiseurApp.initialiserApp();
      
      if (resultat['succes'] == true) {
        if (resultat['session_restauree'] == true) {
          // Session restaurée automatiquement
          setState(() {
            _sessionRestauree = true;
            _donneesUtilisateur = resultat['donnees_utilisateur'];
            _messageStatut = resultat['message'] ?? 'Session restaurée';
          });
        } else {
          // Aucune session à restaurer
          setState(() {
            _sessionRestauree = false;
            _messageStatut = resultat['message'] ?? 'Prêt à se connecter';
          });
        }
      } else {
        // Erreur lors de l'initialisation
        setState(() {
          _messageStatut = resultat['message'] ?? 'Erreur d\'initialisation';
        });
      }
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Exemple de connexion avec persistance
  Future<void> _exempleConnexion() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Connexion en cours...';
    });

    try {
      final resultat = await _serviceAuthentification.signIn(
        email: 'utilisateur@example.com',
        password: 'motdepasse123',
      );

      if (resultat['success'] == true) {
        setState(() {
          _sessionRestauree = true;
          _donneesUtilisateur = resultat['userData'];
          _messageStatut = resultat['message'] ?? 'Connexion réussie';
        });
      } else {
        setState(() {
          _messageStatut = resultat['message'] ?? 'Échec de la connexion';
        });
      }
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Exemple de déconnexion avec nettoyage de la persistance
  Future<void> _exempleDeconnexion() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Déconnexion en cours...';
    });

    try {
      final resultat = await _serviceAuthentification.seDeconnecter();
      
      setState(() {
        _sessionRestauree = false;
        _donneesUtilisateur = null;
        _messageStatut = resultat['message'] ?? 'Déconnecté';
      });
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur de déconnexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Vérifier le statut de la persistance
  Future<void> _verifierStatutPersistance() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Vérification du statut...';
    });

    try {
      final statut = await _initialiseurApp.obtenirStatutPersistance();
      
      setState(() {
        _messageStatut = 'Statut: ${statut['statut_auth']['message']}';
      });
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Exemple de navigation basée sur les rôles
  Future<void> _exempleNavigationParRole() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Navigation vers accueil...';
    });

    try {
      await _initialiseurApp.naviguerVersAccueilParRole(context);
      
      setState(() {
        _messageStatut = 'Navigation réussie vers accueil';
      });
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur de navigation: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Exemple de démarrage d'application avec gestion des rôles
  Future<void> _exempleDemarrageApp() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Démarrage de l\'application...';
    });

    try {
      final resultat = await _initialiseurApp.gererDemarrageApp(context);
      
      setState(() {
        if (resultat['succes'] == true) {
          _messageStatut = resultat['message'] ?? 'Démarrage réussi';
          if (resultat['session_restauree'] == true) {
            _sessionRestauree = true;
            _donneesUtilisateur = resultat['donnees_utilisateur'];
          }
        } else {
          _messageStatut = resultat['message'] ?? 'Échec du démarrage';
        }
      });
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur de démarrage: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  // Vérifier les permissions de l'utilisateur
  Future<void> _verifierPermissionsUtilisateur() async {
    setState(() {
      _estEnChargement = true;
      _messageStatut = 'Vérification des permissions...';
    });

    try {
      final permissions = await _initialiseurApp.obtenirPermissionsUtilisateur();
      
      String textePermissions = 'Permissions: ';
      if (permissions['authentifie'] == true) {
        final listePermissions = permissions['permissions'] as List<String>? ?? [];
        textePermissions += listePermissions.join(', ');
        textePermissions += '\nRôle: ${permissions['role']}';
      } else {
        textePermissions += 'Non authentifié';
      }
      
      setState(() {
        _messageStatut = textePermissions;
      });
    } catch (e) {
      setState(() {
        _messageStatut = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemple de Persistance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple de Persistance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: _verifierStatutPersistance,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_estEnChargement)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      Icon(
                        _sessionRestauree ? Icons.check_circle : Icons.login,
                        size: 64,
                        color: _sessionRestauree ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _messageStatut,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (_donneesUtilisateur != null) ...[
                        Text(
                          'Bienvenue, ${_donneesUtilisateur!['full_name'] ?? _donneesUtilisateur!['email']}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Rôle: ${_donneesUtilisateur!['role']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!_sessionRestauree)
                      ElevatedButton(
                        onPressed: _exempleConnexion,
                        child: const Text('Se Connecter'),
                      ),
                    if (_sessionRestauree)
                      ElevatedButton(
                        onPressed: _exempleDeconnexion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Se Déconnecter'),
                      ),
                    ElevatedButton(
                      onPressed: _verifierStatutPersistance,
                      child: const Text('Vérifier Statut'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Boutons de gestion des rôles
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _exempleNavigationParRole,
                      child: const Text('Navigation par Rôle'),
                    ),
                    ElevatedButton(
                      onPressed: _exempleDemarrageApp,
                      child: const Text('Démarrage App'),
                    ),
                    ElevatedButton(
                      onPressed: _verifierPermissionsUtilisateur,
                      child: const Text('Vérifier Permissions'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'La session persiste même après la fermeture de l\'application',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Instructions d'utilisation:
/*
1. Ajouter la dépendance shared_preferences à pubspec.yaml:
   dependencies:
     shared_preferences: ^2.2.2

2. Importer les services dans votre fichier main.dart:
   import 'services/app_initializer.dart';
   import 'services/auth_service.dart';

3. Initialiser l'application au démarrage:
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     final initialiseurApp = InitialiseurApp();
     final resultat = await initialiseurApp.initialiserApp();
     
     runApp(MyApp(sessionRestauree: resultat['session_restauree']));
   }

4. Utiliser les méthodes d'authentification avec persistance:
   - signIn(): Connecte l'utilisateur et sauvegarde la session
   - seDeconnecter(): Déconnecte et nettoie la session locale
   - restaurerSessionAutomatiquement(): Tente de restaurer une session existante

5. Vérifier l'état de la persistance pour le débogage:
   - obtenirStatutPersistance(): Retourne des informations sur la persistance
   - estUtilisateurAuthentifie(): Vérifie si l'utilisateur est authentifié
*/
