CREATE OR REPLACE PACKAGE ARTHUS.PK_SEPA AS
/*============================================================================*/
/* PACKAGE      : PK_SEPA.sql                                                 */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SBA                                                         */
/* Création     : 03/2012                                                     */
/* Description  : Fonctionnalites SEPA                                        */
/*============================================================================*/
/* Evolution    : Mise en place de la fonction de validité d un rib avant le  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/
/* Correction   : 29/11/2016    Mantis 5203 PHA BIC non obligatoire           */
/*============================================================================*/


  FUNCTION  f_afficher_compte
              ( iv_bic      IN  VARCHAR2
              , iv_iban     IN  VARCHAR2
              , iv_intitule IN  VARCHAR2
              , iv_format   IN  VARCHAR2  DEFAULT NULL
              ) RETURN  VARCHAR2;

  FUNCTION  f_iban_to_string
              ( iv_iban   IN  VARCHAR2
              , iv_format IN  VARCHAR2  DEFAULT NULL
              ) RETURN  VARCHAR2;

  FUNCTION  f_is_iban
              ( iv_clef_iban  IN  VARCHAR2
              , iv_bban       IN  VARCHAR2
              --, ov_erreur     OUT VARCHAR2
              ) RETURN  BOOLEAN;

  FUNCTION  f_to_codpays
              ( iv_clef_iban  IN  VARCHAR2
              , on_nbcarbban  OUT NUMBER
              , ov_erreur     OUT VARCHAR2
              ) RETURN  NUMBER;

    FUNCTION  f_ctrl_devise_clef
              ( iv_clef_iban  IN PAYS.PREF_IBAN%TYPE
              , iv_devise     IN PAYS.CODMON%TYPE
              , iv_codpays     IN PAYS.CODPAYS%TYPE -- MODIF ABO/TLE 01/07/2013
			  , ov_erreur     OUT NUMBER
              ) RETURN  NUMBER;

  FUNCTION  f_to_iban
              ( in_codpays    IN  NUMBER
              , iv_codbque    IN  VARCHAR2
              , iv_guichet    IN  VARCHAR2
              , iv_compte     IN  VARCHAR2
              , iv_clerib     IN  VARCHAR2
              , ov_bban       OUT VARCHAR2
              , ov_clef_iban  OUT VARCHAR2
              , ov_erreur     OUT VARCHAR2
              ) RETURN  VARCHAR2;

  PROCEDURE p_get_informations_bancaires
              ( iv_clef_iban  IN  VARCHAR2
              , iv_bban       IN  VARCHAR2
              , ov_iban       OUT VARCHAR2
              -- , on_codpays    OUT NUMBER    -- MODIF TLE
              , ov_codbque    OUT VARCHAR2
              , ov_guichet    OUT VARCHAR2
              , ov_compte     OUT VARCHAR2
              , ov_clerib     OUT VARCHAR2
              , ov_erreur     OUT VARCHAR2
              );

  FUNCTION  f_rib_iban
              ( iv_idrib   IN  NUMBER
              ) RETURN  number;

  FUNCTION  f_ctrl_donnee_iban (iv_clef_iban VARCHAR2,
                             iv_bban VARCHAR2,
                             iv_BIC VARCHAR2) RETURN  NUMBER;


  FUNCTION  f_ctrl_querable
              ( iv_numindiv   IN  VARCHAR2
              ) RETURN  number;

  FUNCTION F_MANDAT_VALIDE (i_IDHISTOMANDAT IN HISTO_MANDAT.IDHISTOMANDAT%TYPE) RETURN NUMBER;

  PROCEDURE p_inactivation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              );

 PROCEDURE p_maj_histo_querable
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
			  , ov_erreur       OUT VARCHAR2);

  PROCEDURE p_creation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
              );

  PROCEDURE p_creation_querable
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
              );

  PROCEDURE p_generer_amendement
              ( iv_idrib     IN NUMBER
              , iv_clef_iban IN VARCHAR2
              , iv_bban      IN VARCHAR2
              , iv_BIC       IN VARCHAR2
              , iv_idrib_new IN NUMBER
              , ov_retour    OUT NUMBER
              , iv_test_ribadhe IN VARCHAR2 default null
              , iv_idadhesion in number default null
              ) ;

  PROCEDURE p_reactivation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
			  , iv_fract        IN NUMBER
              , ov_retour       OUT NUMBER
              ) ;
  FUNCTION f_reactivation_mandat
             ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              )  RETURN NUMBER ;

  FUNCTION f_mandat_remise_non_validee(iv_mandat IN HISTO_QUERABLE.MANDAT_MAITRE%type) RETURN NUMBER;

  -- TLE : ajout d'une procedure pour PE14 : bloquer la modification d'un RIB
  --       si ce RIB est maitre d'autres mandats
  PROCEDURE P_VERIF_MODIF_RIB ( in_IDRIB   IN histo_mandat.IDRIB%TYPE
                             , in_IDADHESION IN histo_querable.IDADHESION%TYPE
                             , ov_retour  OUT NUMBER);

  -- TLE : ajout d'une procedure pour PE14 : bloquer la modification d'un RIB
  --       sauf si toutes les adhesions liées au RIB sont dans RIB_ADHE
  PROCEDURE P_VERIF_MODIF_RIB_2 ( in_IDRIB   IN histo_mandat.IDRIB%TYPE
                                , ov_retour  OUT NUMBER);


  -- MUR le 17/03/2014 : fonction utilisée dans PE14 permettant de savoir si une modification de rib
  -- porte sur les coordonnées bancaires
  FUNCTION f_modif_coor_banc(iv_idrib     IN rib.idrib%type
                           , iv_clef_iban IN rib.clef_iban%type
                           , iv_bban      IN rib.bban%type
                           , iv_bic       IN rib.bic%type
                           ) RETURN NUMBER;

  -- MUR le 24/04/2014 : procedure qui met à jour HQ.MANDAT
  -- pour les anomalies de HQ : en prelevement et mandat null
  PROCEDURE P_MAJ_MANDAT (iv_idrib  in number ,
                          ov_retour out number);

  PROCEDURE P_INS_journal( i_niv  in NUMBER,
                         i_msg  in VARCHAR2,
                         i_msg2 in varchar2 := null);

  -- MUR M0006633 : fonction qui retourne 1 si contrat B2B sinon 0
  FUNCTION f_contrat_b2b (i_numgar IN contrat.numgar%type) RETURN NUMBER;

  -- Traitement des RIB d’encaissement avec une date de début égal à la date pivot.
  PROCEDURE P_TRAIT_RIB_JOUR ( P_DATE_PIVOT IN DATE );

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SEPA AS
/*============================================================================*/
/* PACKAGE      : PK_SEPA.sql                                                 */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SBA                                                         */
/* Création     : 03/2012                                                     */
/* Description  : Fonctionnalites SEPA                                        */
/*============================================================================*/
/* Evolution    : Mise en place de la fonction de validité d un rib avant le  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/
/* Evolution    : VERIFICATION SUR LA LONGUEUR DE L'IBAN ET DU BBAN DANS F_IS_IBAN  */
/* Auteur       : TLE                                                         */
/* Date         : 30/04/2014                                                  */
/* Commentaire  : Retour GEREP suite saisie IBAN invalide                     */
/*============================================================================*/


  --Variables <PK_TRACE.P_INS_journal_adm>
  --gv_nom_traitement CONSTANT  journal_adm.nom_traitement%TYPE DEFAULT 'PK_SEPA';

  --VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'PK_SEPA';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;

  -- MUR M0006633 : fonction qui retourne 1 si contrat B2B sinon 0
  FUNCTION f_contrat_b2b (i_numgar IN contrat.numgar%type) RETURN NUMBER
  IS
    loc_typequit      contrat.typequit%TYPE;
    loc_mregl         contrat.mregl%TYPE;
  BEGIN
    SELECT typequit, mregl
    INTO loc_typequit, loc_mregl
    FROM contrat
    WHERE numgar = i_numgar ;

    IF loc_typequit = 1 AND loc_mregl = 2 THEN
      RETURN 1 ;
    ELSE
      RETURN 0 ;
    END IF ;

  EXCEPTION
    when others then RETURN 0 ;
  END f_contrat_b2b;


  --Afficher le compte au format {iv_format}...
  --  BIC+IBAN+INTITULE LONG  <>  BIC 12345678901 IBAN 1234 5678 9012 3456 7890 1234 5678 9012 34 {iv_intitule}
  --  BIC+IBAN+INTITULE       <>  12345678901 1234 5678 9012 3456 7890 1234 5678 9012 34 {iv_intitule}
  --  BIC+IBAN LONG           <>  BIC 12345678901 IBAN 1234 5678 9012 3456 7890 1234 5678 9012 34
  --  BIC+IBAN                <>  12345678901 1234 5678 9012 3456 7890 1234 5678 9012 34
  --  IBAN+INTITULE LONG      <>  BIC 1234 5678 9012 3456 7890 1234 5678 9012 34 {iv_intitule}
  --  IBAN+INTITULE           <>  1234 5678 9012 3456 7890 1234 5678 9012 34 {iv_intitule}
  --  IBAN LONG               <>  BIC 1234 5678 9012 3456 7890 1234 5678 9012 34
  --  Autre                   <>  1234 5678 9012 3456 7890 1234 5678 9012 34
  FUNCTION  f_afficher_compte
              ( iv_bic      IN  VARCHAR2
              , iv_iban     IN  VARCHAR2
              , iv_intitule IN  VARCHAR2
              , iv_format   IN  VARCHAR2  DEFAULT NULL
              ) RETURN  VARCHAR2
  IS
    v_afficher_compte VARCHAR2(1024);
    v_bic             VARCHAR2(11);
    v_intitule        VARCHAR2(1024);
  BEGIN
    v_bic :=SUBSTR(iv_iban, 1, 11);

    IF  iv_intitule=NULL  THEN  v_intitule:='';
                          ELSE  v_intitule:=' '||iv_intitule;
                          END IF;

    CASE  UPPER(iv_format)
      WHEN  'BIC+IBAN+INTITULE LONG'  THEN  v_afficher_compte := /*'BIC '||*/v_bic||' ' ||/*f_iban_to_string(*/iv_iban/*, 'LONG')*/ ||v_intitule;
      WHEN  'BIC+IBAN+INTITULE'       THEN  v_afficher_compte :=         v_bic||' ' ||/*f_iban_to_string(*/iv_iban/*        ) */||v_intitule;
      WHEN  'BIC+IBAN LONG'           THEN  v_afficher_compte := /*'BIC '||*/v_bic||' ' ||/*f_iban_to_string(*/iv_iban/*, 'LONG')*/;
      WHEN  'BIC+IBAN'                THEN  v_afficher_compte :=         v_bic||' ' ||/*f_iban_to_string(*/iv_iban/*        )*/;
      WHEN  'IBAN+INTITULE LONG'      THEN  v_afficher_compte :=                      /*f_iban_to_string(*/iv_iban/*, 'LONG') */||v_intitule;
      WHEN  'IBAN+INTITULE'           THEN  v_afficher_compte :=                      /*f_iban_to_string(*/iv_iban/*        ) */||v_intitule;
      WHEN  'IBAN LONG'               THEN  v_afficher_compte :=                      /*f_iban_to_string(*/iv_iban/*, 'LONG')*/;
      ELSE                                  v_afficher_compte :=                      /*f_iban_to_string(*/iv_iban        /*)*/;
    END CASE; --CASE  UPPER(iv_format)

    -- IF TRIM(v_bic) IS NULL OR TRIM(iv_iban) IS NULL THEN
    IF TRIM(iv_iban) IS NULL THEN
     v_afficher_compte:=NULL;
    END IF;

    RETURN  v_afficher_compte;
  END f_afficher_compte;

  --Renvoyer l'IBAN {iv_iban} au format {iv_format}...
  --  LONG        <>  IBAN 1234 5678 9012 3456 7890 1234 5678 9012 34
  --  Autre       <>  1234 5678 9012 3456 7890 1234 5678 9012 34
  FUNCTION  f_iban_to_string
              ( iv_iban   IN  VARCHAR2
              , iv_format IN  VARCHAR2  DEFAULT NULL
              ) RETURN  VARCHAR2
  IS
    v_iban            VARCHAR2(34);
    v_iban_to_string  VARCHAR2(1024):=NULL;
  BEGIN
    v_iban    :=SUBSTR(iv_iban, 01, 34);

    v_iban_to_string:=      SUBSTR(v_iban, 01, 4)
                    ||' '|| SUBSTR(v_iban, 05, 4)
                    ||' '|| SUBSTR(v_iban, 09, 4)
                    ||' '|| SUBSTR(v_iban, 13, 4)
                    ||' '|| SUBSTR(v_iban, 17, 4)
                    ||' '|| SUBSTR(v_iban, 21, 4)
                    ||' '|| SUBSTR(v_iban, 25, 4)
                    ||' '|| SUBSTR(v_iban, 29, 4)
                    ||' '|| SUBSTR(v_iban, 33, 2);

    RETURN  v_iban_to_string;
  END f_iban_to_string;



