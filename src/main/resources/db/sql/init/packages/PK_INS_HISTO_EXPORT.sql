CREATE OR REPLACE PACKAGE ARTHUS.PK_INS_HISTO_EXPORT
-- imsertion dans histo_export des lignes à exporter
-- suppression des lignes insérées avec un numremise = 0 si suppression dans arthus
AS

PROCEDURE INS_HISTO_EXPORT (
				a_entite 	    IN NUMBER,
				a_cle 		    IN NUMBER,
				a_numindiv    IN NUMBER DEFAULT NULL,
				a_idadhesion  IN NUMBER DEFAULT NULL,
				a_numgar      IN NUMBER DEFAULT NULL
				);

PROCEDURE DEL_HISTO_EXPORT (
				a_entite 	    IN NUMBER,
				a_cle 		    IN NUMBER
				);

PROCEDURE INS_PERSONNES (
        a_numindiv    IN NUMBER,
        a_idadhesion  IN NUMBER DEFAULT NULL,
				a_numgar      IN NUMBER DEFAULT NULL
        );

PROCEDURE INSERT_HISTO_EXPORT (
        a_idporte   IN NUMBER,
        a_cle       IN NUMBER
        );

PROCEDURE DELETE_HISTO_EXPORT (
        a_idporte   IN NUMBER,
        a_cle       IN NUMBER
        );

FUNCTION F_RECH_CLEF(
        a_idporte     IN NUMBER,
				a_entite_base IN NUMBER,
				a_cle 		    IN NUMBER,
				a_numindiv    IN NUMBER,
				a_idadhesion  IN NUMBER
        ) RETURN NUMBER;

END PK_INS_HISTO_EXPORT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_INS_HISTO_EXPORT"
AS


/* -- -----------------------------------------------------------------
--  PROCEDURE : ins_histo_export PROCEDURE PRINCIPALE
--  parametres
--  entree :
--  - a_entite, a_cle, a_numindiv, a_idadhesion, a_numgar
--  But :
--  Insertion dans histo_export si pour l'entite : porte existe et contrat autorisé
*/ -- -----------------------------------------------------------------

PROCEDURE INS_HISTO_EXPORT (
				a_entite 	    IN NUMBER,
				a_cle 		    IN NUMBER,
				a_numindiv    IN NUMBER DEFAULT NULL,
				a_idadhesion  IN NUMBER DEFAULT NULL,
				a_numgar      IN NUMBER DEFAULT NULL
				)
IS
-- test si l'entite a une ou plusieurs portes autorisant l'export pour tous les contrats
CURSOR porte_tous
IS
SELECT DISTINCT def_porte.idporte, def_porte.entite_base
  FROM  def_porte,
        libelle, porte_export ,
        contrat_export
        WHERE def_porte.sens        = 2
          AND def_porte.entite_base = libelle.sens
          AND libelle.mnemo         = 'ENT_PHYS'
          AND libelle.code          = a_entite
          AND porte_export.idporte  = def_porte.idporte
          AND porte_export.entite   = libelle.code
          AND contrat_export.idporte= def_porte.idporte
          AND contrat_export.numgar = 0
          AND contrat_export.debut <= SYSDATE
          AND NVL(contrat_export.fin, SYSDATE) >= SYSDATE;
-- test si l'entite a une ou plusieurs portes autorisant l'export pour tous un contrat
CURSOR porte_numgar
IS
SELECT DISTINCT def_porte.idporte, def_porte.entite_base
  FROM  def_porte,
        libelle, porte_export ,
        contrat_export
        WHERE def_porte.sens        = 2
          AND def_porte.entite_base = libelle.sens
          AND libelle.mnemo         = 'ENT_PHYS'
          AND libelle.code          = a_entite
          AND porte_export.idporte  = def_porte.idporte
          AND porte_export.entite   = libelle.code
          AND contrat_export.idporte= def_porte.idporte
          AND contrat_export.numgar = a_numgar
          AND contrat_export.debut <= SYSDATE
          AND NVL(contrat_export.fin, SYSDATE) >= SYSDATE;
