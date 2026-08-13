CREATE OR REPLACE PACKAGE ARTHUS.PK_FICHIER
AS
/*============================================================================*/
/* PACKAGE      : PK_FICHIER.sql                                              */
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

BI_TAILLE_LIGNE_MAXI  CONSTANT  BINARY_INTEGER:=256;
TYPE  TV_ITEMS        IS  TABLE OF  VARCHAR2(256) INDEX BY BINARY_INTEGER;
S_DELIMITEUR          CONSTANT  VARCHAR2(1)   :=';';
E_FIN                 EXCEPTION;


/*PROCEDURE/FONCTION*/
FUNCTION  fGetLine( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
                    os_donnees  OUT VARCHAR2            )
RETURN BOOLEAN;

FUNCTION fPutLine ( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
                    is_donnees  IN  VARCHAR2            )
RETURN BOOLEAN;

FUNCTION  fOpen ( is_chemin             IN  VARCHAR2                                    ,
                  is_fichier            IN  VARCHAR2                                    ,
                  is_mode               IN  VARCHAR2                                    ,
                  is_taille_ligne_maxi  IN  BINARY_INTEGER  DEFAULT BI_TAILLE_LIGNE_MAXI)
RETURN UTL_FILE.FILE_TYPE;

PROCEDURE pCreerTableau( is_liste      IN  VARCHAR2                        ,
                         o_items       OUT TV_ITEMS                        ,
                         is_delimiteur IN  VARCHAR2  DEFAULT S_DELIMITEUR  );

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_SPLIT                                                   */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit la nième valeur d'une liste en fonction d'un      */
/*                 séparateur                                                */
/* Entree       :  p_list, liste de valeurs                                  */
/*                 p_pos, position dans la liste                             */
/*                 p_sep, séparateur                                         */
/* Entree/Sortie:                                                            */
/* Retour       :  chaine                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_SPLIT(p_list VARCHAR2,p_pos NUMBER, p_sep IN VARCHAR2)
RETURN VARCHAR2;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FILE_TO_CLOB                                            */
/* Type         :  Privé                                                     */
/* Description  :  Retourne le clob généré à partir du fichier               */
/*                                                                           */
/* Entree       :  i_fichier, nom du fichier                                 */
/*                 i_repertoire, repertoire oracle d'esxportation            */
/* Entree/Sortie:  o_clob_error , erreur de tupe clob                        */
/* Retour       :  clob                                                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_FILE_TO_CLOB (i_fichier     IN VARCHAR2,
                         i_repertoire  IN typ_batch.repertoire%TYPE,
                         o_clob_error  OUT NUMBER)
RETURN CLOB;

/*
FUNCTION  substitute ( is_chaine                 IN  VARCHAR2                ,
                       ii_position               IN  NUMBER                  ,
                       is_chaine_de_substitution IN  VARCHAR2                ,
                       ii_length                 IN  NUMBER    DEFAULT 0     ,
                       ib_ihm                    IN  BOOLEAN   DEFAULT TRUE  );
*/
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_FICHIER;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_FICHIER
As
/*============================================================================*/
/* PACKAGE      : PK_FICHIER.sql                                              */
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
  e_par_repertoire_vide       EXCEPTION;
  e_par_fichier_vide          EXCEPTION;

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--

  G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'EX34T';
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

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  traitementCFE                                             */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l import du fichier CFE ainsi que le      */
/*                 traitement des données du fichier                         */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier , fichier FacturéCFE                               */
/*                 i_fichierA, fichier Annulé                                */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
/*
FUNCTION   fGetLine ( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
                      os_donnees  OUT VARCHAR2            );
*/
--------------------------------------------------------------------------------
--  FUNCTION fGetLine
--------------------------------------------------------------------------------
-- Lire les donnees de la ligne courante du fichier <ih_fichier> dans <os_donnees>
-- (UTL_FILE.GET_LINE() avec gestion d’erreur)
--------------------------------------------------------------------------------
FUNCTION  fGetLine
  ( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
    os_donnees  OUT VARCHAR2            )
RETURN BOOLEAN
IS
  S_SOURCE  CONSTANT  VARCHAR2(8) :='fGetLine';
BEGIN
  UTL_FILE.GET_LINE(ih_fichier, os_donnees);
  RETURN TRUE;

