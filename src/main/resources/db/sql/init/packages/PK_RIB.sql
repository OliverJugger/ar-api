CREATE OR REPLACE PACKAGE ARTHUS.PK_RIB
AS
/*============================================================================*/
/* PACKAGE      : PK_RIB.sql                                                  */
/* Domaine      : Technique                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 13/04/2012                                                  */
/* Description  : Package de manipulation de fichier plat (ouverture, lecture)*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/

/*Variables globales*/


/*PROCEDURE/FONCTION*/

FUNCTION F_RIB_VALIDE (a_idrib IN RIB.IDRIB%TYPE)
RETURN NUMBER;

FUNCTION F_AFFICHE_RIB ( i_idrib     IN RIB.IDRIB%TYPE)
RETURN VARCHAR2;

FUNCTION F_RIB_SAISI ( i_type      IN RIB.TYPE%TYPE
                     , i_nature    IN RIB.NATURE%TYPE
                     , i_codpays   IN RIB.CODPAYS%TYPE
                     , i_clef_iban IN RIB.CLEF_IBAN%TYPE
                     , i_bban      IN RIB.BBAN%TYPE
                     , i_bic       IN RIB.BIC%TYPE)
RETURN NUMBER;

FUNCTION F_CKECK_IBAN ( i_bban      IN RIB.BBAN%TYPE
                      , i_clef_iban IN RIB.CLEF_IBAN%TYPE)
RETURN NUMBER;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_RIB;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_RIB
As
/*============================================================================*/
/* PACKAGE      : PK_RIB.sql                                                  */
/* Domaine      : Technique                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 13/04/2012                                                  */
/* Description  : Package de manipulation de fichier plat (ouverture, lecture)*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--


   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--

  G_nom_traitement  CONSTANT journal_adm.nom_traitement%TYPE DEFAULT NULL;
  G_niv_msg         journal_adm.niv_msg%TYPE;
  G_idligne         journal_adm.idligne%TYPE := 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- ---------------------------------------------- Fin des constantes privees --

  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des exceptions privees --

  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --

  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PUBLIQUES --------------------------


FUNCTION F_RIB_VALIDE (a_idrib IN RIB.IDRIB%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_RIB_VALIDE.sql                                           */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 08/10/2012                                                 */
/* Description  : Permet de validé la cohérence des données pour un rib non  */
/*                normalisé et un rib normalisé(SEPA)                        */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    : Ajout du controle sur le rib normalisé(SEPA), Mise en place*/
/*                du cartouche,ajout du synonyme,modification typage variable*/
/* Auteur       : JBO                                                        */
/* Date         : 04/10/2012                                                 */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : JBN ABO / 03/2011 / Ajout de la devise et date de validité */
/*              : PHA    / 27/06/2012 / loc_date                             */
/*===========================================================================*/
   loc_valide   NUMBER := 0;
   loc_nature   RIB.NATURE%TYPE:=0;
BEGIN

  -- Vérification de la validation du rib en fonction de sa nature(2=normalisé, 3=non normalisé)
  SELECT DISTINCT r.NATURE
    INTO loc_nature
    FROM RIB r
   WHERE r.IDRIB=a_idrib;

  IF loc_nature=2 THEN -- Rib normalisé

     BEGIN
        SELECT 1
          INTO loc_valide
          FROM rib
         WHERE bic IS NOT NULL
           AND clef_iban IS NOT NULL
           AND bban IS NOT NULL
           AND modpmt = 2
           AND nature = 2
           AND idrib = a_idrib;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_valide := 0;
     END;

  ELSIF loc_nature=3 THEN -- Rib non normalisé

     BEGIN
        SELECT 1
          INTO loc_valide
          FROM rib
         WHERE (   (    codbque IS NOT NULL
                    AND guichet IS NOT NULL
                    AND compte IS NOT NULL
                    AND modpmt = 2
                    AND nature = 2
                   )
                OR (    numindiv_etrg IS NOT NULL
                    AND compte_etrg IS NOT NULL
                    AND modpmt = 2
                    AND nature = 3
                   )
                OR (modpmt = 1 AND nature = 1)
                OR (    modpmt = 1
                    AND nature IN (2, 3)
                    AND codpays = pk_devise.pays_ref
                   )
               )
           AND idrib = a_idrib;
     EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
           loc_valide := 0;
     END;

  ELSE -- Aucun rib
    loc_valide:= 0;
  END IF;

   RETURN loc_valide;
EXCEPTION
  WHEN OTHERS THEN
    loc_valide:= 0;