-- test si l'entite a une ou plusieurs portes autorisant l'export pour tous une adhésion
CURSOR porte_adhe
IS
SELECT DISTINCT def_porte.idporte, def_porte.entite_base
  FROM  def_porte, libelle, porte_export, contrat_export
        WHERE def_porte.sens = 2
          AND def_porte.entite_base = libelle.sens
          AND libelle.mnemo         = 'ENT_PHYS'
          AND libelle.code          = a_entite
          AND porte_export.idporte  = def_porte.idporte
          AND porte_export.entite   = libelle.code
          AND contrat_export.idporte= def_porte.idporte
          AND contrat_export.debut <= SYSDATE
          AND NVL(contrat_export.fin, SYSDATE) >= SYSDATE
          AND EXISTS (
                      SELECT 1 FROM  def_porte,
                    	libelle, porte_export ,
                      histo_export
                      WHERE def_porte.sens = 2
                        AND def_porte.entite_base = libelle.sens
                        AND libelle.mnemo         = 'ENT_PHYS'
                        AND libelle.code          = 31
                        AND porte_export.idporte  = def_porte.idporte
                        AND porte_export.entite   = libelle.code
                        AND histo_export.cle      = a_idadhesion
                        AND histo_export.idporte  = def_porte.idporte
                      );
-- test si l'entite a une ou plusieurs portes autorisant l'export pour tous un individu
CURSOR porte_indv
IS
SELECT DISTINCT def_porte.idporte, def_porte.entite_base
  FROM  def_porte,
      	libelle, porte_export ,
        contrat_export,
        adhe_cntrt
        WHERE def_porte.sens = 2
          AND def_porte.entite_base = libelle.sens
          AND libelle.mnemo         = 'ENT_PHYS'
          AND libelle.code          = a_entite
          AND porte_export.idporte  = def_porte.idporte
          AND porte_export.entite   = libelle.code
          AND contrat_export.idporte= def_porte.idporte
          AND contrat_export.numgar = adhe_cntrt.numgar
          AND contrat_export.debut <= SYSDATE
          AND NVL(contrat_export.fin, SYSDATE) >= SYSDATE
          AND (
              adhe_cntrt.numadhe    = a_numindiv
              OR adhe_cntrt.idadhesion IN
                                  (
                                  SELECT idadhesion FROM adhe_cntrt_membre WHERE numindiv = a_numindiv
                                  UNION
                                  SELECT idadhesion FROM adhesion WHERE numindiv = a_numindiv
                                  )
              );

vidporte	    DEF_PORTE.IDPORTE%Type;
ventite_base  DEF_PORTE.ENTITE_BASE%Type;
loc_traite    NUMBER := -1;