EXCEPTION
  WHEN  UTL_FILE.READ_ERROR THEN
    P_INS_journal('Erreur systeme pendant une operation de lecture ! (code <'||SQLCODE||'>)', S_SOURCE);
    RETURN FALSE;

  WHEN  NO_DATA_FOUND THEN
    RETURN FALSE;

  WHEN  OTHERS  THEN
    P_INS_journal('Erreur inattendue <'||SQLERRM||'>', S_SOURCE);
    RETURN FALSE;
END fGetLine;

/*
FUNCTION  fPutLine  ( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
                      is_donnees  IN  VARCHAR2            );
*/
--------------------------------------------------------------------------------
-- FUNCTION fPutLine
--------------------------------------------------------------------------------
-- Ecrire les donnees <is_donnees> dans le fichier <ih_fichier>
-- (UTL_FILE. PUT_LINE() + UTL_FILE.FFLUSH() avec gestion d’erreur)
--------------------------------------------------------------------------------
FUNCTION fPutLine( ih_fichier  IN  UTL_FILE.FILE_TYPE  ,
                   is_donnees  IN  VARCHAR2            )
RETURN BOOLEAN
IS
  S_SOURCE  CONSTANT  VARCHAR2(8) :='fPutLine';
BEGIN
  UTL_FILE.PUT_LINE(ih_fichier, is_donnees);
  UTL_FILE.FFLUSH(ih_fichier);
  RETURN TRUE;

EXCEPTION
  WHEN  UTL_FILE.WRITE_ERROR THEN
    P_INS_journal('Erreur systeme pendant une operation d''ecriture ! (code <'||SQLCODE||'>) !', S_SOURCE);
    RETURN FALSE;

  WHEN  OTHERS  THEN
    P_INS_journal('Erreur inattendue <'||SQLERRM||'>', S_SOURCE);
    RETURN FALSE;
END fPutLine;

--------------------------------------------------------------------------------
-- FUNCTION  fOpen
--------------------------------------------------------------------------------
-- Ouvrir le fichier <is_chemin>+<is_fichier> en lecture ou ecriture
--------------------------------------------------------------------------------
FUNCTION  fOpen
  ( is_chemin             IN  VARCHAR2                                    ,
    is_fichier            IN  VARCHAR2                                    ,
    is_mode               IN  VARCHAR2                                    ,
    is_taille_ligne_maxi  IN  BINARY_INTEGER  DEFAULT BI_TAILLE_LIGNE_MAXI)
  RETURN  UTL_FILE.FILE_TYPE
IS
  S_DEBUG  CONSTANT  VARCHAR2(256):='fOpen';

  h_fichier UTL_FILE.FILE_TYPE:=NULL;
BEGIN
  IF  is_chemin   IS NOT NULL
  AND is_fichier  IS NOT NULL
  THEN
    h_fichier:=UTL_FILE.FOPEN(is_chemin, is_fichier, is_mode, is_taille_ligne_maxi);
  END IF; -- IF  is_chemin   IS NOT NULL

  RETURN h_fichier;

EXCEPTION
  WHEN  UTL_FILE.ACCESS_DENIED  THEN
    CASE  is_mode
      WHEN  'r' THEN
        P_INS_journal('Impossible d''ouvrir le fichier <'||is_chemin||is_fichier||'> en lecture : droit insuffisant (code <'||SQLCODE||'>) !',S_DEBUG);
      WHEN  'w' THEN
        P_INS_journal('Impossible d''ouvrir le fichier <'||is_chemin||is_fichier||'> en ecriture : droit insuffisant (code <'||SQLCODE||'>) !',S_DEBUG);
    END CASE; -- CASE  is_mode

    RAISE E_FIN;

  WHEN  UTL_FILE.INVALID_OPERATION  THEN  -- (SQLCODE=-29283)
    CASE  is_mode
      WHEN  'r' THEN
        P_INS_journal('Impossible d''ouvrir le fichier <'||is_chemin||is_fichier||'> en lecture : droit insuffisant (code <'||SQLCODE||'>) !',S_DEBUG);
      WHEN  'w' THEN
        P_INS_journal('Impossible d''ouvrir le fichier <'||is_chemin||is_fichier||'> en ecriture : droit insuffisant (code <'||SQLCODE||'>) !',S_DEBUG);
    END CASE; -- CASE  is_mode

 --   RAISE E_FIN;

END fOpen;

--------------------------------------------------------------------------------
--  PROCEDURE pCreerTableau (ex. listeToVector)
--------------------------------------------------------------------------------
--  Convertir une liste chainee <is_liste> delimitee par des separateurs en tableau
--------------------------------------------------------------------------------
PROCEDURE pCreerTableau
  ( is_liste      IN  VARCHAR2                        ,
    o_items       OUT TV_ITEMS                        ,
    is_delimiteur IN  VARCHAR2  DEFAULT S_DELIMITEUR  )