-- MODIF TLE 01/07/2013 : Modification de la fonction f_is_iban :
-- l'algorithme de vérication ne fonctionnait pas toujours.
-- Ex : avec FR4420041010161096655H03768 qui est un code IBAN valide d'après
-- le site http://virements.online.fr/verification-iban.html

/*
Algorithme de vérification de l'IBAN
    Enlever les caractères indésirables (espaces, tirets)
    Déplacer les 4 premiers caractères à droite
    Substituer les lettres par des chiffres via une table de conversion (A=10, B=11, C=12 etc.)
    Diviser le nombre ainsi obtenu par 97.
    Si le reste n'est pas égal à 1 l'IBAN est incorrect : Modulo de 97 égal à 1
*/


FUNCTION f_is_iban(
      iv_clef_iban IN VARCHAR2 ,
      iv_bban      IN VARCHAR2 --,
      --ov_erreur OUT VARCHAR2
	  )
   RETURN BOOLEAN
IS
   b_is_iban   BOOLEAN :=FALSE;
   n_nbcarbban NUMBER;
   IBAN        VARCHAR2(36);
BEGIN
   IBAN := iv_clef_iban||iv_bban;
   -- VERIFICATION SUR LA LONGUEUR DE L'IBAN ET DU BBAN   -- TLE 30/04/2014
   IF ((LENGTH (iv_bban) <> 23) AND (iv_clef_iban LIKE 'FR%' OR iv_clef_iban LIKE 'MC%'))
      OR (LENGTH (iv_clef_iban) <> 4) THEN
      b_is_iban         := FALSE;
--ov_erreur :='Le code IBAN <'||iv_clef_iban||iv_bban||'> est incorrect !';
RETURN b_is_iban;

   END IF;

   --ALGO VERIF IBAN:
   IBAN  := SUBSTR(IBAN,5)||SUBSTR(IBAN,1,4);
   FOR I IN 10..35
   LOOP
      IBAN := REPLACE(IBAN, CHR(I+55), I);
   END LOOP;
   IF (MOD(TO_NUMBER(IBAN), 97)) <> 1 THEN
      -- IBAN KO
      --ov_erreur :='Le code IBAN <'||iv_clef_iban||iv_bban||'> est incorrect !';
      b_is_iban :=FALSE;
   ELSE
      -- IBAN OK
      b_is_iban :=TRUE;
   END IF;
   RETURN b_is_iban;
END f_is_iban;



  --Renvoyer le code pays relatif à la clé IBAN {iv_clef_iban}(Ainsi que le nombre de caractères du code BBAN {on_nbcarbban})
  --En cas d'erreur, {ov_erreur} sera renseigné sinon vide
  FUNCTION  f_to_codpays
              ( iv_clef_iban  IN  VARCHAR2
              , on_nbcarbban  OUT NUMBER
              , ov_erreur     OUT VARCHAR2
              ) RETURN  NUMBER
  IS
    n_to_codpays  NUMBER  :=0;
  BEGIN
    on_nbcarbban:=NULL;
    ov_erreur   :=NULL;

    BEGIN
      SELECT  pays.codpays
      ,       pays.nbcarbban
      INTO  n_to_codpays
      ,     on_nbcarbban
      FROM  pays
      WHERE pays.codeiso=SUBSTR(iv_clef_iban, 1, 2)
        AND pays.pref_iban=NVL(iv_clef_iban,pays.pref_iban)
      ;
    EXCEPTION
      WHEN  NO_DATA_FOUND THEN  ov_erreur :='Code ISO du préfix IBAN <'||iv_clef_iban||'> non conforme !';
      WHEN  TOO_MANY_ROWS THEN  ov_erreur :='Plusieurs codes ISO ont été trouvés pour le préfix IBAN <'||iv_clef_iban||'> !';
    END;

    RETURN  n_to_codpays;
  END f_to_codpays;