BEGIN
-- DBMS_OUTPUT.PUT_LINE( 'INS_HISTO_EXPORT a_entite= '||a_entite||' a_cle '|| a_cle||' a_numindiv= '||a_numindiv || ' a_idadhesion= ' ||a_idadhesion|| ' a_numgar= '||a_numgar );
  -- ouverture du curseur
  OPEN porte_tous;

  LOOP

    FETCH porte_tous INTO vidporte, ventite_base;

    EXIT WHEN porte_tous%NOTFOUND;

    loc_traite := 1;

    INSERT_HISTO_EXPORT(vidporte, F_RECH_CLEF(vidporte, ventite_base, a_cle, a_numindiv, a_idadhesion) );

  END LOOP;

  -- fermeture du curseur
  CLOSE porte_tous;


  IF loc_traite = -1 THEN

    IF a_numgar IS NOT NULL THEN
      -- cas numgar renseigné

      -- ouverture du curseur
      OPEN porte_numgar;

      LOOP

        FETCH porte_numgar INTO vidporte, ventite_base;

        EXIT WHEN porte_numgar%NOTFOUND;

        loc_traite := 1;

        INSERT_HISTO_EXPORT(vidporte, F_RECH_CLEF(vidporte, ventite_base, a_cle, a_numindiv, a_idadhesion) );

      END LOOP;

      -- fermeture du curseur
      CLOSE porte_numgar;

      -- si adhésion, le numgar est renseigné, on recherche les informations du domaine personne à exporter
      -- sinon couverture, idadhesion renseigné
      IF loc_traite = 1 AND a_numindiv IS NOT NULL THEN
        INS_PERSONNES (a_numindiv,a_idadhesion,a_numgar);
      END IF;

    ELSIF a_idadhesion IS NOT NULL THEN
      -- cas idadhesion renseigné

      -- ouverture du curseur
      OPEN porte_adhe;

      LOOP

        FETCH porte_adhe INTO vidporte, ventite_base;

        EXIT WHEN porte_adhe%NOTFOUND;

        loc_traite := 1;

        INSERT_HISTO_EXPORT(vidporte, F_RECH_CLEF(vidporte, ventite_base, a_cle, a_numindiv, a_idadhesion) );

      END LOOP;

      -- fermeture du curseur
      CLOSE porte_adhe;

      -- si adhésion, le numgar est renseigné, on recherche les informations du domaine personne à exporter
      -- sinon couverture, idadhesion renseigné
      IF loc_traite = 1 AND a_numindiv IS NOT NULL THEN
        INS_PERSONNES (a_numindiv,a_idadhesion,a_numgar);
      END IF;

    ELSIF a_numindiv IS NOT NULL THEN
      -- cas numindiv renseigné

      -- ouverture du curseur
      OPEN porte_indv;

      LOOP

        FETCH porte_indv INTO vidporte, ventite_base;

        EXIT WHEN porte_indv%NOTFOUND;

        loc_traite := 1;

        INSERT_HISTO_EXPORT(vidporte, F_RECH_CLEF(vidporte, ventite_base, a_cle, a_numindiv, a_idadhesion) );

      END LOOP;

      -- fermeture du curseur
      CLOSE porte_indv;

    END IF;
  END IF;

EXCEPTION WHEN OTHERS THEN
  -- DBMS_OUTPUT.PUT_LINE( SUBSTR('histo_export : '||sqlerrm, 1, 80) );
  CLOSE porte_numgar;
  CLOSE porte_adhe;
  CLOSE porte_indv;
END INS_HISTO_EXPORT;

/* -- -----------------------------------------------------------------
--  PROCEDURE : DEL_HISTO_EXPORT
--  parametres
--  entree :
--  But :
--  En vue de la suppression des informations dans histo_export
--  si information supprimée dans arthus pour les numéros de remises
-- non encore exportés (= 0)
*/ -- -----------------------------------------------------------------

PROCEDURE DEL_HISTO_EXPORT (
				a_entite 	    IN NUMBER,
				a_cle 		    IN NUMBER
				)
IS
-- test si l'entite a une ou plusieurs portes autorisant l'export
-- on ne regarde pas si l'export doit se faire.
CURSOR porte_recup
IS
SELECT DISTINCT def_porte.idporte
  FROM  def_porte,
        libelle, porte_export
        WHERE def_porte.sens        = 2
          AND def_porte.entite_base = libelle.sens
          AND libelle.mnemo         = 'ENT_PHYS'
          AND libelle.code          = a_entite
          AND porte_export.idporte  = def_porte.idporte
          AND porte_export.entite   = libelle.code;

vidporte	    DEF_PORTE.IDPORTE%Type;

BEGIN

    -- ouverture du curseur
  OPEN porte_recup;

  LOOP

    FETCH porte_recup INTO vidporte;

    EXIT WHEN porte_recup%NOTFOUND;

    DELETE_HISTO_EXPORT(vidporte, a_cle);

  END LOOP;

  -- fermeture du curseur
  CLOSE porte_recup;

EXCEPTION WHEN OTHERS THEN
  -- DBMS_OUTPUT.PUT_LINE( SUBSTR('DEL_HISTO_EXPORT : '||sqlerrm, 1, 80) );
  CLOSE porte_recup;
END DEL_HISTO_EXPORT;

/* -- -----------------------------------------------------------------
--  PROCEDURE : INS_PERSONNES
--  parametres
--  entree :
--  But :
--  En vue de l'insertion des informations personnes dans histo_export
--  test si individu non exporté = non présent dans la table des liens avec données externe (ECHANGE_LIEN))
*/ -- -----------------------------------------------------------------

