#!/bin/bash

# Script pour déployer les règles et indexes Firestore
# Ce script déploie les règles de sécurité et indexes Firestore pour ZIBENE SECURITY

echo "Déploiement des règles et indexes Firestore pour ZIBENE SECURITY..."

# Vérifier si Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    echo "Erreur: Firebase CLI n'est pas installé."
    echo "Veuillez l'installer avec: npm install -g firebase-tools"
    exit 1
fi

# Vérifier si l'utilisateur est connecté à Firebase
echo "Vérification de la connexion Firebase..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "Erreur: Vous n'êtes pas connecté à Firebase."
    echo "Veuillez vous connecter avec: firebase login"
    exit 1
fi

# Déployer les règles
echo "Déploiement des règles de sécurité Firestore..."
firebase deploy --only firestore:rules

if [ $? -ne 0 ]; then
    echo "❌ Échec du déploiement des règles Firestore."
    exit 1
fi

# Déployer les indexes
echo "Déploiement des indexes Firestore..."
firebase deploy --only firestore:indexes

if [ $? -ne 0 ]; then
    echo "❌ Échec du déploiement des indexes Firestore."
    exit 1
fi

echo "✅ Règles et indexes Firestore déployés avec succès!"
echo ""
echo "Résumé de la nouvelle architecture:"
echo "- 👥 Users: Clients et Administrateurs uniquement"
echo "- 🔐 Authentification: Firebase Auth pour users uniquement"
echo "- 🛡️  Agents: Collection séparée, gérée par admins uniquement"
echo ""
echo "Résumé des permissions:"
echo "- 📖 Users: Lecture/écriture pour propriétaires et admins"
echo "- 🛡️  Agents: Lecture publique, CRUD pour admins uniquement"
echo "- 📅 Bookings: CRUD pour clients (leurs réservations) et admins"
echo "- 💳 Payments: CRUD pour propriétaires et admins"
echo "- 🔔 Notifications: CRUD pour propriétaires uniquement"
echo "- ⭐ Reviews: Lecture publique, CRUD pour clients (leurs reviews)"
echo ""
echo "🚀 Architecture mise à jour pour la séparation Agents/Users!"