/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  f_ctrl_devise_clef                                        */
/* Type         :  Public                                                    */
/* Description  :  Controle si la devise et la cle IBAN sont cohérentes      */
/* Entree       :  iv_clef_iban  -                                           */
/* Entree       :  iv_devise  -                                              */
/* Retour       :  Code Message d erreur de la table mess_erreur             */
/* Retour       :  1 => ok, 0 ko                                             */
/*---------------------------------------------------------------------------*/
FUNCTION  f_ctrl_devise_clef
              ( iv_clef_iban  IN  PAYS.PREF_IBAN%TYPE
              , iv_devise     IN  PAYS.CODMON%TYPE
              , iv_codpays     IN  PAYS.CODPAYS%TYPE        -- MODIF ABO/TLE 01/07/2013
              , ov_erreur     OUT NUMBER
              ) RETURN  NUMBER
  IS
    n_to_codpays  NUMBER  :=0;
  BEGIN
    ov_erreur:=NULL;

    BEGIN
      SELECT  1  -- suppression du distinct pour activer erreur 2078
        INTO n_to_codpays
        FROM pays s
       WHERE substr(TRIM(iv_clef_iban),0,2)=TRIM(s.codeiso)
         AND s.codmon=iv_devise
         AND s.codpays= NVL(iv_codpays,s.codpays);    -- MODIF ABO/TLE 01/07/2013
    EXCEPTION
      WHEN  NO_DATA_FOUND THEN  ov_erreur :=2077;
      WHEN  TOO_MANY_ROWS THEN  ov_erreur :=2078;
    END;

    RETURN  n_to_codpays;

  END f_ctrl_devise_clef;



  --Renvoyer le code IBAN à partir des informations bancaires : {in_codpays}, {iv_codbque}, {iv_guichet}, {iv_compte} et {iv_clerib}
  --En cas d'erreur, {ov_erreur} sera renseigné sinon vide
  --  {ov_clef_iban}  <>  Clé IBAN
  --  {ov_bban}       <>  Code BBAN
  --Principe :
  --  1.Créer un IBAN artificiel, composé du code du pays (ISO 3166), suivi de "00" et du BBAN (Sans caractères autres qu'alphanumériques)
  --  2.Déplacer les 4 premiers caractères de l'IBAN vers la droite du numéro
  --  3.Convertir les lettres en chiffres, selon la règle suivante. Chaque lettre est remplacée par les deux chiffres du nombre obtenu en ajoutant 9 à son rang dans l'alphabet. On obtient 10 pour A, 11 pour B, ... et 35 pour Z
  --  4.Appliquer le MOD 97-10 (Calculer le modulo 97, c'est-à-dire le reste de la division du résultat précédent par 97, et retrancher ce reste de 98)
  --    Si le résultat comporte un seul chiffre, le faire précéder du chiffre zéro
  --    Insérer le résultat ainsi obtenu à la position 2 de l'IBAN artificiel créé dans l'étape préalable (en remplacement des 2 zéros)
  --
  --Cette méthode ne s'applique pas aux comptes bancaires allemands, les banques allemandes utilisant différents modes de calcul pour affecter le code de sécurité
  --(Prüfziffer) de l'IBAN (les deux chiffres qui suivent DE)
  FUNCTION  f_to_iban
              ( in_codpays    IN  NUMBER
              , iv_codbque    IN  VARCHAR2
              , iv_guichet    IN  VARCHAR2
              , iv_compte     IN  VARCHAR2
              , iv_clerib     IN  VARCHAR2
              , ov_bban       OUT VARCHAR2
              , ov_clef_iban  OUT VARCHAR2
              , ov_erreur     OUT VARCHAR2
              ) RETURN  VARCHAR2
  IS
    n_check   NUMBER;
    n_indice  NUMBER        :=1;
    c_cle_rib CHAR(2);
    c_codbque CHAR(5);
    c_compte  CHAR(11);
    c_guichet CHAR(5);
    v_codeiso VARCHAR2(2);
    v_to_iban VARCHAR2(1024):=NULL;
    v_x       VARCHAR2(1);
  BEGIN
    ov_clef_iban:=NULL;
    ov_bban     :=NULL;
    ov_erreur   :=NULL;

    BEGIN
      SELECT  pays.codeiso
      INTO  v_codeiso
      FROM  pays
      WHERE pays.codpays=in_codpays
      ;

      IF  LENGTH(v_codeiso) <> 2  THEN ov_erreur :='Code ISO <'||v_codeiso||'> non normalisé (Code pays <'||TO_CHAR(in_codpays)||'>)';
                                  END IF;
      IF  LENGTH(iv_codbque) <> 5
      OR  LENGTH(iv_guichet) <> 5
      OR  LENGTH(iv_compte) <> 11
      OR  LENGTH(iv_clerib) <> 2  THEN ov_erreur :=', Code BBAN <'||NVL(iv_codbque, 'Null')||'><'||NVL(iv_guichet, 'Null')||'><'||NVL(iv_compte, 'Null')||'><'||NVL(iv_clerib, 'Null')||'> non normalisé';
                                  END IF;

      IF  ov_erreur IS  NULL  THEN
        c_codbque :=LPAD(iv_codbque , 5 , '0' );
        c_guichet :=LPAD(iv_guichet , 5 , '0' );
        c_compte  :=LPAD(iv_compte  , 11, '0' );
        c_cle_rib :=LPAD(iv_clerib  , 2 , '0' );
        v_to_iban :=UPPER(c_codbque||c_guichet||c_compte||c_cle_rib||v_codeiso||'00');

        WHILE n_indice <= LENGTH(v_to_iban)  LOOP
          v_x :=SUBSTR(v_to_iban, n_indice, 1);

          IF  TRIM(TRANSLATE(v_x, ' +-.0123456789', ' ')) IS  NOT NULL  THEN  v_to_iban:=REPLACE(v_to_iban, v_x, ASCII(v_x)-55);
                                                                        END IF;

          n_indice :=n_indice+1;
        END LOOP; --WHILE n_indice <= LENGTH(v_to_iban)  LOOP

        n_check :=98-MOD(v_to_iban, 97);

        IF  n_check < 10  THEN  ov_clef_iban  :=v_codeiso||'0'||TO_CHAR(n_check);
                          ELSE  ov_clef_iban  :=v_codeiso||TO_CHAR(n_check);
                          END IF;

        ov_bban   :=UPPER(c_codbque||c_guichet||c_compte||c_cle_rib);
        v_to_iban :=ov_clef_iban||ov_bban;
      ELSE
        ov_erreur:=LTRIM(ov_erreur, ', ');
      END IF; --IF  ov_erreur IS  NULL  THEN
    EXCEPTION
      WHEN  NO_DATA_FOUND THEN  ov_erreur :='Code pays <'||TO_CHAR(in_codpays)||'> non trouvé !';
      WHEN  TOO_MANY_ROWS THEN  ov_erreur :='Plusieurs codes pays <'||TO_CHAR(in_codpays)||'> !';
      WHEN  OTHERS        THEN  ov_erreur :='<'||SQLERRM||'>';
    END;

    RETURN  v_to_iban;
  END f_to_iban;




  --Renvoyer les différentes informations bancaires à partir de l'IBAN ({iv_clef_iban}||{iv_bban}) :
  --En cas d'erreur, {ov_erreur} sera renseigné sinon vide
  --  {on_codpays}    <>  Code pays
  --  {ov_codbque}    <>  Code banque
  --  {ov_guichet}    <>  Guichet
  --  {ov_compte}     <>  Compte
  --  {ov_clerib}     <>  Clé RIB
  PROCEDURE p_get_informations_bancaires
              ( iv_clef_iban  IN  VARCHAR2
              , iv_bban       IN  VARCHAR2
              , ov_iban       OUT VARCHAR2
              --, on_codpays    OUT NUMBER    -- MODIF TLE
              , ov_codbque    OUT VARCHAR2
              , ov_guichet    OUT VARCHAR2
              , ov_compte     OUT VARCHAR2
              , ov_clerib     OUT VARCHAR2
              , ov_erreur     OUT VARCHAR2
              )
  IS
    n_nbcarbban NUMBER;
  BEGIN
    ov_iban   :=NULL;
    -- on_codpays:=NULL;     -- MODIF TLE
    ov_codbque:=NULL;
    ov_guichet:=NULL;
    ov_compte :=NULL;
    ov_clerib :=NULL;
    ov_erreur :=NULL;



    IF  iv_bban IS  NOT NULL  THEN  ov_codbque  :=SUBSTR(iv_bban, 01, 05);
                                    ov_guichet  :=SUBSTR(iv_bban, 06, 05);
                                    ov_compte   :=SUBSTR(iv_bban, 11, 11);
                                    ov_clerib   :=SUBSTR(iv_bban, 22, 02);
                              END IF;

    IF  iv_clef_iban  IS  NOT NULL
    AND iv_bban       IS  NOT NULL  THEN  ov_iban :=UPPER(iv_clef_iban||iv_bban);
                                    END IF;
  END p_get_informations_bancaires;



-- SEPA prelevement function f_rib_iban ; verifie pour un rib que les champs clef_iban et bban et bic sont alimentés et que le bic est de taille 8 ou 11
  FUNCTION  f_rib_iban
      ( iv_idrib   IN  NUMBER
            ) RETURN  NUMBER
  IS
    ctrl_RIB number := 0 ;
  BEGIN
    select 1 into ctrl_RIB
    from RIB
    where idrib = iv_idrib
    and length(clef_iban) = 4 and bban is not null and (bic is null OR length(bic) in (8,11));
--	and length(clef_iban) = 4 and bban is not null and bic is not null  and length(bic) in (8,11); -- CLI 31/10/2014 ajout du test sur longueur BIC (SEPA_MERGE_EPAI)

    RETURN  ctrl_RIB;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0 ;
    WHEN OTHERS THEN
      RETURN 0 ;
  END f_rib_iban ;


-- ===============================================================================================================
--  FUNCTION  f_ctrl_rib_iban
--  Verifie pour un rib que les champs clef_iban et bban et bic sont alimentés (prend les 3 paramêtres en entrée
--  Retourne 1 si les infosz du RIB sont présentes, 0 sinon
-- ===============================================================================================================
  FUNCTION  f_ctrl_donnee_iban ( iv_clef_iban VARCHAR2,
                                 iv_bban VARCHAR2,
                                 iv_BIC VARCHAR2)
            RETURN  NUMBER
  IS
    ctrl_RIB number := 0 ;
  BEGIN
    -- if (iv_clef_iban is null or iv_bban is null or iv_BIC is null) then
    if (iv_clef_iban is null or iv_bban is null) then
      ctrl_RIB := 0;
    else
       ctrl_RIB := 1;
    end if;

    RETURN  ctrl_RIB;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0 ;
    WHEN OTHERS THEN
      RETURN 0 ;
  END f_ctrl_donnee_iban ;




FUNCTION F_MANDAT_VALIDE (i_IDHISTOMANDAT IN HISTO_MANDAT.IDHISTOMANDAT%TYPE) RETURN NUMBER IS
/*===========================================================================*/
/* Fonction     : F_MANDAT_VALIDE.sql                                        */
/* Domaine      : TRESORERIE                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : TLE                                                        */
/* Création     : 08/11/2013                                                 */
/* Description  : vérifie validité d un MANDAT pour un prélèvement SEPA      */
/*                - idhistomandat en entrée                                  */
/*                - Renvoie 2 si Mandat OK                                   */
/*                          1           KO                                   */
/*                          0 en cas d'erreur                                */
/*===========================================================================*/
/* Evolution    : /                                                          */
/* Auteur       : /                                                          */
/* Date         : /                                                          */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : /                                                          */
/*              : /                                                          */
/*===========================================================================*/
  loc_valide NUMBER := 0;
BEGIN
  SELECT CASE WHEN NVL(HISTO_MANDAT.MAJ,sysdate) > add_months(sysdate,-36) THEN 2
              ELSE 1
         END result INTO loc_valide
  FROM HISTO_MANDAT
  WHERE IDHISTOMANDAT = i_IDHISTOMANDAT ;
  RETURN loc_valide ;
EXCEPTION
  WHEN OTHERS THEN RETURN 0 ;

END F_MANDAT_VALIDE;


-- SEPA prelevement ajout MUR le 08/11/2013 :
    FUNCTION  f_ctrl_querable
              ( iv_numindiv  IN  VARCHAR2
              ) RETURN  number
    IS
    count_rib     number := 0  ;
    BEGIN
    select count(1) into count_rib
    from RIB
    where numindiv =  iv_numindiv
    and type = 2 and modpmt = 2 --and nature = 2
    and pk_sepa.f_rib_iban(idrib) = 1
    --and fin is null                                                                              -- MUR : supp le 23/02/2015
    and idrib = pk_treso.f_idrib (iv_numindiv, 2, null, null, SYSDATE, null, pk_devise.devise_ref) -- MUR : ajout le 23/02/2015
    ;

    RETURN  count_rib;

  EXCEPTION
    WHEN OTHERS THEN RETURN  count_rib;
  END f_ctrl_querable;

-- SEPA prelevement : procedure inactivation mandat (histo_querable et histo_mandat)
  PROCEDURE p_inactivation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              )
  IS
    loc_idhistoquerable number ;
    loc_mandat histo_mandat.mandat%type ;
    loc_count number := 0;

  BEGIN
        -- recherche idhistoquerable


    select idhistoquerable , mandat
    into loc_idhistoquerable ,loc_mandat
    from histo_querable
    where numquerable = iv_numquerable
    and idadhesion = iv_idadhesion
    and numgar = iv_numgar
    and etat = 1;

    -- inactivation histo_querable
    update histo_querable
    set etat = 0 , inactif = sysdate , util_inactif = f_numutil
    where idhistoquerable = loc_idhistoquerable ;

   -- Comptage des querables actifs pointant sur le mandat - SEPA B2B
    BEGIN
      SELECT COUNT(*)
      INTO loc_count
      FROM (SELECT -- Liste des querables ayant eu le mandat et leur dernier id
             hq.numquerable,
             hq.idadhesion,
             hq.numgar,
             MAX(hq.idhistoquerable) AS idhq
            FROM histo_querable hq
            WHERE mandat = loc_mandat
            GROUP BY
              hq.numquerable,
              hq.idadhesion,
              hq.numgar
             ) lst_querable,
           histo_querable hq2
      WHERE
          hq2.idhistoquerable = lst_querable.idhq
      AND hq2.etat = 1 ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_count := 0;
      -- WHEN OTHERS THEN
      --   loc_count := 0;   -- TODO BCO
    END;

    -- inactivation histo_mandat
    -- BCO SEPA B2B : inactivation à faire uniquement si le mandat est orphelin de querable actif
    IF loc_count = 0 THEN
      update histo_mandat
      set statut = 0
      where idhistomandat = (SELECT MAX(idhistomandat)
                                 FROM HISTO_MANDAT
                                 WHERE mandat = loc_mandat);
    END IF;

  EXCEPTION
    WHEN no_data_found then null ;
  END p_inactivation_mandat ;

-- SEPA prelevement : procedure creation mandat (histo_querable et histo_mandat)
  PROCEDURE p_creation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
              )
  IS
    loc_idrib         rib.idrib%type ;
    loc_rum           VARCHAR2(35 BYTE);
    loc_idhistomandat histo_mandat.idhistomandat%TYPE;
    loc_mandat_statut histo_mandat.statut%TYPE;
  BEGIN

    SELECT pk_treso.f_idrib (iv_NUMQUERABLE, 2, null, null, SYSDATE, iv_IDADHESION, pk_devise.devise_ref)
    INTO loc_idrib FROM DUAL ;

    loc_rum := NULL;
    -- BCO : SEPA B2B - Chercher un mandat à partir du RIB/Querable ET **Idadhesion = 0**
    --                     Si existe on ne créé pas histo mandat
    --                     sinon on créer histo_mandat avec nouveau RUM
    IF NVL(iv_idadhesion,0) = 0 THEN
      -- RIB du querable
      BEGIN
        SELECT MAX(hm.IDHISTOMANDAT)
        INTO loc_idhistomandat
        FROM histo_mandat hm
        INNER JOIN histo_querable hq ON  hq.mandat = hm.mandat
                                     AND hq.etat   = 1
                                     AND NVL(hq.idadhesion,0) = 0
        WHERE hm.idrib = loc_idrib ;

        SELECT hm.statut
              ,hm.mandat
        INTO loc_mandat_statut
            ,loc_rum
        FROM histo_mandat hm
        WHERE hm.idhistomandat = loc_idhistomandat ;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_idhistomandat := 0;
          loc_mandat_statut := 0;
          loc_rum           := NULL;
        WHEN OTHERS THEN
          loc_rum           := NULL;   -- TODO BCO
      END;
    END IF;

    -- Si mandat non trouvé et/ou inactif ou hors SEPA B2B
    IF loc_rum IS NULL OR loc_mandat_statut not in (1,2) THEN
      -- sequence RUM (voir pour utilisation parametre systeme)
      select F_LIB('MANDAT', '1') || lpad(RUM.NEXTVAL,(35-length(F_LIB('MANDAT', '1'))),'0') into loc_rum from dual ;

      insert into histo_mandat(IDHISTOMANDAT,MANDAT,MAJ,STATUT,IDRIB,MVT,NUMREMISE,AMDT_ICS,AMDT_MNDT,AMDT_ACCT,AMDT_SMNDA,AMDT_CREANCIER,CREATION)
      values (IDHISTOMANDAT.NEXTVAL,
      loc_rum,
      null,
      1, --actif
      loc_idrib ,
      'FRST',
      null,
      null,null,null,null,null,
      sysdate) ;

    END IF;


    -- ajout MUR 30/01/2014 : pour prise en compte du spécifique EPAI pour regroupement adhesion/pret : ajout de mandat_maitre dans HQ
    insert into histo_querable(IDHISTOQUERABLE,NUMQUERABLE,IDADHESION,NUMGAR,MREGL,FRACT,MANDAT,ETAT,CREATION,UTIL_CREA,REVOCATION,UTIL_REVO,INACTIF,UTIL_INACTIF,MANDAT_MAITRE)
    values (IDHISTOQUERABLE.NEXTVAL,
    iv_numquerable,
    iv_idadhesion,
    iv_numgar,
    iv_mregl,
    iv_fract,
    loc_rum ,
    1, -- actif
    sysdate,f_numutil,
    null, null ,
    null, null,
    loc_rum ) ;


  EXCEPTION -- a gerer
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN TOO_MANY_ROWS THEN NULL;
    WHEN OTHERS THEN NULL ;
  END p_creation_mandat ;

-- SEPA prelevement : procedure creation querable (histo_querable - pas de creation dans histo_mandat)
  PROCEDURE p_creation_querable
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
              )
  IS
    loc_idrib      rib.idrib%type ;
  loc_rum        VARCHAR2(35 BYTE) ;
  BEGIN
    -- ajout MUR 30/01/2014 : pour prise en compte du spécifique EPAI pour regroupement adhesion/pret : ajout de mandat_maitre dans HQ
    insert into histo_querable(IDHISTOQUERABLE,NUMQUERABLE,IDADHESION,NUMGAR,MREGL,FRACT,MANDAT,ETAT,CREATION,UTIL_CREA,REVOCATION,UTIL_REVO,INACTIF,UTIL_INACTIF,MANDAT_MAITRE)
    values (IDHISTOQUERABLE.NEXTVAL,
    iv_numquerable,
    iv_idadhesion,
    iv_numgar,
    iv_mregl,
    iv_fract,
    null ,
    1, -- actif
    sysdate,f_numutil,
    null, null ,
    null, null,
    null ) ;

  EXCEPTION -- a gerer
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN TOO_MANY_ROWS THEN NULL;
    WHEN OTHERS THEN NULL ;
  END p_creation_querable ;



