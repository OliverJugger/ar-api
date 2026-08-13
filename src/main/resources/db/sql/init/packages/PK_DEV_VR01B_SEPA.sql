CREATE OR REPLACE PACKAGE ARTHUS.PK_DEV_VR01B_SEPA AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR01B_SEPA.sql                                       */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Génération des fichiers de virements à la norme SEPA        */
/*============================================================================*/
/* Evolution    : Mise en place du cartouche                                  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*                18/05/2016    Mantis 4656 SDA                               */
/*                29/11/2016    Mantis 5203 PHA BIC non obligatoire           */
/*                                                                            */
/*                                                                            */
/*============================================================================*/

-- Fonction ramenant le nom du bénéficiaire en fonction du décaissement
-- dans le cas d'un contrat santé   
FUNCTION "F_BENE_VIREMENT_OPE1"(
    a_numbene     IN NUMBER,
    a_typebene    IN NUMBER,
    a_numdecaismt IN NUMBER DEFAULT 0,
    a_codope      IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;
  -- Fonction ramenant le nom du bénéficiaire en fonction du décaissement
  -- dans le cas d'un contrat prévoyance
FUNCTION "F_BENE_VIREMENT_OPE2"(
    a_numdecaismt IN NUMBER DEFAULT 0 )
  RETURN VARCHAR2;
  -- Fonction ramenant le numéro d'adhérent du bénéficiaire en fonction du
  -- décaissement
  -- dans le cas d'un contrat prévoyance
FUNCTION F_ADHE_VIREMENT_OPE1(
    a_numdecaismt IN NUMBER DEFAULT 0 )
  RETURN VARCHAR2;
  -- Fonction ramenant le numéro d'adhérent du bénéficiaire en fonction du
  -- décaissement
  -- dans le cas d'un contrat prévoyance
FUNCTION "F_ADHE_VIREMENT_OPE2"(
    a_numdecaismt IN NUMBER DEFAULT 0 )
  RETURN VARCHAR2;                              

  /*FUNCTION  f_get_motif_de_paiement
              ( ii_numvirement  IN  INTEGER
              ) RETURN  VARCHAR2;*/
  -- FONCTION QUI RECUPERE LE MOTIF DE PAIEMENT PARAMETRABLE A PARTIR DE LA TABLE LIBELLE 			  
  FUNCTION  f_get_motpmt
              (in_numdecaismt in integer
			  )RETURN  VARCHAR2; 		  

  FUNCTION  f_get_nom_fichier
              ( iv_fichier          IN  VARCHAR2
              , iv_bic              IN  VARCHAR2
              , iv_emetteur         IN  VARCHAR2
              , ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER
              , id_date             IN  DATE
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
              
  PROCEDURE p_clob_to_file
              ( iv_path   IN  VARCHAR2
              , iv_file   IN  VARCHAR2
              , ilob_file IN  CLOB
              );

  PROCEDURE p_generer_virements_bordereaux
              ( ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER   DEFAULT NULL
              , in_session          IN  NUMBER    DEFAULT 1
              , in_niv_msg          IN  NUMBER    DEFAULT 1
              , in_idligne          IN  NUMBER    DEFAULT 0
              , iv_repertoire       IN  VARCHAR2  DEFAULT 'EXPORT'
              , iv_fichier          IN  VARCHAR2  DEFAULT NULL
              , iv_regenerable      IN  VARCHAR2  DEFAULT 'true'
              , iv_btch_bookg       IN  VARCHAR2  DEFAULT 'false'
              , on_found            OUT NUMBER
              , ov_erreur           OUT VARCHAR2
              );

END;  --CREATE OR REPLACE PACKAGE PK_DEV_VR01B_SEPA AS;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_DEV_VR01B_SEPA AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR01B_SEPA.sql                                       */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Génération des fichiers de virements à la norme SEPA        */
/*============================================================================*/
/* Evolution    : Mise en place du cartouche                                  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/

  --Variables <PK_TRACE.P_INS_journal_adm>
  gv_nom_traitement CONSTANT  journal_adm.nom_traitement%TYPE DEFAULT 'PK_DEV_VR01B_SEPA';



-- Fonction ramenant le nom du bénéficiaire en fonction du décaissement
-- dans le cas d'un contrat Santé
FUNCTION F_BENE_VIREMENT_OPE1(
          a_numbene     IN NUMBER,
          a_typebene    IN NUMBER,
          a_numdecaismt IN NUMBER DEFAULT 0,
          a_codope      IN NUMBER DEFAULT 1)
     RETURN VARCHAR2
IS
     loc_nom    VARCHAR2(18);
     loc_numsin NUMBER(9);
BEGIN
     IF (f_numassu(a_numbene)=a_numbene) THEN
          loc_nom           :='';
     Elsif (a_typebene       =1) THEN
          BEGIN
               SELECT      MIN(numsin)
                    INTO loc_numsin
                    FROM sntr       ,
                         dcpt       ,
                         affectation,
                         decaismt
                    WHERE sntr.numdec           =dcpt.numdec
                     AND dcpt.numdec            =affectation.numaffec
                     AND affectation.numdecaismt=decaismt.numdecaismt
                     AND decaismt.codope        =a_codope
                     AND decaismt.numdecaismt   =a_numdecaismt;
               SELECT (indvs.nom
                         ||' '
                         ||indvs.prenom)
                    INTO loc_nom
                    FROM sntr,
                         indvs
                    WHERE indvs.numindiv=sntr.numindiv
                     AND sntr.numsin    =loc_numsin;
          EXCEPTION
          WHEN no_data_found THEN
               loc_nom:='';
          END;
     Elsif (a_typebene=4) THEN
          BEGIN
               SELECT      MIN(prch.numfact)
                    INTO loc_nom
                    FROM prch       ,
                         sntr       ,
                         dcpt       ,
                         affectation,
                         decaismt
                    WHERE prch.numpc            =sntr.numpc
                     AND sntr.numdec            =dcpt.numdec
                     AND dcpt.numdec            =affectation.numaffec
                     AND affectation.numdecaismt=decaismt.numdecaismt
                     AND decaismt.codope        =a_codope
                     AND decaismt.numdecaismt   =a_numdecaismt;
          EXCEPTION
          WHEN no_data_found THEN
               loc_nom:='';
          END;
     ELSE
          BEGIN
               SELECT      MIN(sntr_ref.ref)
                    INTO loc_nom
                    FROM sntr_ref   ,
                         sntr       ,
                         dcpt       ,
                         affectation,
                         decaismt
                    WHERE sntr_ref.numsin       =sntr.numsin
                     AND sntr.numdec            =dcpt.numdec
                     AND dcpt.numdec            =affectation.numaffec
                     AND affectation.numdecaismt=decaismt.numdecaismt
                     AND decaismt.codope        =a_codope
                     AND decaismt.numdecaismt   =a_numdecaismt;
          EXCEPTION
          WHEN no_data_found THEN
               loc_nom:='';
          END;
     END IF;
     RETURN(loc_nom);
END F_BENE_VIREMENT_OPE1;


-- Fonction ramenant le nom du bénéficiaire en fonction du décaissement
-- dans le cas d'un contrat prévoyance
FUNCTION F_BENE_VIREMENT_OPE2(
          a_numdecaismt IN NUMBER DEFAULT 0 )
     RETURN VARCHAR2
IS
     loc_nom     VARCHAR2(400) :='';
     loc_numsin  NUMBER(9);
     nom_adhe    VARCHAR2(200);
     prenom_adhe VARCHAR2(200);
BEGIN
     SELECT      i.nom,
               i.prenom
          INTO nom_adhe ,
               prenom_adhe
          FROM individu i ,
               decaismt d
          WHERE i.numindiv   = d.numdest --d.numbene
           AND d.numdecaismt = a_numdecaismt
           AND i.numindiv  not in (select numindiv from pers_morale);
     loc_nom                := nom_adhe || ' ' || prenom_adhe;
     RETURN loc_nom;
EXCEPTION
WHEN no_data_found THEN
     loc_nom:='';
     RETURN loc_nom;
END F_BENE_VIREMENT_OPE2;

-- Fonction ramenant numadhe en fonction du décaissement
-- dans le cas d'un contrat santé
FUNCTION F_ADHE_VIREMENT_OPE1(
          a_numdecaismt IN NUMBER DEFAULT 0 )
     RETURN VARCHAR2
IS
     num_adherent VARCHAR2(200);
BEGIN
     SELECT   MAX(sinistre.idadhesion)
     INTO num_adherent
          FROM decaismt   ,
               affectation,
               decompte   ,
               sinistre
          WHERE affectation.numdecaismt = decaismt.numdecaismt
           AND decompte.numdec          = affectation.numaffec
           AND sinistre.numdec          = decompte.numdec
           AND affectation.codope       = 1
           AND decaismt.numdecaismt     = a_numdecaismt;
     RETURN num_adherent;
EXCEPTION
WHEN no_data_found THEN
     num_adherent:='';
END F_ADHE_VIREMENT_OPE1;


-- Fonction ramenant numadhe en fonction du décaissement
-- dans le cas d'un contrat prévoyance
FUNCTION F_ADHE_VIREMENT_OPE2(
      a_numdecaismt IN NUMBER DEFAULT 0 )
   RETURN VARCHAR2
IS
   num_adherent VARCHAR2(200);
BEGIN
   SELECT distinct numindiv
   INTO num_adherent
   FROM  beneficiaire, decaismt, affectation, histo_calcul ,repartition
   WHERE beneficiaire.numbene = decaismt.numbene
   and decaismt.numdecaismt = affectation.numdecaismt
   and affectation.codope = 2
   and affectation.numaffec = histo_calcul.numdec
   and repartition.idrepartition = histo_calcul.idrepartition
   and repartition.idadhesion =beneficiaire.idadhesion 
   AND decaismt.numdecaismt = a_numdecaismt;
   
   RETURN num_adherent;
   
EXCEPTION
   WHEN no_data_found THEN
      num_adherent:='';
      RETURN num_adherent;
END F_ADHE_VIREMENT_OPE2;

/*
  --Renvoyer le motif de paiement associé au virement...
  --Ce dernier comprendra si possible les factures et les bénéficaires autre que l'assuré
  FUNCTION  f_get_motif_de_paiement
              ( ii_numvirement  IN  INTEGER
              ) RETURN  VARCHAR2
  IS
    --Factures d'un virement...
    CURSOR  cur_factures
      ( ii_numvirement  IN  INTEGER
      )
    IS
      SELECT  DISTINCT sinistre.num_fact
      FROM    remise_vire_detail
      JOIN    decaismt    ON  decaismt.numdecaismt    =remise_vire_detail.numdecaismt
      JOIN    affectation ON  affectation.numdecaismt =decaismt.numdecaismt
      JOIN    sinistre    ON  sinistre.numdec         =affectation.numaffec
      WHERE   remise_vire_detail.numvirement=   ii_numvirement
      AND     sinistre.num_fact             IS  NOT NULL
      AND     sinistre.num_fact             <>  0
      ;

    --Bénéficiaires d'un virement si différent de l'assuré...
    CURSOR  cur_beneficiaires
      ( ii_numvirement  IN  INTEGER
      )
    IS
      SELECT  DISTINCT TRIM(INITCAP(LOWER(individu.prenom))||' '||UPPER(individu.nom)) beneficiaire
      FROM    remise_vire_detail
      JOIN    decaismt    ON  decaismt.numdecaismt    =remise_vire_detail.numdecaismt
      JOIN    affectation ON  affectation.numdecaismt =decaismt.numdecaismt
      JOIN    sinistre    ON  sinistre.numdec         =affectation.numaffec
      JOIN    individu    ON  individu.numindiv       =sinistre.numbene
      WHERE   remise_vire_detail.numvirement=   ii_numvirement
      AND     sinistre.numbene               <> sinistre.numassu
      ;  

    rec_beneficiaires   cur_beneficiaires%ROWTYPE;
    rec_factures        cur_factures%ROWTYPE;
    v_beneficiaires     VARCHAR2(32767)           :=NULL;
    v_factures          VARCHAR2(32767)           :=NULL;
    v_motif_de_paiement VARCHAR2(32767);
  BEGIN
    FOR rec_factures  IN  cur_factures
                            ( ii_numvirement
                            ) LOOP
      v_factures:=v_factures||','||TO_CHAR(rec_factures.num_fact);
    END LOOP; --FOR rec_factures  IN  cur_factures
    IF  v_factures  IS NOT NULL THEN  v_factures:='Fact.:'||LTRIM(v_factures, ',');
                                END IF;

    FOR rec_beneficiaires IN  cur_beneficiaires
                                ( ii_numvirement
                                ) LOOP
      v_beneficiaires :=v_beneficiaires||','||TO_CHAR(rec_beneficiaires.beneficiaire);
    END LOOP; --FOR rec_factures  IN  cur_factures
    IF  v_beneficiaires IS  NOT NULL  THEN  v_beneficiaires :='Béné.:'||LTRIM(v_beneficiaires, ',');
                                      END IF;

    v_motif_de_paiement:=TRIM(v_factures||' '||v_beneficiaires);

    RETURN  v_motif_de_paiement;
  END f_get_motif_de_paiement;
*/
  --Renvoyer le motif de paiement associé au virement en passant par la table
-- LIBELLE
--Ce dernier comprendra si possible les factures et les bénéficaires autre que
-- l'assuré
FUNCTION f_get_motpmt(
          in_numdecaismt IN INTEGER )
     RETURN VARCHAR2
IS
     v_motif_de_paiement VARCHAR2(32767) ;
     v_numbene           NUMBER(6);
     v_typbene           NUMBER(2);
     v_bene              VARCHAR2(32767) :=NULL;
     v_adhe              VARCHAR2(32767) :=NULL;
     v_codope            NUMBER          :=0;
     v_numindiv_dest          individu.numindiv%TYPE := NULL;
     v_type_indiv_dest        individu.type%TYPE := NULL;
     v_numindiv_bene          individu.numindiv%TYPE := NULL;
     
BEGIN
      SELECT libelle
      INTO v_motif_de_paiement
      FROM libelle
      WHERE mnemo = 'SEPAMOTPMT'
      AND code    =
         (SELECT codope
         FROM decaismt
         WHERE numdecaismt = in_numdecaismt
         ) ;
     /* SI #BENE dans le libelle
     alors rechercher le beneficiaire en fonction du codeope
     Si codeope = 1
     -- SANTE
     f_bene_virement_ope1();
     
     Si codeope <> 1 (SINON)
     -- PREVOYANCE
     f_bene_virement_ope2();
     Remplacer #BENE par retour de fonction appelée
     */
      IF INSTR(v_motif_de_paiement, '#BENE' ) <> 0 THEN -- si le motif de paiement
         -- de la table libelle contient un paramêtre #BENE
         SELECT codope
         INTO v_codope
         FROM decaismt
         WHERE numdecaismt = in_numdecaismt;
         IF v_codope = 1 -- SANTE
            THEN
            SELECT numbene
             , typbene
            INTO v_numbene
             , v_typbene
            FROM remise_vire_detail
             , decaismt
            WHERE decaismt.numdecaismt = remise_vire_detail.numdecaismt
            AND decaismt.numdecaismt   = in_numdecaismt;
            -- Récupération des infos de nom en fonction du type de
            -- bénéficiaire
            v_bene := F_BENE_VIREMENT_OPE1(v_numbene, v_typbene, in_numdecaismt, 1 );
         ELSE -- <> Sante : PREVOYANCE...
            v_bene := F_BENE_VIREMENT_OPE2(in_numdecaismt);
         END IF;
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#BENE','');
      END IF;
     
     IF v_bene  IS NULL THEN
          v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#BENE','');
     ELSE
          v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#BENE', v_bene);
     END IF;
     
     /* Mantis 4656 CARCO*/
     IF INSTR(v_motif_de_paiement, '#PRESTBENE' ) <> 0 THEN

        BEGIN
         SELECT      i.numindiv
         INTO v_numindiv_bene
         FROM individu i ,
         decaismt d
         WHERE i.numindiv   = d.numbene
         AND d.numdecaismt = in_numdecaismt;

        EXCEPTION
            WHEN no_data_found THEN
               v_numindiv_bene := null;
        END;
        IF v_numindiv_bene is not null THEN
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#PRESTBENE',F_nom(v_numindiv_bene));
        ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#PRESTBENE','');
        END IF;
     END IF;

     IF INSTR(v_motif_de_paiement, '#DESTSOC' ) <> 0 THEN
        BEGIN
          SELECT  i.numindiv,
               i.type
          INTO v_numindiv_dest ,
               v_type_indiv_dest
          FROM individu i ,
               decaismt d
          WHERE i.numindiv   = d.numdest --d.numbene
          AND d.numdecaismt = in_numdecaismt;
        EXCEPTION
            WHEN no_data_found THEN
               v_numindiv_dest := null;
        END;
          IF v_type_indiv_dest is not null THEN
             IF v_type_indiv_dest = 2 THEN
               v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#DESTSOC', pk_personne.f_nom(v_numindiv_dest));
             ELSE
               v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#DESTSOC','');
             END IF;
          ELSE
             v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#DESTSOC','');
          END IF;
     END IF;
     /* fin Mantis 4656 CARCO*/

     
     /* SI #ADHESION dans le libelle alors rechercher le numéro d'adhesion
     Remplacer #ADHESION par le numéro d'adhesion  */
      IF INSTR(v_motif_de_paiement, '#ADHESION' ) <> 0 THEN --si le motif de paiement de la table libelle contient un paramêtre #ADHESION
         SELECT codope
         INTO v_codope
         FROM decaismt
         WHERE numdecaismt = in_numdecaismt;
         IF v_codope       = 1 -- SANTE
            THEN
            v_adhe := F_ADHE_VIREMENT_OPE1(in_numdecaismt);
         ELSE -- <> Sante : PREVOYANCE...
            v_adhe := F_ADHE_VIREMENT_OPE2(in_numdecaismt);



         END IF;
         /*    ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#ADHESION','');*/

      END IF;
      --TLE  OR v_bene ='' destinataire de paiement Capra en incapacité
      IF (v_adhe IS NULL) OR (v_bene = '')  OR (v_bene is null) THEN
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#ADHESION','');
      ELSE
         v_motif_de_paiement := REPLACE(v_motif_de_paiement, '#ADHESION', v_adhe);
      END IF;

     RETURN v_motif_de_paiement;
EXCEPTION
  WHEN OTHERS THEN
     v_motif_de_paiement:='Libelle du motif de paiement non trouvé' ;
     RETURN v_motif_de_paiement;
END f_get_motpmt;
  
  
  --Renvoyer le nom fichier de virement...
  --Si {iv_fichier} est vide  Alors Virement_{iv_bic}_{iv_emetteur}_{ii_numremise_debut si {ii_numremise_fin} est vide ou identique à {ii_numremise_début}}_{id_date 
  --                                [YYYYMMDDHHMISS]}.xml
  --                          Sinon {iv_fichier}_{id_date [YYYYMMDDHHMISS]}.xml
  FUNCTION  f_get_nom_fichier
              ( iv_fichier          IN  VARCHAR2
              , iv_bic              IN  VARCHAR2
              , iv_emetteur         IN  VARCHAR2
              , ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER
              , id_date             IN  DATE
              ) RETURN  VARCHAR2
  IS
    v_date    VARCHAR2(1024):=NULL;
    v_fichier VARCHAR2(1024):=NULL;
    v_trash   VARCHAR2(1024):=NULL;
  BEGIN
    v_date:=TO_CHAR(id_date, 'YYMMDDHH24MISS');

    IF  iv_fichier  IS NULL THEN  IF  ii_numremise_debut = NVL(ii_numremise_fin, ii_numremise_debut)  THEN  v_trash :='_'||TO_CHAR(ii_numremise_debut);
                                                                                                      END IF;
                                  v_fichier :='V'||'_'||iv_bic||'_'||v_date||'.xml';
                            ELSE  v_fichier :=REPLACE(iv_fichier, '.xml', '_'||v_date||'.xml');
                            END IF;
                            
    RETURN  v_fichier;
  END f_get_nom_fichier;

  --Convertir {in_number} au format utf8...
  --Le montant est exprimé en chiffres sans virgule, espace, autre signe ou lettre.
  --Le séparateur des décimales est représenté par un point.
  --Il n'est pas obligatoire de renseigner les décimales non significatives (par exemple 100000.00 peut être renseigné par 100000)
  --5 décimales maximum après le point
  --La longueur maximale d'un montant est de 18 caractères (séparateur de décimale compris)
  --Le nombre de décimale doit être compatible avec la norme ISO 4217 relative aux devises.
  --Pour les montants d'une longueur supérieure à 14 caractères avant le séparateur de décimale, le client devra impérativement vérifier auprès de sa banque s'il peut
  --être traité.
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

  --Convertir {id_date} au format iso : YYYY-MM-DDTHH:MI:SS...
  FUNCTION  f_to_iso_date
              ( id_date IN  DATE
              ) RETURN  VARCHAR2
  IS
    v_date  VARCHAR2(1024);
  BEGIN
    v_date:=TO_CHAR(id_date, 'YYYYMMDDHH24:MI:SS');

    RETURN  SUBSTR(v_date, 1, 4)||'-'||SUBSTR(v_date, 5, 2)||'-'||SUBSTR(v_date, 7, 2)||'T'||SUBSTR(v_date, 9, 8);
  END f_to_iso_date;

  --Convertir {iv_varchar2} au format utf8...
  --Les caractères autorisés dans les messages ISO 20022 sont ceux de la norme UTF8. Cependant, les banques françaises se limitent au jeu de caractères latins,
  --composé de :
  --a b c d e f g h i j k l m n o p q r s t u v w x y z
  --A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  --0 1 2 3 4 5 6 7 8 9
  --/ - ? : ( ) . , ? +
  --Espace
  --
  --Néanmoins, d'autres caractères comme les caractères accentués (é, è, ê, â...) ou des caractères particuliers (@) peuvent être échangés sous réserve d'accord
  --bilatéral entre la banque et son client. Ces caractères spécifiques peuvent faire l'objet d'une convention par la banque d'exécution avant l'échange
  --interbancaire.
  --Par contre, les caractères qui ne font partie ni des caractères latins cités ci-dessus ni d'une convention avec la banque d?exécution sont des caractères
  --interdits. Il est recommandé de ne pas utiliser des caractères tels que le « et commercial » de « Père et Fils » ou « < » ou « > ». L'utilisation de tels caractères peut
  --amener des rejets des messages.
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

  --Ecrire les données {ilob_file} dans le fichier {iv_file} sous le répertoire Oracle {iv_path}...
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

  --Générer des fichiers de virements à la norme SEPA pour la plage des bordereaux [{ii_numremise_debut};{ii_numremise_fin}]...
  --Les fichiers de virements seront nommés selon {f_get_nom_fichier({iv_fichier}...} comme suite sous le répertoire Oracle {iv_repertoire}
  --Chaque nupplet {bic}x{emetteur} aura son fichier de virements
  --Chaque fichier de virements regroupera des lots de virements (équivalent à la notion de bordereaux de virements Arthus)
  --
  --Les comptes SEPA à débiter et les comptes SEPA à créditer sont des comptes pour lesquels leurs bic et iban sont connus
  --
  --Avec,
  --  {in_session}      : Session à tracer
  --
  --  {i_niv_msg}       :
  --    0       <>  Message d'erreurs Oracle
  --    1       <>  Message informatif
  --    2 et +  <>  Niveau de detail
  --
  --  {iv_regenerable}  :
  --    'false' <>  Ne pas autoriser la regénération des fichiers de virements
  --    'true'  <>  Autoriser la regénération des fichiers de virements
  --
  --  {iv_btch_bookg}   :
  --    'false' <>  Mode à positionner lorsque l'émetteur souhaite que sa banque effectue un débit par virement
  --    'true'  <>  Mode à positionner lorsque l'émetteur souhaite que sa banque effectue un débit global par lot de virements
  --
  --  {on_found}        : Nb. de bordereaux de virements traités
  --  {ov_erreur}       : Message d'erreur (Vide sinon)
  PROCEDURE p_generer_virements_bordereaux
              ( ii_numremise_debut  IN  INTEGER
              , ii_numremise_fin    IN  INTEGER   DEFAULT NULL
              , in_session          IN  NUMBER    DEFAULT 1
              , in_niv_msg          IN  NUMBER    DEFAULT 1
              , in_idligne          IN  NUMBER    DEFAULT 0
              , iv_repertoire       IN  VARCHAR2  DEFAULT 'EXPORT'
              , iv_fichier          IN  VARCHAR2  DEFAULT NULL
              , iv_regenerable      IN  VARCHAR2  DEFAULT 'true'
              , iv_btch_bookg       IN  VARCHAR2  DEFAULT 'false'
              , on_found            OUT NUMBER
              , ov_erreur           OUT VARCHAR2
              )
  IS
    --Niveaux de regroupement appliqués pour générer un fichier de virements SEPA par upplet {bic}x{emetteur} pour la plage des bordereaux...
    --_________________________________________________________________________________________________________________________________________________________________   
    --   {bic à débiter 1}____________(Fichier de virements {bic 1}x{emetteur 1})______________________________________________________________________________________
    --  x{emetteur 1}                 <Document>
    --  "                               <CstmrCdtTrfInitn>
    --  "                                 <GrpHdr>
    --  "                                   <MsgId>Virement_{bic à débiter 1}_{emetteur 1}_{numremise si ii_numremise_debut=ii_numremise_fin}_{sysdate}.xml
    --  "                                   <InitgPty>
    --  "                                     <Nm>{emetteur 1}
    --  "                                     ...
    --  +  {numremise 1}____________________[1..n]___<PmtInf>___(Lot de virements)_____________________________________________________________________________________
    --   (x{clef_iban à débiter 1}          <PmtInf>{numremise 1}
    --    x{bban à débiter 1}               <Dbtr>
    --    x{rais_soc 1})                      <Nm>{rais_soc 1}
    --    "                                 <DbtrAcct>
    --    "                                   <Id>
    --    "                                     <IBAN>{clef_iban à débiter 1}+{bban à débiter 1}
    --    "                                 <DbtrAgt>
    --    "                                   <FinInstnId>
    --    "                                     <BIC>{bic à débiter 1}
    --    "                                   ...
    --    +  {numvirement 1}__________________[1..n]___<CdtTrfTxInf>___(Virement)______________________________________________________________________________________
    --     (x{bic à créditer 1}               <PmtId>{numvirement 1}
    --      x{clef iban à créditer 1}         <ReqdExctnDt>{rais_soc 1}
    --      x{bban à créditer 1})             <DbtrAcct>
    --      "                                   <Id>
    --      "                                     <IBAN>{clef iban à créditer 1}+{bban à créditer 1}
    --      "                                 <DbtrAgt>
    --      "                                   <FinInstnId>
    --      "                                     <BIC>{bic à créditer 1}
    --      "                                     ...
    --      "                         </document>
    --_________________________________________________________________________________________________________________________________________________________________
    --   {bic 2}______________________(Fichier de virements {bic 2}x{emetteur 2})______________________________________________________________________________________
    --  x{emetteur 2}                 <Document>
    --  "                               ...
    CURSOR  cur_fichiers_virements
      ( ii_numremise_debut  IN  INTEGER
      , ii_numremise_fin    IN  INTEGER
      , iv_fichier          IN  VARCHAR2
      , id_date             IN  DATE
      , iv_date             IN  VARCHAR2
      , iv_regenerable      IN  VARCHAR2
      , iv_btch_bookg       IN  VARCHAR2
      )
    IS
      SELECT    f_get_nom_fichier
                  ( iv_fichier
                  , compte_1.bic
                  , compte_1.emetteur
                  , ii_numremise_debut
                  , ii_numremise_fin
                  , id_date
                  ) v_file
      ,         XMLROOT
                  ( XMLELEMENT
                      ( "Document"
                      , XMLATTRIBUTES('urn:iso:std:iso:20022:tech:xsd:pain.001.001.03' AS "xmlns")
                      , XMLELEMENT
                          ( "CstmrCdtTrfInitn"
                          , XMLELEMENT
                              ( "GrpHdr"
                              , XMLFOREST(f_varchar2_to_uft8(f_get_nom_fichier
                                                                ( iv_fichier
                                                                , compte_1.bic
                                                                , compte_1.emetteur
                                                                , ii_numremise_debut
                                                                , ii_numremise_fin
                                                                , id_date
                                                                )) AS "MsgId")
                              , XMLFOREST(f_varchar2_to_uft8(iv_date) AS "CreDtTm")
                              , ( SELECT  XMLAGG
                                            ( XMLCONCAT
                                              ( XMLELEMENT
                                                  ( "NbOfTxs"
                                                  --, COUNT(DISTINCT remise_vire_detail.numremise)   -- MOTIF TLE POUR CORRECTION DU NOMBRE DE TRANSACTION
                                                   ,COUNT(remise_vire_detail.numremise) 
                                                  )
                                              , XMLELEMENT
                                                  ( "CtrlSum"
                                                  , f_number_to_uft8(SUM(remise_vire_detail.montant_d))
                                                  )
                                              )
                                            )
                                  FROM  compte
                                  JOIN  remise_vire        ON remise_vire.numcpte         =compte.numcpte
                                  JOIN  remise_vire_detail ON remise_vire_detail.numremise=remise_vire.numremise
                                  WHERE compte.bic                    =       compte_1.bic
                                  AND   compte.emetteur               =       compte_1.emetteur
                                  AND   compte.clef_iban              IS      NOT NULL
                                  AND   compte.bban                   IS      NOT NULL
                                  AND   remise_vire.numremise         BETWEEN ii_numremise_debut
                                                                      AND     NVL(ii_numremise_fin, ii_numremise_debut)
                                  AND   DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire.datdisk, NULL, 'ok', 'ko'))='ok'
                                  --#Tests#
                                  -- AND   remise_vire_detail.bic        IS      NOT NULL
                                  AND   remise_vire_detail.clef_iban  IS      NOT NULL
                                  AND   remise_vire_detail.bban       IS      NOT NULL
                                  GROUP BY  compte.bic
                                  ,         compte.emetteur
                                )
                              , XMLELEMENT
                                  ( "InitgPty"
                                  , XMLFOREST(f_varchar2_to_uft8(compte_1.emetteur) AS "Nm")
                                  )
                              )
                          , ( SELECT  XMLAGG
                                        ( XMLELEMENT
                                            ( "PmtInf"
                                            , XMLFOREST(remise_vire_2.numremise AS "PmtInfId")
                                            , XMLFOREST('TRF' AS "PmtMtd")
                                            , XMLFOREST(iv_btch_bookg AS "BtchBookg")
                                            , ( SELECT    XMLAGG
                                                            ( XMLCONCAT
                                                              ( XMLELEMENT
                                                                  ( "NbOfTxs"
                                                                  --, COUNT(DISTINCT remise_vire_detail.numvirement) -- modif MUR
                                                                  , COUNT( remise_vire_detail.numvirement)
																  )
                                                              , XMLELEMENT
                                                                  ( "CtrlSum"
                                                                  , f_number_to_uft8(SUM(remise_vire_detail.montant_d))
                                                                  )
                                                              )
                                                            )
                                                FROM      remise_vire_detail
                                                WHERE     remise_vire_detail.numremise  =remise_vire_2.numremise
                                                --#Tests#
                                                -- AND       remise_vire_detail.bic        IS      NOT NULL
                                                AND       remise_vire_detail.clef_iban  IS      NOT NULL
                                                AND       remise_vire_detail.bban       IS      NOT NULL
                                                GROUP BY  remise_vire_detail.numremise
                                              ) --Un bordereau ayant 1 et 1 seul compte, on peut donc regrouper uniquement par bordereau pour les agregats <NbOfTxs> et <CtrlSum>
                                            , XMLELEMENT
                                                ( "PmtTpInf"
                                                , XMLELEMENT
                                                    ( "SvcLvl"
                                                    , XMLFOREST('SEPA' AS "Cd")
                                                    )
                                                )
                                            --, XMLFOREST(f_varchar2_to_uft8(SUBSTR(iv_date, 1, 10)) AS "ReqdExctnDt") -- MUR M0004376 prise en compte date de valeur
                                            , XMLFOREST(f_varchar2_to_uft8(to_char(remise_vire_2.date_valeur,'YYYY-MM-DD')) AS "ReqdExctnDt") -- MUR M0004376 prise en compte date de valeur
                                            , XMLELEMENT
                                                ( "Dbtr"
                                                , XMLFOREST(f_varchar2_to_uft8(compte_2.rais_soc) AS "Nm")
                                                -- MUR M0005828
                                                , XMLELEMENT
                                                   ("PstlAdr"
                                                   , XMLFOREST(f_varchar2_to_uft8(substr(compte_2.clef_iban,1,2)) as "Ctry")

                                                   , ( select xmlelement ( "AdrLine"  ,
                                                                            substr(pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 70 )  || ' ' ||  ad.adresse_2  || ' ' ||
                                                                                   ad.comp_adresse  || ' ' ||  ad.codpos || ' ' ||  ad.ville
                                                                                   ,1,70 )
                                                                         )
                                                       from pers_adresse ad
                                                       where IDADRESSE = pk_personne.f_idadresse ( compte_2.numsoc ) --236489 ) --compte_2.numsoc )
                                                     )
                                                   , ( select xmlelement ( "AdrLine"  ,
                                                                            substr(pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 70 )  || ' ' ||  ad.adresse_2  || ' ' ||
                                                                                   ad.comp_adresse  || ' ' ||  ad.codpos || ' ' ||  ad.ville
                                                                                   ,71,70 )
                                                                         )
                                                       from pers_adresse ad
                                                       where IDADRESSE = pk_personne.f_idadresse ( compte_2.numsoc ) --236489 ) -- compte_2.numsoc )
                                                       and length(pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 70 )  || ' ' ||  ad.adresse_2  || ' ' ||
                                                           ad.comp_adresse  || ' ' ||  ad.codpos || ' ' ||  ad.ville) > 70
                                                     )

                                                   )
                                                )
                                            , XMLELEMENT
                                                ( "DbtrAcct"
                                                , XMLELEMENT("Id"
                                                    , XMLFOREST(f_varchar2_to_uft8(compte_2.clef_iban||compte_2.bban) AS "IBAN")
                                                    )
                                                )
                                            , XMLELEMENT
                                                ( "DbtrAgt"
                                                , XMLELEMENT
                                                    ( "FinInstnId"
                                                    , XMLFOREST(f_varchar2_to_uft8(compte_2.bic) AS "BIC")
                                                    )
                                                )
                                            , ( SELECT  XMLAGG
                                                          ( XMLELEMENT
                                                              ( "CdtTrfTxInf"
                                                              , XMLELEMENT
                                                                  ( "PmtId"
                                                                  , XMLFOREST(remise_vire_detail_3.numvirement AS "EndToEndId")
                                                                  )
                                                              , XMLELEMENT
                                                                  ( "Amt"
                                                                  , ( SELECT    XMLAGG
                                                                                  ( XMLELEMENT
                                                                                      ( "InstdAmt"
                                                                                      , XMLATTRIBUTES(f_varchar2_to_uft8(pk_devise.symbole(remise_vire_detail_3.monnaie_d)) AS "Ccy")
                                                                                      --, f_number_to_uft8(SUM(remise_vire_detail.montant_d)) modif MUR
																					  , f_number_to_uft8((remise_vire_detail.montant_d))
                                                                                      )
                                                                                  )
                                                                      FROM      remise_vire_detail
                                                                      WHERE     remise_vire_detail.numremise  =remise_vire_2.numremise
                                                                      AND       remise_vire_detail.numvirement=remise_vire_detail_3.numvirement
																	  AND       remise_vire_detail.numdecaismt=remise_vire_detail_3.numdecaismt -- ajout MUR
                                                                      GROUP BY  remise_vire_detail.numremise
                                                                      ,         remise_vire_detail.numvirement
																	  ,         remise_vire_detail.numdecaismt --ajout MUR
                                                                    )
                                                                  )
                                                              , decode(remise_vire_detail_3.bic
                                                                       , null , null ,
                                                                XMLELEMENT
                                                                  ( "CdtrAgt"
                                                                  , XMLELEMENT
                                                                      ( "FinInstnId"
                                                                      , XMLFOREST(f_varchar2_to_uft8(remise_vire_detail_3.bic) AS "BIC")
                                                                      )
                                                                  ) )
                                                              , XMLELEMENT
                                                                  ( "Cdtr"
                                                                  , XMLFOREST(f_varchar2_to_uft8(remise_vire_detail_3.intitule) AS "Nm")
                                                                  )
                                                              , XMLELEMENT
                                                                  ( "CdtrAcct"
                                                                  , XMLELEMENT
                                                                      ( "Id"
                                                                      , XMLFOREST(f_varchar2_to_uft8(remise_vire_detail_3.clef_iban||remise_vire_detail_3.bban) AS "IBAN")
                                                                      )
                                                                  )
                                                                  , XMLFOREST
                                                                  ( XMLFOREST(f_varchar2_to_uft8(SUBSTR(f_get_motpmt(remise_vire_detail_3.numdecaismt), 1, 140)) AS "Ustrd")
                                                                    AS "RmtInf"
                                                                  )
                                                              )
                                                          )
                                                FROM  remise_vire_detail  remise_vire_detail_3
                                                WHERE remise_vire_detail_3.numremise=remise_vire_2.numremise
                                                --#Tests#
                                                -- AND   remise_vire_detail_3.bic        IS  NOT NULL
                                                AND   remise_vire_detail_3.clef_iban  IS  NOT NULL
                                                AND   remise_vire_detail_3.bban       IS  NOT NULL
                                              )
                                            )
                                        )
                              FROM    compte  compte_2
                              JOIN    remise_vire remise_vire_2 ON remise_vire_2.numcpte=compte_2.numcpte
                              WHERE   compte_2.bic            =       compte_1.bic
                              AND     compte_2.emetteur       =       compte_1.emetteur
                              AND     compte_2.clef_iban      IS      NOT NULL
                              AND     compte_2.bban           IS      NOT NULL
                              AND     remise_vire_2.numremise BETWEEN ii_numremise_debut
                                                              AND     NVL(ii_numremise_fin, ii_numremise_debut)
                              AND     DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire_2.datdisk, NULL, 'ok', 'ko'))='ok'
                            )
                          )
                      )  
                  , VERSION '1.0" encoding="utf-8'
                  , STANDALONE  NO
                  ) xml_file
      FROM      compte  compte_1
      WHERE     compte_1.numcpte    IN  ( SELECT  remise_vire.numcpte
                                          FROM  remise_vire
                                          -- MUR SEPA 06/11/2013 : ajout jointure ne pas commencer à generer le fichier xml si pas de virement concerné
                                          inner join remise_vire_detail on (remise_vire.numremise =  remise_vire_detail.numremise ) --and remise_vire_detail.bic is not null)
                                          WHERE remise_vire.numremise BETWEEN ii_numremise_debut
                                                                      AND     NVL(ii_numremise_fin, ii_numremise_debut)
                                          AND   DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire.datdisk, NULL, 'ok', 'ko'))='ok'
                                        )
      AND       compte_1.bic        IS  NOT NULL
      AND       compte_1.clef_iban  IS  NOT NULL
      AND       compte_1.bban       IS  NOT NULL
      GROUP BY  compte_1.bic
      ,         compte_1.emetteur
      ;

    d_top_1 CONSTANT  DATE  :=SYSDATE;

    lob_xml_file            CLOB;
    d_top_2                 DATE;
    i_duree                 INTERVAL DAY TO SECOND;
    n_log                   NUMBER                          :=in_idligne;
    rec_fichiers_virements  cur_fichiers_virements%ROWTYPE;
    v_log                   VARCHAR2(1024)                  :=''; --'p_generer_virements_bordereaux('||TO_CHAR(ii_numremise_debut)||', ...;';
    v_montant_virements     VARCHAR2(1024)                  :='0';
    v_nb_lots               VARCHAR2(1024)                  :='0';
    v_nb_virements          VARCHAR2(1024)                  :='0';
    xml_file                XMLTYPE;
    l_xml                   XMLTYPE;
    v_ret                   NUMBER;
    exc_novalid             EXCEPTION;
  BEGIN
    on_found  :=0;
    ov_erreur :=NULL;

    n_log :=n_log+1;
    pk_trace.p_ins_journal_adm
      ( gv_nom_traitement
      , in_session
      , in_niv_msg
      , SUBSTR(v_log||'Début de génération du fichier XML (SEPA) : '||TO_CHAR(d_top_1, 'DD/MM/YYYY HH24:MI:SS'),1,132)
      , i_idligne =>n_log
      ); 

    FOR rec_fichiers_virements  IN  cur_fichiers_virements
                                      ( ii_numremise_debut
                                      , ii_numremise_fin
                                      , iv_fichier
                                      , d_top_1
                                      , f_to_iso_date(d_top_1)
                                      , iv_regenerable
                                      , iv_btch_bookg
                                      ) LOOP
      lob_xml_file:=XMLTYPE.GETCLOBVAL(rec_fichiers_virements.xml_file);
      l_xml := XMLTYPE(lob_xml_file);
      xml_file    :=XMLTYPE(REPLACE(lob_xml_file, ' xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"', ''));  --Supprimer le NameSpace pour pouvoir utiliser les commandes XPath...

      --XMLISVALID(rec_fichiers_virements.xml_file, 'http://www.w3.org/2001/XMLSchema/pain.001.001.03.xsd')...
      
      --ABO
      -- Test validité XML
      v_ret := l_xml.isschemavalid('pain.001.001.03.xsd');
      
      if v_ret<> 1 then
         -- Historisation de l'erreur
         BEGIN
            -- l_xml := lob_xml_file;
             l_xml := l_xml.createSchemaBasedXML('pain.001.001.03.xsd');
             -- Test validité XML
             xmltype.schemaValidate(l_xml);
             --return(FALSE);
            
         EXCEPTION
             WHEN OTHERS THEN
              n_log   :=n_log+1;
              pk_trace.p_ins_journal_adm
                ( gv_nom_traitement
                , in_session
                , in_niv_msg
                , SUBSTR(v_log||'Erreur : '||sqlerrm,1,132)
                , i_idligne =>n_log
                );
				--TLE 08/10/13
				 pk_trace.p_ins_journal_adm
                ( gv_nom_traitement
                , in_session
                , in_niv_msg
                , SUBSTR(v_log||'Erreur : '||sqlerrm,133,132)
                , i_idligne =>n_log
                );
             
               --dbms_output.put_line(l_xml.getclobval());
               RAISE exc_novalid;
           END;
      END IF;
      

      SELECT EXTRACTVALUE(xml_file, '/Document/CstmrCdtTrfInitn/GrpHdr/NbOfTxs') INTO v_nb_lots FROM DUAL;

      IF  v_nb_lots IS NOT  NULL  THEN
        p_clob_to_file
          ( iv_repertoire
          , rec_fichiers_virements.v_file
          , lob_xml_file
          );
          /*
        FOR i_indice IN 1 .. TO_NUMBER(v_nb_lots) LOOP
          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrCdtTrfInitn/PmtInf/NbOfTxs') INTO v_nb_virements      FROM DUAL;
          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrCdtTrfInitn/PmtInf/CtrlSum') INTO v_montant_virements FROM DUAL;

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Fichier <'||rec_fichiers_virements.v_file||'> (Lot <'||v_nb_lots||'>)...',1,132)
            , i_idligne =>n_log
            );

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Nb. de virements : '||v_nb_virements,1,132)
            , i_idligne =>n_log
            );

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Montant des virements : '||v_montant_virements,1,132)
            , i_idligne =>n_log
            );
        END LOOP; --FOR i_indice IN v_nb_virements.FIRST .. v_nb_virements.LAST LOOP
        */
      END IF ;  --IF  v_nb_lots IS NOT  NULL  THEN
    END LOOP; --FOR rec_fichiers_virements  IN  cur_fichiers_virements


          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrCdtTrfInitn/PmtInf/NbOfTxs') INTO v_nb_virements      FROM DUAL;
          SELECT EXTRACTVALUE(xml_file, '/Document/CstmrCdtTrfInitn/PmtInf/CtrlSum') INTO v_montant_virements FROM DUAL;

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Le fichier XML a été généré',1,132)
            , i_idligne =>n_log
            );

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Nb. de décaissement : '||v_nb_virements,1,132)
            , i_idligne =>n_log
            );

          n_log :=n_log+1;
          pk_trace.p_ins_journal_adm
            ( gv_nom_traitement
            , in_session
            , in_niv_msg
            , SUBSTR(v_log||'Montant des virements : '||v_montant_virements,1,132)
            , i_idligne =>n_log
            );


    UPDATE  remise_vire
    SET remise_vire.datdisk =d_top_1
    WHERE remise_vire.numremise BETWEEN NVL(ii_numremise_debut, remise_vire.numremise)
                                AND     NVL(ii_numremise_fin, NVL(ii_numremise_debut, remise_vire.numremise))
    AND iv_regenerable = 'true' --  DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire.datdisk, NULL, 'ok', 'ko'))='ok'
    AND remise_vire.datdisk IS NULL --on ne doit jamais écraser la date système de génération d'un virement
    ;
    
    /*n_log :=n_log+1;
    pk_trace.p_ins_journal_adm
      ( gv_nom_traitement
      , in_session
      , in_niv_msg
      , SUBSTR(v_log||'Nb. de bordereaux traités : '||TO_CHAR(SQL%ROWCOUNT),1,132)
      , i_idligne =>n_log
      );
    */
    
    UPDATE  decaismt
    SET   decaismt.datpay =d_top_1
    ,     decaismt.numchq =0
    ,     decaismt.refpmt = ( SELECT  remise_vire_detail.numvirement
                              FROM  remise_vire_detail
                              WHERE remise_vire_detail.numdecaismt=decaismt.numdecaismt
                            )
    WHERE decaismt.numdecaismt  IN  ( SELECT  remise_vire_detail.numdecaismt
                                      FROM    compte
                                      JOIN    remise_vire         ON remise_vire.numcpte          =compte.numcpte
                                      JOIN    remise_vire_detail  ON remise_vire_detail.numremise =remise_vire.numremise
                                      WHERE   -- compte.bic                      IS      NOT NULL AND
                                              compte.clef_iban                IS      NOT NULL
                                      AND     compte.bban                     IS      NOT NULL
                                      AND     remise_vire.numremise           BETWEEN NVL(ii_numremise_debut, remise_vire.numremise)
                                                                              AND     NVL(ii_numremise_fin, NVL(ii_numremise_debut, remise_vire.numremise))
                                      --#Tests#
                                      -- AND     remise_vire_detail.bic          IS      NOT NULL
                                      AND     remise_vire_detail.clef_iban    IS      NOT NULL
                                      AND     remise_vire_detail.bban         IS      NOT NULL
                                      AND     iv_regenerable = 'true' 
                                     -- AND     DECODE(iv_regenerable, 'true', 'ok', DECODE(remise_vire.datdisk, NULL, 'ok', 'ko'))='ok'
                                    )
    AND decaismt.datpay IS NULL --on n'écrase pas une date de paiement du décaissement surtout lors d'une regénération
    ;
    on_found:=SQL%ROWCOUNT;
    /*
    n_log   :=n_log+1;
    pk_trace.p_ins_journal_adm
      ( gv_nom_traitement
      , in_session
      , in_niv_msg
      , SUBSTR(v_log||'Nb. de décaissements traités : '||TO_CHAR(on_found),1,132)
      , i_idligne =>n_log
      );
    */
    
    COMMIT;

    d_top_2:=SYSDATE;
    i_duree:=NUMTODSINTERVAL(d_top_2-d_top_1, 'DAY');

    n_log :=n_log+1;
    pk_trace.p_ins_journal_adm
      ( gv_nom_traitement
      , in_session
      , in_niv_msg
      , SUBSTR(v_log||'Fin de génération du fichier XML (SEPA) : '||TO_CHAR(d_top_2, 'DD/MM/YYYY HH24:MI:SS')||' (Durée : '||EXTRACT(DAY FROM i_duree)||' '||EXTRACT(HOUR FROM i_duree)||':'||EXTRACT(MINUTE FROM i_duree)||':'||EXTRACT(SECOND FROM i_duree)||')',1,132)
      , i_idligne =>n_log
      );

  EXCEPTION
    WHEN exc_novalid THEN  pk_trace.p_ins_journal_adm
                            ( gv_nom_traitement
                            , in_session
                            , 0
                            , 'Le fichier comporte une erreur de syntaxe, génération impossible'
                            , i_idligne =>n_log
                            );
     WHEN  OTHERS  THEN  BEGIN
                          n_log :=n_log+1;
                          pk_trace.p_ins_journal_adm
                            ( gv_nom_traitement
                            , in_session
                            , 0
                            , SUBSTR(v_log||'6]'||SQLERRM, 1, 132)
                            , i_idligne =>n_log
                            );
                        END;
  END p_generer_virements_bordereaux;

END;  --CREATE OR REPLACE PACKAGE BODY PK_DEV_VR01B_SEPA AS;
/
