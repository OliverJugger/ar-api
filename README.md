# AR-WC3 Backend

Backend Spring Boot pour l'application AR-WC3, généré à partir du contrat OpenAPI
partagé avec le front Angular (`../AR-WC3/openapi/openapi.yaml`, copié dans
`src/main/resources/openapi/openapi.yaml`).

## Stack

- Java 21, Spring Boot 3.3
- Architecture simple : `controller` → `service` → `repository` (Spring Data JPA)
- DTO et interfaces de contrôleur générés depuis le contrat OpenAPI
  (`openapi-generator-maven-plugin`, génération à la phase `generate-sources`)
- MapStruct pour le mapping entité ↔ DTO généré
- Oracle Database (driver `ojdbc11`)
- Sécurité : HTTP Basic Auth (voir plus bas)

## Prérequis

- JDK 21
- Maven 3.9+
- Une base Oracle accessible (Oracle XE/Free fonctionne très bien en local)

## Configuration de la base de données

Variables d'environnement (valeurs par défaut entre parenthèses) :

| Variable          | Défaut                                     |
|-------------------|---------------------------------------------|
| `ORACLE_URL`      | `jdbc:oracle:thin:@localhost:1521/GEREP19CL` |
| `ORACLE_USERNAME` | `arthus`                                    |
| `ORACLE_PASSWORD` | `ENC(BY_JASYPT)`                                  |

## Lancer le projet

```bash
mvn clean spring-boot:run -Pgerep-catamania -Dspring-boot.run.arguments="--jasypt.encryptor.password=MOT_DE_PASSE_CHIFFRAGE_A_DEMANDER"
```

## Chiffrer/Déchiffrer un nouveau password

Chiffrer
```bash
mvn jasypt:encrypt-value -Djasypt.encryptor.password=MOT_DE_PASSE_CHIFFRAGE_A_DEMANDER -Djasypt.plugin.value=MOT_DE_PASSE_A_CHIFFRER
```

Déchiffrer
```bash
mvn jasypt:decrypt-value -Djasypt.encryptor.password=MOT_DE_PASSE_CHIFFRAGE_A_DEMANDER -Djasypt.plugin.value=CONTENU_DE_ENC
```

Les DTO et interfaces de contrôleur sont (re)générés automatiquement dans
`target/generated-sources/openapi` à chaque `mvn generate-sources` /
`mvn compile`.

- API : http://localhost:8080
- Swagger UI : http://localhost:8080/swagger-ui.html

## Authentification — HTTP Basic

Comme demandé, l'authentification est un simple **HTTP Basic Auth** :
chaque requête porte un en-tête

```
Authorization: Basic base64(username:password)
```

Le contrat OpenAPI a été modifié en conséquence (schéma de sécurité
`basicAuth` à la place de `bearerAuth`, suppression de `LoginRequest` et du
champ `token` de `LoginResponse` puisque les identifiants transitent dans
l'en-tête et non plus dans le corps de la requête).

Utilisateur de démonstration inséré par `data.sql` :

- **username** : `olivier.mignot83`
- **password** : `password123`

⚠️ **Le mot de passe est stocké encodé en base64** (`Base64PasswordEncoder`),
tel que demandé. Le base64 est un encodage, pas un hachage : il est
trivialement réversible. Ne pas utiliser cette approche telle quelle sur un
système exposé publiquement — pour de la production, remplacer
`Base64PasswordEncoder` par un `BCryptPasswordEncoder` (le reste du code
n'a pas besoin de changer).

## ⚠️ Impact sur le front Angular / Mockoon

Le contrat OpenAPI partagé (`AR-WC3/openapi/openapi.yaml`) a été modifié pour
passer de `bearerAuth` à `basicAuth` :

- `LoginRequest` a été supprimé (les identifiants ne sont plus envoyés dans le
  corps de `/login` mais dans l'en-tête `Authorization`)
- `LoginResponse.token` a été supprimé
- `/statistics` documente désormais aussi une réponse `401`

Ceci est un **changement cassant** pour le client Angular généré par
`ng-openapi-gen` et pour le mock Mockoon (`mockoon/environment.json`), qui
devront être mis à jour séparément — cela n'a pas été fait ici, le périmètre
de cette tâche étant le backend.

## Postman

Voir le dossier [`postman/`](postman/) : une collection et un environnement
avec les requêtes `/login` et `/statistics` déjà configurées en Basic Auth.
