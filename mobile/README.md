# 📱 Digital Cooperative Management

Une application mobile développée avec Flutter permettant de gérer efficacement une coopérative (cotisations, membres, objectifs, etc.).

---

## 🚀 Objectif du projet

L'application vise à digitaliser la gestion des coopératives en permettant :

* La gestion des membres
* Le suivi des cotisations
* La définition des objectifs de contribution
* La gestion des dates de paiement par le trésorier
* La consultation des informations en temps réel

---

## 🛠️ Technologies utilisées

* Flutter (Frontend mobile)
* API REST (Backend)
* Base de données ( MongoDB)
* Firebase (optionnel pour OTP/authentification)

---

## 📂 Structure du projet

```
cop_management/
 ├── backend/          # API (Node.js / Laravel / Django)
 ├── frontend-web/     # Interface web (admin)
 ├── mobile/           # Application Flutter
```

---

## ⚙️ Installation

### 1. Cloner le projet

```bash
git clone https://github.com/ton-repo/cop_management.git
cd cop_management/mobile
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Lancer l'application

```bash
flutter run
```

---

## 🔐 Fonctionnalités principales

### 👤 Administrateur

* Gérer les membres
* Définir les objectifs de contribution
* Suivre les activités

### 💰 Trésorier

* Fixer les dates de cotisation
* Valider les paiements
* Suivre les contributions

### 📱 Utilisateur

* Consulter ses cotisations
* Recevoir des notifications
* Voir les objectifs fixés

---

## 📡 API

L'application mobile communique avec un backend via API REST :

Exemple :

```
POST /login
GET /members
POST /cotisations
```

---

## 📌 Améliorations futures

* Notifications push
* Paiement mobile (Orange Money, Moov, etc.)
* Tableau de bord avancé
* Mode hors ligne

---

## 📖 Documentation

Consulte la documentation Flutter :
https://docs.flutter.dev/

---

## 👨‍💻 Auteur

Projet réalisé par 

KANTAGBA EFRAIM

KABORE AWA

ZONGO PAWENDTAOERE

COULIBALY FAEZ

COMPAORE KISITO

---

# Déploiement automatisé de cop_management
# Backend (API) → Render
# Frontend Web Flutter → Vercel

## Étape 1 : Préparer le backend
1. Assurez-vous que votre serveur écoute sur le port fourni par Render :
   Node.js exemple :
   const PORT = process.env.PORT || 3000;
   app.listen(PORT, () => console.log(`Server running on ${PORT}`));

2. Ajouter un fichier .render.yaml (optionnel) pour config Render :
   services:
     - type: web
       name: cop-backend
       env: node
       plan: free
       buildCommand: npm install
       startCommand: npm start

3. Pousser votre backend sur GitHub/GitLab.

## Étape 2 : Déployer sur Render
1. Aller sur https://render.com → New → Web Service.
2. Connecter le dépôt backend.
3. Spécifier :
   - Branch: main ou master
   - Build Command: npm install
   - Start Command: npm start
4. Ajouter les variables d’environnement nécessaires (DB, clés API…).
5. Cliquer sur Deploy → récupérer l’URL publique du backend, ex: https://cop-backend.onrender.com

## Étape 3 : Préparer le frontend Flutter Web
1. Depuis le dossier frontend :
   flutter build web

2. Vérifier que le dossier `build/web` contient tous les fichiers nécessaires.

3. Mettre à jour l’URL de l’API dans le code Flutter :
   final String apiUrl = "https://cop-backend.onrender.com";

4. Si nécessaire, activer CORS côté backend pour le domaine Vercel :
   Node.js exemple :
   const cors = require('cors');
   app.use(cors({ origin: 'https://cop-web.vercel.app' }));

## Étape 4 : Déployer sur Vercel
1. Aller sur https://vercel.com → New Project → Import Git Repository.
2. Choisir le dépôt frontend Flutter Web.
3. Paramètres du projet :
   - Framework : Other
   - Build Command : flutter build web
   - Output Directory : build/web
4. Cliquer sur Deploy → récupérer l’URL publique, ex: https://cop-web.vercel.app

## Étape 5 : Vérification finale
1. Accéder au site Vercel → tester les fonctionnalités qui appellent l’API Render.
2. Si tout fonctionne, le déploiement est terminé.
3. Optionnel : configurer un domaine personnalisé sur Vercel et Render.