PROCEDURE INS_PERSONNES (
        a_numindiv    IN NUMBER,
        a_idadhesion  IN NUMBER DEFAULT NULL,
				a_numgar      IN NUMBER DEFAULT NULL
        )
IS

dummy			        NUMBER;
a_idporte         NUMBER;
a_cle             NUMBER;
a_entite 	        NUMBER;
vIDADRESSE        PERS_ADRESSE.IDADRESSE%TYPE;
vIDPERSHISTPHYS   PERS_HISTO_PHYS.IDPERSHISTPHYS%TYPE;
vIDRIB            RIB.IDRIB%TYPE;
vIDCONTACT        CONTACT.IDCONTACT%TYPE;
-- si a_idadhesion est renseigné, il faut vérifier que l'individus donné par a_numindiv est déjà exporté sinon l'exporter aussi.
-- si a_numgar est alimenté, on cherche tous les individus de l'adhésion
BEGIN

IF NVL(a_numindiv,0) > 0 THEN

    BEGIN
      SELECT 1
        INTO dummy
        FROM HISTO_EXPORT
        WHERE HISTO_EXPORT.IDPORTE IN (SELECT PORTE_EXPORT.IDPORTE FROM PORTE_EXPORT WHERE PORTE_EXPORT.ENTITE = 1)
          AND HISTO_EXPORT.CLE     = a_numindiv;
      EXCEPTION WHEN No_data_found THEN
      BEGIN
        -- insertion domaine personne sur a_individu
        -- DBMS_OUTPUT.PUT_LINE( 'INS_PERSONNES a_numindiv= '||a_numindiv || ' a_idadhesion = ' ||a_idadhesion|| ' a_numgar = '||a_numgar );
        -- individu
        a_entite  := 1;
        a_cle     := a_numindiv;
        INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        -- adresse + adresse internationale
        a_entite := 2;
        -- boucle sur les adresses
        FOR vIDADRESSE IN (
                      SELECT IDADRESSE FROM PERS_ADRESSE WHERE NUMINDIV = a_numindiv
                      )
        LOOP
          a_cle := vIDADRESSE.IDADRESSE;
          INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        END LOOP;
        -- pers_histo_phys
        a_entite := 3;
        -- boucle sur les pers_histo_phys
        FOR vIDPERSHISTPHYS IN (
                      SELECT IDPERSHISTPHYS FROM PERS_HISTO_PHYS WHERE NUMINDIV = a_numindiv
                      )
        LOOP
          a_cle := vIDPERSHISTPHYS.IDPERSHISTPHYS;
          INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        END LOOP;
        -- rib
        a_entite := 4;
        -- boucle sur les rib
        FOR vIDRIB IN (
                      SELECT IDRIB FROM RIB WHERE NUMINDIV = a_numindiv
                      )
        LOOP
          a_cle := vIDRIB.IDRIB;
          INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        END LOOP;
        -- pers_morale
        a_entite  := 6;
        a_cle     := a_numindiv;
        -- boucle sur les pers_morale
        SELECT COUNT(NUMINDIV)
          INTO dummy
            FROM PERS_MORALE WHERE NUMINDIV = a_numindiv;
        IF dummy > 0 THEN
          INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        END IF;
        -- contact
        a_entite := 8;
        -- boucle sur les contacts
        FOR vIDCONTACT IN (
                      SELECT IDCONTACT FROM CONTACT WHERE NUMINDIV = a_numindiv
                      )
        LOOP
          a_cle := vIDCONTACT.IDCONTACT;
          INS_HISTO_EXPORT(a_entite, a_cle, null, a_idadhesion, a_numgar);
        END LOOP;
      END;
    END;

END IF;

EXCEPTION WHEN OTHERS THEN
  -- DBMS_OUTPUT.PUT_LINE( SUBSTR('INS_PERSONNES : '||sqlerrm, 1, 80) );
  NULL;
END INS_PERSONNES;

/* -- -----------------------------------------------------------------
--  PROCEDURE : INSERT_HISTO_EXPORT
--  parametres
--  entree : a_idporte, a_cle
--  But :
--  Insertion des informations personnes dans histo_export si non présente
*/ -- -----------------------------------------------------------------