-- SEPA prelevement : procedure inactivation mandat (histo_querable et histo_mandat)
  PROCEDURE p_maj_histo_querable
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
			  , ov_erreur       OUT VARCHAR2)
 IS
    loc_idhistoquerable number ;
    loc_mandat histo_mandat.mandat%type ;
    loc_idligne        NUMBER(9) :=0 ;
  BEGIN
      ov_erreur :=null;
			-- recherche idhistoquerable
    select idhistoquerable , mandat
    into loc_idhistoquerable ,loc_mandat
    from histo_querable
    where numquerable = iv_numquerable
    and idadhesion = iv_idadhesion
    and numgar = iv_numgar
    and etat = 1;

     -- inactivation de l'ancien histo_querable
    update histo_querable
    set etat = 0 , inactif = sysdate , util_inactif = f_numutil
    where idhistoquerable = loc_idhistoquerable ;

    -- création d'une nouvelle ligne avec la nouvelle info de fractionnement
    insert into histo_querable(IDHISTOQUERABLE,NUMQUERABLE,IDADHESION,NUMGAR,MREGL,FRACT,MANDAT,ETAT,CREATION,UTIL_CREA,REVOCATION,UTIL_REVO,INACTIF,UTIL_INACTIF)
    values (IDHISTOQUERABLE.NEXTVAL,
    iv_numquerable,
    iv_idadhesion,
    iv_numgar,
    iv_mregl,
    iv_fract,
    loc_mandat ,
    1, -- actif
    sysdate,f_numutil,
    null, null ,
    null, null ) ;

	 EXCEPTION
         WHEN  NO_DATA_FOUND THEN  ov_erreur :='Valeur non trouvée dans p_maj_histo_querable';
                             pk_trace.p_ins_journal_adm('pk_sepa',SID,3,'Valeur non trouvée dans p_maj_histo_querable ',SYSDATE,loc_idligne) ;
         WHEN  TOO_MANY_ROWS THEN  ov_erreur :='Plusieurs valeurs trouvées dans p_maj_histo_querable';
                             pk_trace.p_ins_journal_adm('pk_sepa',SID,3,'Plusieurs valeurs trouvées dans p_maj_histo_querable ',SYSDATE,loc_idligne) ;
         WHEN  OTHERS        THEN  ov_erreur :='<'||SQLERRM||'>';
                             pk_trace.p_ins_journal_adm('pk_sepa',SID,3,'Erreur dans pk_sepa.p_maj_histo_querable ',SYSDATE,loc_idligne) ;

   END p_maj_histo_querable;




