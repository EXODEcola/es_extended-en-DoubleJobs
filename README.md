# **Version 1.12.4 - ES Extended (Double Jobs + Notifications okok)**

**Voici la version 1.12.4 de es_extended reprise de :**
👉 [GitHub ESX Core](https://github.com/esx-framework/esx_core)

---

### **🛠️ Modifications apportées :**
- Correction des erreurs de code.
- Suppression des boucles inutiles.
- Passage en **double jobs** (`job` + `job2`).
- Intégration des notifications via **okokNotify**.
- Suppression des `print` inutiles pour un code plus propre.
- **Ajout d'un nouveau système de groupes administratifs**.

---

### **✅ Compatibilité assurée :**
- **qs-inventory** ⇒ Quasar.
- **okokNotify** ⇒ OkOk.
- **JobCreator** ⇒ Jacksam.
- **MSerie/Venice** ⇒ Codem.
- Ajout des groupes : `Modo`, `Admin`, `SuperAdmin`, `Owner`, `_dev`.

---

### **🌱 Correctifs ajoutés :**
1. Gestion des **callbacks manquants**, comme `esx_skin:getPlayerSkin`.
2. Correction des problèmes liés aux sauvegardes dans la base de données pour le **double jobs**.
3. Suppression des **logs redondants** (`print`) pour un meilleur suivi dans la console.
4. Optimisation des requêtes SQL pour éviter les erreurs avec `oxmysql`.

---

### **🔄 Changements majeurs :**

#### 1️⃣ **Double Jobs :**
- Ajout complet du second job (`job2`) et de son grade (`job2_grade`).
- Les commandes administratives `/setjob` et `/setjob2` permettent maintenant de gérer le job principal et secondaire indépendamment.

#### 2️⃣ **Notifications via okokNotify :**
- Remplacement des notifications natives par l'intégration avec **okokNotify** :
  ```lua
  exports['okokNotify']:Alert("Titre", "Message", 5000, "success")
  ```
- Types disponibles : `success`, `info`, `warning`, `error`.

#### 3️⃣ **Nouveau système de groupes :**
- Ajout des groupes administratifs :
  - `_dev`, `owner`, `superadmin`, `admin`, `moderator`.
- Système basé sur une table dans la base de données :
  ```sql
  CREATE TABLE user_perm (
      id INT AUTO_INCREMENT PRIMARY KEY,
      identifier VARCHAR(50) NOT NULL,
      group_name VARCHAR(50) DEFAULT 'user',
      date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  ```
- Vérification des permissions pour toutes les commandes sensibles (comme `/setjob`).

#### 4️⃣ **Amélioration de la compatibilité :**
- Support complet pour :
  - **qs-inventory**.
  - **JobCreator**.

#### 5️⃣ **SQL optimisé :**
- Nouvelle structure pour les jobs :
  ```sql
  ALTER TABLE users ADD COLUMN job2 VARCHAR(50) DEFAULT 'unemployed';
  ALTER TABLE users ADD COLUMN job2_grade INT DEFAULT 0;
  ```

---

### **📋 Instructions pour la mise à jour :**

1. **Mise à jour de la base de données :**
   Exécutez les commandes SQL suivantes :
   ```sql
   ALTER TABLE users ADD COLUMN job2 VARCHAR(50) DEFAULT 'unemployed';
   ALTER TABLE users ADD COLUMN job2_grade INT DEFAULT 0;

   CREATE TABLE IF NOT EXISTS user_perm (
       id INT AUTO_INCREMENT PRIMARY KEY,
       identifier VARCHAR(50) NOT NULL,
       group_name VARCHAR(50) DEFAULT 'user',
       date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

2. **Téléchargez les ressources nécessaires :**
   - [okokNotify](https://github.com/okok/okokNotify)
   - [qs-inventory](https://github.com/qs/qs-inventory)

3. **Remplacez les fichiers modifiés :**
   - `server/functions.lua`
   - `client/main.lua`
   - `server/main.lua`
   - `esx_skin/server/main.lua`

4. **Testez les fonctionnalités :**
   - Assurez-vous que `/setjob` et `/setjob2` fonctionnent correctement.
   - Vérifiez que les notifications sont bien affichées.

---

### **💻 Commandes :**

- **Changer le job principal :**
  ```bash
  /setjob [playerId] [job] [grade]
  ```

- **Changer le second job :**
  ```bash
  /setjob2 [playerId] [job2] [grade]
  ```

---

### **📢 Remarques :**
- Testé et compatible avec les frameworks :
  - **qs-inventory**
  - **okokNotify**
  - **JobCreator**

Si vous rencontrez des problèmes ou avez des questions, ouvrez une issue sur ce dépôt.