PROCEDURE INSERT_HISTO_EXPORT (
        a_idporte   IN NUMBER,
        a_cle       IN NUMBER
        )
IS
dummy			    NUMBER;
BEGIN
-- DBMS_OUTPUT.PUT_LINE( 'DEBUT INSERT_HISTO_EXPORT a_idporte= '||a_idporte || ' a_cle = ' ||a_cle );
  SELECT	1
    INTO	Dummy
  FROM	Dual
  WHERE	EXISTS (
  	SELECT	1
  	FROM	histo_export
  	WHERE	idporte = a_idporte
  	AND	numremise = 0
  	AND	cle = a_cle);
  EXCEPTION WHEN No_data_found THEN
  	BEGIN
  	-- DBMS_OUTPUT.PUT_LINE( 'INSERT_HISTO_EXPORT a_idporte= '||a_idporte || ' a_cle = ' ||a_cle );
  	INSERT INTO histo_export (
  		idporte,
  		cle,
  		numremise)
  	VALUES (
  		a_idporte,
  		a_cle,
  		0);
  	END;

END INSERT_HISTO_EXPORT;

/* -- -----------------------------------------------------------------
--  PROCEDURE : DELETE_HISTO_EXPORT
--  parametres
--  entree : a_idporte, a_cle
--  But :
--  Suppression des informations personnes dans histo_export si numremise = 0
*/ -- -----------------------------------------------------------------

PROCEDURE DELETE_HISTO_EXPORT (
        a_idporte   IN NUMBER,
        a_cle       IN NUMBER
        )

IS
dummy			    NUMBER;
BEGIN

  SELECT	1
    INTO	Dummy
  FROM	Dual
  WHERE	NOT EXISTS (
  	SELECT	1
  	FROM	histo_export
  	WHERE	idporte = a_idporte
  	AND	numremise = 0
  	AND	cle = a_cle);
  EXCEPTION WHEN No_data_found THEN
  	BEGIN
  	-- DBMS_OUTPUT.PUT_LINE( 'DELETE_HISTO_EXPORT a_idporte= '||a_idporte || ' a_cle = ' ||a_cle );
  	DELETE FROM histo_export
            WHERE idporte   = a_idporte
              AND cle       = a_cle
              AND numremise = 0;
    EXCEPTION WHEN OTHERS THEN NULL;
  	END;

  WHEN OTHERS THEN NULL;

END DELETE_HISTO_EXPORT;

/* -- -----------------------------------------------------------------
--  FUNCTION : F_RECH_CLEF
--  parametres
--  entree : a_idporte, a_entite_base, a_cle, a_numindiv, a_idadhesion
--  But :
--  Recherche la clef à exporter
*/ -- -----------------------------------------------------------------

FUNCTION F_RECH_CLEF(
        a_idporte     IN NUMBER,
				a_entite_base IN NUMBER,
				a_cle 		    IN NUMBER,
				a_numindiv    IN NUMBER,
				a_idadhesion  IN NUMBER
        )
RETURN NUMBER

IS
LOC_RETOUR  NUMBER;
aCount      NUMBER;
BEGIN

  LOC_RETOUR  := 0;
  aCount      := 0;

  SELECT COUNT(DISTINCT ENTITE)
    INTO aCount
      FROM PORTE_EXPORT
      WHERE IDPORTE   = a_idporte;

  IF aCount > 1 THEN
    -- lorsqu'il y a plusieurs entites dans un porte,
    -- la selection des données à exporter se fait sur l'entite principale de l'entite base.
    CASE a_entite_base
      WHEN 0 THEN
        LOC_RETOUR := a_numindiv;
      WHEN 13 THEN
        LOC_RETOUR := a_idadhesion;
      ELSE
        LOC_RETOUR := a_cle;
    END CASE;
  ELSE
    -- une entite par porte => la ligne déterminée par la clef de l'entite est à exporter
    LOC_RETOUR := a_cle;
  END IF;

  RETURN(LOC_RETOUR);

  EXCEPTION WHEN OTHERS THEN
    LOC_RETOUR  := a_cle;
    RETURN(LOC_RETOUR);

END F_RECH_CLEF;

END;
/