-- SEPA generation amendement
-- modif le 07/01/2014 pour prise en compte modification du BIC qui doit generer une amendement SMNDA - on repart en FRST
-- modif le 08/07/2014 : ajout de l'adhesion en parametre d'entree (quand on provient de ad24 ou ad26)
-- modif le 05/09/2014 : changement de BIC => amendement ACCOUNT (au lieu de SMNDA)
  PROCEDURE p_generer_amendement
              ( iv_idrib     IN NUMBER
              , iv_clef_iban IN VARCHAR2
              , iv_bban      IN VARCHAR2
              , iv_BIC       IN VARCHAR2
              , iv_idrib_new IN NUMBER
              , ov_retour    OUT NUMBER
              , iv_test_ribadhe IN VARCHAR2 default null -- renseigné quand on vient de PE14 - trigger rib_enc.post_insert
              , iv_idadhesion in number default null     -- renseigné quand on vient de ad24 ou ad26
        )
  IS
  cursor C_MANDAT is -- mandats non inactifs liés à idrib
    select a.IDHISTOMANDAT , a.MANDAT , a.MAJ , a.STATUT , a.IDRIB , a.MVT , a.NUMREMISE ,
         a.AMDT_ICS , a.AMDT_MNDT , a.AMDT_ACCT , a.AMDT_SMNDA , a.AMDT_CREANCIER ,
         b.clef_iban , b.BBAN , b.BIC ,
         hq.idadhesion
    from histo_mandat a
    inner join rib b on (a.idrib = b.idrib)
    inner join histo_querable hq on (hq.mandat = a.mandat and hq.etat = 1)
    where a.idrib = iv_idrib
    and iv_idrib_new = pk_treso.f_idrib (b.numindiv, 2, null, null, SYSDATE, hq.idadhesion, pk_devise.devise_ref)
    and a.statut <> 0
    -- SEPA 19/02/2014 : Lors de la fermeture d’un rib (et donc création d’un nouveau RIB) ,
    -- on ne fait pas de modifications au niveau du mandat existant si le rib est présent dans RIB_ADHE avec type = 2 (gestion des RIb qg17),
    -- cela pour ne pas créer de dephasage entre GQ17 et le mandat
    and not exists (select 1 from histo_querable c
                    inner join rib_adhe d on (d.idadhesion = c.idadhesion and d.type = 2)
                    where c.mandat = a.mandat
                    and c.etat = 1
                    and upper(iv_test_ribadhe) = 'TEST'
                    )
    and a.idhistomandat = (select max(hm2.idhistomandat) from histo_mandat hm2 where a.mandat = hm2.mandat ) -- ne traiter que la derniere situation du mandat
    and  hq.idadhesion = nvl(iv_idadhesion,hq.idadhesion)
    ;

  R_MANDAT     C_MANDAT%ROWTYPE ;
  loc_remise_non_valide number ;

  BEGIN

    P_INS_journal(1,'Début pk_sepa.p_generer_amendement'); -- TLE
    -- verification mandat impliqué dans remise non validée
    select count(1) into loc_remise_non_valide
    from rib a
    inner join histo_mandat b on (a.idrib = b.idrib and b.statut <> 0 ) --recherche des mandats actifs ou amendés liés au rib
    inner join remise_prelev c on (b.numremise = c.numremise and c.valide = 'N')
    where a.idrib = iv_idrib
    and b.idhistomandat =  (select max(hm2.idhistomandat) from histo_mandat hm2 where b.mandat = hm2.mandat ) -- ne traiter que la derniere situation du mandat;
    ;
    P_INS_journal(1,'loc_remise_non_valide : ' || loc_remise_non_valide);

    IF loc_remise_non_valide > 0 then
      ov_retour := 2083 ;
    ELSE
      IF iv_idrib_new is null THEN -- cas modification d'un rib existant (update de la table RIB seulement)
        P_INS_journal(1,'iv_idrib_new : ' || iv_idrib_new);
        P_INS_journal(1,'Debut boucle mandat');
        FOR R_MANDAT IN C_MANDAT LOOP
          P_INS_journal(1,'histo_mandat:' || R_MANDAT.IDHISTOMANDAT);
          IF R_MANDAT.MAJ is not null then -- ne rien faire si non communiqué donc si MAJ est nulle
            P_INS_journal(1,'Cas changement de banque ou changement de BIC');
            -- cas changement de banque ou changement de BIC
            --IF (substr(R_MANDAT.bban,1,5) <> substr(iv_bban,1,5) OR R_MANDAT.bic <> iv_bic  ) then
            IF substr(R_MANDAT.bban,1,5) <> substr(iv_bban,1,5) then -- MUR le 5/09/2014
              P_INS_journal(1,'R_MANDAT.MAJ : ' || R_MANDAT.MAJ);
              P_INS_journal(1,'update histo_mandat SMNDA');
              update histo_mandat
              set STATUT = 2 , AMDT_ACCT = null ,AMDT_SMNDA = 'SMNDA' , MVT = 'FRST' where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ;
              ov_retour := 2082 ;
            --ELSIF substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) then
            -- ELSIF (substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) OR R_MANDAT.bic <> iv_bic ) then -- MUR le 5/09/2014
            ELSIF (substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) OR NVL(R_MANDAT.bic, '0') <> NVL(iv_bic, '0') ) then
              -- changement de compte
              P_INS_journal(1,'Cas  changement de compte');
              P_INS_journal(1,'update histo_mandat ACCT');
              update histo_mandat
              set STATUT = 2 , AMDT_ACCT = decode(AMDT_SMNDA,null,R_MANDAT.clef_iban||R_MANDAT.bban,null) where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ;
              ov_retour := 2082 ;
            END IF ;
          END IF ;
        END LOOP;
        P_INS_journal(1,'Fin boucle mandat');
      ELSE -- cas fermeture d'un rib existant et creation d'un nouveau RIB (update et insert de la table RIB)
        P_INS_journal(1,'Cas fermeture d''un rib existant et creation d''un nouveau RIB');
        P_INS_journal(1,'Debut boucle mandat');
        FOR R_MANDAT IN C_MANDAT LOOP
          -- RIB identique => pas d'amendement
          P_INS_journal(1,'RIB identique => pas d''amendement');
          -- IF (R_MANDAT.bban = iv_bban and R_MANDAT.bic = iv_bic)  then -- clef_iban non pris en compte dans test
          IF (R_MANDAT.bban = iv_bban and NVL(R_MANDAT.bic, '0') = NVL(iv_bic, '0'))  then
            P_INS_journal(1,'Maj idrib seulement');
            update HISTO_MANDAT set IDRIB = iv_idrib_new where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ; -- maj idrib seulement
          -- cas changement de banque ou changement de BIC
          --ELSIF (substr(R_MANDAT.bban,1,5) <> substr(iv_bban,1,5) OR R_MANDAT.bic <> iv_bic ) then
          ELSIF substr(R_MANDAT.bban,1,5) <> substr(iv_bban,1,5) then -- MUR le 05/09/2014
            IF R_MANDAT.MAJ IS NULL THEN -- non communiqué
              update HISTO_MANDAT set IDRIB = iv_idrib_new where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ; -- maj idrib seulement
            ELSE -- deja communiqué alors à amender
              P_INS_journal(1,'deja communiqué alors à amender');
              update HISTO_MANDAT
              set STATUT = 2 ,
                IDRIB = iv_idrib_new ,
                AMDT_ACCT = null ,
                AMDT_SMNDA = 'SMNDA' ,
                MVT = 'FRST'
              where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ;
              ov_retour := 2082 ;
            END IF ;
          -- changement de compte
          --ELSIF substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) then
          P_INS_journal(1,'changement de compte');
          -- ELSIF (substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) OR R_MANDAT.bic <> iv_bic)  then
          ELSIF (substr(R_MANDAT.bban,6,16) <> substr(iv_bban,6,16) OR NVL(R_MANDAT.bic, '0') <> NVL(iv_bic, '0'))  then
            IF R_MANDAT.MAJ IS NULL THEN -- non communiqué
              update HISTO_MANDAT set IDRIB = iv_idrib_new where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ; -- maj idrib seulement
            ELSE -- deja communiqué alors à amender
              update HISTO_MANDAT
              set STATUT = 2 ,
                IDRIB = iv_idrib_new ,
                AMDT_ACCT = decode(AMDT_SMNDA,null,R_MANDAT.clef_iban||R_MANDAT.BBAN,null)
              where IDHISTOMANDAT = R_MANDAT.IDHISTOMANDAT ;
              ov_retour := 2082 ;
            END IF ;
          end if ;
        END LOOP ;
        P_INS_journal(1,'Debut boucle mandat');
      END IF;
    END IF;
  END;

  -- procedure qui permet de réactiver le dernier mandat inactif
  PROCEDURE p_reactivation_mandat
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
			     , iv_fract        IN NUMBER   -- TLE : AJOUT DE LA PRISE EN COMPTE DU FRACTIONNEMENT
              , ov_retour       OUT NUMBER
              )
  IS
    loc_nbenreg number ;
    cursor C_MANDAT_INACTIF is -- liste des mandats inactifs
      select
        hq.idhistoquerable , hq.idadhesion , hq.numquerable , hq.numgar ,
        hq.mregl , hq.mandat , hq.etat , hq.fract , hq.creation creation_q , hq.util_crea , hq.revocation , hq.util_revo , hq.mandat_maitre ,
        hm.idhistomandat , hm.statut, hm.idrib ,
        hm.maj, hm.mvt , hm.numremise , hm.amdt_ics , hm.amdt_mndt , hm.amdt_acct , hm.amdt_smnda , hm.amdt_creancier , hm.creation creation_m ,
        pk_sepa.f_mandat_valide(hm.IDHISTOMANDAT) caducite -- : ok si 2
      from histo_querable HQ
      left outer  join histo_mandat HM on (hm.mandat = hq.mandat)
      -- criteres de recherche
      where HQ.idadhesion = iv_idadhesion and hq.numquerable = iv_numquerable and hq.numgar = iv_numgar and hq.mregl = iv_mregl
      and hq.etat = 0 and hm.statut = 0
      order by hq.idhistoquerable desc , hm.idhistomandat desc;
    R_MANDAT_INACTIF C_MANDAT_INACTIF%rowtype ;

    loc_oldrib_cleiban varchar2(4) ;
    loc_oldrib_bban varchar2(30) ;
    loc_oldrib_bic  varchar2(11) ;

    loc_newrib_cleiban varchar2(4) ;
    loc_newrib_bban varchar2(30) ;
    loc_newrib_bic  varchar2(11) ;

  BEGIN
    P_INS_journal(1,'Début p_reactivation_mandat');
    P_INS_journal(1,'Adhésion: ' || iv_idadhesion);
    P_INS_journal(1,'Contrat: ' || iv_numgar);
    P_INS_journal(1,'Querable: ' || iv_numquerable);

    loc_nbenreg := 0 ;
    ov_retour := -1 ;
    FOR  R_MANDAT_INACTIF IN  C_MANDAT_INACTIF LOOP
      loc_nbenreg := loc_nbenreg + 1 ;
      EXIT when loc_nbenreg > 1 ;-- pour ne traiter que le premier enreg du curseur

      -- si mandat non caduque => reactivation du mandat , cad creation nouvel enreg dans HQ et maj de HM
      IF R_MANDAT_INACTIF.caducite = 2 THEN
        P_INS_journal(1,'Mandat non caduque');
        P_INS_journal(1,'Insertion dans histo_querable');
        insert into histo_querable(IDHISTOQUERABLE,NUMQUERABLE,IDADHESION,NUMGAR,MREGL,FRACT,MANDAT,ETAT,CREATION,UTIL_CREA,REVOCATION,UTIL_REVO,INACTIF,UTIL_INACTIF,MANDAT_MAITRE)
        values (IDHISTOQUERABLE.NEXTVAL,
                R_MANDAT_INACTIF.NUMQUERABLE,
                R_MANDAT_INACTIF.IDADHESION,
                R_MANDAT_INACTIF.NUMGAR,
                R_MANDAT_INACTIF.MREGL,
                --R_MANDAT_INACTIF.FRACT,
				    iv_fract,  -- TLE : insertion du fractionnement du quérable précédent.
                R_MANDAT_INACTIF.MANDAT,
                1, -- passage à actif
                R_MANDAT_INACTIF.CREATION_Q,
                R_MANDAT_INACTIF.UTIL_CREA,
                R_MANDAT_INACTIF.REVOCATION,
                R_MANDAT_INACTIF.UTIL_REVO,
                null,
                null,
                R_MANDAT_INACTIF.mandat_maitre) ;
        /*insert into histo_mandat(IDHISTOMANDAT,MANDAT,MAJ,STATUT,IDRIB,MVT,NUMREMISE,AMDT_ICS,AMDT_MNDT,AMDT_ACCT,AMDT_SMNDA,AMDT_CREANCIER,CREATION)
        values (IDHISTOMANDAT.NEXTVAL,
                R_MANDAT_INACTIF.MANDAT,
                R_MANDAT_INACTIF.MAJ,
                1,
                R_MANDAT_INACTIF.IDRIB,
                R_MANDAT_INACTIF.MVT,
                R_MANDAT_INACTIF.NUMREMISE,
                R_MANDAT_INACTIF.AMDT_ICS,
                R_MANDAT_INACTIF.AMDT_MNDT,
                R_MANDAT_INACTIF.AMDT_ACCT,
                R_MANDAT_INACTIF.AMDT_SMNDA,
                R_MANDAT_INACTIF.AMDT_CREANCIER,
                R_MANDAT_INACTIF.CREATION_M) ;*/
        P_INS_journal(1,'update histo_mandat');
        update histo_mandat set STATUT = 1 where IDHISTOMANDAT = R_MANDAT_INACTIF.idhistomandat ;

        -- verification si changement de RIB
        IF R_MANDAT_INACTIF.idrib != pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref) then
          IF R_MANDAT_INACTIF.maj is null then
          -- si mandat non utilisé alors maj de idrib seulement
            P_INS_journal(1,'mandat non utilisé ->  maj de idrib seulement');
            P_INS_journal(1,'update histo_mandat');
            update histo_mandat set idrib = pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref)
            where IDHISTOMANDAT = R_MANDAT_INACTIF.idhistomandat ;
          ELSE --  gestion des amendements
            -- recup des infos bancaires de ancien et nouveau rib
            select clef_iban , bban , bic into loc_oldrib_cleiban , loc_oldrib_bban , loc_oldrib_bic
            from rib where idrib = R_MANDAT_INACTIF.idrib ;

            select clef_iban , bban , bic into loc_oldrib_cleiban , loc_oldrib_bban , loc_oldrib_bic
            from rib where idrib = pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref) ;

            -- coordonnées bancaires identiques alors maj de idrib seulement
            -- IF loc_oldrib_bban = loc_newrib_bban and loc_oldrib_bic = loc_newrib_bic then
            IF loc_oldrib_bban = loc_newrib_bban and NVL(loc_oldrib_bic, '0') = NVL(loc_newrib_bic, '0') then
               P_INS_journal(1,'coordonnées bancaires identiques-> maj de idrib seulement');
              update histo_mandat set idrib = pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref)
              where IDHISTOMANDAT = R_MANDAT_INACTIF.idhistomandat ;
            ELSE  -- sinon generer amendement si données bancaires différentes
              --IF substr(loc_oldrib_bban,1,5) != substr(loc_newrib_bban,1,5) or loc_oldrib_bic != loc_newrib_bic then
              P_INS_journal(1,'generer amendement si données bancaires différentes');
              IF substr(loc_oldrib_bban,1,5) != substr(loc_newrib_bban,1,5) then
                -- changement de banque ou de bic
                update histo_mandat
                set idrib = pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref),
                    STATUT = 2,
                    AMDT_ACCT = null ,
                    AMDT_SMNDA = 'SMNDA' ,
                    MVT = 'FRST'
                where IDHISTOMANDAT = R_MANDAT_INACTIF.idhistomandat ;
              ELSE
                -- changement de compte ou de bic
                P_INS_journal(1,'changement de compte ou de bic');
                update histo_mandat
                set idrib = pk_treso.f_idrib (R_MANDAT_INACTIF.NUMQUERABLE, 2, null, null, SYSDATE, R_MANDAT_INACTIF.IDADHESION, pk_devise.devise_ref),
                    STATUT = 2,
                    AMDT_ACCT = decode(AMDT_SMNDA,null,loc_oldrib_cleiban || loc_oldrib_bban,null)
                where IDHISTOMANDAT = R_MANDAT_INACTIF.idhistomandat ;
              END IF ;
            END IF ;
          END IF ;
        END IF ;
        ov_retour := 0 ;

      END IF ;
    END LOOP ;
  END ;

  -- fonction qui permet de savoir si il existe un mandat réactivable
  -- cela permet de parametrer l'affichage du message 2081 au niveau des écrans des cotisations
  FUNCTION f_reactivation_mandat
             ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              )  RETURN NUMBER
  IS
    loc_retour number ;
  BEGIN
    select count(1) into loc_retour
    from histo_querable HQ
    left outer  join histo_mandat HM on (hm.mandat = hq.mandat)
    -- criteres de recherche
    where HQ.idadhesion = iv_idadhesion and hq.numquerable = iv_numquerable and hq.numgar = iv_numgar and hq.mregl = iv_mregl
    and hq.etat = 0 and hm.statut = 0
    and pk_sepa.f_mandat_valide(hm.IDHISTOMANDAT)  = 2 ;

    RETURN  loc_retour;
  END f_reactivation_mandat;

