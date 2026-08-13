CREATE OR REPLACE PACKAGE ARTHUS.PK_EDITION AS
/*============================================================================*/
/* PACKAGE      : PK_EDITION.sql                                              */
/* Domaine      : Paramétrage                                                 */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Gestion des editions sous Arthus                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 11/03/2013 / Mantis 3448: Mise en commentaire de la   */
/*                fonction P_insere_envoi avec ses 6 parametres(obsolete).    */
/* Correction   : PHA / 27/08/2015 / Mantis 4547 : Correction de la recherche */
/*                du nombre de relance : ignorer les pièces déjà demandées    */
/*                non encore réceptionnée et non annulées                     */
/*              : PHA / 09/09/2016 / M0005155: Anomalie pièces /              */
/*                relance inopportune                                         */
/*============================================================================*/

-- Chaine de reconnaissance SCCS
-- @(#)pk_edition.sql    1.1  00/09/15
--
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- --------------------------------------------- Fin des types publiques ------
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --
-- PROCEDURES ET FONCTIONS PUBLIQUES ------------------------------------------
--
-- PROCEDURE ET FONCTION Utilisees par les Courriers
/*
FUNCTION F_numrelance ( I_entite         IN pieces.entite%TYPE,
                        I_numindiv_dest  IN pieces.numindiv_dest%TYPE,
                        I_NbRel          IN pieces.nbrel%TYPE DEFAULT NULL) RETURN NUMBER;
*/

Function F_numrelance ( I_entite         IN pieces.entite%TYPE,
                        I_numindiv_dest  IN pieces.numindiv_dest%TYPE,
                        I_NbRel          IN pieces.nbrel%TYPE DEFAULT NULL,
                        I_dateRef        IN DATE DEFAULT NULL) RETURN NUMBER;


PRAGMA RESTRICT_REFERENCES(F_numrelance, WNDS);
--

PROCEDURE P_insere_envoi( I_numero        IN  envoi.numero%TYPE,
                          I_idtexte       IN  envoi.idtexte%TYPE,
                          I_numbene       IN  envoi.numbene%TYPE,
                          I_numindiv_dest IN  envoi.numindiv_dest%TYPE,
                          I_numutil       IN  envoi.numutil%TYPE,
                          I_numedit       IN  envoi.numedit%TYPE DEFAULT 0,
                          I_etendue       IN  envoi.etendue%TYPE,
                          I_clef          IN  envoi.clef%TYPE,
                          O_numenvoi      OUT envoi.numenvoi%TYPE);

PROCEDURE P_insere_envoi( I_numero        IN  envoi.numero%TYPE,
                          I_idtexte       IN  envoi.idtexte%TYPE,
                          I_numbene       IN  envoi.numbene%TYPE,
                          I_numindiv_dest IN  envoi.numindiv_dest%TYPE,
                          I_numutil       IN  envoi.numutil%TYPE,
                          I_numedit       IN  envoi.numedit%TYPE DEFAULT 0,
                          O_numenvoi      OUT envoi.numenvoi%TYPE);
/*
PROCEDURE P_insere_envoi( I_numero        IN  envoi.numero%TYPE,
                          I_idtexte       IN  envoi.idtexte%TYPE,
                          I_numbene       IN  envoi.numbene%TYPE,
                          I_numindiv_dest IN  envoi.numindiv_dest%TYPE,
                          I_numutil       IN  envoi.numutil%TYPE,
                          O_numenvoi      OUT envoi.numenvoi%TYPE);
*/
--
PROCEDURE P_SEL_param_texte( I_idTexte IN envoi.idtexte%TYPE,
                             IO_Rec_param_texte IN OUT Param_texte%ROWTYPE);

FUNCTION F_ETEN_ENVOI (i_TYPE_CRRR IN param_texte.code%TYPE) RETURN NUMBER;
FUNCTION F_TYP_CRRR (i_IDTEXTE IN param_texte.idtexte%TYPE)  RETURN NUMBER;

FUNCTION F_Papier_Client ( I_Client IN APPLI_CLIENT.CLIENT%TYPE DEFAULT NULL) RETURN BOOLEAN;

FUNCTION F_NUMUTIL (i_NUMEDIT IN FILE_EDITION.NUMEDIT%TYPE) RETURN NUMBER;

FUNCTION F_GET_IMGREP (is_ImgPath IN VARCHAR2) RETURN VARCHAR2;

/* -- Fonction utilisé par la version v6 chez Welcare (en attente de fusion)
FUNCTION F_Formule_Image ( I_NumFormule IN  FORMULE.NUMFOR%TYPE) RETURN FORMULE.IMG_DGAR%TYPE;
*/

--
-- --------------------------------------------- Fin des variables publiques --
END PK_EDITION;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_EDITION AS
/*============================================================================*/
/* PACKAGE      : PK_EDITION.sql                                              */
/* Domaine      : Paramétrage                                                 */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Gestion des editions sous Arthus                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 11/03/2013 / Mantis 3448: Mise en commentaire de la   */
/*                fonction P_insere_envoi avec ses 6 parametres(obsolete).    */
/*============================================================================*/

-- Chaine de reconnaissance SCCS
-- @(#)pk_edition.sql    1.1  00/09/15
--
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --
-- -- PROCEDURES PRIVEES ------------------------------------------------------
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
-- ------------------------------------------------------------------------
--
/* PROCEDURE ET FONCTION Utilisees par les Courriers */
/*
Function F_numrelance ( I_entite         IN pieces.entite%TYPE,
                        I_numindiv_dest  IN pieces.numindiv_dest%TYPE,
                        I_NbRel          IN pieces.nbrel%TYPE DEFAULT NULL)
                                                            RETURN NUMBER
IS
 L_nbrel pieces.nbrel%TYPE;
BEGIN
  Select max(nvl(nbrel,-1))+1 nbrel
   Into L_nbrel
  from   pieces
  Where  entite = I_entite
    And  numindiv_dest = I_numindiv_dest
    -- Groupement par niveau de relance
    And ((I_NbRel IS NULL) OR -- pour Retro-compatibilité
         (I_NbRel < 0 AND NbRel IS NULL) OR
         (I_NbRel >= 0 AND NbRel = I_NbRel))
    And    daterecep Is Null;

  RETURN L_nbrel;
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;
*/

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_numrelance                                              */
/* Type         :  Public                                                    */
/* Description  :  Controle du numéro de bénéficiaire a partir du numéro de  */
/*                 l assure et des informations du bénéficaire               */
/* Entree       :  I_entite  : adhesion                                      */
/*                 I_numindiv_dest : individu destinataire du courrier   	 */
/*                 I_NbRel						        					 */
/*                 I_dateRef : date de référence							 */
/* Retour       :  nombre de relance                                         */
/*---------------------------------------------------------------------------*/
/* ABO 11/10/12 : prise en compte d'une date de référence pour les relances  */
/*                adhésion(surchage de la fonction)                          */
/*---------------------------------------------------------------------------*/
Function F_numrelance ( I_entite         IN pieces.entite%TYPE,
                        I_numindiv_dest  IN pieces.numindiv_dest%TYPE,
                        I_NbRel          IN pieces.nbrel%TYPE DEFAULT NULL,
                        I_dateRef        IN DATE DEFAULT NULL) RETURN NUMBER
IS
 L_nbrel pieces.nbrel%TYPE;
BEGIN
  Select max(nvl(nbrel,-1))+1 nbrel
   Into L_nbrel
  from   pieces
  Where  entite = I_entite
    And  numindiv_dest = I_numindiv_dest
    -- and (nvl(daterel,nvl(dateavis,e2d('01/01/01')))+ delai<nvl(I_dateRef,sysdate) OR I_dateRef IS NULL)
    and (
        (nvl(daterel,nvl(dateavis,e2d('01/01/01')))+ delai<nvl(I_dateRef,sysdate)  )
        OR dateavis  IS NULL
        )
    -- M0005155 filtre sur actifs :
    AND (
          (idrepartition = 0 AND EXISTS(SELECT 1 FROM adhesion a
                                                      WHERE a.idadhesion = pieces.entite
                                                        AND a.numindiv = pieces.numbene
                                                        AND NVL(datper, I_dateRef) >= I_dateRef )
                                                          )
       OR
          (idrepartition > 0 AND EXISTS(SELECT 1 FROM repartition r, repartition_bene rb
                                                      WHERE r.idrepartition = pieces.idrepartition
                                                        AND r.idrepartition = rb.idrepartition
                                                        AND rb.numbene = pieces.numbene
                                                        AND r.valide = 'O'
                                                        AND rb.valide = 'O')
                                                          )
      OR
          (idrepartition = 0 AND EXISTS(SELECT 1 FROM sntrprt a
                                                      WHERE numremise||TO_CHAR( numsin, 'FM000000000') = pieces.entite
                                                        AND a.numindiv = pieces.numbene)
                                                          )

      OR
          (idrepartition = 0 AND EXISTS(SELECT 1 FROM dossier_sante a
                                                      WHERE num_dossier = pieces.entite
                                                        AND a.numindiv = pieces.numbene)
                                                          )
        )
    -- Groupement par niveau de relance
    And ((I_NbRel IS NULL) OR -- pour Retro-compatibilité
         (I_NbRel < 0 AND NbRel IS NULL) OR
         (I_NbRel >= 0 AND NVL(NbRel, 0) = I_NbRel))
    And  daterecep Is Null
    And  datannul  Is Null;

  -- Gestion aucune pièce demandée.
  IF L_nbrel IS NULL THEN
    L_nbrel := -1 ;
  END IF;

  RETURN L_nbrel;
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

-- Procédure P_Insere_Envoi Principale (I_numedit, I_etendue, I_clef)
PROCEDURE P_Insere_Envoi( I_numero          IN  envoi.numero%TYPE,
                          I_idtexte         IN  envoi.idtexte%TYPE,
                          I_numbene         IN  envoi.numbene%TYPE,
                          I_numindiv_dest   IN  envoi.numindiv_dest%TYPE,
                          I_numutil         IN  envoi.numutil%TYPE,
                          I_numedit         IN  envoi.numedit%TYPE DEFAULT 0,
                          I_etendue         IN  envoi.etendue%TYPE,
                          I_clef            IN  envoi.clef%TYPE,
                          O_numenvoi        OUT envoi.numenvoi%TYPE)
IS
BEGIN
  INSERT INTO envoi(numenvoi,numero,idtexte,numbene,
                   numindiv_dest,datemis,numutil,numedit, clef, etendue)
        VALUES    (numenvoi.nextval, I_numero, I_idtexte, I_numbene,
                   I_numindiv_dest, SYSDATE, I_numutil, I_numedit, NVL(I_clef,TO_CHAR(I_numero)), NVL(I_etendue,F_ETEN_ENVOI(F_TYP_CRRR(I_idtexte))));
  -- /!\ NE PAS EFFECTUER DE COMMIT, car cela commit également les modifications en attente du cylce précédent dans reports.

  Select NVL(numenvoi.currval,0) into O_numenvoi from dual;
END;

-- Procédure P_Insere_Envoi Surchargé (I_numedit)
PROCEDURE P_insere_envoi( I_numero        IN  envoi.numero%TYPE,
                          I_idtexte       IN  envoi.idtexte%TYPE,
                          I_numbene       IN  envoi.numbene%TYPE,
                          I_numindiv_dest IN  envoi.numindiv_dest%TYPE,
                          I_numutil       IN  envoi.numutil%TYPE,
                          I_numedit       IN  envoi.numedit%TYPE DEFAULT 0,
                          O_numenvoi      OUT envoi.numenvoi%TYPE)
IS
BEGIN
  P_Insere_Envoi(I_numero, I_idtexte, I_numbene, I_numindiv_dest, I_numutil, I_numedit, NULL, NULL, O_numenvoi);
END;
/*
-- Procédure P_Insere_Envoi Surchargé
PROCEDURE P_insere_envoi( I_numero        IN  envoi.numero%TYPE,
                          I_idtexte       IN  envoi.idtexte%TYPE,
                          I_numbene       IN  envoi.numbene%TYPE,
                          I_numindiv_dest IN  envoi.numindiv_dest%TYPE,
                          I_numutil       IN  envoi.numutil%TYPE,
                          O_numenvoi      OUT envoi.numenvoi%TYPE)
IS
BEGIN
  P_Insere_Envoi(I_numero, I_idtexte, I_numbene, I_numindiv_dest, I_numutil, NULL, O_numenvoi);
END;
*/

PROCEDURE P_SEL_param_texte( I_idTexte IN envoi.idtexte%TYPE,
                             IO_Rec_param_texte IN OUT Param_texte%ROWTYPE)
IS
--
CURSOR C_param_texte IS
                     SELECT *
                     From   Param_texte
                     WHERE  idtexte = I_idtexte;
--
Rec_C_param_texte Param_texte%ROWTYPE;
BEGIN
  OPEN  C_param_texte;
  FETCH C_param_texte INTO Rec_c_param_texte;
  IO_Rec_param_texte := Rec_c_param_texte;
END;


FUNCTION F_ETEN_ENVOI (i_TYPE_CRRR IN param_texte.code%TYPE)
  RETURN NUMBER
IS
  i_Result NUMBER(2);
BEGIN
  i_Result := F_CONTEXTE('TYPE_CRRR2',i_Type_Crrr);
  IF NVL(i_Result,-1) < 0 THEN
    RAISE NO_DATA_FOUND;
  END IF;
  RETURN i_Result;
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

FUNCTION F_TYP_CRRR (i_IDTEXTE IN param_texte.idtexte%TYPE)
  RETURN NUMBER
IS
  i_TYPE_CRRR NUMBER(2);
BEGIN
  SELECT CODE INTO i_TYPE_CRRR FROM PARAM_TEXTE WHERE IDTEXTE=i_IDTEXTE;
  RETURN (i_TYPE_CRRR);
EXCEPTION
  WHEN OTHERS THEN RETURN NULL;
END;

-- Vérification de l'autorisation du Client à utilisateur
-- la Personnalisation du Papier des courriers :
FUNCTION F_Papier_Client ( I_Client IN APPLI_CLIENT.CLIENT%TYPE DEFAULT NULL) RETURN BOOLEAN
IS
  L_Exclu NUMBER(1);
BEGIN
  -- Vérification des exclusions pour accéder à la fonctionnalité du Papier Personnalisé
  SELECT COUNT(*)
     INTO L_Exclu
     FROM APPLI_CLIENT
    WHERE CODAPLI = 'CR22' -- Gestion du Papier Personnalisé
      AND CLIENT = NVL(I_Client,(SELECT CLIENT FROM PARAMETRES));

  -- Si le client n'est pas exclu, alors il est autorisé.
  RETURN (L_Exclu = 0);
EXCEPTION
  WHEN OTHERS THEN RETURN FALSE;
END;

-- Fonction pour récupérer le UserID de l'utilisateur ayant demandé l'édition (!= FONCTION -> F_NUMUTIL)
FUNCTION F_NUMUTIL (i_NUMEDIT IN FILE_EDITION.NUMEDIT%TYPE)
   RETURN NUMBER
AS
   I_UserID NUMBER := 0;
BEGIN

  SELECT NUMUTIL INTO I_UserID
  FROM UTIL
  WHERE NOM = (SELECT USERID FROM FILE_EDITION WHERE NUMEDIT = i_NUMEDIT);

  RETURN (I_UserID);

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
  WHEN OTHERS THEN RETURN(-1);
END;

FUNCTION F_GET_IMGREP (is_ImgPath IN VARCHAR2)
  RETURN VARCHAR2 IS
  s_ImgDir VARCHAR2(256);
BEGIN

  BEGIN
    SELECT DIR_REPORT||'\Images\' AS Img_Report
      INTO s_ImgDir
      FROM PARAM_MACHINE
     WHERE SRV_TYPE='A'
       AND DIR_REPORT IS NOT NULL;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  IF (INSTR(is_ImgPath,':') = 0) THEN
    RETURN UPPER(s_ImgDir||is_ImgPath);
  ELSE
    RETURN UPPER(is_ImgPath);
  END IF;
END;

/* -- Fonction utilisé par la version v6 chez Welcare (en attente de fusion)
-- Vérification de l'autorisation du Client à utilisateur
-- la Personnalisation du Papier des courriers :
FUNCTION F_Formule_Image ( I_NumFormule IN  FORMULE.NUMFOR%TYPE) RETURN FORMULE.IMG_DGAR%TYPE
IS
  L_Image FORMULE.IMG_DGAR%TYPE;
BEGIN
  SELECT img_dgar INTO L_Image
  FROM (
  SELECT g.numfor, g.img_dgar
    FROM Garanties g
   WHERE g.numfor = I_NumFormule
  UNION
  SELECT f.numfor, f.img_dgar
    FROM Formule f
   WHERE f.numfor = I_NumFormule);

  -- Si la formule est à editer...
  RETURN L_Image;
END;
*/

-- =============================================================================
-- ---------------------------------- Fin des corps des procedures publiques --
END PK_EDITION;
/
