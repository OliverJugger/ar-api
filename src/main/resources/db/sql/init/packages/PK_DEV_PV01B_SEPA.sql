CREATE OR REPLACE PACKAGE ARTHUS."PK_DEV_PV01B_SEPA"
AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_PV01B_SEPA.sql                                       */
/* Domaine      : Trésorerie                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : TLE                                                         */
/* Création     : ???                                                         */
/* Description  : Génération des fichiers de prélèvement à la norme SEPA      */
/*============================================================================*/
/* Correction   :                                                             */
/* Auteur       : TLE                                                         */
/* Date         : 28/11/2013                                                  */
/* Commentaire  : AJOUT DE "AND  prelevement_3.NUMREMISE = i_numremise"       */
/*                et modif des jointures en INNER JOIN                        */
/*                ------------------------------------------------------------*/
/* Correction   : 03/04/2014                                                  */
/* Auteur       : TLE                                                         */
/* Date         : 03/04/2014                                                  */
/* Commentaire  : Suppression des balises commentaires à la demande d'EPAI    */
/*                                                                            */
/* ---------------------------------------------------------------------------*/
/* Correction   : 28/04/2014                                                  */
/* Auteur       : TLE                                                         */
/* Date         : 28/04/2014                                                  */
/* Commentaire  : Modification du nom de la remise dans la balise <PmtInfId>  */
/*                à la demande de HSBC:                                       */
/*               on concatene le numéro de la balise avec -F pour le lot First*/
/*               et avec -R pour le lot RCUR                                  */
/* Evolution    : MARS 2016 PHA Ajout #RS et #CT pour EPAI                    */
/*              : 30/11/2016 PHA M0005203 BIC n'est plus obligatoire          */
/*============================================================================*/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --                      -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --       ATTENTION      -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --                      -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- --       PK_DEV_PV01B_SEPA est à controler      -- -- -- -- -- --
-- -- -- -- -- --  client par client avant chaque livraison ...-- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


  FUNCTION  f_get_nom_fichier
              ( iv_fichier          IN  VARCHAR2
              , iv_bic              IN  VARCHAR2
              , iv_compte           IN  VARCHAR2
              , i_numremise         IN  INTEGER
              , id_date             IN  DATE
              , i_typesepa          IN VARCHAR2
              ) RETURN  VARCHAR2;

  FUNCTION  f_number_to_uft8
              ( in_number   IN  NUMBER
              , is_decimal  IN  VARCHAR2  DEFAULT '.'
              ) RETURN  VARCHAR2;

  FUNCTION  f_to_iso_date
              ( id_date IN  DATE
              ) RETURN  VARCHAR2;

  FUNCTION  f_varchar2_to_uft8
              ( iv_varchar2 IN  VARCHAR2
              ) RETURN  VARCHAR2;

  FUNCTION  f_get_statut
              ( iv_number IN  NUMBER
              ) RETURN  varchar2 ;

  PROCEDURE p_clob_to_file
              ( iv_path   IN  VARCHAR2
              , iv_file   IN  VARCHAR2
              , ilob_file IN  CLOB
              );

   -- Fonction ramenant le numéro de contrat du quérable en fonction du prélèvement
   FUNCTION F_NUMGAR_PRELEV(
         in_numprelev IN NUMBER DEFAULT 0 )
   RETURN NUMBER;


  FUNCTION F_NUMCLI_PRELEV(in_numprelev NUMBER) RETURN NUMBER;
  FUNCTION F_TRIM_PRELEV(in_numprelev NUMBER) RETURN VARCHAR2;
  FUNCTION F_RISK_PRELEV(in_numprelev NUMBER) RETURN VARCHAR2;

  FUNCTION f_get_motpmt(in_numprelev IN NUMBER, in_typesepa IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  PROCEDURE p_gen_prelev_bordereaux
              ( ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER   DEFAULT NULL
              , in_session          IN  NUMBER    DEFAULT 1
              , in_niv_msg          IN  NUMBER    DEFAULT 1
              , in_idligne          IN  NUMBER    DEFAULT 0
              , iv_repertoire       IN  VARCHAR2  DEFAULT 'EXPORT'
              , iv_fichier          IN  VARCHAR2  DEFAULT NULL
              , iv_regenerable      IN  VARCHAR2  DEFAULT 'true'
              , iv_btch_bookg       IN  VARCHAR2  DEFAULT 'false'
              , in_param_HSBC       IN  NUMBER  DEFAULT 0
              , on_found            OUT NUMBER
              , ov_erreur           OUT VARCHAR2
              );

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_DEV_PV01B_SEPA AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_PV01B_SEPA.sql                                       */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : TLE                                                         */
/* Création     : Octobre 2013                                                */
/* Description  : Génération des fichiers de prélèvement à la norme SEPA      */
/*============================================================================*/
/* Evolution    : /                                                           */
/* Auteur       : /                                                           */
/* Date         : /                                                           */
/* Commentaire  : /                                                           */
/*============================================================================*/



-- =============================================================================
-- DECLARATION DES PROCEDURES PRIVEES
-- ==============================================================================
   PROCEDURE p_ins_journal;

   -- Variables de sortie
      g_numremise                 NUMBER (7);


	-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE  DEFAULT 'pk_pv01B_SEPA';
   g_msg_adm                   journal_adm.msg_adm%TYPE;   -- ajout du paramêtre en entrée de la procédure
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE:= 1; -- ajout du paramêtre en entrée de la procédure
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;



-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
---------------------- Fin des variables globales privees --



  --Variables <PK_TRACE.P_INS_journal_adm>
  gv_nom_traitement CONSTANT  journal_adm.nom_traitement%TYPE DEFAULT 'PK_DEV_PV01B_SEPA';



  -- ==========================================================================================
  -- FONCTION f_get_nom_fichier
  -- Renvoyer le nom fichier de prelevement...
  -- Si {iv_fichier} est vide  Alors Prelevement_{iv_bic}_{id_date[YYYYMMDDHHMISS]}.xml
  --                           Sinon {iv_fichier}_{id_date [YYYYMMDDHHMISS]}.xml
  -- ==========================================================================================
  FUNCTION  f_get_nom_fichier
              ( iv_fichier          IN  VARCHAR2
              , iv_bic              IN  VARCHAR2
              , iv_compte           IN  VARCHAR2   --  TLE REMETTRE EN COMMENTAIRE
              , i_numremise         IN  INTEGER
              , id_date             IN  DATE
              ,i_typesepa           IN VARCHAR2
              ) RETURN  VARCHAR2
  IS
    v_date    VARCHAR2(1024):=NULL;
    v_fichier VARCHAR2(1024):=NULL;
  BEGIN
    v_date:=TO_CHAR(id_date, 'YYMMDDHH24MISS');

    IF  iv_fichier  IS NULL THEN
                              v_fichier :='P'||'_'||iv_bic||'_'||v_date;
     ELSE

      /*SELECT REPLACE (REPLACE (REPLACE (REPLACE (iv_fichier, '#DT', v_date),
                                        '#HR',
                                        REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
                                       ),
                               '#BQE',
                               TO_CHAR (iv_compte)
                              ),
                      '#BDX',
                      i_numremise
                     )
        INTO v_fichier
        FROM DUAL;  */
        SELECT REPLACE(REPLACE (REPLACE (REPLACE (REPLACE (iv_fichier, '#DT', to_char(sysdate,'yymmddhh24mi')),
                                        '#HR',
                                        REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
                                       ),
                               '#BQE',
                               TO_CHAR (iv_compte)
                              ),
                      '#BDX',
                      i_numremise
                       ),
                      '#TYP',
                     decode(i_typesepa,'1','CORE','2','B2B')    --RKO SEPA B2B
                      )

        INTO v_fichier
        FROM DUAL;

     END IF;

    RETURN  v_fichier||'.xml';
  END f_get_nom_fichier;



  -- =============================================================================================




  -- =============================================================================================================================
  -- FONCTION f_number_to_uft8
  --Convertir {in_number} au format utf8...
  --Le montant est exprimé en chiffres sans virgule, espace, autre signe ou lettre.
  --Le séparateur des décimales est représenté par un point.
  --Il n'est pas obligatoire de renseigner les décimales non significatives (par exemple 100000.00 peut être renseigné par 100000)
  --5 décimales maximum après le point
  --La longueur maximale d'un montant est de 18 caractères (séparateur de décimale compris)
  --Le nombre de décimale doit être compatible avec la norme ISO 4217 relative aux devises.
  --Pour les montants d'une longueur supérieure à 14 caractères avant le séparateur de décimale, le client devra impérativement
  --vérifier auprès de sa banque s'il peut être traité.
  -- ==============================================================================================================================
  FUNCTION  f_number_to_uft8
              ( in_number   IN  NUMBER
              , is_decimal  IN  VARCHAR2  DEFAULT '.'
              ) RETURN  VARCHAR2
  IS
    v_varchar2  VARCHAR2(32767);
  BEGIN
    v_varchar2:=TO_CHAR(in_number);
    v_varchar2:=REPLACE(v_varchar2, ',', is_decimal);

    RETURN  v_varchar2;
  END f_number_to_uft8;





  -- ===============================================================================================================================
  -- FUNCTION  f_to_iso_date
  -- Convertir {id_date} au format iso : YYYY-MM-DDTHH:MI:SS...
  -- ===============================================================================================================================
  FUNCTION  f_to_iso_date
              ( id_date IN  DATE
              ) RETURN  VARCHAR2
  IS
    v_date  VARCHAR2(1024);
  BEGIN
    v_date:=TO_CHAR(id_date, 'YYYYMMDDHH24:MI:SS');

    RETURN  SUBSTR(v_date, 1, 4)||'-'||SUBSTR(v_date, 5, 2)||'-'||SUBSTR(v_date, 7, 2)||'T'||SUBSTR(v_date, 9, 8);
  END f_to_iso_date;




  -- ================================================================================================================================
  --  FUNCTION  f_varchar2_to_uft8
  --Convertir {iv_varchar2} au format utf8...
  --Les caractères autorisés dans les messages ISO 20022 sont ceux de la norme UTF8. Cependant, les banques franÃ§aises se limitent au jeu de caractères latins,
  --composé de :
  --a b c d e f g h i j k l m n o p q r s t u v w x y z
  --A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  --0 1 2 3 4 5 6 7 8 9
  --/ - ? : ( ) . , ? +
  --Espace
  --
  --Néanmoins, d'autres caractères comme les caractères accentués (é, è, ê, Ã¢...) ou des caractères particuliers (@) peuvent être échangés sous réserve d'accord
  --bilatéral entre la banque et son client. Ces caractères spécifiques peuvent faire l'objet d'une convention par la banque d'exécution avant l'échange
  --interbancaire.
  --Par contre, les caractères qui ne font partie ni des caractères latins cités ci-dessus ni d'une convention avec la banque d?exécution sont des caractères
  --interdits. Il est recommandé de ne pas utiliser des caractères tels que le Â« et commercial Â» de Â« Père et Fils Â» ou Â« < Â» ou Â« > Â». L'utilisation de tels caractères peut
  --amener des rejets des messages.
  -- ================================================================================================================================
  FUNCTION  f_varchar2_to_uft8
              ( iv_varchar2 IN  VARCHAR2
              ) RETURN  VARCHAR2
  IS
    v_varchar2  VARCHAR2(32767);
  BEGIN
   -- TRANSLATE pour enlever les caractère interdits
    v_varchar2:=CONVERT(TRANSLATE(UPPER(iv_varchar2),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ&''','AAEEEEIIaaaaeeeeiiouuUUO '), 'UTF8');

    RETURN  v_varchar2;
  END f_varchar2_to_uft8;





  -- ================================================================================================================================
  --  FUNCTION  f_get_statut
  --  Convertir le statut du prélèvement au format numérique vers un boolean
  -- ================================================================================================================================
  FUNCTION  f_get_statut
              ( iv_number IN  NUMBER
              ) RETURN  varchar2
  IS
     v_retour  varchar2(5);
  BEGIN
   IF iv_number = 2 then v_retour := 'true';
      else
      v_retour := 'false';
   END IF;
    return v_retour;
  END f_get_statut;





  -- =================================================================================================
  -- PROCEDURE p_clob_to_file
  -- Ecrire les données {ilob_file} dans le fichier {iv_file} sous le répertoire Oracle {iv_path}...
  -- =================================================================================================
  PROCEDURE p_clob_to_file
              ( iv_path   IN  VARCHAR2
              , iv_file   IN  VARCHAR2
              , ilob_file IN  CLOB
              )
  IS
    i_offset      INTEGER;
    i_size_buffer INTEGER;
    i_size_lob    INTEGER;
    h_file        UTL_FILE.FILE_TYPE;
    v_buffer      VARCHAR2(32767);
  BEGIN
      i_size_lob  :=DBMS_LOB.GETLENGTH(ilob_file);
      i_offset    :=1;
      h_file      :=UTL_FILE.FOPEN(iv_path, iv_file, 'w', 32767);

      WHILE i_offset < i_size_lob LOOP
        v_buffer:=NULL;

        IF i_size_lob - (i_offset - 1) > 32767  THEN  i_size_buffer:=32767;
                                                ELSE  i_size_buffer:=i_size_lob - (i_offset - 1);
                                                END IF;

        DBMS_LOB.READ(ilob_file, i_size_buffer, i_offset, v_buffer);

        UTL_FILE.PUT(h_file, v_buffer);
        UTL_FILE.FFLUSH(h_file);

        i_offset:=i_offset + i_size_buffer;
      END LOOP;

      UTL_FILE.FCLOSE(h_file);
  END p_clob_to_file;




-- =======================================================
-- Fonction ramenant le numéro de contrat du quérable
-- en fonction du prélèvement
-- =======================================================
FUNCTION F_NUMGAR_PRELEV(in_numprelev NUMBER)
RETURN NUMBER
IS
     v_numgar NUMBER;
     v_numquerable NUMBER;
BEGIN
      SELECT distinct prelevement.numquerable, qttc_global.numgar
      INTO v_numquerable , v_numgar
      FROM prelevement
      inner join prelevement_detail on prelevement_detail.numprelev = prelevement.numprelev
      inner join qttc_global on prelevement_detail.numfact = qttc_global.numquit
      WHERE prelevement.numprelev = in_numprelev;

     RETURN v_numgar;
EXCEPTION
WHEN no_data_found THEN
     v_numgar :='';
WHEN OTHERS THEN
     v_numgar := NULL;
END F_NUMGAR_PRELEV;



-- =======================================================
-- Fonction ramenant le numéro de contrat du quérable
-- en fonction du prélèvement
-- =======================================================
FUNCTION F_ADHESION_PRELEV(in_numprelev NUMBER)
RETURN NUMBER
IS
     v_idadhesion NUMBER;
BEGIN
      SELECT distinct qttc_global.idadhesion
      INTO v_idadhesion
      FROM prelevement
      inner join prelevement_detail on prelevement_detail.numprelev = prelevement.numprelev
      inner join qttc_global on prelevement_detail.numfact = qttc_global.numquit
      WHERE prelevement.numprelev = in_numprelev;

     RETURN v_idadhesion;
EXCEPTION
WHEN no_data_found THEN
     v_idadhesion :='';
WHEN OTHERS THEN
     v_idadhesion := NULL;
END F_ADHESION_PRELEV;


-- =======================================================
-- Fonction ramenant le numéro de client
-- en fonction du prélèvement
-- =======================================================
FUNCTION F_NUMCLI_PRELEV(in_numprelev NUMBER)
RETURN NUMBER
IS
  v_numcli NUMBER;
BEGIN
  SELECT DISTINCT contrat.numcli
  INTO v_numcli
  FROM prelevement_detail
  INNER JOIN qttc_global ON prelevement_detail.numfact = qttc_global.numquit
  INNER JOIN contrat     ON contrat.numgar             = qttc_global.numgar
  WHERE prelevement_detail.numprelev = in_numprelev;

  RETURN v_numcli;

EXCEPTION
  WHEN no_data_found THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
  END F_NUMCLI_PRELEV;


-- =======================================================
-- Fonction ramenant le(s) trimestre(s)
-- en fonction du prélèvement
-- =======================================================
FUNCTION F_TRIM_PRELEV(in_numprelev NUMBER)
RETURN VARCHAR2
IS
  v_trim VARCHAR2(50);

  CURSOR C_TRIM IS
    SELECT DISTINCT
    'Trimestre ' || TO_CHAR(qttc_global.DEBUT,'Q') trimestre
    FROM  prelevement_detail
    INNER JOIN qttc_global on prelevement_detail.numfact = qttc_global.numquit
    WHERE prelevement_detail.numprelev = in_numprelev
    ORDER BY 'Trimestre ' || TO_CHAR(qttc_global.DEBUT,'Q') ;

BEGIN
  FOR R_TRIM IN C_TRIM LOOP
    IF v_trim IS NOT NULL THEN
      v_trim := v_trim || ',';
    END IF;
    v_trim := v_trim || R_TRIM.trimestre;
  END LOOP;
  RETURN v_trim;

EXCEPTION
  WHEN no_data_found THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN 'KO';
END F_TRIM_PRELEV;


-- =======================================================
-- Fonction ramenant le(s) RISQUE(s)
-- en fonction du prélèvement
-- =======================================================
FUNCTION F_RISK_PRELEV(in_numprelev NUMBER)
RETURN VARCHAR2
IS
  v_risk VARCHAR2(100);

  CURSOR C_RISK IS
    SELECT DISTINCT
      contrat.type_contrat,
      f_lble('TYP_CONT', contrat.type_contrat) librisque
    FROM  prelevement_detail
    INNER JOIN qttc_global ON prelevement_detail.numfact = qttc_global.numquit
    INNER JOIN contrat     ON contrat.numgar             =  qttc_global.numgar
    WHERE prelevement_detail.numprelev = in_numprelev
    ORDER BY contrat.type_contrat
    ;


BEGIN
  FOR R_RISK IN C_RISK LOOP
    IF v_risk IS NOT NULL THEN
      v_risk := v_risk || ',';
    END IF;
    v_risk := v_risk || R_RISK.librisque;
  END LOOP;
  RETURN v_risk;

EXCEPTION
  WHEN no_data_found THEN
       v_risk := NULL;
  WHEN OTHERS THEN
       v_risk := NULL;
END F_RISK_PRELEV;




  -- =================================================================================================
--Renvoyer le motif de paiement associé au prelevement en passant par la table
-- LIBELLE
-- Ce dernier comprendra si possible les factures et les bénéficaires autre que
-- l'assuré
  -- =================================================================================================
FUNCTION f_get_motpmt(
      in_numprelev IN NUMBER
     ,in_typesepa  IN VARCHAR2 DEFAULT NULL)
   RETURN VARCHAR2
IS
   v_motif_de_paiement VARCHAR2(32767) :=NULL ;
   v_numquerable       NUMBER(10);
   v_querable          VARCHAR2(32767) :=NULL;
   v_codope            NUMBER          :=0;
   v_num_contrat       NUMBER(10)      :=0;
   v_lib_recherche     VARCHAR2(255)   := NULL;

-- Encaismt cotisation MCD : #QUER #CONT #ADHES
BEGIN
   BEGIN
      SELECT libelle
      INTO v_motif_de_paiement
      FROM libelle
      WHERE mnemo = 'SEPAMOTPMT'
      AND code    =
         ( SELECT DISTINCT codope
         FROM prelevement_detail
         INNER JOIN prelevement
         ON prelevement.numprelev           = prelevement_detail.numprelev
         WHERE prelevement_detail.numprelev = in_numprelev
         )
      AND sens = NVL(in_typesepa,1);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      v_motif_de_paiement := NULL;
   WHEN TOO_MANY_ROWS THEN
      v_motif_de_paiement := 'Plusieurs libellés du motif de paiement trouvés';
   WHEN OTHERS THEN
      RETURN 'Libelle du motif de paiement non trouvé' ;
   END;

   BEGIN

      -- si le motif de paiement de la table libelle contient le paramêtre #RS
      IF INSTR(v_motif_de_paiement, '#RS' ) <> 0 THEN
         v_lib_recherche := null;

         SELECT nom
         INTO v_lib_recherche
         FROM societe ;

         v_motif_de_paiement        := REPLACE(v_motif_de_paiement, '#RS', v_lib_recherche);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#RS','');
      END IF;
      IF v_lib_recherche IS NULL THEN
         v_lib_recherche := REPLACE(v_motif_de_paiement, '#RS','');
      END IF;

      -- si le motif de paiement de la table libelle contient le paramêtre #CT
      IF INSTR(v_motif_de_paiement, '#CT' ) <> 0 THEN
         v_lib_recherche := null;
         v_num_contrat := F_NUMGAR_PRELEV(in_numprelev);
         SELECT refcie
         INTO v_lib_recherche
         FROM contrat WHERE numgar = v_num_contrat;
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#CT', v_lib_recherche);
       ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#CT','');
      END IF;
      IF v_lib_recherche IS NULL THEN
         v_lib_recherche := REPLACE(v_motif_de_paiement, '#CT','');
      END IF;


      -- si le motif de paiement de la table libelle contient le paramêtre #QUER
      IF INSTR(v_motif_de_paiement, '#QUER' ) <> 0 THEN
         -- CODOPE = 4 POUR LES PRELEVEMENTS
         SELECT prelevement.numquerable
         INTO v_numquerable
         FROM prelevement
         WHERE prelevement.numprelev = in_numprelev;

         v_motif_de_paiement        := REPLACE(v_motif_de_paiement, '#QUER', v_numquerable);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#QUER','');
      END IF;

      IF v_numquerable IS NULL THEN
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#QUER','');
      END IF;

      -- si le motif de paiement de la table libelle contient le paramêtre #LQUE
      IF INSTR(v_motif_de_paiement, '#LQUE' ) <> 0 THEN
         -- CODOPE = 4 POUR LES PRELEVEMENTS
         SELECT prelevement.numquerable
         INTO v_numquerable
         FROM prelevement
         WHERE prelevement.numprelev = in_numprelev;

         v_motif_de_paiement        := REPLACE(v_motif_de_paiement, '#LQUE', 'N0:' || v_numquerable);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LQUE','');
      END IF;

      IF v_numquerable IS NULL THEN
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LQUE','');
      END IF;

      -- si le motif de paiement de la table libelle contient le paramêtre #CONT
      IF INSTR(v_motif_de_paiement, '#CONT' ) <> 0 THEN
         v_num_contrat := F_NUMGAR_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#CONT',v_num_contrat);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#CONT','');
      END IF;
      IF v_num_contrat IS NULL THEN
         v_num_contrat := REPLACE(v_motif_de_paiement, '#CONT','');
      END IF;

	   -- si le motif de paiement de la table libelle contient le paramêtre #LCON
      IF INSTR(v_motif_de_paiement, '#LCON' ) <> 0 THEN
         v_num_contrat := F_NUMGAR_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LCON','- CONTRAT N0 : ' ||  v_num_contrat);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LCON','');
      END IF;
      IF v_num_contrat IS NULL THEN
         v_num_contrat := REPLACE(v_motif_de_paiement, '#LCON','');
      END IF;

      -- si le motif de paiement de la table libelle contient le paramêtre #ADHES
      IF INSTR(v_motif_de_paiement, '#ADHES' ) <> 0 THEN
         v_num_contrat := F_ADHESION_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#ADHES', v_num_contrat);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#ADHES','');
      END IF;
      IF v_num_contrat IS NULL THEN
         v_num_contrat := REPLACE(v_motif_de_paiement, '#ADHES','');
      END IF;

	  -- si le motif de paiement de la table libelle contient le paramêtre #LADHE
      IF INSTR(v_motif_de_paiement, '#LADHE' ) <> 0 THEN
         v_num_contrat := F_ADHESION_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LADHE','- ADHESION N0 : ' ||  v_num_contrat);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#LADHE','');
      END IF;
      IF v_num_contrat IS NULL THEN
         v_num_contrat := REPLACE(v_motif_de_paiement, '#LADHE','');
      END IF;


   -- si le motif de paiement de la table libelle contient le paramêtre #NUMCLI
      IF INSTR(v_motif_de_paiement, '#NUMCLI' ) <> 0 THEN
         v_lib_recherche := F_NUMCLI_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#NUMCLI',  v_lib_recherche);
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#NUMCLI','');
      END IF;

   -- si le motif de paiement de la table libelle contient le paramêtre #RISK
      IF INSTR(v_motif_de_paiement, '#RISK' ) <> 0 THEN
         v_lib_recherche := F_RISK_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#RISK', v_lib_recherche);
       ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#RISK','');
      END IF;

   -- si le motif de paiement de la table libelle contient le paramêtre #TRIM
      IF INSTR(v_motif_de_paiement, '#TRIM' ) <> 0 THEN
         v_lib_recherche := F_TRIM_PRELEV(in_numprelev);
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#TRIM', v_lib_recherche);
       ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#TRIM','');
      END IF;


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      v_motif_de_paiement := NULL;
   WHEN TOO_MANY_ROWS THEN
      v_motif_de_paiement := 'Problème lors de la récupération du quérable ou de l''adhésion';
   WHEN OTHERS THEN
      RETURN 'Libelle du motif de paiement non trouvé' ;
   END;

   RETURN v_motif_de_paiement;

EXCEPTION
WHEN OTHERS THEN
   RETURN 'Libelle du motif de paiement non trouvé' ;
END f_get_motpmt;



  -- =========================================================================================================================================
  -- PROCEDURE p_generer_prelevements_bordereaux
  -- Générer des fichiers de prélèvement à la norme SEPA pour la plage des bordereaux [{ii_numremise_debut};{ii_numremise_fin}]...
  -- Les fichiers de prélèvement seront nommés selon {f_get_nom_fichier({iv_fichier}...} comme suite sous le répertoire Oracle {iv_repertoire}
  -- A VOIR TLE
  -- Chaque nupplet {bic}x{emetteur} aura son fichier de prélèvement
  -- Chaque fichier de prelevement regroupera des lots de prelevement (équivalent à la notion de bordereaux de prelevement Arthus)
  --
  -- Les comptes SEPA à débiter et les comptes SEPA à créditer sont des comptes pour lesquels leurs bic et iban sont connus
  --
  -- Avec,
  --  {in_session}      : Session à tracer
  --
  --  {i_niv_msg}       :
  --    0       <>  Message d'erreurs Oracle
  --    1       <>  Message informatif
  --    2 et +  <>  Niveau de detail
  --
  --  {iv_regenerable}  :
  --    'false' <>  Ne pas autoriser la regénération des fichiers de prelevement
  --    'true'  <>  Autoriser la regénération des fichiers de prelevement
  --
  --  {iv_btch_bookg}   :
  --    'false' <>  Mode à positionner lorsque l'émetteur souhaite que sa banque effectue un débit par prelevement
  --    'true'  <>  Mode à positionner lorsque l'émetteur souhaite que sa banque effectue un débit global par lot de prelevement
  --
  --  {on_found}        : Nb. de bordereaux de prelevement traités
  --  {ov_erreur}       : Message d'erreur (Vide sinon)
  -- ===========================================================================================================================================
  PROCEDURE p_gen_prelev_bordereaux
              ( ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER   DEFAULT NULL
              , in_session          IN  NUMBER    DEFAULT 1
              , in_niv_msg          IN  NUMBER    DEFAULT 1
              , in_idligne          IN  NUMBER    DEFAULT 0
              , iv_repertoire       IN  VARCHAR2  DEFAULT 'EXPORT'
              , iv_fichier          IN  VARCHAR2  DEFAULT NULL
              , iv_regenerable      IN  VARCHAR2  DEFAULT 'true'
              , iv_btch_bookg       IN  VARCHAR2  DEFAULT 'false'
              , in_param_HSBC       IN  NUMBER  DEFAULT 0
              , on_found            OUT NUMBER
              , ov_erreur           OUT VARCHAR2
              )
  IS

    CURSOR  cur_fichiers_prelevements
      ( i_numremise  IN  INTEGER
      , iv_fichier          IN  VARCHAR2
      , id_date             IN  DATE
      , iv_date             IN  VARCHAR2
      , iv_regenerable      IN  VARCHAR2
      , iv_btch_bookg       IN  VARCHAR2
      , iv_presence_mandat_first in number
      , iv_presence_mandat_recur in number
      , loc_F               IN VARCHAR2
      , loc_R               IN VARCHAR2
      )
    IS
      SELECT    f_get_nom_fichier
                  ( iv_fichier
                  , compte_1.bic
                  , compte_1.numcpte
                  , i_numremise
                  , id_date
                  , remise_prelev.typesepa
                  ) v_file
      ,         XMLROOT
                  ( XMLELEMENT
                      ( "Document", XMLATTRIBUTES('urn:iso:std:iso:20022:tech:xsd:pain.008.001.02' AS "xmlns")   -- DEBUT D ECRITURE DE L ENTETE
                      , XMLELEMENT
                          ( "CstmrDrctDbtInitn"
                          --, (SELECT XMLComment('DEBUT D ECRITURE DE L ENTETE') AS cmnt FROM DUAL )
                          , XMLELEMENT
                              ( "GrpHdr"
                              , XMLFOREST(f_varchar2_to_uft8(f_get_nom_fichier( iv_fichier
                                                           , compte_1.bic
                                                           , compte_1.emetteur
                                                           , i_numremise
                                                           , id_date
                                                           , remise_prelev.typesepa
                                                           )) AS "MsgId")
                              , XMLFOREST(f_varchar2_to_uft8(iv_date) AS "CreDtTm")
                              , ( SELECT  XMLAGG
                                            ( XMLCONCAT( XMLFOREST(f_number_to_uft8(count(prelevement.numremise)) as "NbOfTxs")
                                                       , XMLFOREST(f_number_to_uft8(SUM(prelevement.montant)) as "CtrlSum")
                                                       )
                                             )
                                   FROM COMPTE
                                   INNER JOIN REMISE_PRELEV ON COMPTE.NUMCPTE = REMISE_PRELEV.NUMCPTE
                                   INNER JOIN PRELEVEMENT   ON REMISE_PRELEV.NUMREMISE = PRELEVEMENT.NUMREMISE
                                   WHERE COMPTE.BIC = compte_1.bic
                                   AND   compte.emetteur               =       compte_1.emetteur
                                   AND   compte.clef_iban              IS      NOT NULL
                                   AND   compte.bban                   IS      NOT NULL
                                   AND   PRELEVEMENT.numremise = i_numremise
                                   AND   DECODE(iv_regenerable, 'true', 'ok', DECODE(REMISE_PRELEV.datdisk, NULL, 'ok', 'ko'))='ok'
                                   AND pk_sepa.f_ctrl_donnee_iban(PRELEVEMENT.clef_iban, PRELEVEMENT.bban, PRELEVEMENT.bic) = 1
                                   AND NOT EXISTS (
                                                  SELECT 1
                                                    FROM annul_encais
                                                    WHERE annul_encais.numencaismt =
                                                                           prelevement.numencaismt)
                                   GROUP BY  --compte.bic
                                            compte.emetteur
                                 )
                                 , XMLELEMENT( "InitgPty"
                                                      , XMLFOREST(f_varchar2_to_uft8(compte_1.rais_soc) AS "Nm")
                                             )
                              )  --fin GrpHdr  -- FIN D ECRITURE DE L ENTETE
                             -- , (SELECT XMLComment('FIN D ECRITURE DE L ENTETE') AS cmnt FROM DUAL )
-- PAYMENT INFORMATION FRST
                         --, (SELECT XMLComment('DEBUT D ECRITURE PAYMENT INFORMATION FRST') AS cmnt FROM DUAL )
                         , (select DECODE(iv_presence_mandat_first, 0, null
																			 ,( SELECT  XMLAGG
																				   (XMLELEMENT("PmtInf", XMLFOREST((f_varchar2_to_uft8(remise_prelev_2.numremise) || loc_F) as "PmtInfId")    -- TLE - 28/04/2014 - DISTINCTION REMISES FIRST ET RCUR - DEMANDE BANQUE GEREP
																																	, XMLFOREST('DD' as "PmtMtd")
																																	, XMLFOREST(iv_btch_bookg as "BtchBookg")
																																	,( SELECT  XMLAGG
																																		( XMLCONCAT( XMLFOREST(f_number_to_uft8(count(prelevement.numremise)) as "NbOfTxs")
																																				   , XMLFOREST(f_number_to_uft8(SUM(prelevement.montant)) as "CtrlSum")
																																				   )
																																		 )
																																		 FROM COMPTE
																																		 INNER JOIN REMISE_PRELEV ON COMPTE.NUMCPTE = REMISE_PRELEV.NUMCPTE
																																		 INNER JOIN PRELEVEMENT   ON REMISE_PRELEV.NUMREMISE = PRELEVEMENT.NUMREMISE
																																		 WHERE COMPTE.BIC = compte_1.bic
																																		 AND   compte.emetteur               =       compte_1.emetteur
																																		 AND   compte.clef_iban              IS      NOT NULL
																																		 AND   compte.bban                   IS      NOT NULL
																																		 AND   PRELEVEMENT.numremise = i_numremise
																																		 AND   DECODE(iv_regenerable, 'true', 'ok', DECODE(REMISE_PRELEV.datdisk, NULL, 'ok', 'ko'))='ok'
																																		 AND pk_sepa.f_ctrl_donnee_iban(PRELEVEMENT.clef_iban, PRELEVEMENT.bban, PRELEVEMENT.bic) = 1
																																		 AND   PRELEVEMENT.mvt = 'FRST'
																																		 AND NOT EXISTS (
																																			  SELECT 1
																																				FROM annul_encais
																																				WHERE annul_encais.numencaismt =
																																									   prelevement.numencaismt)
																																		 GROUP BY  --compte.bic
																																		           compte.emetteur
																																	 ) --Un bordereau ayant 1 et 1 seul compte, on peut donc regrouper uniquement par bordereau pour les agregats <NbOfTxs> et <CtrlSum>
																																	, XMLELEMENT("PmtTpInf"
																																				 , XMLELEMENT ("SvcLvl"
																																									 , XMLFOREST('SEPA' AS "Cd")
																																							   )
																																				 , XMLELEMENT ("LclInstrm"
																																									 , XMLFOREST(decode(remise_prelev_2.typesepa,1, 'CORE',2,'B2B') AS "Cd")
																																							   )
																																				 , XMLFOREST ('FRST' as "SeqTp" )
																																				 /*, XMLELEMENT ("CtgyPurp"
																																										, XMLFOREST('CODE' AS "Cd")  -- TODO FACULTATIF
																																							  )    */
																																				)  -- FIN PmtTpInf
                                                                   -- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*
																																	--, XMLFOREST(to_char((to_date(remise_prelev_2.eche_prelev||'2013','ddmmyyyy')), 'YYYY-MM-DD') as "ReqdColltnDt")   -- TODO : A REVOIR IMPERATIVEMENT
                                                                                                   , XMLFOREST(to_char((to_date(remise_prelev_2.eche_prelev_sepa,'ddmmyyyy')), 'YYYY-MM-DD') as "ReqdColltnDt")
                                                                   -- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*
																																	, XMLELEMENT ("Cdtr"
																																						 , XMLFOREST(f_varchar2_to_uft8(compte_2.rais_soc) AS "Nm")
																																				   ) -- FIN Cdtr
																																	, XMLELEMENT
																																			  ( "CdtrAcct"
																																					, XMLELEMENT
																																							 ( "Id"
																																								  , XMLFOREST(f_varchar2_to_uft8(compte_2.clef_iban||compte_2.bban) AS "IBAN")
																																							 ) -- Fin Id
																																					 --,  XMLFOREST( f_varchar2_to_uft8(compte_2.monnaie)AS "Ccy")
																																			  ) -- Fin CdtrAcct
																																	 , XMLELEMENT ("CdtrAgt"
																																						, XMLELEMENT("FinInstnId"
																																									   , XMLFOREST(f_varchar2_to_uft8(compte_2.bic) AS "BIC")
																																									 )
																																				   )  -- FIN CdtrAgt
																																	  /*, XMLELEMENT ("UltmtCdtr"   -- ne figure pas dans le fichier exemple
																																						 , XMLFOREST(('Nom du creantier d origine') AS "Nm")
																																						 , XMLELEMENT("Id"
																																									   ,XMLFOREST('OrgId' AS "OrgId"))
																																				   )  -- FIN UltmtCdtr
																																	 */
																																	 , XMLFOREST('SLEV' AS "ChrgBr")
																																	 , XMLELEMENT ("CdtrSchmeId"
																																						, XMLELEMENT("Id"
																																									  , XMLELEMENT("PrvtId"
																																													   , XMLELEMENT("Othr"
																																																	, XMLFOREST( f_varchar2_to_uft8(compte_2.ICS) AS "Id")
																																																	, XMLELEMENT("SchmeNm"
																																																						 ,XMLFOREST(f_varchar2_to_uft8('SEPA') AS "Prtry")
																																																				 ) -- Fin SchmeNm
																																																   )  -- Fin Othr
																																												  ) -- Fin PrvId
																																									) -- Fin Id
																																				   ) -- FIN CdtrSchemeId
																							-- DIRECT DEBIT FRST
																																	 --, (SELECT XMLComment('DEBUT D ECRITURE DIRECT DEBIT FRST') AS cmnt FROM DUAL )
                                                                     ,( SELECT  XMLAGG
																								(XMLELEMENT ("DrctDbtTxInf"
																										 , XMLELEMENT("PmtId"
																													 , XMLFOREST(f_varchar2_to_uft8('Prelevement SEPA'||' No '|| prelevement_3.numprelev)  AS "InstrId")
																													 , XMLFOREST(f_varchar2_to_uft8('REF - ' || prelevement_3.numprelev ) AS "EndToEndId")
																													 )  -- Fin PmyId
																										 , ( SELECT    XMLAGG
																															  ( XMLELEMENT
																																  ( "InstdAmt"
																																  , XMLATTRIBUTES(f_varchar2_to_uft8(pk_devise.symbole(prelevement_3.monnaie_d)) AS "Ccy")
																																  , f_number_to_uft8(SUM(prelevement.montant_d))
																																  )
																															  )
																												  FROM      prelevement
																												  WHERE     prelevement.numremise  = remise_prelev_2.numremise
																												  AND       prelevement.numprelev = prelevement_3.numprelev
																												  GROUP BY  prelevement.numremise
																												  ,         prelevement.numprelev
																											)
																										 , XMLELEMENT("DrctDbtTx"
																													 , XMLELEMENT("MndtRltdInf"
																																  , XMLFOREST(f_varchar2_to_uft8(prelevement_3.MANDAT) AS "MndtId")
																																  , XMLFOREST(prelevement_3.create_mandat AS "DtOfSgntr")
																																  , XMLFOREST(f_get_statut(prelevement_3.STATUT) AS "AmdmntInd")
																																  , DECODE(f_get_statut(prelevement_3.STATUT),'false',null, XMLELEMENT ("AmdmntInfDtls",
                                                                                                                                                        DECODE(prelevement_3.amdt_mndt, null, null, XMLFOREST(prelevement_3.amdt_mndt AS "OrgnlMndtId"))
                                                                                                                                                      , DECODE(prelevement_3.amdt_ics,  null, null, XMLELEMENT("OrgnlCdtrSchmeId"
                                                                                                                                                                                                                                , DECODE(prelevement_3.amdt_creancier, null, null, XMLFOREST(prelevement_3.amdt_creancier AS "Nm"))
                                                                                                                                                                                                                                , DECODE(prelevement_3.amdt_ics,null,null, XMLELEMENT("Id"
                                                                                                                                                                                                                                                                                         , XMLELEMENT("PrvtId"
                                                                                                                                                                                                                                                                                                            , XMLELEMENT("Othr"
                                                                                                                                                                                                                                                                                                                              , XMLFOREST(prelevement_3.amdt_ics AS "Id")
                                                                                                                                                                                                                                                                                                                              , XMLELEMENT("SchmeNm"
                                                                                                                                                                                                                                                                                                                                                    , XMLFOREST('SEPA' AS "Prtry")
                                                                                                                                                                                                                                                                                                                                          ) -- Fin SchmeNm
                                                                                                                                                                                                                                                                                                                        ) -- Fin Othr
                                                                                                                                                                                                                                                                                                      ) --Fin PrvtId
                                                                                                                                                                                                                                                                                       ) -- Fin Id
                                                                                                                                                                                                                                          )
                                                                                                                                                                                                                 )
                                                                                                                                                            ) -- Fin decode OrgnlCdtrSchmeId
                                                                                                                                                       , DECODE(prelevement_3.amdt_acct , NULL, null,XMLELEMENT("OrgnlDbtrAcct"
                                                                                                                                                                                                                              , DECODE(prelevement_3.amdt_acct,null,null,XMLELEMENT("Id"
                                                                                                                                                                                                                                                                                        , XMLFOREST(prelevement_3.amdt_acct AS "IBAN")
                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                       )

                                                                                                                                                                                                              )
                                                                                                                                                              ) -- Fin decode OrgnlDbtrAcct
                                                                                                                                                      , DECODE( prelevement_3.amdt_smnda, NULL,null, XMLELEMENT("OrgnlDbtrAgt"
                                                                                                                                                                                                                                    , XMLELEMENT("FinInstnId"
                                                                                                                                                                                                                                                          , XMLELEMENT("Othr"
                                                                                                                                                                                                                                                                            , XMLFOREST('SMNDA' AS "Id")
                                                                                                                                                                                                                                                                      ) -- Fin Othr
                                                                                                                                                                                                                                                 ) -- Fin FinlnstnId
                                                                                                                                                                                                                          )
                                                                                                                                                              ) -- Fin decode OrgnlDbtrAgt

																																																		) -- Fin SELECT XMLELEMENT ("AmdmntInfDtls"
																																		) -- Fin AmdmntInfDtls
																																	) -- Fin MndtRltdInf
																													)  -- Fin DrctDbtTx
																													 /*, XMLELEMENT("UltmtCdtr"                                   -- TODO : VOIR PLUS TARD
																																 , XMLforest('Nom creancier origine' AS "Nm")
																																 , XMLELEMENT( "Id"
																																				, XMLFOREST('Organisation identification' AS "OrgId")
																																			 ) -- Fin Id
																																 ) -- FIN UltmtCdtr
																													 */
																																						 , XMLELEMENT("DbtrAgt"
																																									 , XMLELEMENT("FinInstnId"
																																												  , XMLFOREST(prelevement_3.BIC AS "BIC")
																																												  ) -- Fin FinInstnId
																																									 ) -- FIN DbtrAgt
																																						 , XMLELEMENT("Dbtr"
																																									 , XMLFOREST(f_varchar2_to_uft8(prelevement_3.intitule) AS "Nm")
																																									 , XMLELEMENT( "Id"
																																														 , XMLELEMENT("OrgId"
																																																		 , XMLELEMENT("Othr"
																																																					, XMLFOREST(prelevement_3.NUMQUERABLE AS "Id")
																																																					  )
																																																	  )
																																												 )-- Fin id
																																									 ) -- FIN Dbtr
																																						  , XMLELEMENT("DbtrAcct"
																																									 , XMLELEMENT("Id"
																																												  , XMLFOREST(f_varchar2_to_uft8(prelevement_3.clef_iban||prelevement_3.bban) AS "IBAN")
																																												  )-- Fin id

																																									 ) -- FIN DbtrAcct
																																						 /* , XMLELEMENT("UltmtDbtr"   -- Pas de tierce partie
																																											 , XMLFOREST('Nm' AS "Nm")
																																											 , XMLELEMENT("Id"
																																														 , XMLFOREST('OrgId' AS "OrgId")
																																														 ) -- Fin id
																																									  ) -- FIN UltmtDbtr     */
																																						  /* , XMLELEMENT("Purp"
																																											 , XMLFOREST('Cd' AS "Cd")
																																									   ) -- FIN Purp
																																						   , XMLELEMENT("RgltryRptg"
																																											 , XMLELEMENT("Dtls"
																																														 , XMLFOREST('Cd' AS "Cd")
																																														 ) -- Fin Dtls
																																									   ) -- FIN RgltryRptg*/
                                                                                                                     ,  XMLELEMENT("RmtInf"
																																												 , XMLFOREST(f_varchar2_to_uft8(SUBSTR(f_get_motpmt(prelevement_3.numprelev,remise_prelev.typesepa), 1, 140)) AS "Ustrd")
																																												 /*, XMLELEMENT("Strd"
																																															 , XMLELEMENT("CdtrRefInf"
																																																		  , XMLELEMENT("Tp"
																																																					   , XMLELEMENT("CdOrPrtry"
																																																									, XMLFOREST('SCOR' AS "Cd")
																																																									) -- Fin CdOrPrtry
																																																					  ) -- Fin Tp
																																																		  ) -- Fin CdtrRefInf
																																															)*/ -- Fin Strd
																																									   ) -- Fin RmtInf
																																						--, (SELECT XMLComment('FIN D ECRITURE DIRECT DEBIT FIRST') AS cmnt FROM DUAL )
																																						 )  -- FIN DrctDbtTxInf
																							-- FIN DIRECT DEBIT FIRST
																																						 )
																																			FROM prelevement  prelevement_3
																																			INNER JOIN remise_prelev remise_prelev_3 ON prelevement_3.numremise = remise_prelev_3.numremise
																																			WHERE --prelevement_3.bic        IS  NOT NULL AND
                                                                            prelevement_3.clef_iban  IS  NOT NULL
																																			AND   prelevement_3.bban       IS  NOT NULL
																																			AND   prelevement_3.MVT='FRST'
                                                                                                         AND  prelevement_3.NUMREMISE = i_numremise
																																			AND NOT EXISTS (
                                                                                                                          SELECT 1
                                                                                                                           FROM annul_encais
                                                                                                                           WHERE annul_encais.numencaismt =
                                                                                                                           prelevement_3.numencaismt)
																																		 ) -- fin SELECT  XMLAGG
																								)  -- FIN ("PmtInf"
																				 ) -- FIN XMLELEMENT("PmtInf"
																			 FROM    compte  compte_2
																			 INNER JOIN    remise_prelev remise_prelev_2 ON remise_prelev_2.numcpte=compte_2.numcpte
																			 WHERE   compte_2.bic            =       compte_1.bic
																			 AND     compte_2.emetteur       =       compte_1.emetteur
																			 AND     compte_2.clef_iban      IS      NOT NULL
																			 AND     compte_2.bban           IS      NOT NULL
																			 AND     remise_prelev_2.numremise = i_numremise
																			 AND     DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_prelev_2.datdisk, NULL, 'ok', 'ko'))='ok'
																			  ) -- fin ( SELECT  XMLAGG
                                    ) -- FIN DECODE
                                 FROM DUAL
                              ) -- FIN SELECT DECODE
                        --, (SELECT XMLComment('FIN D ECRITURE LOT FIRST') AS cmnt FROM DUAL )
-- FIN LOT FIRST
-- PAYMENT INFORMATION RCUR
                  --, (SELECT XMLComment('DEBUT D ECRITURE PAYMENT INFORMATION RCUR') AS cmnt FROM DUAL )
                      , (select DECODE(iv_presence_mandat_recur, 0, null
                         ,( SELECT  XMLAGG
                              (XMLELEMENT("PmtInf"
                                        , XMLFOREST((f_varchar2_to_uft8(remise_prelev_2.numremise) || loc_R) as "PmtInfId")     -- TLE - 28/04/2014 - DISTINCTION REMISES FIRST ET RCUR - DEMANDE BANQUE GEREP
                                        , XMLFOREST('DD' as "PmtMtd")
                                        , XMLFOREST(iv_btch_bookg as "BtchBookg")
                                        ,( SELECT  XMLAGG
                                            ( XMLCONCAT( XMLFOREST(f_number_to_uft8(count(prelevement.numremise)) as "NbOfTxs")
                                                       , XMLFOREST(f_number_to_uft8(SUM(prelevement.montant)) as "CtrlSum")
                                                       )
                                             )
                                             FROM COMPTE
                                             INNER JOIN REMISE_PRELEV ON COMPTE.NUMCPTE = REMISE_PRELEV.NUMCPTE
                                             INNER JOIN PRELEVEMENT   ON REMISE_PRELEV.NUMREMISE = PRELEVEMENT.NUMREMISE
                                             WHERE COMPTE.BIC = compte_1.bic
                                             AND   compte.emetteur               =       compte_1.emetteur
                                             AND   compte.clef_iban              IS      NOT NULL
                                             AND   compte.bban                   IS      NOT NULL
                                             AND   PRELEVEMENT.numremise = i_numremise
                                             AND   DECODE(iv_regenerable, 'true', 'ok', DECODE(REMISE_PRELEV.datdisk, NULL, 'ok', 'ko'))='ok'
                                             AND pk_sepa.f_ctrl_donnee_iban(PRELEVEMENT.clef_iban, PRELEVEMENT.bban, PRELEVEMENT.bic) = 1
                                             AND   PRELEVEMENT.mvt = 'RCUR'
                                             AND NOT EXISTS (
                                                  SELECT 1
                                                    FROM annul_encais
                                                    WHERE annul_encais.numencaismt =
                                                                           prelevement.numencaismt)
                                             GROUP BY --compte.bic
                                                       compte.emetteur
                                         ) --Un bordereau ayant 1 et 1 seul compte, on peut donc regrouper uniquement par bordereau pour les agregats <NbOfTxs> et <CtrlSum>
                                        , XMLELEMENT("PmtTpInf"
                                                     , XMLELEMENT ("SvcLvl"
                                                                         , XMLFOREST('SEPA' AS "Cd")
                                                                   )
                                                     , XMLELEMENT ("LclInstrm"
                                                                         , XMLFOREST(decode(remise_prelev_2.typesepa,1, 'CORE',2,'B2B') AS "Cd")
                                                                   )
                                                     , XMLFOREST ('RCUR' as "SeqTp" )
                                                     /*, XMLELEMENT ("CtgyPurp"
                                                                            , XMLFOREST('CODE' AS "Cd")  -- TODO FACULTATIF
                                                                  )    */
                                                     )  -- FIN PmtTpInf
                                          -- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*
                                          --, XMLFOREST(to_char((to_date(remise_prelev_2.eche_prelev||'2013','ddmmyyyy')), 'YYYY-MM-DD') as "ReqdColltnDt")   -- TODO : A REVOIR IMPERATIVEMENT
                                          , XMLFOREST(to_char((to_date(remise_prelev_2.eche_prelev_sepa,'ddmmyyyy')), 'YYYY-MM-DD') as "ReqdColltnDt")
                                           -- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*
                                        , XMLELEMENT ("Cdtr"
                                                             , XMLFOREST(f_varchar2_to_uft8(compte_2.rais_soc) AS "Nm")
                                                       ) -- FIN Cdtr
                                        , XMLELEMENT
                                                  ( "CdtrAcct"
                                                        , XMLELEMENT
                                                                 ( "Id"
                                                                      , XMLFOREST(f_varchar2_to_uft8(compte_2.clef_iban||compte_2.bban) AS "IBAN")
                                                                 ) -- Fin Id
                                                         --,  XMLFOREST( f_varchar2_to_uft8(compte_2.monnaie)AS "Ccy")
                                                  ) -- Fin CdtrAcct
                                         , XMLELEMENT ("CdtrAgt"
                                                            , XMLELEMENT("FinInstnId"
                                                                           , XMLFOREST(f_varchar2_to_uft8(compte_2.bic) AS "BIC")
                                                                         )
                                                       )  -- FIN CdtrAgt
                                          /*, XMLELEMENT ("UltmtCdtr"
                                                             , XMLFOREST(('Nom du creantier d origine') AS "Nm")
                                                             , XMLELEMENT("Id"
                                                                           ,XMLFOREST('OrgId' AS "OrgId"))
                                                       )  -- FIN UltmtCdtr
                                         */
                                         , XMLFOREST('SLEV' AS "ChrgBr")
                                         , XMLELEMENT ("CdtrSchmeId"
                                                            , XMLELEMENT("Id"
                                                                          , XMLELEMENT("PrvtId"
                                                                                           , XMLELEMENT("Othr"
                                                                                                        , XMLFOREST( f_varchar2_to_uft8(compte_2.ICS) AS "Id")
                                                                                                        , XMLELEMENT("SchmeNm"
                                                                                                                             ,XMLFOREST(f_varchar2_to_uft8('SEPA') AS "Prtry")
                                                                                                                     ) -- Fin SchmeNm
                                                                                                       )  -- Fin Othr
                                                                                      ) -- Fin PrvId
                                                                        ) -- Fin Id
                                                       ) -- FIN CdtrSchemeId
-- DIRECT DEBIT RCUR
                                             --, (SELECT XMLComment('DEBUT D ECRITURE DIRECT DEBIT RCUR') AS cmnt FROM DUAL )
                                             , (SELECT  XMLAGG
                                                    (XMLELEMENT ("DrctDbtTxInf"
                                                             , XMLELEMENT("PmtId"
                                                                         , XMLFOREST(f_varchar2_to_uft8('Prelevement SEPA'||' No '|| prelevement_3.numprelev)  AS "InstrId")
                                                                         , XMLFOREST(f_varchar2_to_uft8('REF - ' || prelevement_3.numprelev ) AS "EndToEndId")
                                                                         )  -- Fin PmtId
                                                             , ( SELECT    XMLAGG
                                                                                  ( XMLELEMENT
                                                                                      ( "InstdAmt"
                                                                                      , XMLATTRIBUTES(f_varchar2_to_uft8(pk_devise.symbole(prelevement_3.monnaie_d)) AS "Ccy")
                                                                                      , f_number_to_uft8(SUM(prelevement.montant_d))
                                                                                      )
                                                                                  )
                                                                      FROM      prelevement
                                                                      WHERE     prelevement.numremise  = remise_prelev_2.numremise
                                                                      AND       prelevement.numprelev = prelevement_3.numprelev
                                                                      GROUP BY  prelevement.numremise
                                                                      ,         prelevement.numprelev
                                                                )
																										 , XMLELEMENT("DrctDbtTx"
																													 , XMLELEMENT("MndtRltdInf"
																																  , XMLFOREST(f_varchar2_to_uft8(prelevement_3.MANDAT) AS "MndtId")
																																  , XMLFOREST(prelevement_3.create_mandat AS "DtOfSgntr")
																																  , XMLFOREST(f_get_statut(prelevement_3.STATUT) AS "AmdmntInd")
																																  , DECODE(f_get_statut(prelevement_3.STATUT),'false',null, XMLELEMENT ("AmdmntInfDtls",
                                                                                                                                                        DECODE(prelevement_3.amdt_mndt, null, null, XMLFOREST(prelevement_3.amdt_mndt AS "OrgnlMndtId"))
                                                                                                                                                      , DECODE(prelevement_3.amdt_ics,  null, null, XMLELEMENT("OrgnlCdtrSchmeId"
                                                                                                                                                                                                                                , DECODE(prelevement_3.amdt_creancier, null, null, XMLFOREST(prelevement_3.amdt_creancier AS "Nm"))
                                                                                                                                                                                                                                , DECODE(prelevement_3.amdt_ics,null,null, XMLELEMENT("Id"
                                                                                                                                                                                                                                                                                         , XMLELEMENT("PrvtId"
                                                                                                                                                                                                                                                                                                            , XMLELEMENT("Othr"
                                                                                                                                                                                                                                                                                                                              , XMLFOREST(prelevement_3.amdt_ics AS "Id")
                                                                                                                                                                                                                                                                                                                              , XMLELEMENT("SchmeNm"
                                                                                                                                                                                                                                                                                                                                                    , XMLFOREST('SEPA' AS "Prtry")
                                                                                                                                                                                                                                                                                                                                          ) -- Fin SchmeNm
                                                                                                                                                                                                                                                                                                                        ) -- Fin Othr
                                                                                                                                                                                                                                                                                                      ) --Fin PrvtId
                                                                                                                                                                                                                                                                                       ) -- Fin Id
                                                                                                                                                                                                                                          )
                                                                                                                                                                                                                 )
                                                                                                                                                            ) -- Fin decode OrgnlCdtrSchmeId
                                                                                                                                                       , DECODE(prelevement_3.amdt_acct , NULL, null,XMLELEMENT("OrgnlDbtrAcct"
                                                                                                                                                                                                                              , DECODE(prelevement_3.amdt_acct,null,null,XMLELEMENT("Id"
                                                                                                                                                                                                                                                                                        , XMLFOREST(prelevement_3.amdt_acct AS "IBAN")
                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                       )

                                                                                                                                                                                                              )
                                                                                                                                                              ) -- Fin decode OrgnlDbtrAcct
                                                                                                                                                      , DECODE( prelevement_3.amdt_smnda, NULL,null, XMLELEMENT("OrgnlDbtrAgt"
                                                                                                                                                                                                                                    , XMLELEMENT("FinInstnId"
                                                                                                                                                                                                                                                          , XMLELEMENT("Othr"
                                                                                                                                                                                                                                                                            , XMLFOREST('SMNDA' AS "Id")
                                                                                                                                                                                                                                                                      ) -- Fin Othr
                                                                                                                                                                                                                                                 ) -- Fin FinlnstnId
                                                                                                                                                                                                                          )
                                                                                                                                                              ) -- Fin decode OrgnlDbtrAgt

																																																		) -- Fin SELECT XMLELEMENT ("AmdmntInfDtls"
																																		) -- Fin AmdmntInfDtls
																																	) -- Fin MndtRltdInf
																													)  -- Fin DrctDbtTx
                                                             /*, XMLELEMENT("UltmtCdtr"                                   -- TODO : VOIR PLUS TARD
                                                                         , XMLforest('Nom creancier origine' AS "Nm")
                                                                         , XMLELEMENT( "Id"
                                                                                        , XMLFOREST('Organisation identification' AS "OrgId")
                                                                                     ) -- Fin Id
                                                                         ) -- FIN UltmtCdtr
                                                             */
                                                             , XMLELEMENT("DbtrAgt"
                                                                         , XMLELEMENT("FinInstnId"
                                                                                      , XMLFOREST(prelevement_3.BIC AS "BIC")
                                                                                      ) -- Fin FinInstnId
                                                                         ) -- FIN DbtrAgt
                                                             , XMLELEMENT("Dbtr"
                                                                         , XMLFOREST(f_varchar2_to_uft8(prelevement_3.intitule) AS "Nm")
                                                                         , XMLELEMENT( "Id"
                                                                                             , XMLELEMENT("OrgId"
                                                                                                             , XMLELEMENT("Othr"
                                                                                                                        , XMLFOREST(prelevement_3.NUMQUERABLE AS "Id")
                                                                                                                          )
                                                                                                          )
                                                                                             )-- Fin id
                                                                         ) -- FIN Dbtr
                                                              , XMLELEMENT("DbtrAcct"
                                                                         , XMLELEMENT("Id"
                                                                                      , XMLFOREST(f_varchar2_to_uft8(prelevement_3.clef_iban||prelevement_3.bban) AS "IBAN")
                                                                                      )-- Fin id

                                                                         ) -- FIN DbtrAcct
                                                             /* , XMLELEMENT("UltmtDbtr"
                                                                                 , XMLFOREST('Nm' AS "Nm")
                                                                                 , XMLELEMENT("Id"
                                                                                             , XMLFOREST('OrgId' AS "OrgId")
                                                                                             ) -- Fin id
                                                                          ) -- FIN UltmtDbtr     */
                                                              /* , XMLELEMENT("Purp"
                                                                                 , XMLFOREST('Cd' AS "Cd")
                                                                           ) -- FIN Purp
                                                               , XMLELEMENT("RgltryRptg"
                                                                                 , XMLELEMENT("Dtls"
                                                                                             , XMLFOREST('Cd' AS "Cd")
                                                                                             ) -- Fin Dtls
                                                                           ) -- FIN RgltryRptg*/
                                                               ,  XMLELEMENT("RmtInf"
																																												 , XMLFOREST(f_varchar2_to_uft8(SUBSTR(f_get_motpmt(prelevement_3.numprelev,remise_prelev.typesepa), 1, 140)) AS "Ustrd")
																																												 /*, XMLELEMENT("Strd"
																																															 , XMLELEMENT("CdtrRefInf"
																																																		  , XMLELEMENT("Tp"
																																																					   , XMLELEMENT("CdOrPrtry"
																																																									, XMLFOREST('SCOR' AS "Cd")
																																																									) -- Fin CdOrPrtry
																																																					  ) -- Fin Tp
																																																		  ) -- Fin CdtrRefInf
																																															)*/ -- Fin Strd
																																									   ) -- Fin RmtInf
                                                             --, (SELECT XMLComment('FIN D ECRITURE DIRECT DEBIT RCUR ') AS cmnt FROM DUAL )
                                                             )  -- FIN DrctDbtTxInf
-- FIN DIRECT DEBIT RCUR
                                                             )
                                                FROM prelevement  prelevement_3
                                                INNER JOIN remise_prelev remise_prelev_3 ON prelevement_3.numremise = remise_prelev_3.numremise
                                                WHERE -- prelevement_3.bic        IS  NOT NULL AND
                                                      prelevement_3.clef_iban  IS  NOT NULL
                                                AND   prelevement_3.bban       IS  NOT NULL
                                                AND  prelevement_3.MVT='RCUR'
                                                AND  prelevement_3.NUMREMISE = i_numremise
                                                AND NOT EXISTS (
                                                  SELECT 1
                                                    FROM annul_encais
                                                    WHERE annul_encais.numencaismt =
                                                                           prelevement_3.numencaismt)
                                             )
                                        )
                             ) -- FIN PmtInf

                         FROM    compte  compte_2
                         INNER JOIN    remise_prelev remise_prelev_2 ON remise_prelev_2.numcpte=compte_2.numcpte
                         WHERE   compte_2.bic            =       compte_1.bic
                         AND     compte_2.emetteur       =       compte_1.emetteur
                         AND     compte_2.clef_iban      IS      NOT NULL
                         AND     compte_2.bban           IS      NOT NULL
                         AND     remise_prelev_2.numremise = i_numremise
                         AND     DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_prelev_2.datdisk, NULL, 'ok', 'ko'))='ok'
                          ) -- fin XMLAGG
                          ) -- FIN DECODE
                     FROM DUAL
                     ) -- FIN SELECT DECODE

-- FIN LOT RCUR
                         --, (SELECT XMLComment('FIN D ECRITURE LOT RCUR ') AS cmnt FROM DUAL )
                         )  -- FIN CstmrCdtTrfInitn
                      )  -- FIN Document
                  , VERSION '1.0" encoding="utf-8'
                  , STANDALONE  NO
                  ) xml_file
      FROM      compte  compte_1   ,remise_prelev
      WHERE       compte_1.bic        IS  NOT NULL
      AND       compte_1.clef_iban  IS  NOT NULL
      AND       compte_1.bban       IS  NOT NULL
      AND remise_prelev.numcpte   =compte_1.numcpte
      AND  remise_prelev.numremise = i_numremise
      ;

    d_top_1 CONSTANT  DATE  := SYSDATE;

    lob_xml_file            CLOB;
    d_top_2                 DATE;
    i_duree                 INTERVAL DAY TO SECOND;
    n_log                   NUMBER                          :=in_idligne;
    rec_fichiers_prelevements  cur_fichiers_prelevements%ROWTYPE;
    v_montant_prelevements  VARCHAR2(1024)                  :='0';
    v_nb_lots               VARCHAR2(1024)                  :='0';
    v_nb_prelevements       VARCHAR2(1024)                  :='0';
    xml_file                XMLTYPE;
    l_xml                   XMLTYPE;
    v_ret                   NUMBER;
    exc_novalid             EXCEPTION;
    exc_compte              EXCEPTION;
    exc_prelev_non_sepa     EXCEPTION;
    iv_presence_mandat_first  number ;
    iv_presence_mandat_recur  number ;
    v_nbprelev              NUMBER;
    loc_f                   VARCHAR2(2);
    loc_r                   VARCHAR2(2);



    CURSOR  cur_select_remise( ii_numremise_debut in number , ii_numremise_fin in number) IS
      SELECT remise_prelev.numremise, compte.BIC, compte.clef_iban, compte.BBAN, compte.ics, compte.numcpte
      FROM remise_prelev, compte
      WHERE remise_prelev.numremise BETWEEN ii_numremise_debut and  ii_numremise_fin
      AND remise_prelev.numcpte = compte.numcpte;

    r_select_remise cur_select_remise%ROWTYPE;



   -- DEBUT DES TRAITEMENTS : CREATION D'UN FICHIER DE PRELEVEMENT PAR BORDEREAU
   BEGIN  -- DEBUT DE BOUCLAGE SUR CHAQUE REMISE

    g_session := in_session;

    g_niv_msg := 1;
    g_msg_adm := 'Debut du traitement (SEPA) : '||TO_CHAR(d_top_1, 'DD/MM/YYYY HH24:MI:SS');
    p_ins_journal;
    on_found  :=0;
    ov_erreur :=NULL;

    -- Si le parametre HSBC = O, les variables locales sont mises à null. Sinon, on met -F pour le lot First et -R pour le lot RCUR
    if in_param_HSBC = 0 then
         loc_F := null;
         loc_R := null;
    else
         loc_F := '-F';
         loc_R := '-R';
    end if;



      FOR r_select_remise in cur_select_remise(ii_numremise_debut,ii_numremise_fin) LOOP
        BEGIN

          v_nbprelev :=0;
          g_niv_msg := 1;
          g_msg_adm := 'Remise : '||r_select_remise.numremise;
          p_ins_journal;
          dbms_output.put_line(g_msg_adm);

          -- TEST DE LA PRESENCE DES INFOS DE BIC, CLEF_IBAN, BBAN, ICS AU NIVEAU DU COMPTE POUR LA REMISE CONCERNEE

          IF  PK_SEPA.f_ctrl_donnee_iban (r_select_remise.clef_iban, r_select_remise.bban, r_select_remise.BIC)=0 OR r_select_remise.ICS IS NULL THEN
           RAISE exc_compte;
          END IF;

           -- ===================================================================================
          -- TEST DE LA PRESENCE DE DONNEES NON SEPA
          -- ===================================================================================
          select count(numprelev)
          INTO v_nbprelev
          FROM  prelevement
          WHERE (prelevement.MVT IS NULL
          OR  mandat is NULL
          OR PK_SEPA.f_ctrl_donnee_iban(clef_iban, bban,bic) =0)
          AND numremise = r_select_remise.numremise;

          IF v_nbprelev >0 THEN
            RAISE exc_prelev_non_sepa;
          END IF;


          -- ===================================================================================
          -- TEST DE LA PRESENCE DE MANDAT FIRST DANS LE BORDEREAU : PRESENCE SI 1, sinon null
          -- ===================================================================================
          select count(1)
          into  iv_presence_mandat_first
          FROM  prelevement
          WHERE prelevement.MVT='FRST'
          AND   numremise = r_select_remise.numremise;
          --dbms_output.put_line('iv_presence_mandat_first : '|| iv_presence_mandat_first);

          -- ===================================================================================
          -- TEST DE LA PRESENCE DE MANDAT RCUR DANS LE BORDEREAU : PRESENCE SI 1, sinon null
          -- ===================================================================================
          select count(1)
          into  iv_presence_mandat_recur
          FROM  prelevement
          WHERE prelevement.MVT='RCUR'
          AND   numremise = r_select_remise.numremise;
          --dbms_output.put_line('iv_presence_mandat_recur : '|| iv_presence_mandat_recur);

          FOR rec_fichiers_prelevements  IN  cur_fichiers_prelevements
                                          (r_select_remise.numremise
                                          , iv_fichier
                                          , d_top_1
                                          , f_to_iso_date(d_top_1)
                                          , iv_regenerable
                                          , iv_btch_bookg
                                          , iv_presence_mandat_first
                                          , iv_presence_mandat_recur
                                          , loc_F
                                          , loc_R
                                          ) LOOP
            lob_xml_file:=XMLTYPE.GETCLOBVAL(rec_fichiers_prelevements.xml_file);
            l_xml := XMLTYPE(lob_xml_file);
            xml_file    :=XMLTYPE(REPLACE(lob_xml_file, ' xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"', ''));  --Supprimer le NameSpace pour pouvoir utiliser les commandes XPath...


            -- ===========================================================================================================================================
            --  Test de validité du fichier XML
            -- ===========================================================================================================================================
            v_ret := l_xml.isschemavalid('pain.008.001.02.xsd');

            IF v_ret<> 1 then
               -- Historisation de l'erreur
               BEGIN
                dbms_output.put_line('createSchemaBasedXML');
                l_xml := l_xml.createSchemaBasedXML('pain.008.001.02.xsd');

                -- Test validité XML
                dbms_output.put_line('schemaValidate(l_xml)');
                xmltype.schemaValidate(l_xml);

               EXCEPTION
                WHEN OTHERS THEN

                  g_niv_msg := 1;
                  g_msg_adm := SUBSTR('Erreur : '||sqlerrm,1,132);
                  p_ins_journal;
                  g_msg_adm := SUBSTR( 'Erreur : '||sqlerrm,133,132);  -- Ecriture du message d'erreur sur 2 lignes
                  p_ins_journal;

                 RAISE exc_novalid;
               END;
            END IF;
              -- ===========================================================================================================================================


            SELECT EXTRACTVALUE(xml_file, '/Document/CstmrDrctDbtInitn/GrpHdr/NbOfTxs') INTO v_nb_lots FROM DUAL;
            dbms_output.put_line('v_nb_lots : ' || v_nb_lots);

            IF  v_nb_lots IS NOT  NULL  THEN
               p_clob_to_file
                ( iv_repertoire
                , rec_fichiers_prelevements.v_file
                , lob_xml_file
                );
             END IF ;  --IF  v_nb_lots IS NOT  NULL  THEN
          END LOOP; --FOR rec_fichiers_prelevements  IN  cur_fichiers_prelevements



          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrDrctDbtInitn/GrpHdr/NbOfTxs') INTO v_nb_prelevements      FROM DUAL;
          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrDrctDbtInitn/GrpHdr/CtrlSum') INTO v_montant_prelevements FROM DUAL;
          dbms_output.put_line('v_nb_prelevements : ' || v_nb_prelevements);
          dbms_output.put_line('v_montant_prelevements : ' || v_montant_prelevements);

          g_niv_msg := 1;
          g_msg_adm := SUBSTR('Le fichier ' ||rec_fichiers_prelevements.v_file|| 'a été généré.',1,132);
          p_ins_journal;

          g_niv_msg := 1;
          g_msg_adm := SUBSTR('Nb. de prélèvements : '||v_nb_prelevements,1,132);
          p_ins_journal;

          g_niv_msg := 1;
          g_msg_adm := 'Montant des prelevements : '||v_montant_prelevements;
          p_ins_journal;


          UPDATE remise_prelev
          SET remise_prelev.datdisk = TRUNC (SYSDATE)
          WHERE remise_prelev.numremise BETWEEN NVL(ii_numremise_debut, remise_prelev.numremise)
                                        AND     NVL(ii_numremise_fin, NVL(ii_numremise_debut, remise_prelev.numremise))
          AND iv_regenerable = 'true'  --  DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire.datdisk, NULL, 'ok', 'ko'))='ok'
          AND remise_prelev.datdisk IS NULL --on ne doit jamais écraser la date système de génération d'un prelevement
          ;


      --exception concernant uniquement la granularité remise.
      EXCEPTION
        WHEN exc_compte THEN
           g_niv_msg := 1;
           g_msg_adm := 'ERREUR : Compte de trésorerie non SEPA pour la remise :  '||r_select_remise.numremise;
           p_ins_journal;
        WHEN exc_prelev_non_sepa THEN
          g_niv_msg := 1;
           g_msg_adm := 'ERREUR : au moins un prélèvement comporte une anomalie de format pour la remise :  '||r_select_remise.numremise;
           p_ins_journal;
        WHEN exc_novalid THEN
          g_niv_msg := 1;
          g_msg_adm := 'Le fichier de la remise '||r_select_remise.numremise || ' comporte une erreur de syntaxe, génération impossible';
          p_ins_journal;
        WHEN  OTHERS  THEN
          g_niv_msg := 1;
          g_msg_adm := SQLERRM;
          p_ins_journal;
      END;

      END LOOP; --curserur des remises

      g_niv_msg := 1;
      g_msg_adm := ('Fin du traitement (SEPA)') ;
      p_ins_journal;

        -- FIN DE BOUCLAGE SUR CHAQUE REMISE
  END p_gen_prelev_bordereaux;




  -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

  -- ====================================================================
  -- PROCEDURE p_ins_journal
  -- Insertion dans journal_adm
  -- ====================================================================
   PROCEDURE p_ins_journal
          IS
            l_idligne NUMBER;
          BEGIN
            --
            IF (g_niv_msg  <= g_max_msg) THEN
              g_idligne    := g_idligne + 1;
              IF (g_niv_msg = 0) THEN
                l_idligne  := -1 * g_idligne;
              ELSE
                l_idligne := g_idligne;
              END IF;
              pk_trace.p_ins_journal_adm (i_nom_traitement => g_nom_traitement, i_session => g_session, i_niv_msg => g_niv_msg, i_msg_adm => substr(g_msg_adm,0,132), i_idligne => l_idligne);
            END IF;
  --
   END p_ins_journal;

---------------- Fin des corps des procedures privees --



END;  --CREATE OR REPLACE PACKAGE BODY PK_DEV_PV01B_SEPA AS;
/