FUNCTION f_mandat_remise_non_validee(iv_mandat IN HISTO_QUERABLE.MANDAT_MAITRE%type) RETURN NUMBER IS
/*===========================================================================*/
/* Fonction     : f_mandat_remise_non_validee                                */
/* Domaine      : TRESORERIE                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : MUR                                                        */
/* Création     : 07/02/2014                                                 */
/* Description  : vérifie si mandat est present dans remise non validée      */
/*                - mandat en entrée                                         */
/*                - Renvoie 0 si OK                                          */
/*                          1 si ko                                          */
/*                          0 en cas d'erreur                                */
/*===========================================================================*/
/* Evolution    : /                                                          */
/* Auteur       : /                                                          */
/* Date         : /                                                          */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : /                                                          */
/*              : /                                                          */
/*===========================================================================*/
  loc_valide NUMBER := 0;
BEGIN
  select count(1) into loc_valide
  from prelevement pre
  inner join remise_prelev remi on (remi.numremise = pre.numremise)
  where remi.valide= 'N'
  and pre.mandat = iv_mandat
  ;
  RETURN loc_valide ;
EXCEPTION
  WHEN OTHERS THEN RETURN 0 ;

END f_mandat_remise_non_validee;


  -- TLE : ajout d'une fonction pour PE14 : bloquer la modification d'un RIB
  --       si ce RIB est maitre d'autres mandats
 PROCEDURE P_VERIF_MODIF_RIB ( in_IDRIB   IN histo_mandat.IDRIB%TYPE
                             , in_IDADHESION IN histo_querable.IDADHESION%TYPE
                             , ov_retour  OUT NUMBER) IS