IS
  S_SOURCE  CONSTANT  VARCHAR2(13):='pCreerTableau';

  i_compteur            NUMBER  :=0;
  i_position_delimiter  NUMBER  :=0;
  i_position_item       NUMBER  :=0;
BEGIN
  IF  is_liste IS NOT NULL  THEN
    LOOP
      i_compteur:=i_compteur+1;

      IF  i_compteur=1  THEN
        i_position_item  :=1;
      ELSE
        i_position_item:=i_position_delimiter+LENGTH(is_delimiteur);
      END IF; -- IF  i_compteur=1  THEN

      i_position_delimiter:=INSTR(is_liste, is_delimiteur, i_position_item);
      IF  i_position_delimiter=0  THEN
        o_items(i_compteur):= SUBSTR(is_liste, i_position_item);
      ELSE
        o_items(i_compteur):= SUBSTR(is_liste, i_position_item, i_position_delimiter-i_position_item);
      END IF; -- IF  i_position_delimiter=0  THEN

      EXIT WHEN i_position_delimiter=0;
    END LOOP; -- LOOP
  END IF; -- IF  is_liste IS NOT NULL  THEN

EXCEPTION
  WHEN  OTHERS  THEN
    P_INS_journal('Erreur inattendue <'||SQLERRM||'>', S_SOURCE);
END pCreerTableau;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_SPLIT                                                   */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit la nième valeur d'une liste en fonction d'un      */
/*                 séparateur                                                */
/* Entree       :  p_list, liste de valeurs                                  */
/*                 p_pos, position dans la liste                             */
/*                 p_sep, séparateur                                         */
/* Entree/Sortie:                                                            */
/* Retour       :  chaine                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_SPLIT(p_list VARCHAR2,p_pos NUMBER, p_sep IN VARCHAR2)
RETURN VARCHAR2 IS

  v_list varchar2(32767) := p_sep || p_list;
  pos_deb NUMBER;
  pos_fin NUMBER;

BEGIN
  pos_deb := instr(v_list, p_sep, 1, p_pos);
  IF pos_deb > 0 THEN
    pos_fin := instr( v_list, p_sep, 1, p_pos + 1);
    IF pos_fin = 0 THEN
      pos_fin := length(v_list) + 1;
    END IF;
    RETURN(substr(v_list, pos_deb + 1, pos_fin - pos_deb - 1));
  ELSE
    RETURN NULL;
  END IF;
END F_SPLIT;

FUNCTION F_FILE_TO_CLOB (i_fichier     IN VARCHAR2,
                         i_repertoire  IN typ_batch.repertoire%TYPE,
                         o_clob_error  OUT NUMBER)
RETURN CLOB IS

   --variable pour clob
  Loc_clob CLOB;
  Loc_clob_empty CLOB;
  Loc_Bfile BFILE;
  Loc_clob_Len NUMBER := dbms_lob.lobmaxsize;
  Loc_start_src PLS_INTEGER := 1 ;
  Loc_start_dest PLS_INTEGER := 1 ;
  loc_clob_lang NUMBER := dbms_lob.default_lang_ctx ;

BEGIN

  Loc_Bfile := BFILENAME( i_repertoire, i_fichier);
  dbms_lob.fileopen(Loc_Bfile, dbms_lob.file_readonly);

  IF dbms_lob.fileexists( Loc_Bfile ) = 1 AND dbms_lob.getlength( Loc_Bfile ) >0 THEN

    DBMS_LOB.CREATETEMPORARY(Loc_clob,true);--initialisation du CLOB

    dbms_lob.loadclobfromfile(Loc_clob,              -- CLOB de destination
                              Loc_Bfile,             -- Pointeur fichier en entrée
                              Loc_clob_Len,          -- Nombre d'octets à lire
                              Loc_start_src,         -- Position source de départ
                              Loc_start_dest,        -- Position destination de départ
                              dbms_lob.default_csid, -- CSID
                              loc_clob_lang,         -- Contexte langue
                              o_clob_error);       -- Message d'avertissement
    dbms_lob.fileclose(Loc_Bfile);

   ELSE
    o_clob_error:=1;
   END IF;

   RETURN Loc_clob;

END F_FILE_TO_CLOB;

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

END PK_FICHIER;
/