END F_RIB_VALIDE;

FUNCTION F_AFFICHE_RIB ( i_idrib     IN RIB.IDRIB%TYPE)
RETURN VARCHAR2
AS
/*===========================================================================*/
/* Fonction     : F_AFFICHE_RIB.sql                                           */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                        */
/* Création     : 08/10/2012                                                 */
/* Description  : Permet d afficher le rib normalisé ou non normalisé        */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  /* loc_infoRib   VARCHAR2(50):= NULL;
   loc_nature    NUMBER:=NULL;

BEGIN
  -- Vérification de la validation du rib en fonction de sa nature(2=normalisé, 3=non normalisé)
  SELECT DISTINCT r.NATURE
    INTO loc_nature
    FROM RIB r
   WHERE r.IDRIB=i_idrib;

  IF loc_nature = 2 THEN
    BEGIN
      SELECT r.CLEF_IBAN || ' - ' || r.BBAN || ' - ' || r.BIC
        INTO loc_infoRib
        FROM RIB r
       WHERE r.idrib=i_idrib
         AND r.CLEF_IBAN IS NOT NULL
         AND r.BBAN IS NOT NULL
         AND r.BIC IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT r.CODBQUE || ' - ' || r.GUICHET || ' - ' || r.COMPTE
          INTO loc_infoRib
          FROM RIB r
         WHERE r.idrib=i_idrib
           AND r.CODBQUE IS NOT NULL
           AND r.GUICHET IS NOT NULL
           AND r.COMPTE IS NOT NULL;
   END;
 ELSIF loc_nature=3 THEN
   SELECT r.CODBQUE || ' - ' || r.GUICHET || ' - ' || r.COMPTE
     INTO loc_infoRib
     FROM RIB r
   WHERE r.idrib=i_idrib;
 END IF;


  RETURN loc_infoRib;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Aucune information sur le RIB trouvée';
END F_AFFICHE_RIB;
*/
 loc_infoRib   VARCHAR2(50):= NULL;
   loc_nature    NUMBER:=NULL;
   loc_codpays   NUMBER := NULL;

BEGIN
  -- Vérification de la validation du rib en fonction de sa nature(2=normalisé, 3=non normalisé)
  SELECT DISTINCT r.NATURE
    INTO loc_nature
    FROM RIB r
   WHERE r.IDRIB=i_idrib;

   -- récupération du codpays en fonction de l'IDRIB
     SELECT DISTINCT R.CODPAYS
       INTO loc_codpays
     FROM RIB r
     WHERE r.IDRIB=i_idrib;

  IF loc_nature = 2 THEN
    BEGIN
      SELECT r.CLEF_IBAN || ' - ' || r.BBAN || ' - ' || r.BIC
        INTO loc_infoRib
        FROM RIB r
       WHERE r.idrib=i_idrib
         AND r.CLEF_IBAN IS NOT NULL
         AND r.BBAN IS NOT NULL
         AND r.BIC IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT r.CODBQUE || ' - ' || r.GUICHET || ' - ' || r.COMPTE
          INTO loc_infoRib
          FROM RIB r
         WHERE r.idrib=i_idrib
           AND r.CODBQUE IS NOT NULL
           AND r.GUICHET IS NOT NULL
           AND r.COMPTE IS NOT NULL;
   END;

 ELSIF (loc_nature=3  AND loc_codpays = 1)  THEN
   SELECT r.CODBQUE || ' - ' || r.GUICHET || ' - ' || r.COMPTE
     INTO loc_infoRib
     FROM RIB r
   WHERE r.idrib=i_idrib;

   -- DEBUT MODIF TLE : GESTION DES BICS NON NORMALISES (RIB.NATURE=3) ET ETRANGERS (<>1 pour la France)
    ELSIF (loc_nature=3  AND loc_codpays <> 1) THEN
   SELECT -- r.DOMICILIATION || ' - ' ||   -- On n'affiche pas la domiciliation car elle apparait déjà dans la requête de gs12
          r.CODBQUE_ETRG || ' - ' || r.COMPTE_ETRG
     INTO loc_infoRib
     FROM RIB r
   WHERE r.idrib=i_idrib;
   -- FIN MODIF TLE

 END IF;


  RETURN loc_infoRib;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Aucune information sur le RIB trouvée';
END F_AFFICHE_RIB;