/*===========================================================================*/
/* Fonction     : P_VERIF_MODIF_RIB                                          */
/* Domaine      : TRESORERIE                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : TLE                                                        */
/* Création     : 10/02/2014                                                 */
/* Description  : vérifie si pour un idrib donné en paramêtre,               */
/*                on peut modifier le RIB:                                   */
/*              - vérification que les mandats liés à IDRIB sont tous maitre */
/*                d'eux-même                                                 */
/*              - vérifier qu'ils ne sont pas maitre d'autres mandats        */
/*                La fonction ramène O si on ne peut pas modifier le RIB     */
/*===========================================================================*/
/* Evolution    : /                                                          */
/* Auteur       : /                                                          */
/* Date         : /                                                          */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : MUR/02/07/2014/pour modif AD24                             */
/*              :    ne rechercher que le mandat de l'adhesion concernée     */
/*===========================================================================*/
  --loc_verif NUMBER := 0;
  loc_idrib NUMBER := in_idrib;
  loc_mandat histo_mandat.mandat%type ;

   cursor C_SELECT_MANDAT(p_mandat histo_mandat.mandat%TYPE) is
     select mandat
     from histo_mandat HM
     where HM.mandat = nvl(p_mandat,HM.mandat)
     and HM.IDRIB = in_IDRIB
     and statut <>0
     and hm.idhistomandat =  (SELECT MAX(hm2.idhistomandat) FROM HISTO_MANDAT hm2 WHERE hm2.mandat = hm.mandat);

  R_SELECT_MANDAT    C_SELECT_MANDAT%ROWTYPE ;

  loc_compt_MM number :=0;
  loc_compt_AM number :=0;

BEGIN
        ov_retour := 0 ;
        loc_mandat := null ;

        -- recherche du mandat de l'adhesion (ON NE PASSE PAS LA EN VENANT DE PE14)
        IF in_IDADHESION is not null then
          BEGIN
            select hq.mandat into loc_mandat
            from histo_querable hq
            where hq.idadhesion  = in_IDADHESION
            and hq.etat = 1 ;
          END;
        END IF;

        FOR R_SELECT_MANDAT IN C_SELECT_MANDAT(loc_mandat) LOOP  -- LOC_MANDAT IS NULL EN VENANT DE PE14

               -- Verif si le mandat est maitre de lui-même
               select count(1) into loc_compt_MM
               from histo_querable
               where mandat =  R_SELECT_MANDAT.mandat
               and etat = 1
               and mandat = mandat_maitre ;

               IF loc_compt_MM = 0
               THEN  ov_retour := 2093;
               END IF;
               EXIT WHEN ov_retour = 2093;

               -- Vérif si le mandat n'est pas maitre d'un autre
               select count(1) into loc_compt_AM
               from histo_querable
               where mandat_maitre =  R_SELECT_MANDAT.mandat
               and etat = 1
               and mandat != mandat_maitre ;

               IF loc_compt_AM <> 0
                 THEN  ov_retour := 2093;
               END IF;
               EXIT WHEN ov_retour = 2093;
        END LOOP;

EXCEPTION
  WHEN OTHERS THEN ov_retour := 0;

END P_VERIF_MODIF_RIB;

-- --------------------------------------------------------------------------------------------------
-- TLE : ajout d'une procedure pour PE14 : bloquer la modification d'un RIB
--       sauf si toutes les adhesions liées au RIB sont dans RIB_ADHE
PROCEDURE P_VERIF_MODIF_RIB_2(in_IDRIB IN histo_mandat.IDRIB%TYPE ,
                              ov_retour OUT NUMBER)
IS
   /*===========================================================================*/
   /* Fonction     : P_VERIF_MODIF_RIB                                          */
   /* Domaine      : TRESORERIE                                                 */
   /* Version      : V1.0                                                       */
   /* Auteur       : TLE                                                        */
   /* Création     : 10/02/2014                                                 */
   /* Description  : ov_retour = 2093 si on ne peut pas modifier le RIB         */
   /*                ov_retour = 0 si on peut pas modifier le RIB               */
   /*===========================================================================*/
   /* Evolution    : /                                                          */
   /* Auteur       : /                                                          */
   /* Date         : /                                                          */
   /* Commentaire  :                                                            */
   /*===========================================================================*/
   /* Correction   :                                                            */
   /*              :                                                            */
   /*===========================================================================*/
   loc_idrib NUMBER := in_idrib;
   loc_mandat histo_mandat.mandat%type ;
   loc_idadhesion histo_querable.idadhesion%type ;

   -- Curseur de récupération des mandats
   CURSOR C_SELECT_MANDAT IS
   SELECT mandat
   FROM histo_mandat HM
   WHERE HM.IDRIB       = in_IDRIB
   AND statut          <> 0
   AND hm.idhistomandat =
      (SELECT MAX(hm2.idhistomandat)
      FROM HISTO_MANDAT hm2
      WHERE hm2.mandat = hm.mandat
      );
    R_SELECT_MANDAT C_SELECT_MANDAT%ROWTYPE ;


   -- Curseur de récupération des adhésions
   CURSOR C_SELECT_ADHESION(p_mandat histo_mandat.mandat%TYPE) IS
      SELECT idadhesion
      FROM histo_querable HQ
      WHERE HQ.mandat = p_mandat
      and HQ.ETAT != 2 -- On exclu les mandats révoqués
      and idhistoquerable = (select max (idhistoquerable)
                             from histo_querable hq2 where hq2.mandat = hq.mandat )
      ;
   R_SELECT_ADHESION C_SELECT_ADHESION%ROWTYPE ;

   loc_compt_ADH NUMBER                            := 0;
   loc_max_idhisto_mandat histo_mandat.mandat%type := 0;
   loc_compt_RIB_ADHE NUMBER                       := 0;

BEGIN
   ov_retour  := 0 ;
   loc_mandat := NULL ;


   -- Récupération des mandats
   FOR R_SELECT_MANDAT IN C_SELECT_MANDAT
         LOOP

         -- récupération des adhésions
         FOR R_SELECT_ADHESION IN C_SELECT_ADHESION(R_SELECT_MANDAT.MANDAT)
         LOOP
            -- Test pour vérifier que les adhesions sont présentes dans RIB_ADHE
            SELECT COUNT(1)
            INTO loc_compt_RIB_ADHE
            FROM RIB_ADHE
            WHERE R_SELECT_ADHESION.IDADHESION = RIB_ADHE.IDADHESION;

            IF loc_compt_RIB_ADHE = 0
               THEN ov_retour := 2093;
            END IF;

            EXIT WHEN ov_retour = 2093;
         END LOOP; -- R_SELECT_ADHESION
   END LOOP; -- R_SELECT_MANDAT

EXCEPTION
WHEN OTHERS THEN
   ov_retour := 0;
