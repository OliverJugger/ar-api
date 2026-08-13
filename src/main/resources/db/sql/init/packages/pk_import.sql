CREATE OR REPLACE PACKAGE ARTHUS.pk_import
AS
  type donnee IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  type donnum IS TABLE OF NUMBER;
  t_enreg               donnum;
  t_enregnull           donnum;
  t_import              donnee;
  t_entite_1            donnee;
  t_entite_2            donnee;
  t_entite_3            donnee;
  t_entite_4            donnee;
  t_entite_30           donnee;
  t_entite_6            donnee;
  t_entite_7            donnee;
  t_entite_8            donnee;
  t_nul                 donnee;
  cle_primaire          VARCHAR2(50);
  erreur                VARCHAR2(200);
  separateur            VARCHAR2(2);
  flag_erreur           BINARY_INTEGER ;
  flag_init             BINARY_INTEGER := 0;
  loc_idporte           BINARY_INTEGER := 1;
  numutil_porte         BINARY_INTEGER := 0;
  entite_base           BINARY_INTEGER := 0;
  pk_import_int         BINARY_INTEGER := 1;
  flag_entite_1         BINARY_INTEGER := 0;
  flag_entite_2         BINARY_INTEGER := 0;
  flag_entite_3         BINARY_INTEGER := 0;
  flag_entite_4         BINARY_INTEGER := 0;
  flag_entite_30        BINARY_INTEGER := 0;
  flag_entite_6         BINARY_INTEGER := 0;
  flag_entite_7         BINARY_INTEGER := 0;
  flag_entite_8         BINARY_INTEGER := 0;
  flag_insere_adh       BINARY_INTEGER := 0;
  flag_insere_memb      BINARY_INTEGER := 0;
  flag_insere_couv      BINARY_INTEGER := 0;
  flag_autorise_maj_1   BINARY_INTEGER := 1;
  flag_autorise_maj_2   BINARY_INTEGER := 1;
  flag_autorise_maj_3   BINARY_INTEGER := 1;
  flag_autorise_maj_4   BINARY_INTEGER := 1;
  flag_autorise_maj_6   BINARY_INTEGER := 1;
  flag_autorise_maj_7   BINARY_INTEGER := 1;
  flag_autorise_maj_8   BINARY_INTEGER := 1;
  flag_autorise_maj_30  BINARY_INTEGER := 0;
  loc_idadhesion        NUMBER;
  loc_numindiv          NUMBER;
  loc_numassu           NUMBER;
  loc_interloc          NUMBER;
  loc_no_voie           NUMBER;
  loc_bis               VARCHAR2(1);
  loc_type_voie         VARCHAR2(4);
  loc_nom_voie          VARCHAR2(30);
  loc_role              NUMBER;
  numindiv_maj          NUMBER;
  flag_insere           BINARY_INTEGER := 0;
  adhesion_idporte      NUMBER :=0;
  loc_TYPE_ECHANGE      NUMBER(9) := 0;
  a_existadhe           NUMBER(1) := 0;
  loc_numremiseglobal   NUMBER(6);

  PROCEDURE Charge_Donnee_Import(
                                aTYPE_ECHANGE IN NUMBER,
                                I_session	    IN	NUMBER				Default 1,
                                I_niv_msg	    IN	NUMBER				Default 1,
                                O_found	      OUT	NUMBER,
                                O_erreur      OUT	VARCHAR2
                                );

  PROCEDURE Init_porte  (
                         a_idporte  IN  NUMBER
                        );

  PROCEDURE Charge_donnee (
                          a_record             IN  VARCHAR2
                          ,a_idporte           IN  NUMBER
                          ,a_role              IN  NUMBER DEFAULT 0
                          ,o_erreur            OUT VARCHAR2
                          ,o_flag_erreur       OUT NUMBER
                          );

  PROCEDURE Lit_un_champ  (
                          a_chaine    IN      VARCHAR2
                          ,champ      IN OUT  VARCHAR2
                          ,reste      IN OUT  VARCHAR2
                          );

  PROCEDURE Charge_cle_primaire;
  
  PROCEDURE Init_entites (
                          a_entite   IN NUMBER
                         );

  PROCEDURE Charge_entites;
  
  PROCEDURE Charge_personne;
  
  PROCEDURE Charge_couverture(
                              a_idporte IN NUMBER
                              );
  
  PROCEDURE Charge_adhesion(a_idporte IN NUMBER,
                              a_motif IN NUMBER);
  
  PROCEDURE Charge_role(a_role IN NUMBER);
  
  FUNCTION Recherche_Echange_Clef_Int (  
                                  aCLEF_EXT IN NUMBER, 
                                  aENTITE IN NUMBER
                                  ) RETURN NUMBER;
  
  PROCEDURE Insert_Echange_Clef (  
                                aCLEF_INT       IN NUMBER,
                                aCLEF_EXT       IN NUMBER, 
                                aENTITE         IN NUMBER,
                                aTYPE_ECHANGE   IN NUMBER
                                );

  PROCEDURE Insert_histo_import (
                                aidporte      IN NUMBER,
                                acle          IN NUMBER,
                                aaction       IN VARCHAR2,
                                anumremise    IN NUMBER
                                );

  FUNCTION F_Traite_Homonymie (
                              anumindivext    NUMBER,
                              aQualite        NUMBER,
                              anom            VARCHAR2,
                              aprenom         VARCHAR2,
                              adatenaissance  DATE,
                              aTYPE_ECHANGE   NUMBER 
                              ) RETURN VARCHAR2;

  FUNCTION F_Blocage_Homonyme ( anumindivext     NUMBER,
                              aTYPE_ECHANGE   NUMBER 
                              ) RETURN VARCHAR2;

END pk_import;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_IMPORT" 
AS
-- $Rev:: 129                                    $:  Revision du dernier commit
-- $Author:: b.cortial                           $:  Auteur du dernier commit
-- $Date: 2022-12-29 15:38:06 +0100 (jeu., 29 dÃ©c. 2022) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGE_BODIES/PK_IMPORT.pkb $:  Chemin


Procedure P_INS_journal;

-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_import';
G_msg_adm		journal_adm.msg_adm%TYPE;
G_session		journal_adm.id_session%TYPE default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
--	0 --> Message d'erreurs (Erreur ORACLE)
--	1 --> Message informatif(tout se passe bien)
--	2 et + Niveau de detail


/* -- -----------------------------------------------------------------
--  PROCEDURE : Init_porte
--  parametres
--  entree :
--  - identifiant du gabarit de l'importation : 
--      a_idporte IN NUMBER, DEF_PORTE(IDPORTE)
--  But :
--  Rechercher les données du gabarit de l'importation defini en base
*/ -- -----------------------------------------------------------------
 
PROCEDURE Init_porte  (
      a_idporte  IN  NUMBER
      )
IS
BEGIN 
  flag_init := 1;
  BEGIN
    loc_idporte := a_idporte;
    SELECT  separateur,
            numutil,
            entite_base
      INTO  separateur,
            numutil_porte,
            entite_base
      FROM  def_porte
     WHERE  idporte = a_idporte;
  EXCEPTION WHEN No_data_found THEN
    erreur := 'Les paramètres de l''interface N° '||TO_CHAR(a_idporte)||' ne sont pas définies.';
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Init_porte - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
  WHEN Others THEN
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Init_porte - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
  END;
END  Init_porte;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_donnee
--  parametres
--  entree :
--  - enregistrement (ligne) du fichier (<= 1024 caractères)
--      a_record             IN  VARCHAR2,
--  - identifiant du gabarit de l'importation : 
--      a_idporte IN  NUMBER, NUMBER DEF_PORTE(IDPORTE)
--  - a_type_cle_primaire  IN  NUMBER DEFAULT 0,
--  - a_type_cle1          IN  NUMBER DEFAULT 0,
--  - a_type_cle2          IN  NUMBER DEFAULT 0,
--  - a_type_cle3          IN  NUMBER DEFAULT 0,
--  sortie :
--  - o_erreur            OUT  VARCHAR2,
--  - o_flag_erreur       OUT  NUMBER
--  But :
--   PROCEDURE principale.
--   Charge les donnees du fichier dans la base
--   Recherche le gabarit s'il n'est pas passe en parametre
--   Lit tous les champs de la ligne passée en parametre
--   Charge les entites, en fonction du champ entite_base de la table def_porte
--   Soit charge les personnes puis leur role (0)
--   Soit charge les couvertures (11)
--   Met à jour la table des historiques d'importation
--   Voir aussi dans LIBELLE les valeurs pour le MNEMO = TYPE_CLE
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_donnee (
      a_record            IN  VARCHAR2,
      a_idporte           IN  NUMBER,
      a_role              IN  NUMBER DEFAULT 0,
      o_erreur            OUT VARCHAR2,
      o_flag_erreur       OUT NUMBER
      )
IS
  a_chaine    VARCHAR2(1024) := a_record;
  reste       VARCHAR2(1024);
  champ       VARCHAR2(50);
BEGIN
  BEGIN
    flag_erreur           := 0;
    loc_role              := a_role;
    erreur                := NULL;
    
    --IF ( flag_init = 0 ) THEN
     Init_porte( a_idporte );
    --END IF;
    
    IF ( flag_erreur != 0 ) THEN
     GOTO Errexit;
    END IF;                    
    
    t_import        := t_nul;
    pk_import_int := 1;
    Lit_un_champ( a_record, champ, reste );
    t_import(pk_import_int) := champ;

    DBMS_OUTPUT.PUT_LINE( 'I = '|| pk_import_int ||' Champ = '|| champ );
    WHILE ( LENGTH(reste) > 0 )
    LOOP
      pk_import_int := pk_import_int + 1;
      Lit_un_champ( reste, champ, reste );
      t_import(pk_import_int) := champ;
      DBMS_OUTPUT.PUT_LINE( 'I = '|| pk_import_int ||' Champ = '|| champ );
    END LOOP;
    
    Charge_entites;
    
    IF ( flag_erreur != 0 ) THEN
     GOTO Errexit;
    END IF;
    
    IF (entite_base = 0) THEN
      Charge_personne;
      Charge_role(loc_role);
    ELSIF (entite_base = 13) THEN
      a_existadhe       := 1;
      adhesion_idporte  := a_idporte;
      Charge_couverture(a_idporte);
    END IF;
    
  EXCEPTION WHEN OTHERS THEN
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_donnee - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
    P_INS_journal;
  END;
  o_flag_erreur := flag_erreur;
  o_erreur := erreur;
  <<Errexit>>
  o_flag_erreur := flag_erreur;
  o_erreur := erreur;
  DBMS_OUTPUT.PUT_LINE( 'Flag erreur = '||flag_erreur||' '||erreur );