FUNCTION F_RIB_SAISI ( i_type      IN RIB.TYPE%TYPE
                     , i_nature    IN RIB.NATURE%TYPE
                     , i_codpays   IN RIB.CODPAYS%TYPE
                     , i_clef_iban IN RIB.CLEF_IBAN%TYPE
                     , i_bban      IN RIB.BBAN%TYPE
                     , i_bic       IN RIB.BIC%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_RIB_SAISI.sql                                            */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 09/10/2012                                                 */
/* Description  : Permet de valider la cohérence de la structure d un rib    */
/*                normalisé(SEPA)                                            */
/* Entree       : i_type                                                     */
/*                i_nature                                                   */
/*                i_codpays                                                  */
/*                i_clef_iban                                                */
/*                i_bban                                                     */
/*                i_bic                                                      */
/* Retour       : 1 si le RIB est valide, Code erreur Arthus si RIB invalide */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_Nom            PAYS.NOM%TYPE:=NULL;
  loc_NbCarBBAN      PAYS.NBCARBBAN%TYPE:=NULL;
  loc_Pref_IBAN      PAYS.PREF_IBAN%TYPE:=NULL;
  loc_CodeISO        PAYS.PREF_IBAN%TYPE:=NULL;
  loc_valide         NUMBER:=0;
BEGIN

  -- Récupère les informations sur la validité d un rib normailisé pour un code pays
  SELECT NOM
       , NbCarBBAN
       , Pref_IBAN
       , CodeISO
    INTO loc_Nom
       , loc_NbCarBBAN
       , loc_Pref_IBAN
       , loc_CodeISO
    FROM PAYS
   WHERE CodPays=i_codpays;

  IF i_nature=2 THEN -- Rib normalisé

    IF i_clef_iban IS NOT NULL AND i_bban IS NOT NULL THEN
      IF loc_NbCarBBAN IS NOT NULL -- Controler la longueur saisie du BBAN suivant la longueur
      AND loc_NbCarBBAN > 0        -- définie sur le pays (si une longeur est renseignée)
      AND LENGTH(i_bban) != loc_NbCarBBAN THEN
        loc_valide:=1257;
      ELSE
        --P_CHECK_DEC_IBAN
        loc_valide:=0;
      END IF;
    END IF;

  ELSE
    loc_valide:=0;
  END IF;

   RETURN loc_valide;
EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
    RETURN 1255;
  WHEN OTHERS THEN
    RETURN SQLERRM;
END F_RIB_SAISI;

FUNCTION F_CKECK_IBAN ( i_bban      IN RIB.BBAN%TYPE
                      , i_clef_iban IN RIB.CLEF_IBAN%TYPE)

RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_CKECK_IBAN.sql                                           */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 09/10/2012                                                 */
/* Description  : Permet de rechercher la clé de l iban                      */
/* Entree       : i_bban                                                     */
/*                i_clef_iban                                                */
/* Retour       : 1 si le RIB est valide, Code erreur Arthus si RIB invalide */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  Modulo_IBAN   NUMBER:=NULL;
  Replace_RIB   VARCHAR2(34):=NULL;
  loc_valide    NUMBER:=0;
BEGIN
  Replace_RIB := TO_NUMBER( REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE(
                            REPLACE( i_bban||
                                     i_clef_iban
                                    ,'A','10')
                                    ,'B','11')
                                    ,'C','12')
                                    ,'D','13')
                                    ,'E','14')
                                    ,'F','15')
                                    ,'G','16')
                                    ,'H','17')
                                    ,'I','18')
                                    ,'J','19')
                                    ,'K','20')
                                    ,'L','21')
                                    ,'M','22')
                                    ,'N','23')
                                    ,'O','24')
                                    ,'P','25')
                                    ,'Q','26')
                                    ,'R','27')
                                    ,'S','28')
                                    ,'T','29')
                                    ,'U','30')
                                    ,'V','31')
                                    ,'W','32')
                                    ,'X','33')
                                    ,'Y','34')
                                    ,'Z','35'));
  Modulo_IBAN := MOD(Replace_RIB, 97);

  IF Modulo_IBAN <> 1 THEN
    loc_valide:=1257;
  ELSE
    loc_valide:=1;
  END IF;
  RETURN loc_valide;
EXCEPTION
  WHEN OTHERS THEN
    RETURN SQLERRM;
END F_CKECK_IBAN;

-- Insertion dans journal_adm
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO G_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = G_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            G_niv_msg := 1;
    END;
  END IF;
G_niv_msg := 3;
  IF G_niv_msg >= P_niv THEN
     G_IDLIGNE := G_IDLIGNE +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => G_nom_traitement,
        I_session  => SID,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

END PK_RIB;
/