END P_VERIF_MODIF_RIB_2;
-- --------------------------------------------------------------------------------------------------


  -- MUR le 17/03/2014 : fonction utilisée dans PE14 permettant de savoir si une modification de rib
  -- porte sur les coordonnées bancaires
  FUNCTION f_modif_coor_banc(iv_idrib     IN rib.idrib%type
                           , iv_clef_iban IN rib.clef_iban%type
                           , iv_bban      IN rib.bban%type
                           , iv_bic       IN rib.bic%type
                           ) RETURN NUMBER is
    loc_retour number ;
  BEGIN
    select count(1) into loc_retour
    from RIB
    where idrib = iv_idrib
    and clef_iban = iv_clef_iban
    and bban = iv_bban
    and NVL(bic, '0') = NVL(iv_bic, '0');
    -- and bic = iv_bic ;
    return loc_retour ;

  END f_modif_coor_banc ;


  -- MUR le 24/04/2014 : procedure qui met à jour HQ.MANDAT
  -- pour les anomalies de HQ : en prelevement et mandat null
  -- BCO SEPA B2B - A analyser : on créer des histo_mandat peut être en trop pour SEPA B2B !
  PROCEDURE P_MAJ_MANDAT (iv_idrib  in number ,
                          ov_retour out number)
  IS
    cursor C_MAJ_MANDAT is
      select idhistoquerable , numquerable , idadhesion , numgar
      from histo_querable
      where mandat is null and etat = 1
      and pk_treso.f_idrib (NUMQUERABLE, 2, null, null, SYSDATE, IDADHESION, pk_devise.devise_ref) = iv_idrib
      and mregl = 2 -- MUR le 03/11/2014 : pour ne mettre à jour le mandat que pour les prelevements
      ;
    R_MAJ_MANDAT C_MAJ_MANDAT%rowtype ;

    loc_rum           histo_querable.mandat%type ;
    loc_IDHISTOMANDAT histo_mandat.IDHISTOMANDAT%type ;

  BEGIN
    ov_retour := 0 ;
    FOR R_MAJ_MANDAT IN C_MAJ_MANDAT LOOP
      -- nouvelle sequence RUM
      select F_LIB('MANDAT', '1') || lpad(RUM.NEXTVAL,(35-length(F_LIB('MANDAT', '1'))),'0') into loc_rum from dual ;
      -- MAJ HQ
      UPDATE HISTO_QUERABLE
      SET MANDAT = loc_rum , MANDAT_MAITRE = loc_rum
      WHERE IDHISTOQUERABLE = R_MAJ_MANDAT.idhistoquerable
      ;
      -- insert HM
      select IDHISTOMANDAT.NEXTVAL into loc_IDHISTOMANDAT from dual ;
      insert into histo_mandat(IDHISTOMANDAT,MANDAT,MAJ,STATUT,IDRIB,MVT,NUMREMISE,AMDT_ICS,AMDT_MNDT,AMDT_ACCT,AMDT_SMNDA,AMDT_CREANCIER,CREATION)
			values (loc_IDHISTOMANDAT,
                 loc_rum,
			  		  null,
				  	  1, --actif
					  iv_idrib ,
					  'FRST',
	  					null,
		  				null,
                  null,
                  null,
                  null,
                  null,
                  sysdate) ;
    END LOOP ;
  EXCEPTION
    when others then ov_retour := 1 ;
  END P_MAJ_MANDAT;


  PROCEDURE P_FIND_RUM (i_numquerable   IN  HISTO_QUERABLE.NUMQUERABLE%TYPE,
                        i_idadhesion    IN  HISTO_QUERABLE.IDADHESION%TYPE,
                        i_numgar        IN  HISTO_QUERABLE.NUMGAR%TYPE,
                        o_mandat        OUT HISTO_MANDAT.MANDAT%TYPE,
                        o_idhistomandat OUT HISTO_MANDAT.IDHISTOMANDAT%TYPE)
  -- Pour un triplet Querable (numquerable,idadhesion,numgar), renvoit
  --         - le mandat (RUM) (qui est alloué si besoin)
  --         - un IDHISTOMANDAT non NULL s'il existe un mandat actif (charge à l'appellant de le créer le cas échéant avec o_mandat)
  IS
  loc_idrib         RIB.IDRIB%TYPE;
  loc_mandat_statut histo_mandat.statut%TYPE;

  BEGIN
  o_mandat        := NULL;
  o_idhistomandat := NULL;


  -- Recherche d'un mandat actif sur querable actif
  --  on s'assure de ne pas créer des mandats intempestifs
  BEGIN
    SELECT
      hm.mandat,
      hm.idhistomandat
    INTO
      o_mandat,
      o_idhistomandat
    FROM       histo_mandat   hm
    INNER JOIN histo_querable hq ON  hq.mandat = hm.mandat
                                 AND hq.etat   = 1
    WHERE
        hq.numquerable = i_numquerable
    AND hq.idadhesion  = i_idadhesion
    AND hq.numgar      = i_numgar
    and hq.etat        = 1 ;

    -- Si on a trouvé, fini --
    RETURN;
    --------------------------

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
   END;

  -- BCO : SEPA B2B - Chercher un mandat à partir du RIB/Querable ET **Idadhesion = 0**
  IF NVL(i_idadhesion,0) = 0 THEN
    SELECT pk_treso.f_idrib (i_numquerable, 2, null, null, SYSDATE, i_idadhesion, pk_devise.devise_ref)
    INTO loc_idrib FROM DUAL ;
    -- RIB du querable
    BEGIN
      SELECT MAX(hm.IDHISTOMANDAT)
      INTO o_idhistomandat
      FROM histo_mandat hm
      INNER JOIN histo_querable hq ON  hq.mandat = hm.mandat
                                   AND hq.etat   = 1
                                   AND NVL(hq.idadhesion,0) = 0
      WHERE hm.idrib = loc_idrib ;

      SELECT hm.statut
            ,hm.mandat
      INTO loc_mandat_statut
          ,o_mandat
      FROM histo_mandat hm
      WHERE hm.idhistomandat = o_idhistomandat ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_idhistomandat   := 0;
        loc_mandat_statut := 0;
        o_mandat          := NULL;
      WHEN OTHERS THEN
        o_mandat          := NULL;
    END;
  --FinSi SEPA B2B
  END IF;

  -- Si mandat non trouvé et/ou inactif ou hors SEPA B2B
  IF o_mandat IS NULL OR loc_mandat_statut not in (1,2) THEN
    -- sequence RUM (voir pour utilisation parametre systeme)
    select F_LIB('MANDAT', '1') || lpad(RUM.NEXTVAL,(35-length(F_LIB('MANDAT', '1'))),'0') into o_mandat from dual ;
    o_idhistomandat := NULL;
  END IF;



  EXCEPTION
    WHEN OTHERS THEN NULL ;
  END P_FIND_RUM;



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2,
                        i_msg2 in varchar2 := null
                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF g_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO g_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = g_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            g_niv_msg := 1;
    END;
  END IF;

  IF g_niv_msg >= i_niv THEN
     g_idligne := g_idligne +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => nvl(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => substr(i_msg||' '||i_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;
  COMMIT;
END P_INS_journal;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRAIT_RIB_JOUR                                          */
/* Type         :  Public                                                    */
/* Description  :  Traitement des RIB d’encaissement avec une date de début  */
/*                 égal à la date pivot.                                     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

-- Traitement des RIB d’encaissement avec une date de début égal à la date pivot.
PROCEDURE P_TRAIT_RIB_JOUR ( p_date_pivot IN DATE )
IS

-- Curseur de selection des rib, adhesions, querables, mandats
-- il s'agit d'identifier les adhésions prélevées avec des incohérence de mandat liée à de RIB dont la prise d'effet est dans le futur
-- mandat vide ou mandat pointant sur le mauvais RIB suite à une historisation des RIB encaissements
CURSOR C_RIB_JOUR ( pc_date_pivot DATE ) IS
    SELECT
        r1.numindiv,
        r1.idrib,
        r1.debut,
        r1.fin,
        r1.clef_iban,
        r1.bban,
        r1.bic,
        r2.idrib idrib_old,
        r2.debut debut_old,
        r2.fin   fin_old,
        a.idadhesion,
        hq.mandat
    FROM
        RIB r1
        INNER JOIN      ADHE_CNTRT     a  ON ( a.numquerable  = r1.numindiv   AND
                                               a.mregl        = 2 )
        LEFT OUTER JOIN HISTO_QUERABLE hq ON ( hq.idadhesion  = a.idadhesion  AND
                                               hq.numquerable = a.numquerable AND
                                               hq.etat        = 1 )
        LEFT OUTER JOIN HISTO_MANDAT   hm ON ( hm.mandat      = hq.mandat )
        LEFT OUTER JOIN RIB            r2 ON ( r2.idrib       = hm.idrib )
    WHERE
        r1.debut >= pc_date_pivot    AND
        r1.debut <  pc_date_pivot +1 AND
        r1.type   = 2                AND
        r1.modpmt = 2
    ORDER BY
        r1.numindiv ASC,
        r1.fin      ASC;

R_RIB_JOUR C_RIB_JOUR%ROWTYPE;
loc_code_retour NUMBER;

BEGIN

    P_INS_journal(1,'Début PK_SEPA.P_TRAIT_RIB_JOUR');
    P_INS_journal(1,'Date Pivot : ' || TO_CHAR(p_date_pivot,'DD/MM/YYYY'));

    FOR R_RIB_JOUR IN C_RIB_JOUR( TRUNC(p_date_pivot) ) LOOP

        -- Le RIB est déjà associé à un mandat
        IF R_RIB_JOUR.idrib = R_RIB_JOUR.idrib_old THEN

            P_INS_journal(1,'RIB ' || TO_CHAR(R_RIB_JOUR.idrib) || ' non traité : Le RIB a déjà un mandat' );

        /*
        -- L’adhésion est résiliée==> même si elle est résiliée on doit pouvoir la prélever
        ELSIF R_RIB_JOUR.date_fin_adhe < p_date_pivot THEN

            P_INS_journal(1,'RIB ' || TO_CHAR(R_RIB_JOUR.idrib) || ' non traité : L’adhésion est résiliée' );
        */


        -- le mandat dans le futur non synchronisé avec le mode de paiement de l'adhésion (add_rib extranet affiliation)
        -- histo_querable existant mais histo_mandat vide
        ELSIF R_RIB_JOUR.idrib_old IS NULL AND
              R_RIB_JOUR.mandat IS NULL THEN

            P_MAJ_MANDAT (R_RIB_JOUR.idrib ,loc_code_retour);

            P_INS_journal(1,'RIB ' || TO_CHAR(R_RIB_JOUR.idrib) || ' traité : Creation de mandat de l''adhésion '|| R_RIB_JOUR.idadhesion  );

        -- Amendement de mandat : le rib futur nécessite d'amender le mandat précédent
        ELSIF R_RIB_JOUR.idrib_old IS NOT NULL AND
              R_RIB_JOUR.idrib_old <> R_RIB_JOUR.idrib AND
              R_RIB_JOUR.mandat IS NOT NULL THEN

            P_GENERER_AMENDEMENT ( iv_idrib        => R_RIB_JOUR.idrib_old
                                 , iv_clef_iban    => R_RIB_JOUR.clef_iban
                                 , iv_bban         => R_RIB_JOUR.bban
                                 , iv_BIC          => R_RIB_JOUR.bic
                                 , iv_idrib_new    => R_RIB_JOUR.idrib
                                 , ov_retour       => loc_code_retour
                                 );

            P_INS_journal(1,'RIB ' || TO_CHAR(R_RIB_JOUR.idrib) || ' traité : Amendement de mandat de l''adhésion '|| R_RIB_JOUR.idadhesion );

        END IF;

    END LOOP;

    P_INS_journal(1,'Fin PK_SEPA.P_TRAIT_RIB_JOUR');

END P_TRAIT_RIB_JOUR;

END;
/