END  Charge_donnee;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Lit_un_champ
--  parametres
--  entree :
--  - ligne du fichier 
--     a_chaine   IN       VARCHAR2, 
--  - valeur du champ a modifier 
--     champ      IN OUT  VARCHAR2,
--  - restante a exploiter
--  - reste      IN OUT  VARCHAR2
--  sortie :
--  - valeur du cjamp trouve 
--     champ      IN OUT  VARCHAR2,
--  - chaine restante a exploiter
--     reste      IN OUT  VARCHAR2
--  But :
--   lit un champ de la ligne passee en parametre
--   le champ est constitue de tous les caracteres avant le separateur 
--   defini au prealable
--   renvoi la valeur du champ et le reste de la ligne encore a exploiter
*/ -- -----------------------------------------------------------------

PROCEDURE Lit_un_champ  (
                        a_chaine  IN       VARCHAR2,
                        champ      IN OUT  VARCHAR2,
                        reste      IN OUT  VARCHAR2
                        )
IS
  i                 BINARY_INTEGER := 0;
  loc_delimiteur    BINARY_INTEGER := 0;
BEGIN
  loc_delimiteur := INSTR( a_chaine, separateur );
  
  IF ( loc_delimiteur > 0 ) THEN
   champ := SUBSTR( a_chaine, 1, loc_delimiteur -1 );
  ELSE
   champ := a_chaine;
  END IF;
/*
  IF ( SUBSTR(champ, 1, 1) = delimiteur ) THEN
   champ := SUBSTR( champ, 2, LENGTH(champ)-2 );
  END IF;
*/
  IF ( loc_delimiteur = 0 ) THEN
   reste := NULL;
  ELSE
   reste := SUBSTR( a_chaine, loc_delimiteur+1, LENGTH(a_chaine) );
  END IF;
END  Lit_un_champ;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_cle_primaire
--  parametres
--  entree :
--  sortie :
--  But :
--   Recherche la cle primaire de l'entite traitee
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_cle_primaire
IS
  idcle  BINARY_INTEGER;
BEGIN
  BEGIN
    SELECT porte_import.no_champ
      INTO idcle
      FROM porte_import
     WHERE idporte = loc_idporte
       AND entite = 1
       AND id_donnee = 7
    UNION
    SELECT  porte_import.no_champ
      FROM  porte_import
     WHERE  idporte = loc_idporte
       AND  entite = 1
       AND  id_donnee = 1;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE( 'Erreur : impossible de déterminer la clé primaire' );
    erreur := ( 'Impossible de déterminer la clé primaire' );
    flag_erreur := 1;
  END;
  DBMS_OUTPUT.PUT_LINE( 'Idcle = '|| idcle );
  
  BEGIN
    Cle_primaire := t_import( idcle );
  EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE( 'Erreur : impossible de déterminer la clé primaire' );
    erreur := ( 'Impossible de déterminer la clé primaire' );
    flag_erreur := 1;
  END;
  DBMS_OUTPUT.PUT_LINE( 'Cle_primaire = '|| cle_primaire );
  EXCEPTION WHEN OTHERS THEN
  erreur := Substr('Cle_primaire : '||sqlerrm, 1, 80);
  flag_erreur := 1;
END  Charge_cle_primaire;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Init_entites
--  parametres
--  entree : 
--  - numero de l'entite dans la table LIBELLE pour mnemo = 'DON_PHYS'
--  sortie :
--  But :
--   Initialiser tous les champs des 8 tableaux t_entite_N (N = 1..7)
*/ -- -----------------------------------------------------------------

PROCEDURE Init_entites (
      a_entite   IN NUMBER
      )
IS
  don_phys  libelle%Rowtype;
BEGIN
  FOR don_phys IN (
                   SELECT  code
                     FROM  libelle
                    WHERE  mnemo = 'DON_PHYS'
                      AND  sens = a_entite)
  LOOP
    IF ( a_entite = 1 ) THEN
      t_entite_1( don_phys.code ) := NULL;
    ElsIf ( a_entite = 2 ) then
      t_entite_2( don_phys.code ) := NULL;
    ElsIf ( a_entite = 3 ) then
      t_entite_3( don_phys.code ) := NULL;
    ElsIf ( a_entite = 4 ) then
      t_entite_4( don_phys.code ) := NULL;
    ElsIf ( a_entite = 30 ) then
      t_entite_30( don_phys.code ) := NULL;
    ElsIf ( a_entite = 6 ) then
      t_entite_6( don_phys.code ) := NULL;
    ElsIf ( a_entite = 7 ) then
      t_entite_7( don_phys.code ) := NULL;
    ElsIf ( a_entite = 8 ) then
      t_entite_8( don_phys.code ) := NULL;
    End if;
  END LOOP;
END  Init_entites;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_entites
--  parametres
--  entree : 
--  sortie :
--  But :
--   Charger les tableaux des entites avec les donnees de la table PORTE_IMPORT
--   pour le gabarit defini
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_entites
IS
  c_import  porte_import%Rowtype;
BEGIN
  -- Charge_cle_primaire;
  Init_entites(1);  -- //Entite logique Personne
  Init_entites(2);  -- //Entite logique Adresse
  Init_entites(3);  -- //Entite logique pers_histo_phys
  Init_entites(4);  -- //Entite logique Rib
  Init_entites(30); -- //Entite logique Transcod
  Init_entites(6);  -- //Entite logique Personne Morale
  Init_entites(7);  -- //Entite logique Interlocuteur
  Init_entites(8);  -- //Entite logique Contact
  flag_entite_1   := 0;
  flag_entite_2   := 0;
  flag_entite_3   := 0;
  flag_entite_4   := 0;
  flag_entite_30  := 0;
  flag_entite_6   := 0;
  flag_entite_7   := 0;
  flag_entite_8   := 0;
  
  FOR c_import IN (
                    SELECT entite,
                           id_donnee,
                           no_champ,
                           type
                      FROM porte_import
                     WHERE idporte = loc_idporte
                  ORDER BY no_champ)
  LOOP
    BEGIN
      -- il faut au moins un champ de renseigné pour valider l'importation
      IF ( c_import.entite = 1 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_1 := 1;
        END IF;
        t_entite_1( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement personne Id_donnee = '||c_import.id_donnee|| ' Valeur = '|| t_entite_1( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 2 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_2 := 1;
        END IF;
        t_entite_2( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement adresse Id_donnee = '||c_import.id_donnee|| ' Valeur = '|| t_entite_2( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 3 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_3 := 1;
        END IF;
        t_entite_3( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement situation Id_donnee = '||c_import.id_donnee|| ' Valeur = '|| t_entite_3( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 4 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_4 := 1;
        END IF;
        t_entite_4( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement rib Id_donnee = '||c_import.id_donnee|| ' Valeur = '|| t_entite_4( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 30 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_30 := 1;
        END IF;
        t_entite_30( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement transcodif cvrt Id_donnee= '||c_import.id_donnee|| ' Valeur = '|| t_entite_30( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 6 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_6 := 1;
        END IF;
        t_entite_6( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement personnes morales= '||c_import.id_donnee|| ' Valeur = '|| t_entite_6( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 7 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_7 := 1;
        END IF;
        t_entite_7( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement interlocuteur= '||c_import.id_donnee|| ' Valeur = '|| t_entite_7( c_import.id_donnee ) );
      ELSIF ( c_import.entite = 8 ) THEN
        IF NVL(LENGTH(t_import( c_import.no_champ )),0) > 0 THEN
          flag_entite_8 := 1;
        END IF;
        t_entite_8( c_import.id_donnee ) := t_import( c_import.no_champ );
        -- DBMS_OUTPUT.PUT_LINE( 'Chargement contact= '||c_import.id_donnee|| ' Valeur = '|| t_entite_8( c_import.id_donnee ) );
      End if;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        -- DBMS_OUTPUT.PUT_LINE( 'Erreur : Nombre de champs ('||pk_import_int||') inférieur au paramétrage ('||c_import.no_champ||')' );
        erreur := ( 'Nombre de champs ('||pk_import_int||') inférieur au paramétrage ('||c_import.no_champ||')' );
        flag_erreur := 1;
        G_niv_msg	:= 0;
        G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_entites - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
        P_INS_journal;
    END;
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_entites - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END  Charge_entites;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_personne
--  parametres
--  entree : 
--  sortie :
--  But : Mise à jour ou insertion des données dans les tables suivantes
--   -- INDIVIDU
--   -- PERS_ADRESSE
--   -- PERS_HISTO_PHYS
--   -- RIB
--   -- PERS_MORALE    
--   -- INTERLOCUTEUR
--
-- 25/03/2009 ph - changement 
-- Si l'individu est en mise à jour, le reste des infos personnes peut être en insertion,
-- ce qui n'était pas géré avant. 
--
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_personne
IS
  loc_idadresse   NUMBER;
  loc_idrib       NUMBER;
  loc_rib         NUMBER;
  loc_sens        NUMBER;
  -- flag d'insertion par entite autre qu'individu(1)
  flag_insere_2   NUMBER; -- (Pers_adresse, Adr_internationale)
  flag_insere_3   NUMBER; -- (pers_histo_phys)
  flag_insere_4   NUMBER; -- (Rib)
  flag_insere_6   NUMBER; -- PERS_MORALE
  flag_insere_7   NUMBER; -- Interlocuteur
  flag_insere_8   NUMBER; -- (Contact)
  nVal            NUMBER;
  
  loc_idcontact       NUMBER;
  loc_idpershistphys  NUMBER;
  loc_idinterlocuteur NUMBER;
  loc_idpersmorale    NUMBER;
  

BEGIN
-- test si blocage homonyme
IF F_Traite_Homonymie (t_entite_1(1), nvl( t_entite_1(4), 0 ), t_entite_1(3),
                      t_entite_1(5), e2d( t_entite_1(6) ), loc_TYPE_ECHANGE 
                      ) = 'N' THEN
  -- homonymie blocage de l'insertion
  t_enreg(loc_idporte) := COALESCE(t_enreg(loc_idporte),0) + 1;
  GOTO Errexit;
END IF;
                    
-- S'agit-il d'une insertion ou d'une mise a jour d'individu ? 
-- ( NUMINDIVdonnée obligatoire dans le porte import Personne)

numindiv_maj := Recherche_Echange_Clef_Int (t_entite_1(1), 1);
Cle_primaire := t_entite_1(1);
IF numindiv_maj = 0 THEN
  flag_insere := 1;
ELSE
  flag_insere := 0;
END IF;

-- récupération du numéro individu de l'assuré
IF t_entite_1(18) = 1 THEN 
  loc_numassu   := Recherche_Echange_Clef_Int (t_entite_1(1), 1);
ELSE
  loc_numassu   := Recherche_Echange_Clef_Int (t_entite_1(17), 1);
  IF loc_numassu = 0 AND NVL(t_entite_1(17),0) > 0  THEN
    -- bloquer l'import, l'individu doit être lié via numassu à un assuré principal non présent dans Arthus
      erreur := 'Import. bloqué : assuré principal non présent dans Arthus';
      flag_erreur := 7;
      GOTO Errexit;
  END IF;
END IF;

/* -- -------  
-- INSERTION 
*/ -- -------

IF ( flag_insere = 1 ) THEN

  -- insertion générale
  flag_insere_2 := 1;
  flag_insere_3 := 1;
  flag_insere_4 := 1;
  flag_insere_6 := 1;
  flag_insere_7 := 1;
  flag_insere_8 := 1;

  IF ( flag_entite_1 = 1 ) THEN
  
    t_enreg(loc_idporte) := COALESCE(t_enreg(loc_idporte),0) + 1;
    loc_numindiv  := f_numero( 'INDVS' );
    
    IF loc_numassu = 0 THEN
      loc_numassu := loc_numindiv;
    END IF;
    numindiv_maj  := loc_numindiv; -- pour alimenter les infos de l'individu (adresse, contact ...)
    DBMS_OUTPUT.PUT_LINE( 'Insertion Individu Numindiv = '||loc_numindiv||' Cle externe = '||cle_primaire );
-- INDIVIDU          
    BEGIN
      INSERT INTO individu (
                            numindiv,
                            type,
                            nom,
                            qualite,
                            prenom,
                            datnais,
                            refcie,
                            codcourrier1,
                            codcourrier2,
                            codtitre,
                            sexe,
                            potentiel,
                            nomjf,
                            creation,
                            maj,
                            numutil,
                            numassu,
                            typassu,
                            typadr,
                            regime,
                            orgbase,
                            matorg,
                            cless,
                            rang,
                            natur,
                            caisse,
                            tel,
                            fax,
                            adr1,
                            adr2,
                            codpos,
                            ville,
                            codpays,
                            guichetorg,
                            cle,
                            guichetpmt,
                            email,
                            deces,
                            n_insee,
                            modificateur,
                            datnais_regime
                            )
          SELECT
                loc_numindiv,
                nvl( t_entite_1(2), 1 ),
                t_entite_1(3),
                nvl( t_entite_1(4), 0 ),
                t_entite_1(5),
                e2d( t_entite_1(6) ),
                t_entite_1(7),
                nvl(t_entite_1(8), nvl( t_entite_1(4), 0 )),
                nvl(t_entite_1(9),libelle.sens),
                t_entite_1(10),
                t_entite_1(11),
                t_entite_1(12),
                t_entite_1(13),
                nvl( e2d(t_entite_1(14)), trunc(sysdate) ),
                nvl( e2d(t_entite_1(15)), trunc(sysdate) ),
                nvl( t_entite_1(16), numutil_porte ),
                loc_numassu,
                t_entite_1(18), 
                t_entite_1(19),
                t_entite_1(20),
                nvl(t_entite_1(21),99),
                replace(t_entite_1(22),' ', Null),
                t_entite_1(23),
                t_entite_1(24),
                t_entite_1(25),
                t_entite_1(26),
                t_entite_1(27),
                t_entite_1(28),
                t_entite_1(29),
                t_entite_1(30),
                t_entite_1(31),
                t_entite_1(32),
                t_entite_1(33),
                t_entite_1(34),
                t_entite_1(35),
                t_entite_1(36),
                t_entite_1(37),
                t_entite_1(38),
                t_entite_1(39),
                t_entite_1(40),
                e2d( t_entite_1(41) )
          FROM  libelle
         WHERE  libelle.mnemo='QLTE'
           AND  libelle.code=nvl(t_entite_1(4),0);
           
    Insert_Echange_Clef (loc_numindiv, t_entite_1(1), 1, loc_TYPE_ECHANGE);

    -- histo_import
    Insert_histo_import (loc_idporte, loc_numindiv, 'C', 0);
    EXCEPTION WHEN OTHERS THEN
      erreur := Substr('Insertion individu : '||sqlerrm, 1, 128);
      flag_erreur := 1;
      GOTO Errexit;
    END;

  END IF;
      
ELSE

/* -- -------  
-- MISE A JOUR  Individu
*/ -- -------  

  IF ( flag_entite_1 = 1 AND flag_autorise_maj_1 = 1 ) THEN
    
    t_enreg(loc_idporte) := COALESCE(t_enreg(loc_idporte),0) + 1;
    DBMS_OUTPUT.PUT_LINE( 'Maj personne Cle externe = '||cle_primaire  );
      Begin
        SELECT SENS
          INTO LOC_SENS
          FROM LIBELLE
         WHERE MNEMO  = 'QLTE'
           AND CODE   = NVL(t_entite_1(4),0);
           
        ------------------
        -- INDIVIDU maj --
        ------------------
        UPDATE INDIVIDU
           SET
               type           = NVL( t_entite_1(2), 1 ),
               nom            = t_entite_1(3),
               qualite        = nvl( t_entite_1(4), 0 ),
               prenom         = t_entite_1(5),
               datnais        = e2d( t_entite_1(6) ),
               refcie         = t_entite_1(7),
               codcourrier1   = nvl(t_entite_1(8), nvl(t_entite_1(4),0)),
               codcourrier2   = nvl(t_entite_1(9),loc_sens),
               codtitre       = t_entite_1(10),
               sexe           = t_entite_1(11),
               potentiel      = t_entite_1(12),
               nomjf          = t_entite_1(13),
               numutil        = nvl( t_entite_1(16), numutil_porte ),
               numassu        = loc_numassu,
               typassu        = t_entite_1(18),
               typadr         = t_entite_1(19),
               regime         = t_entite_1(20),
               orgbase        = nvl(t_entite_1(21),99),
               matorg         = t_entite_1(22),
               cless          = t_entite_1(23),
               rang           = t_entite_1(24),
               natur          = t_entite_1(25),
               caisse         = t_entite_1(26),
               tel            = t_entite_1(27),
               fax            = t_entite_1(28),
               adr1           = t_entite_1(29),
               adr2           = t_entite_1(30),
               codpos         = t_entite_1(31),
               ville          = t_entite_1(32),
               codpays        = t_entite_1(33),
               guichetorg     = t_entite_1(34),
               cle            = t_entite_1(35),
               guichetpmt     = t_entite_1(36),
               email          = t_entite_1(37),
               deces          = t_entite_1(38),
               n_insee        = t_entite_1(39),
               modificateur   = t_entite_1(40),
               datnais_regime = e2d( t_entite_1(41) )
         WHERE numindiv  = numindiv_maj;

        -- histo_import
        Insert_histo_import (loc_idporte, numindiv_maj, 'M', 0);
    EXCEPTION WHEN OTHERS THEN
      erreur := SUBSTR('Maj individu : '||sqlerrm, 1, 128);
      flag_erreur := 1;
      GOTO Errexit;
    END;
  END IF;
      
  -- A tester au cas par cas :
  flag_insere_2 := 0;
  flag_insere_3 := 0;
  flag_insere_4 := 0;
  flag_insere_6 := 0;
  flag_insere_7 := 0;
  flag_insere_8 := 0;
  
  -- Adresse
  IF flag_entite_2 = 1 THEN

    loc_idadresse := Recherche_Echange_Clef_Int (t_entite_2(1), 2);
    IF loc_idadresse = 0 THEN
      flag_insere_2 := 1;
    ELSE
      flag_insere_2 := 0;
    END IF;
    IF numindiv_maj = 0 THEN
      numindiv_maj := Recherche_Echange_Clef_Int (t_entite_2(2), 1);
    END IF;
  END IF;
  
  -- PERS_HISTO_PHYS
  IF flag_entite_3 = 1 THEN
  
      loc_idpershistphys := Recherche_Echange_Clef_Int (t_entite_3(12), 3);
      
      IF loc_idpershistphys = 0 THEN
        flag_insere_3 := 1;
      ELSE
        flag_insere_3 := 0;
      END IF;
      IF numindiv_maj = 0 THEN
        numindiv_maj := Recherche_Echange_Clef_Int (t_entite_3(1), 1);
      END IF;
      
  END IF;
  
  -- RIB
  IF flag_entite_4 = 1 THEN

    loc_Rib := Recherche_Echange_Clef_Int (t_entite_4(1), 4);
    
    IF loc_Rib = 0 THEN
      flag_insere_4 := 1;
    ELSE
      flag_insere_4 := 0;
    END IF;
    
    IF numindiv_maj = 0 THEN
      numindiv_maj := Recherche_Echange_Clef_Int (t_entite_4(2), 1);
    END IF;
    
  END IF;
  
  -- PERS_MORALE
  IF flag_entite_6 = 1 THEN
  
    loc_idpersmorale := Recherche_Echange_Clef_Int (t_entite_6(1), 6);
    
    IF loc_idpersmorale = 0 THEN
      flag_insere_6 := 1;
    ELSE
      flag_insere_6 := 0;
    END IF;
    
    IF numindiv_maj = 0 THEN
      numindiv_maj := Recherche_Echange_Clef_Int (t_entite_6(1), 1);
    END IF;
    
  END IF;
  
  -- INTERLOCUTEUR
  IF flag_entite_7 = 1 THEN
  
    loc_idinterlocuteur := Recherche_Echange_Clef_Int (t_entite_7(1), 6);
    
    IF loc_idinterlocuteur = 0 THEN
      flag_insere_7 := 1;
    ELSE
      flag_insere_7 := 0;
    END IF;

    IF numindiv_maj = 0 THEN
      numindiv_maj := Recherche_Echange_Clef_Int (t_entite_7(2), 1);
    END IF;
    
  END IF;
  
  -- CONTACT
  IF flag_entite_8 = 1 THEN
  
    loc_idcontact := Recherche_Echange_Clef_Int (t_entite_8(9), 8);
    IF loc_idcontact = 0 THEN
      flag_insere_8 := 1;
    ELSE
      flag_insere_8 := 0;
    END IF;

    IF numindiv_maj = 0 THEN
      numindiv_maj := Recherche_Echange_Clef_Int (t_entite_8(1), 1);
    END IF;
  END IF;
    
END IF;

-------------------------------------------------------
-- INSERT / MAJ AUTRES ENTITES DU DOMAINE PERSONNE : --
-------------------------------------------------------

-------------------------
-- PERS_ADRESSE Insert --
-------------------------
IF ( flag_entite_2 = 1 AND flag_insere_2 = 1) THEN
  BEGIN
    SELECT  idadresse.nextval
      INTO  loc_idadresse
      FROM  Dual;
    DBMS_OUTPUT.PUT_LINE( 'Insertion adresse Numindiv = '||numindiv_maj||' Cle externe = '||cle_primaire  );

    INSERT INTO pers_adresse (
                              idadresse,
                              numindiv,
                              debut,
                              codope,
                              numgar,
                              defaut,
                              numutil,
                              maj,
                              no_voie,
                              bis,
                              type_voie,
                              nom_voie,
                              adresse_2,
                              comp_adresse,
                              codpos,
                              ville,
                              flag_cedex,
                              no_cedex,
                              codpays,
                              type
                              )
                      VALUES (
                              loc_idadresse,
                              numindiv_maj,
                              NVL( e2d(t_entite_2(3)), TRUNC(SYSDATE) ),
                              NVL( t_entite_2(4), 0 ),
                              NVL( t_entite_2(5), 0 ),
                              NVL( t_entite_2(6), 'O' ),
                              NVL( t_entite_2(7), numutil_porte ),
                              NVL( e2d(t_entite_2(8)), TRUNC(SYSDATE) ),
                              t_entite_2(9),
                              t_entite_2(10),
                              t_entite_2(11),
                              t_entite_2(12),
                              t_entite_2(13),
                              t_entite_2(14),
                              t_entite_2(15),
                              t_entite_2(16),
                              NVL( t_entite_2(17), 'N' ),
                              t_entite_2(18),
                              NVL( t_entite_2(19), 1 ),
                              NVL(t_entite_2(20), 1)
                              );
  
  Insert_Echange_Clef (loc_idadresse, t_entite_2(1), 2, loc_TYPE_ECHANGE);

  -- Si adresse internationnale
  IF (t_entite_2(22) IS NOT NULL OR
      t_entite_2(23) IS NOT NULL OR
      t_entite_2(24) IS NOT NULL OR
      t_entite_2(25) IS NOT NULL OR
      t_entite_2(26) IS NOT NULL )
  THEN

      DBMS_OUTPUT.PUT_LINE( 'Insertion adresse internationale Numindiv = '||numindiv_maj||' Cle externe = '||cle_primaire  );
      INSERT INTO adr_internationale (
                              idadresse,
                              adr1,
                              adr2,
                              adr3,
                              adr4,
                              adr5
                              )
                      VALUES (
                              loc_idadresse,
                              t_entite_2(22),
                              t_entite_2(23),
                              t_entite_2(24),
                              t_entite_2(25),
                              t_entite_2(26)
                              );

  END IF;

  EXCEPTION WHEN OTHERS THEN
    erreur := SUBSTR('Insertion ardresse/adr_internationale : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

----------------------
-- PERS_ADRESSE Maj --
----------------------

IF (flag_entite_2 = 1 AND flag_insere_2 = 0 AND flag_autorise_maj_2 = 1 ) THEN
  BEGIN

    IF loc_idadresse != 0 THEN
      DBMS_OUTPUT.PUT_LINE( 'Maj adresse Cle externe = '||cle_primaire||' Cle Interne = '||numindiv_maj );
      UPDATE pers_adresse
         SET
            debut         = nvl( e2d(t_entite_2(3)), debut ),
            codope        = nvl( t_entite_2(4), 0 ),
            numgar        = nvl( t_entite_2(5), 0 ),
            defaut        = nvl( t_entite_2(6), 'O' ),
            numutil       = nvl( t_entite_2(7), numutil_porte ),
            maj           = nvl( e2d(t_entite_2(8)), trunc(sysdate) ),
            no_voie       = t_entite_2(9),
            bis           = t_entite_2(10),
            type_voie     = t_entite_2(11),
            nom_voie      = t_entite_2(12),
            adresse_2     = t_entite_2(13),
            comp_adresse  = t_entite_2(14),
            codpos        = t_entite_2(15),
            ville         = t_entite_2(16),
            flag_cedex    = nvl( t_entite_2(17), 'N' ),
            no_cedex      = t_entite_2(18),
            codpays       = nvl( t_entite_2(19), codpays ),
            type          = nvl(t_entite_2(20), 1)
      WHERE idadresse     = loc_idadresse; 

      -- Si adresse internationnale
      IF (t_entite_2(22) IS NOT NULL OR
          t_entite_2(23) IS NOT NULL OR
          t_entite_2(24) IS NOT NULL OR
          t_entite_2(25) IS NOT NULL OR
          t_entite_2(26) IS NOT NULL )
      THEN

        DBMS_OUTPUT.PUT_LINE( 'Maj adresse internationale Numindiv = '||numindiv_maj||' Cle externe = '||cle_primaire  );
        UPDATE adr_internationale
          SET 
            adr1 = t_entite_2(22),
            adr2 = t_entite_2(23),
            adr3 = t_entite_2(24),
            adr4 = t_entite_2(25),
            adr5 = t_entite_2(26)
            WHERE idadresse = loc_idadresse;
            
      END IF;
  
    END IF;
    
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( SUBSTR('Maj adresse/adr_internationale : '||sqlerrm, 1, 80) );
    erreur := SUBSTR('Maj adresse/adr_internationale : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

----------------------------
-- PERS_HISTO_PHYS Insert --
----------------------------
IF ( flag_entite_3 = 1 AND flag_insere_3 = 1) THEN
  BEGIN
    DBMS_OUTPUT.PUT_LINE( 'Insertion situation Numindiv = '||numindiv_maj||' Cle externe = '||cle_primaire  );
    
    SELECT  idpershistphys.nextval
      INTO  loc_idpershistphys
      FROM  Dual;
      
    INSERT INTO pers_histo_phys (
                                idpershistphys,
                                numindiv,
                                debut,
                                situ_fam,
                                situ_prof,
                                csp_1,
                                csp_2,
                                profession,
                                salaire,
                                numutil,
                                creation,
                                maj
                                )
                        VALUES (
                                loc_idpershistphys,
                                numindiv_maj,
                                NVL( e2d(t_entite_3(2)), TRUNC(SYSDATE) ),
                                t_entite_3(3),
                                t_entite_3(4),
                                t_entite_3(5),
                                t_entite_3(6),
                                t_entite_3(7),
                                t_entite_3(8),
                                NVL( t_entite_3(9), numutil_porte),
                                NVL( e2d(t_entite_3(10)), TRUNC(SYSDATE) ),
                                NVL( e2d(t_entite_3(11)), TRUNC(SYSDATE) )
                                );
  
  Insert_Echange_Clef (loc_idpershistphys, t_entite_3(12), 3, loc_TYPE_ECHANGE);
  
  EXCEPTION WHEN OTHERS THEN
      erreur := SUBSTR('Insertion situation : '||sqlerrm, 1, 128);
      flag_erreur := 1;
      GOTO Errexit;
  END;
END IF;

-------------------------
-- PERS_HISTO_PHYS Maj --
-------------------------  
IF ( flag_entite_3 = 1 AND flag_insere_3 = 0 AND flag_autorise_maj_3 = 1 ) THEN
  DBMS_OUTPUT.PUT_LINE( 'Maj situation Cle externe = '||cle_primaire||' Cle Interne = '||numindiv_maj  );
  BEGIN
    UPDATE pers_histo_phys
       SET
          debut       = nvl( e2d(t_entite_3(2)), trunc(sysdate) ),
          situ_fam    = t_entite_3(3),
          situ_prof   = t_entite_3(4),
          csp_1       = t_entite_3(5),
          csp_2       = t_entite_3(6),
          profession  = t_entite_3(7),
          salaire     = t_entite_3(8),
          numutil     = nvl( t_entite_3(9), numutil_porte),
          maj         = nvl( e2d(t_entite_3(11)), trunc(sysdate) )
    WHERE idpershistphys = loc_idpershistphys;
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( SUBSTR('Maj situation : '||sqlerrm, 1, 80) );
    erreur := SUBSTR('Maj situation : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

----------------
-- RIB Insert --
----------------
IF ( flag_entite_4 = 1 AND flag_insere_4 = 1) THEN
  BEGIN
    SELECT  idrib.nextval
      INTO  loc_idrib
      FROM  Dual;
  
    DBMS_OUTPUT.PUT_LINE( 'Insertion Rib Numindiv = '||numindiv_maj||' Cle externe = '||cle_primaire  );

    INSERT INTO rib (
                    idrib,
                    numindiv,
                    type,
                    debut,
                    codope,
                    numgar,
                    modpmt,
                    devise_compte,
                    devise_ope,
                    creation,
                    numutil_creation,
                    codbque,
                    guichet,
                    compte,
                    clerib,
                    intitule,
                    domiciliation,
                    maj,
                    numutil_maj,
                    clef_iban,
                    bban,
                    bic,
                    codpays,
                    codbque_etrg,
                    typ_bq_etrg,
                    guichet_etrg,
                    typ_gui_etrg,
                    compte_etrg,
                    clerib_etrg,
                    typ_cle_etrg,
                    numindiv_etrg,
                    nature
                    )
            VALUES (
                    loc_idrib,
                    numindiv_maj,
                    NVL( t_entite_4(3), 2 ),
                    NVL( e2d(t_entite_4(4)), TRUNC(SYSDATE) ),
                    NVL( t_entite_4(5), 0 ),
                    NVL( t_entite_4(6), 0 ),
                    NVL( t_entite_4(7), 1 ),
                    NVL( t_entite_4(8), 1 ),
                    NVL( t_entite_4(9), 1 ),
                    NVL( e2d(t_entite_4(10)), TRUNC(SYSDATE) ),
                    NVL( t_entite_4(11), numutil_porte ),
                    t_entite_4(12),
                    t_entite_4(13),
                    t_entite_4(14),
                    t_entite_4(15),
                    t_entite_4(16),
                    t_entite_4(17),
                    NVL( e2d(t_entite_4(18)), TRUNC(SYSDATE) ),
                    NVL( t_entite_4(19), numutil_porte ),
                    t_entite_4(20),
                    t_entite_4(21),
                    t_entite_4(22),
                    t_entite_4(23),
                    t_entite_4(24),
                    t_entite_4(25),
                    t_entite_4(26),
                    t_entite_4(27),
                    t_entite_4(28),
                    t_entite_4(29),
                    t_entite_4(30),
                    t_entite_4(31),
                    t_entite_4(32)
                    );

  Insert_Echange_Clef (loc_idrib, t_entite_4(1), 4, loc_TYPE_ECHANGE);
  
  EXCEPTION WHEN OTHERS THEN
      erreur := SUBSTR('Insertion Rib : '||sqlerrm, 1, 128);
      flag_erreur := 1;
      GOTO Errexit;
  END;
END IF;

-------------
-- RIB Maj --
-------------  
IF ( flag_entite_4 = 1 AND flag_insere_4 = 0 AND flag_autorise_maj_4 = 1 ) THEN

  DBMS_OUTPUT.PUT_LINE( 'Maj Rib Cle externe = '||cle_primaire||' Cle Interne = '||numindiv_maj  );
  BEGIN
    UPDATE rib 
       SET
          debut         = NVL( e2d(t_entite_4(4)), TRUNC(SYSDATE) ),
          codope        = NVL( t_entite_4(5), 0 ),
          numgar        = NVL( t_entite_4(6), 0 ),
          modpmt        = NVL( t_entite_4(7), 1 ),
          devise_compte = NVL( t_entite_4(8), 1 ),
          devise_ope    = NVL( t_entite_4(9), 1 ),
          codbque       = t_entite_4(12),
          guichet       = t_entite_4(13),
          compte        = t_entite_4(14),
          clerib        = t_entite_4(15),
          intitule      = t_entite_4(16),
          domiciliation = t_entite_4(17),
          maj           = NVL( e2d(t_entite_4(18)), TRUNC(SYSDATE) ),
          numutil_maj   = NVL( t_entite_4(19), numutil_porte ),
          clef_iban     = t_entite_4(20),
          bban          = t_entite_4(21),
          bic           = t_entite_4(22),
          codpays       = t_entite_4(23),
          codbque_etrg  = t_entite_4(24),
          typ_bq_etrg   = t_entite_4(25),
          guichet_etrg  = t_entite_4(26),
          typ_gui_etrg  = t_entite_4(27),
          compte_etrg   = t_entite_4(28),
          clerib_etrg   = t_entite_4(29),
          typ_cle_etrg  = t_entite_4(30),
          numindiv_etrg = t_entite_4(31),
          nature        = t_entite_4(32)
    WHERE idrib = loc_Rib;
    -- WHERE numindiv = numindiv_maj;
  EXCEPTION WHEN OTHERS THEN
    erreur := SUBSTR('Maj Rib : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

------------------------
-- PERS_MORALE Insert --
------------------------
IF ( flag_entite_6 = 1 AND flag_insere_6 = 1) THEN
  BEGIN
    DBMS_OUTPUT.PUT_LINE( 'Insertion personne Morale = '||numindiv_maj||' Cle externe = '||cle_primaire  );

    INSERT INTO pers_morale (
                            numindiv,
                            creation,
                            siret,
                            ape,
                            code_naf,
                            vip,
                            convention,
                            potentiel,
                            abrege,
                            nom_compta
                            )
                    VALUES (
                            numindiv_maj,
                            NVL( e2d(t_entite_6(2)), TRUNC(SYSDATE) ),
                            t_entite_6(3),
                            t_entite_6(4),
                            t_entite_6(5),
                            t_entite_6(6),
                            t_entite_6(7),
                            t_entite_6(8),
                            t_entite_6(9),
                            t_entite_6(10)
                            );

  Insert_Echange_Clef (numindiv_maj, t_entite_6(1), 6, loc_TYPE_ECHANGE);

  EXCEPTION WHEN OTHERS THEN
    erreur := SUBSTR('Insertion personne morale : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

---------------------
-- PERS_MORALE Maj --
---------------------
IF ( flag_entite_6 = 1 AND flag_insere_6 = 0 AND flag_autorise_maj_6 = 1 ) THEN

  DBMS_OUTPUT.PUT_LINE( 'Maj personne morale = '||cle_primaire||' Cle Interne = '||numindiv_maj  );

  BEGIN
    UPDATE pers_morale
       SET
           siret        = t_entite_6(3),
           ape          = t_entite_6(4),
           code_naf     = t_entite_6(5),
           vip          = t_entite_6(6),
           convention   = t_entite_6(7),
           potentiel    = t_entite_6(8),
           abrege       = t_entite_6(9),
           nom_compta   = t_entite_6(10)
     WHERE numindiv     = numindiv_maj;
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( SUBSTR('Maj personne morale : '||sqlerrm, 1, 80) );
    erreur := SUBSTR('Maj personne morale : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

--------------------------
-- INTERLOCUTEUR Insert --
--------------------------
IF ( flag_entite_7 = 1 AND flag_insere_7 = 1) THEN
  BEGIN

    loc_interloc := Recherche_Echange_Clef_Int (t_entite_7(6), 1);

    SELECT  idinterlocuteur.nextval
      INTO  loc_idinterlocuteur
      FROM  Dual;

    DBMS_OUTPUT.PUT_LINE( 'Insertion intelocuteur ID = '||loc_idinterlocuteur||' Cle externe = '||cle_primaire  );
    
    INSERT INTO interlocuteur (
                              idinterlocuteur,
                              interlocuteur,
                              numindiv,
                              ope_crrr,
                              valide,
                              fonction
                              )
                      VALUES (
                              loc_idinterlocuteur,
                              loc_interloc,
                              numindiv_maj,
                              NVL(t_entite_7(3),0),
                              NVL(t_entite_7(4),'O'),
                              t_entite_7(5)
                              );

    Insert_Echange_Clef (loc_idinterlocuteur, t_entite_7(6), 7, loc_TYPE_ECHANGE);

  EXCEPTION WHEN OTHERS THEN
    erreur := SUBSTR('Insertion interlocuteur : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

-----------------------
-- INTERLOCUTEUR Maj --
-----------------------  
IF ( flag_entite_7 = 1 AND flag_insere_7 = 0 AND flag_autorise_maj_7 = 1 ) THEN
  DBMS_OUTPUT.PUT_LINE( 'Maj interlocuteur ID = '||loc_idinterlocuteur||' Cle Interne = '||numindiv_maj  );
  BEGIN
    UPDATE interlocuteur
       SET
           ope_crrr       = nvl(t_entite_7(3),0),
           valide         = nvl(t_entite_7(4),'O'),
           fonction       = t_entite_7(5)
     WHERE idinterlocuteur = loc_idinterlocuteur;

  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( SUBSTR('Maj interlocuteur : '||sqlerrm, 1, 80) );
    erreur := SUBSTR('Maj interlocuteur : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;

--------------------
-- CONTACT Insert --
--------------------
IF ( flag_entite_8 = 1 AND flag_insere_8 = 1) THEN
  BEGIN
             
    DBMS_OUTPUT.PUT_LINE( 'Insertion contact = '||numindiv_maj||' Cle externe = '||cle_primaire  );

    SELECT  idcontact.nextval
      INTO  loc_idcontact
      FROM  Dual;
      
    INSERT INTO contact (
                        idcontact,
                        numindiv,
                        nature,
                        type,
                        coordonnee,
                        flag,
                        creation,
                        maj,
                        numutil
                        )
                VALUES (
                        loc_idcontact,
                        numindiv_maj,
                        t_entite_8(2),
                        t_entite_8(3),
                        t_entite_8(4),
                        t_entite_8(5),
                        NVL( e2d(t_entite_8(6)), TRUNC(SYSDATE) ),
                        NVL( e2d(t_entite_8(7)), TRUNC(SYSDATE) ),
                        t_entite_8(8)
                        );

  Insert_Echange_Clef (loc_idcontact, t_entite_8(9), 8, loc_TYPE_ECHANGE);

  EXCEPTION WHEN OTHERS THEN
    erreur := SUBSTR('Insertion contact : '||sqlerrm, 1, 128);
    flag_erreur := 1;
    GOTO Errexit;
  END;
END IF;
  
-----------------
-- CONTACT Maj --
-----------------  
IF ( flag_entite_8 = 1 AND flag_insere_8 = 0 AND flag_autorise_maj_8 = 1 ) THEN
  
    DBMS_OUTPUT.PUT_LINE( 'Maj contact = '||cle_primaire||' Cle Interne = '||numindiv_maj  );
    
    BEGIN
      UPDATE contact
         SET
            coordonnee  = t_entite_8(4),
            flag        = t_entite_8(5),
            maj         = NVL( e2d(t_entite_8(7)), TRUNC(SYSDATE) ),
            numutil     = t_entite_8(8)
        WHERE idcontact  = loc_idcontact;

    EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE( SUBSTR('Maj contact : '||sqlerrm, 1, 80) );
      erreur := SUBSTR('Maj contact : '||sqlerrm, 1, 128);
      flag_erreur := 1;
      GOTO Errexit;
    END;

END IF;

  <<Errexit>>
    IF flag_erreur != 0 THEN
      G_niv_msg	:= 0;
      G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_personne - '||erreur,1,132);
      P_INS_journal;
    END IF;
END  Charge_personne;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_couverture
--  parametres
--  entree : 
--  sortie :
--  But : Mise à jour ou insertion des données dans les tables suivantes
--   -- TRANSCOD
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_couverture  (
                              a_idporte  IN  NUMBER
                              )
IS
aClef           NUMBER(9);
aTest           NUMBER(1);
BEGIN

  -- controle homonymie
  IF F_Blocage_Homonyme(t_entite_30(10), loc_TYPE_ECHANGE) = 'O' THEN
    flag_erreur := 8;
  END IF;

/*
  -- control parametrage PARAM_TRANSCOD
  IF flag_erreur = 0 THEN
    
    BEGIN
      SELECT 1 
          INTO aTest
            FROM  param_transcod
           WHERE  param_transcod.idporte      = a_idporte
             AND  param_transcod.cle1         = t_entite_30(1)  -- numgar
             AND  param_transcod.cle2         = t_entite_30(2)
             AND  param_transcod.cle3         = t_entite_30(3)  -- numfor
             ;

    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      -- erreur parametrage manquant dans PARAM_TRANSCOD
      flag_erreur := 1; 
    END;
  END IF;
*/
  -- traitement insertion dans TRANSCOD
  IF flag_erreur = 0 THEN
    
    BEGIN
      SELECT  1 
        INTO  flag_insere
        FROM  Dual
       WHERE NOT EXISTS (
                         SELECT  1
                           FROM  transcod
                            WHERE transcod.cle_primaire   = t_entite_30(10) -- numindiv ou clef externe
                            AND   transcod.cle1           = t_entite_30(1)  -- numgar
                            AND   transcod.cle3           = t_entite_30(3)  -- numfor
                            AND   transcod.idporte        = a_idporte       -- porte utilisé
                            AND   transcod.assure         = t_entite_30(19) -- assure
                          );
    EXCEPTION WHEN NO_DATA_FOUND THEN 
      flag_insere := 0; 
    END;
  
    BEGIN
    
      -- INSERTION  
      
      IF (flag_insere=1)
      THEN
        IF ( flag_entite_30 = 1 ) THEN
          DBMS_OUTPUT.PUT_LINE( 'Insertion transcodif Cle Interne = '||t_entite_30(10)  );
          BEGIN
    
            INSERT INTO transcod
                        (cle_primaire,cle1,cle2,cle3,debut,idporte,cle6,cle7,cle8,cle9,
                         type_cle_primaire,type_cle1,type_cle2,type_cle3,type_cle6,
                         type_cle7,type_cle8,type_cle9, assure, cle10, cle11, cle12,
                         type_cle10, type_cle11, type_cle12
                        )
                  SELECT  
                          t_entite_30(10),
                          t_entite_30(1),
                          t_entite_30(2),
                          t_entite_30(3),
                          nvl(e2d(t_entite_30(4)),trunc(sysdate)),
                          a_idporte,
                          t_entite_30(6),
                          t_entite_30(7),
                          t_entite_30(8),
                          t_entite_30(9),
                          t_entite_30(11),
                          t_entite_30(12),
                          t_entite_30(13),
                          t_entite_30(14),
                          t_entite_30(15),
                          t_entite_30(16),
                          t_entite_30(17),
                          t_entite_30(18),
                          NVL(t_entite_30(19), 'N'),
                          t_entite_30(20),
                          t_entite_30(21),
                          t_entite_30(22),
                          t_entite_30(23),
                          t_entite_30(24),
                          t_entite_30(25)
                    FROM  dual;
          END;
        END IF;
      ELSE
  
    -- MISE A JOUR 
  
        BEGIN
          
          UPDATE transcod
             SET
                  cle2              = t_entite_30(2),
                  debut             = nvl(e2d(t_entite_30(4)),trunc(sysdate)),
                  cle6              = t_entite_30(6),
                  cle7              = t_entite_30(7),
                  cle8              = t_entite_30(8),
                  cle9              = t_entite_30(9),
                  type_cle1         = t_entite_30(12),
                  type_cle2         = t_entite_30(13),
                  type_cle3         = t_entite_30(14),
                  type_cle6         = t_entite_30(15),
                  type_cle7         = t_entite_30(16),
                  type_cle8         = t_entite_30(17),
                  type_cle9         = t_entite_30(18),
                  assure            = NVL(t_entite_30(19), 'N'),
                  cle10             = t_entite_30(20),
                  cle11             = t_entite_30(21),
                  cle12             = t_entite_30(22),
                  type_cle10        = t_entite_30(23),
                  type_cle11        = t_entite_30(24),
                  type_cle12        = t_entite_30(25)
            WHERE cle_primaire          = t_entite_30(10)
              AND cle1                  = t_entite_30(1) -- numgar
              AND cle3                  = t_entite_30(3) -- numfor
              AND idporte               = a_idporte
              AND transcod.assure       = t_entite_30(19); -- assure
        END;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE( SUBSTR('ERREUR Maj transcod : '||sqlerrm, 1, 80) );
      flag_erreur := 1;
      G_niv_msg	:= 0;
      G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_couverture - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
      P_INS_journal;
      GOTO Errexit;
    END;
  END IF;

<<Errexit>>
  NULL;
END  Charge_couverture;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_adhesion
--  parametres
--  entree : 
--   - identifiant du porte  
--     a_idporte IN NUMBER
--   - 
--     a_motif   IN NUMBER
--  sortie :
--  But : Inserer les donnees dans les table adhe_cntrt
--                                           histo_adhesion
--                                           adhe_cntrt_membre
--                                           adhesion
--        et supprimer de la table transcod    
-- 31 Adhésion            (adhe_cntrt)
-- 32 Situation adhésion  (histo_adhesion)
-- 33 Affiliés            (adhe_cntrt_membre)
-- 34 Couverture          (adhésion)                                         
*/ -- -----------------------------------------------------------------
PROCEDURE Charge_adhesion(a_idporte IN NUMBER
                         ,a_motif   IN NUMBER)
IS

  CURSOR Fetch_transcod
  IS
  SELECT  *
    FROM  transcod
    WHERE idporte = a_idporte ORDER BY assure, transcod.cle_primaire;

  loc_transcod fetch_transcod%ROWTYPE;
  loc_numindiv    NUMBER;
  loc_idadhesion  NUMBER;
  loc_typassu     NUMBER;
  loc_typadr      NUMBER;
  loc_numassu     NUMBER;
  loc_numorg      NUMBER;
  regime          NUMBER;
  
  loc_idhistoadhe     NUMBER;
  loc_idadhecntrtmb   NUMBER;
  loc_idcouverture    NUMBER;
  
  nbcount             NUMBER;
  
  L_etendue           NUMBER DEFAULT 2;
  L_numfor            NUMBER;
  L_ins_journal       BOOLEAN DEFAULT FALSE;
  L_valeur            NUMBER DEFAULT 0;
  L_code_pays         NUMBER DEFAULT 1;
  L_session           NUMBER DEFAULT 0;
  L_date_trait        DATE  DEFAULT SYSDATE;
  O_code_msg          mess_erreur.code_msg%TYPE;

  erreur_transcod     NUMBER;
  
BEGIN
  FOR loc_transcod IN fetch_transcod
  LOOP
    BEGIN
      erreur_transcod := 0;
      
      -- cle_primaire = (si type_cle_primaire=4 Numindiv si type_cle_primaire=5 clef externe)
      IF loc_transcod.type_cle_primaire = 4 THEN
        SELECT  numindiv,
                typassu,
                typadr,
                NVL(orgbase,99),
                numassu
          INTO  loc_numindiv,
                loc_typassu,
                loc_typadr,
                loc_numorg,
                loc_numassu
          FROM  indvs
         WHERE  numindiv = loc_transcod.cle_primaire;
      ELSIF loc_transcod.type_cle_primaire = 5 THEN
        loc_numindiv := Recherche_Echange_Clef_Int (loc_transcod.cle_primaire, 1);
        SELECT  numindiv,
                typassu,
                typadr,
                NVL(orgbase,99),
                numassu
          INTO  loc_numindiv,
                loc_typassu,
                loc_typadr,
                loc_numorg,
                loc_numassu
          FROM  indvs
         WHERE  numindiv = loc_numindiv;
      END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        flag_erreur:=1;
    END;
        
    -- INSERTION ou MAJ ? (pour l'instant gestion insert uniquement   flag_autorise_maj_30 = 1)
    flag_insere_adh   := 0;
    flag_insere_memb  := 0;
    flag_insere_couv  := 0;
    
    loc_idadhesion := Recherche_Echange_Clef_Int (loc_transcod.cle6, 31);
    
    -- insertion si cela concerne une adhésion (loc_transcod.ASSURE = 'N' suffitrait)
    IF loc_typassu = 1 AND loc_idadhesion = 0 and loc_transcod.ASSURE = 'N' THEN
    
      t_enreg(loc_idporte) := COALESCE(t_enreg(loc_idporte),0) + 1;
--      SELECT idadhesion.NEXTVAL
--        INTO loc_idadhesion
--        FROM dual;
     /* SELECT NVL(MAX(idadhesion), 0) + 1
        INTO    loc_idadhesion
        FROM    adhe_cntrt;  */
  
     loc_idadhesion := pk_adhesion.f_idadhesion;  -- unification des idaadhesion projet BIA CLI le 27/08/2018

      DBMS_OUTPUT.PUT_LINE( 'idadhesion  = '||loc_idadhesion || 'personne  = '||loc_numindiv);

      INSERT INTO adhe_cntrt
                  (idadhesion
                  ,ref_ext
                  ,numgar
                  ,numadhe
                  ,date_adhe
                  ,meme_gar
                  ,date_fin_adhe
                  ,numquerable
                  ,fract
                  ,echesuiv
                  ,dereche
                  ,mregl
                  ,delai
                  ,dsous
                  ,numutil
                  ,eche_anniv)
           SELECT  loc_idadhesion
                  ,loc_transcod.cle10
                  ,param_transcod.cle1_interne
                  ,loc_numindiv
                  ,loc_transcod.debut
                  ,'N'
                  ,''
                  ,loc_numindiv 
                  ,loc_transcod.cle7
                  ,''
                  ,null
                  ,loc_transcod.cle8
                  ,loc_transcod.cle9
                  ,loc_transcod.debut
                  ,f_numutil
                  ,CASE WHEN contrat.TYPE_ECHE = 1 -- Contrat Glissant 
                      THEN loc_transcod.debut
                      ELSE contrat.eche_anniv
                   END CASE
            FROM  param_transcod
                 ,contrat
           WHERE  param_transcod.idporte      = a_idporte
             AND  param_transcod.cle1_interne = contrat.numgar
             AND  param_transcod.cle1         = loc_transcod.cle1
             AND  param_transcod.cle2         = loc_transcod.cle2
             AND  param_transcod.cle3         = loc_transcod.cle3
             AND  loc_typadr                  = param_transcod.cle2;

      IF SQL%rowcount = 1 THEN
      
        COMMIT;
        Insert_Echange_Clef (loc_idadhesion, loc_transcod.cle6 , 31, loc_TYPE_ECHANGE);

        -- histo_import
        Insert_histo_import (a_idporte, loc_idadhesion, 'C', 0);
        
        DBMS_OUTPUT.PUT_LINE( 'insertion adhe_cntrt  = '||loc_idadhesion  );
  
        SELECT idhistoadhe.NEXTVAL
          INTO loc_idhistoadhe
          FROM DUAL;
  
        INSERT INTO histo_adhesion
                   (idhistoadhe
                   ,idadhesion
                   ,debut
                   ,datsai
                   ,etat
                   ,motif
                   ,numutil)
            SELECT loc_idhistoadhe
                  ,loc_idadhesion
                  ,loc_transcod.debut
                  ,sysdate
                  ,0
                  ,a_motif
                  ,f_numutil
              FROM dual;
        
        IF SQL%rowcount = 1 THEN
          IF loc_transcod.type_cle10 = '17' THEN
            Insert_Echange_Clef (loc_idhistoadhe, loc_transcod.cle10 , 32, loc_TYPE_ECHANGE);
          END IF;
          DBMS_OUTPUT.PUT_LINE( 'insertion histo_adhesion  = '||loc_idhistoadhe  );
        ELSE
          flag_erreur := 1;
          erreur_transcod := 1;
        END IF;
              
      ELSE
        flag_erreur := 1;
        erreur_transcod := 1;
        DBMS_OUTPUT.PUT_LINE( 'Echec insertion adhe_cntrt  = '||loc_idadhesion || ' , controler PARAM_TRANSCOD' );
        
      END IF; -- IF SQL%rowcount = 1 THEN

    END IF;

    IF loc_transcod.assure = 'O'  THEN -- assuré 

      loc_idadhecntrtmb := Recherche_Echange_Clef_Int (loc_transcod.cle11, 33);
      -- Contrats membres -- 
      SELECT COUNT(*) 
        INTO nbcount
        FROM adhe_cntrt_membre 
          WHERE idadhesion  = loc_idadhesion 
            AND numindiv    = loc_numindiv;
            
      IF nbcount = 0 THEN
        SELECT idadhecntrtmb.NEXTVAL
          INTO loc_idadhecntrtmb
          FROM DUAL;

        INSERT INTO adhe_cntrt_membre
                   (idadhecntrtmb
                   ,idadhesion
                   ,numindiv
                   ,typadr
                   ,numbene)
             SELECT loc_idadhecntrtmb
                   ,loc_idadhesion
                   ,loc_numindiv
                   ,loc_typadr
                   ,''
              FROM dual
             WHERE EXISTS(SELECT 1 
                            FROM adhe_cntrt
                           WHERE idadhesion = loc_idadhesion)
               AND loc_idadhesion!=0;

        IF SQL%rowcount = 1 THEN
        
          Insert_Echange_Clef (loc_idadhecntrtmb, loc_transcod.cle11 , 33, loc_TYPE_ECHANGE);
          DBMS_OUTPUT.PUT_LINE( 'insertion adhe_cntrt_membre  = '||loc_idadhecntrtmb);
        ELSE
          flag_erreur := 1;
          erreur_transcod := 1;
        END IF;
      END IF;

    -- couvertures --
    
    loc_idcouverture := Recherche_Echange_Clef_Int (loc_transcod.cle12, 34);
    IF loc_idcouverture = 0 THEN
    
      SELECT COUNT(idcouverture)
              INTO nbcount FROM adhesion, gar_cntrt, param_transcod
                                  WHERE param_transcod.idporte = a_idporte
                                    AND param_transcod.cle1    = loc_transcod.cle1
                                    AND param_transcod.cle2    = loc_transcod.cle2
                                    AND param_transcod.cle3    = loc_transcod.cle3
                                    AND gar_cntrt.numfor       = param_transcod.cle2_interne
                                    AND gar_cntrt.numgar       = param_transcod.cle1_interne
                                    AND loc_idadhesion        != 0
                                    AND adhesion.idadhesion  = loc_idadhesion
                                    AND adhesion.numindiv    = loc_numindiv
                                    AND adhesion.numgar      = param_transcod.cle1_interne
                                    AND adhesion.numfor      = param_transcod.cle2_interne
                                    AND adhesion.datapli     = loc_transcod.debut
                                    AND adhesion.etat        = 1
                                    AND adhesion.typfor      = gar_cntrt.type
                                    AND adhesion.numorg      = loc_numorg
                                    AND adhesion.flag_regime = 'C'
                                    AND adhesion.dis_carence = 'O'
                                    AND adhesion.dis_franchise = 'O'
                                    AND adhesion.rang        = 1
                                    AND adhesion.regime      = regime;
    
      IF nbcount = 0 THEN
        -- couverture à créer
        
        SELECT idcouverture.NEXTVAL
          INTO loc_idcouverture
          FROM DUAL;
          
  		  regime := 1;
  		  
        INSERT INTO adhesion
                   (idcouverture
                   ,idadhesion
                   ,numindiv
                   ,numgar
                   ,numfor
                   ,datapli
                   ,etat
                   ,typfor
                   ,numorg
                   ,flag_regime
                   ,dis_carence
                   ,dis_franchise
                   ,rang
                   ,regime
                   ,numutil
                   ,creation)
            SELECT loc_idcouverture
                   ,loc_idadhesion
                   ,loc_numindiv
                   ,param_transcod.cle1_interne
                   ,param_transcod.cle2_interne
                   ,loc_transcod.debut
                   ,1
                   ,gar_cntrt.type
                   ,loc_numorg
                   ,'C'
                   ,'O'
                   ,'O'
                   ,1
                   ,regime
                   ,f_numutil
                   ,SYSDATE
              FROM gar_cntrt,
                   param_transcod
             WHERE param_transcod.idporte = a_idporte
               AND param_transcod.cle1    = loc_transcod.cle1
               AND param_transcod.cle2    = loc_transcod.cle2
               AND param_transcod.cle3    = loc_transcod.cle3
               AND gar_cntrt.numfor       = param_transcod.cle2_interne
               AND gar_cntrt.numgar       = param_transcod.cle1_interne
               AND loc_idadhesion        != 0;
  
          IF SQL%rowcount = 1 THEN
            SELECT numfor
                INTO L_numfor
              FROM ADHESION WHERE IDCOUVERTURE = loc_idcouverture;
            -- insertion donnees utilisateur attachée à l'adhésion et aux personnes couvertes
            L_session       := G_session;
            PK_insert_var.P_INS_val_var(L_etendue,
                                 loc_idadhesion,
                                 L_numfor,
                                 loc_numindiv,
                                 L_ins_journal,
                                 L_valeur,
                                 L_code_pays,
                                 L_session, 
                                 L_date_trait,
                                 O_code_msg);
            -- L_session     => L_session Number := userenv('sessionid');
            DBMS_OUTPUT.PUT_LINE( 'insertion couverture - message : '||O_code_msg);
            Insert_Echange_Clef (loc_idcouverture, loc_transcod.cle12 , 34, loc_TYPE_ECHANGE);
            DBMS_OUTPUT.PUT_LINE( 'insertion couverture  = '||loc_idcouverture  );
          ELSE
            flag_erreur := 1;
            erreur_transcod := 1;
          END IF;
          
        END IF;
      END IF;
      
    END IF;


    IF erreur_transcod = 0 THEN
      DELETE FROM transcod
        WHERE cle_primaire            = loc_transcod.cle_primaire
            AND cle1                  = loc_transcod.cle1
            AND cle3                  = loc_transcod.cle3
            AND idporte               = a_idporte;
      COMMIT;
    END IF;
    
  END LOOP;
  
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( SUBSTR('ERREUR Charge_adhesion : '||sqlerrm, 1, 80) );
    erreur := SUBSTR('Charge_adhesion : '||sqlerrm, 1, 80);
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_adhesion - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;

END Charge_adhesion;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_role
--  parametres
--  entree : 
--   - role 
--     a_role IN NUMBER
--  sortie :
--  But : Inserer les donnees dans la table PERS_INTERMEDIAIRE 
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_role(a_role IN NUMBER)
IS
BEGIN
  IF (a_role=8)
  THEN
    IF (flag_insere=1)
    THEN
      INSERT INTO pers_intermediaire
                (numindiv
                ,numinterm
                ,mode_retro)
          SELECT loc_numindiv
                ,loc_numindiv
                ,2
            FROM dual;
    END IF;
  END IF;
END Charge_role;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Charge_Donnee_Import
--  parametres
--  entree : 
--   - aTYPE_ECHANGE type de l'échange - origine de l'import
--  But : lire les lignes de données de l'import pour chargement dans la base
*/ -- -----------------------------------------------------------------

PROCEDURE Charge_Donnee_Import (
                                aTYPE_ECHANGE IN NUMBER,
                                I_session	IN	NUMBER				Default 1,
                                I_niv_msg	IN	NUMBER				Default 1,
                                O_found	OUT	NUMBER,
                                O_erreur	OUT	VARCHAR2
                                )
IS
  a_newline           VARCHAR2(1024);
  C_Import            ECHANGE_DONNEE%Rowtype;
  maj_etat            NUMBER;
  a_idporte           NUMBER;
  o_flag_erreur       NUMBER;
  a_nb_enreg          NUMBER;
  loc_idporte         HISTO_IMPORT.IDPORTE%Type;
BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
	
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
  --
	G_niv_msg	:= 1;
	G_msg_adm	:= 'PK_IMPORT Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	
  flag_erreur := 0;
  loc_TYPE_ECHANGE := aTYPE_ECHANGE;
  loc_numremiseglobal := 0;
  t_enreg := donnum();
  t_enreg.EXTEND(20);
  
  -- import des données (sens 0) des code_etat à 0 (non traité) et 8 (homonymes possibles)
  FOR C_Import IN 
    (SELECT  ECHANGE_DONNEE.NUM_EXTRACTION,
            ECHANGE_DONNEE.NUM_LIGNE,
            ECHANGE_DONNEE.IDPORTE,
            ECHANGE_DONNEE.CODE_ETAT,
            ECHANGE_DONNEE.CHAINE_INFORM,
            ECHANGE_DONNEE.DATE_CREATION 
      FROM ECHANGE_DONNEE
      INNER JOIN DEF_PORTE ON DEF_PORTE.IDPORTE = ECHANGE_DONNEE.IDPORTE AND DEF_PORTE.TYPE_ECHANGE = loc_TYPE_ECHANGE
      WHERE ECHANGE_DONNEE.CODE_ETAT IN(0, 7, 8)
        AND ECHANGE_DONNEE.SENS      = 0
      ORDER BY  ECHANGE_DONNEE.IDPORTE,
                ECHANGE_DONNEE.NUM_EXTRACTION,
                ECHANGE_DONNEE.NUM_LIGNE)

  -- boucle de lecture du fichier
  LOOP
      a_idporte := C_Import.IDPORTE;
      -- récupération de la ligne en cours
      a_newline := C_Import.CHAINE_INFORM;
      -- appel de la procédure d'insertion de données de la ligne dans la base
      -- a_record, a_idporte, a_role, o_erreur, o_flag_erreur
      Charge_donnee (a_newline,a_idporte,0,o_erreur,o_flag_erreur);

      CASE 
        WHEN flag_erreur = 0 THEN maj_etat := 1;
        WHEN flag_erreur = 7 THEN maj_etat := 7; -- blocage assuré principal non présent dans Arthus
        WHEN flag_erreur = 8 THEN maj_etat := 8; -- blocage homonymie possible
        ELSE maj_etat := 2;  -- erreur
      END CASE;

      -- pas d'erreur, mettre à jour l'état à transféré 1 sinon ... 2
      UPDATE ECHANGE_DONNEE 
        SET CODE_ETAT = maj_etat 
          WHERE NUM_EXTRACTION  = C_Import.NUM_EXTRACTION
          AND   NUM_LIGNE       = C_Import.NUM_LIGNE
          AND   SENS            = 0;
      COMMIT;
  END LOOP;

  -- TRANSCOD a été chargé dans la boucle précédente, on charge maintenant les adhésions.
  IF a_existadhe = 1 THEN
    Charge_adhesion(adhesion_idporte, 1 ); -- fonctionne si 1 idporte concerne les adhesions.
  END IF;

  FOR loc_idporte IN 
    (SELECT DISTINCT IDPORTE 
      FROM HISTO_IMPORT 
      WHERE NUMREMISE = 0)

  -- boucle de lecture du fichier
  LOOP
    a_idporte := loc_idporte.IDPORTE;
    a_nb_enreg := t_enreg(a_idporte);
    -- mise à jour remise_import et histo_import
    ins_remise_import (a_idporte,	a_nb_enreg , Current_date, loc_numremiseglobal);
    DBMS_OUTPUT.PUT_LINE( 'ins_remise_import ok');
  END LOOP;

  COMMIT;
  
  --
  O_found	:= 0;
	G_niv_msg	:= 1;
	G_msg_adm	:= 'PK_IMPORT Fin de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    flag_erreur := 1;
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Charge_Donnee_Import - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
    P_INS_journal;
    o_flag_erreur := flag_erreur;
    DBMS_OUTPUT.PUT_LINE( 'Flag erreur = '||flag_erreur||' '||erreur );
END Charge_Donnee_Import;

/* -- -----------------------------------------------------------------
--  FUNCTION : Recherche_Echange_Clef_Int
--  parametres
--  entree : 
--   - CLEF_EXT, ENTITE, TYPE_ECHANGE
--  sortie :
--   - CLEF_INT
--  But : Recherche la clef dans arthus à partir de la clef externe à arthus
*/ -- -----------------------------------------------------------------
FUNCTION Recherche_Echange_Clef_Int (  
                                  aCLEF_EXT IN NUMBER, 
                                  aENTITE IN NUMBER
                                  )
RETURN NUMBER
IS
loc_valeur    NUMBER(9);

BEGIN

  loc_valeur  := 0;

  SELECT CLEF_INT 
    INTO loc_valeur
    FROM ECHANGE_LIEN
      WHERE CLEF_EXT      = aCLEF_EXT
        AND ENTITE        = aENTITE
        AND TYPE_ECHANGE  = loc_TYPE_ECHANGE;
  
  RETURN ( loc_valeur );
  
  EXCEPTION WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE( 'Erreur : Plusieurs données ont la même cle : '||aCLEF_EXT||' entité '||aENTITE );
      erreur := ( 'Plusieurs données ont la même cle : '||aCLEF_EXT||' entité '||aENTITE );
      flag_erreur := 1;
      RETURN 0;
  WHEN No_Data_Found THEN RETURN 0;
  
END Recherche_Echange_Clef_Int;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Insert_Echange_Clef
--  parametres
--  entree : 
--   - CLEF_EXT, ENTITE, TYPE_ECHANGE
--  sortie :
--   - CLEF_INT
--  But : Recherche la clef dans arthus à partir de la clef externe à arthus
*/ -- -----------------------------------------------------------------
PROCEDURE Insert_Echange_Clef (  
                            aCLEF_INT       IN NUMBER,
                            aCLEF_EXT       IN NUMBER, 
                            aENTITE         IN NUMBER,
                            aTYPE_ECHANGE   IN NUMBER)
IS

BEGIN

  IF aCLEF_INT IS NOT NULL AND aCLEF_EXT IS NOT NULL THEN

    INSERT INTO ECHANGE_LIEN 
                            (
                            CLEF_INT,
                            CLEF_EXT,
                            ENTITE,
                            TYPE_ECHANGE,
                            DATE_CREATION
                            )
          VALUES
                            (
                            aCLEF_INT,
                            aCLEF_EXT,
                            aENTITE,
                            aTYPE_ECHANGE,
                            SYSDATE
                            );
                            
    DBMS_OUTPUT.PUT_LINE( 'Insertion lien = '|| aCLEF_INT  ||'  vers = '|| aCLEF_EXT );

  END IF;

  COMMIT;
    
  EXCEPTION WHEN OTHERS THEN
    flag_erreur := 1;
    ROLLBACK;
    erreur := SUBSTR('Insert_Echange_Clef : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(erreur);
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Insert_Echange_Clef - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END Insert_Echange_Clef;

/* -- -----------------------------------------------------------------
--  PROCEDURE : Insert_histo_import
--  parametres
--  entree : 
--   - CLEF_EXT, ENTITE, TYPE_ECHANGE
--  sortie :
--   - CLEF_INT
--  But : Recherche la clef dans arthus à partir de la clef externe à arthus
*/ -- -----------------------------------------------------------------
PROCEDURE Insert_histo_import (
                              aidporte      IN NUMBER,
                              acle          IN NUMBER,
                              aaction       IN VARCHAR2,
                              anumremise    IN NUMBER)
IS

BEGIN

  -- histo_import
  INSERT INTO histo_import (
                            idporte,
                            cle,
                            action,
                            numremise)
      VALUES  (
              aidporte,
              acle,
              aaction,
              anumremise
              );

  COMMIT;
  
  EXCEPTION WHEN OTHERS THEN
    flag_erreur := 1;
    ROLLBACK;
    erreur := SUBSTR('Insert_histo_import : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(erreur);
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - Insert_histo_import - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END Insert_histo_import;


/* -- -----------------------------------------------------------------
--  PROCEDURE : F_Traite_Homonymie
--  parametres
--  entree : 
--   - anumindivext, aQualite, anom, aprenom, adatenaissance, aTYPE_ECHANGE
--  sortie :
--   - renvoie 'O' si à traiter, 'N' si bloqué
--  But : Effectue un controle d'homonyme + met de coté les homonymes
--  créé le lien entre les individus si traité.
*/ -- -----------------------------------------------------------------
FUNCTION F_Traite_Homonymie (
                      anumindivext    NUMBER,
                      aQualite        NUMBER,
                      anom            VARCHAR2,
                      aprenom         VARCHAR2,
                      adatenaissance  DATE,
                      aTYPE_ECHANGE   NUMBER 
                    )
RETURN VARCHAR2
IS
LOC_RETOUR    VARCHAR(1);
aCount        NUMBER;
aTraite       VARCHAR2(1);
aPresent      VARCHAR2(1);
aNumindiv     NUMBER(9);
aNumindivClef NUMBER(9);
BEGIN

  aPresent := 'N';
  aTraite   := 'N';
  
  -- si l'individu est présent dans la table d'echange des liens, 
  -- traitement à poursuivre
  aNumindivClef := Recherche_Echange_Clef_Int (anumindivext, 1);
  
  IF aNumindivClef = 0 THEN
    -- test de la presence de l'individu dans la table des homonymes
    -- et si oui, si il a été traité
    BEGIN
    SELECT  COALESCE(TRAITE, 'N'), 'O', NUMINDIV 
            INTO aTraite, aPresent, aNumindiv
              FROM ECHANGE_HOMONYME 
                WHERE NUMINDIVEXT   = anumindivext
                  AND TYPE_ECHANGE  = aTYPE_ECHANGE ;
    
    EXCEPTION WHEN No_data_found THEN 
      aTraite  := 'N';
      aPresent := 'N';
      aNumindiv := 0;
    END;
  
    IF aPresent = 'N' THEN
    -- si l'individu n'est pas dans la table des homonymes possibles,
    -- test
      SELECT COUNT(NUMINDIV) INTO aCount
        FROM INDVS 
          WHERE QUALITE   = aQualite
            AND NOM       = anom 
            AND PRENOM    = aprenom
            AND DATNAIS   = adatenaissance;
            
      IF aCount > 0 THEN
      
        -- homonyme possible
        -- pas d'import avant control et validation utilisateur
        INSERT INTO ECHANGE_HOMONYME (TYPE_ECHANGE, NUMINDIVEXT, QUALITE, NOM, PRENOM, DATENAIS, TRAITE, HOMONYME, CREATION)
          VALUES
            (aTYPE_ECHANGE, anumindivext, aQualite, anom, aprenom, adatenaissance, 'N', 'N', sysdate);
        COMMIT;
        erreur := 'Blocage importation: Homonymie possible';
        flag_erreur := 8; 
        LOC_RETOUR := 'N';
      ELSE
        LOC_RETOUR := 'O';
      END IF;
      
    ELSE
      
      -- l'individu se trouve dans la table des homonymes
      -- si il a été traité, on peut importer les données, sinon non.
      IF aTraite  != 'O' THEN
        erreur := 'Blocage importation: Homonymie possible';
        flag_erreur := 8;
        LOC_RETOUR := 'N';
      ELSE
          -- individu non présent dans la table des liens, il faut l'insérer pour continuer.
          -- si ce n'est pas un homonyme, c'est un doublon (aNumindiv renseigné), 
          -- faire le lien avec le numéro arthus.
          IF COALESCE(aNumindiv,0) != 0 THEN
            Insert_Echange_Clef (aNumindiv, anumindivext, 1, aTYPE_ECHANGE);
          END IF;
          LOC_RETOUR := 'O';
      END IF;
      
    END IF;
    
  ELSE
    LOC_RETOUR := 'O';
  END IF;
  
  RETURN(LOC_RETOUR);
  
  EXCEPTION WHEN OTHERS THEN 
  
    flag_erreur := 1;
    erreur := SUBSTR('F_Traite_Homonymie : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(erreur);
    G_niv_msg	:= 0;
    G_msg_adm	:= SUBSTR('PK_IMPORT - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
    LOC_RETOUR  := 'N';
    RETURN(LOC_RETOUR);
  
END F_Traite_Homonymie;

/* -- -----------------------------------------------------------------
--  FUNCTION : F_Blocage_Homonyme
--  parametres
--  entree : 
--   - numindivext, aTYPE_ECHANGE
--  sortie :
--   - O/N
--  But : test si l'individu externe est à importer ou non
*/ -- -----------------------------------------------------------------
FUNCTION F_Blocage_Homonyme ( anumindivext     NUMBER,
                            aTYPE_ECHANGE   NUMBER 
                            )
RETURN VARCHAR2
IS 
LOC_RETOUR  VARCHAR(1);
aCount      NUMBER;
BEGIN

  LOC_RETOUR  := 'N';
  aCount      := 0;
  BEGIN 
  
    SELECT 1 
      INTO aCount
        FROM ECHANGE_HOMONYME 
        WHERE NUMINDIVEXT   = anumindivext
          AND TYPE_ECHANGE  = aTYPE_ECHANGE
          AND COALESCE(TRAITE, 'N') = 'N' ;
        
  EXCEPTION WHEN No_data_found THEN 
    aCount  := 0;
  END;
  
  IF aCount = 1 THEN 
    LOC_RETOUR := 'O';
    erreur := 'Blocage importation: Homonymie possible';
    flag_erreur := 8;
  END IF;
  
  RETURN(LOC_RETOUR);
  
  EXCEPTION WHEN OTHERS THEN 
    flag_erreur := 1;
    LOC_RETOUR  := 'N';
    RETURN(LOC_RETOUR);
  
END F_Blocage_Homonyme;



----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv

-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne	Number;
BEGIN
  If ( G_niv_msg <= G_max_msg ) then
  	G_idligne := G_idligne + 1;
  	If ( G_niv_msg = 0 ) then
  		L_idligne := -1 * G_idligne;
  	Else
  		L_idligne := G_idligne;
  	End If;
  	PK_trace.P_INS_journal_adm (
  		I_nom_traitement => G_nom_traitement,
  		I_session	 => G_session,
  		I_niv_msg	 => G_niv_msg,
  		I_msg_adm	 => G_msg_adm,
  		I_idligne	 => L_idligne);
  End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --

END pk_import;
/
