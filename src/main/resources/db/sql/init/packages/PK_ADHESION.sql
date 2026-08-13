CREATE OR REPLACE PACKAGE ARTHUS.PK_ADHESION AS
/*===========================================================================*/
/* Package      : PK_ADHESION.sql                                            */
/* Domaine      : Contrat                                                    */
/* Version      : V1.1                                                       */
/* Auteur       : VDA                                                        */
/* Création     : 01/12/2006                                                 */
/* Description  :                                                            */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : VDA / 30/11/2010 / MAJ F_CONTRAT_TYPECHGLISS               */
/*===========================================================================*/

-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
-- Procedure permettant de mettre a jour la table adhesion en relation avec
-- la table adhe_cntrt. Cette Procedure est appelee a partir du Trigger
-- (After Update) sur table adhe_cntrt suite  a la mise a jour de "date_adhe".
--
   PROCEDURE P_Upd_Adhesion (
      i_idadhesion      IN   adhe_cntrt.idadhesion%TYPE,
      i_old_date_adhe   IN   adhe_cntrt.date_adhe%TYPE,
      i_new_date_adhe   IN   adhe_cntrt.date_adhe%TYPE
   );
--
-- Procedure permettant de mettre a jour la table Val_variable en relation
-- avec la table adhesion. Cette Procedure est appelee a partir du Trigger
-- (After Update) sur la table Adhesion suite  a la mise a jour de "datapli".
--
   PROCEDURE P_Upd_Val_Variable (
      i_idadhesion    IN   adhesion.idadhesion%TYPE,
      i_numgar        IN   adhesion.numgar%TYPE,
      i_numindiv      IN   adhesion.numindiv%TYPE,
      i_old_datapli   IN   adhesion.datapli%TYPE,
      i_new_datapli   IN   adhesion.datapli%TYPE
   );

--
-- Procedure permettant de supprimer les enregistrements de la table table
-- Val_variable en relation avec la table adhesion. Cette Procedure est appelee
-- a partir du Trigger (After Delete) sur la table Adhesion suite a la
-- suppression de lignes sur adhesion.
--
   PROCEDURE P_Del_Val_Variable (
      i_idadhesion    IN   adhesion.idadhesion%TYPE,
      i_numgar        IN   adhesion.numgar%TYPE,
      i_numindiv      IN   adhesion.numindiv%TYPE,
      i_old_datapli   IN   adhesion.datapli%TYPE
   );

-- 07/10/2010 VDA : M0002719 Fonction utilisée pour l'édition ad01b
-- Renvoi une date d'effet d'une adhésion en fonction d'une date de référence
  FUNCTION F_Date_Effet(I_IdAdhesion IN ADHESION.IdAdhesion%TYPE,
                        I_DateRef    IN DATE DEFAULT SYSDATE) RETURN DATE;

-- Renvoi le libellé de la formule principale avec les options en fonction d'une date de référence
  FUNCTION F_Formule_Option(I_IdAdhesion IN ADHESION.IdAdhesion%TYPE,
                            I_Sepa       IN VARCHAR2 DEFAULT ', ',
                            I_DateRef    IN DATE DEFAULT SYSDATE) RETURN VARCHAR2;

-- Renvoi l'indicateur si le contrat est de type échéance glissante ou non
   FUNCTION F_CONTRAT_TYPECHGLISS(I_IdAdhesion IN ADHESION.IDADHESION%TYPE) RETURN BOOLEAN;
-- 07/10/2010 VDA : ____________________________________________________________

--
-- -------------------------------------------- Fin des procedures publiques --
/***Function qui renvoi un idadhesion unique***/
FUNCTION F_IDADHESION RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_ADHESION AS
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
   PROCEDURE P_Upd_Adhesion (
      i_idadhesion      IN   adhe_cntrt.idadhesion%TYPE,
      i_old_date_adhe   IN   adhe_cntrt.date_adhe%TYPE,
      i_new_date_adhe   IN   adhe_cntrt.date_adhe%TYPE
   )
   IS
   BEGIN
      UPDATE adhesion
         SET datapli = i_new_date_adhe
       WHERE idadhesion = i_idadhesion
         AND TRUNC (datapli) = i_old_date_adhe;

      --
      UPDATE adhesion
         SET datapli = i_new_date_adhe
       WHERE idadhesion = i_idadhesion
         AND TRUNC (datapli) < i_new_date_adhe
         AND adhesion.datper IS NULL;
   --
   END;

--
--
   PROCEDURE P_Upd_Val_Variable (
      i_idadhesion    IN   adhesion.idadhesion%TYPE,
      i_numgar        IN   adhesion.numgar%TYPE,
      i_numindiv      IN   adhesion.numindiv%TYPE,
      i_old_datapli   IN   adhesion.datapli%TYPE,
      i_new_datapli   IN   adhesion.datapli%TYPE
   )
   IS
   BEGIN
      UPDATE val_variable
         SET debut = i_new_datapli
       WHERE statique = 'O'
         AND TRUNC (debut) = i_old_datapli
         AND etendue = 13
         AND clef = i_idadhesion
         AND numgar = pk_qttc.f_sel_numgar (i_numgar);

      --
      UPDATE val_variable
         SET debut = i_new_datapli
       WHERE statique = 'O'
         AND TRUNC (debut) = i_old_datapli
         AND etendue = 4
         AND clef = f_numassu (i_numindiv, i_idadhesion)
         AND numgar = pk_qttc.f_sel_numgar (i_numgar);

      --
      UPDATE val_variable
         SET debut = i_new_datapli
       WHERE statique = 'O'
         AND TRUNC (debut) = i_old_datapli
         AND etendue = 12
         AND clef = i_numindiv
         AND numgar = pk_qttc.f_sel_numgar (i_numgar);
   END;

--
--
   PROCEDURE P_Del_Val_Variable (
      i_idadhesion    IN   adhesion.idadhesion%TYPE,
      i_numgar        IN   adhesion.numgar%TYPE,
      i_numindiv      IN   adhesion.numindiv%TYPE,
      i_old_datapli   IN   adhesion.datapli%TYPE
   )
   IS
   BEGIN
      DELETE FROM val_variable
            WHERE statique = 'O'
              AND TRUNC (debut) = i_old_datapli
              AND etendue = 13
              AND clef = i_idadhesion
              AND numgar = pk_qttc.f_sel_numgar (i_numgar);

      --
      DELETE FROM val_variable
            WHERE statique = 'O'
              AND TRUNC (debut) = i_old_datapli
              AND etendue = 4
              AND clef = f_numassu (i_numindiv, i_idadhesion)
              AND numgar = pk_qttc.f_sel_numgar (i_numgar);

      --
      DELETE FROM val_variable
            WHERE statique = 'O'
              AND TRUNC (debut) = i_old_datapli
              AND etendue = 12
              AND clef = i_numindiv
              AND numgar = pk_qttc.f_sel_numgar (i_numgar);
   END;


  -- Renvoi une date d'effet d'une adhésion en fonction d'une date de référence
  FUNCTION F_Date_Effet(I_IdAdhesion IN ADHESION.IdAdhesion%TYPE,
                        I_DateRef    IN DATE DEFAULT SYSDATE) RETURN DATE
  IS
    d_Result DATE := NULL;
    d_MaxDatApli DATE;
    d_MaxDatPer DATE;
    d_DateAnniv DATE;
  BEGIN

    SELECT MAX(A.DATAPLI)
    INTO d_MaxDatApli
    FROM
      adhe_cntrt ac,
      adhe_cntrt_membre acm,
      adhesion a,
      indvs i,
      gar_cntrt_edit gce
    WHERE a.numgar = gce.numgar
      AND a.idadhesion = I_IdAdhesion
      AND i.numindiv = a.numindiv
      AND a.numindiv = acm.numindiv
      AND a.idadhesion = ac.idadhesion
      AND ac.idadhesion = acm.idadhesion
      AND I_DateRef BETWEEN a.datapli AND NVL(a.datper,I_DateRef)
      AND nvl(a.datper,a.datapli+1) != a.datapli
      --AND a.datapli <= I_DateRef
      AND a.etat IN (SELECT code FROM lble WHERE mnemo='ETIN' AND sens=0)
      AND ( (a.numfor    = gce.numfor)
      OR EXISTS
        (SELECT 1
        FROM grp_gar_def ggd
        WHERE numgrpgar = a.numfor
        AND ggd.numfor  = gce.numfor
        ) )
      AND gce.Ind_Edit = 'O';

    SELECT MAX(A.DATPER)
    INTO d_MaxDatPer
    FROM
      adhe_cntrt ac,
      adhe_cntrt_membre acm,
      adhesion a,
      indvs i,
      gar_cntrt_edit gce
    WHERE a.numgar = gce.numgar
      AND a.idadhesion = I_IdAdhesion
      AND i.numindiv = a.numindiv
      AND a.numindiv = acm.numindiv
      AND a.idadhesion = ac.idadhesion
      AND ac.idadhesion = acm.idadhesion
      --AND I_DateRef BETWEEN a.datapli AND NVL(a.datper,I_DateRef)
      AND nvl(a.datper,a.datapli+1) != a.datapli
      AND a.datper < I_DateRef
      AND a.etat IN (SELECT code FROM lble WHERE mnemo='ETIN' AND sens=0)
      AND ( (a.numfor    = gce.numfor)
      OR EXISTS
        (SELECT 1
        FROM grp_gar_def ggd
        WHERE numgrpgar = a.numfor
        AND ggd.numfor  = gce.numfor
        ) )
      AND gce.Ind_Edit = 'O';

    SELECT MAX(TO_DATE(TO_CHAR(AC.ECHE_ANNIV,'DD/MM/')||TO_CHAR(I_DateRef,'YYYY'),'DD/MM/YYYY')) INTO d_DateAnniv
    FROM adhe_cntrt ac
    WHERE ac.idadhesion = I_IdAdhesion AND d_MaxDatApli IS NOT NULL;

    SELECT MAX(aDATE) INTO d_Result FROM (
      SELECT d_MaxDatApli AS aDATE FROM DUAL
        UNION ALL
      SELECT d_MaxDatPer+1 AS aDATE FROM DUAL WHERE d_MaxDatPer IS NOT NULL
        UNION ALL
      SELECT d_DateAnniv AS aDATE FROM DUAL
    );

    RETURN d_Result;

  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  -- Renvoi le libellé de la formule principale avec les options en fonction d'une date de référence
  FUNCTION F_Formule_Option(I_IdAdhesion IN ADHESION.IdAdhesion%TYPE,
                            I_Sepa       IN VARCHAR2 DEFAULT ', ',
                            I_DateRef    IN DATE DEFAULT SYSDATE ) RETURN VARCHAR2
  IS
    s_Result VARCHAR2(4000) := '';
    s_Sepa   VARCHAR2(8)    := I_Sepa;

    CURSOR C_LIBELLE(P_IdAdhesion ADHESION.IdAdhesion%TYPE,
                     P_DateRef    DATE) IS
    SELECT NVL(gce.Lib_Edit, gce.libelle) AS Lib_Garantie ,
           gce.Ind_Option                 AS Ind_Option
      FROM
        gar_cntrt_edit gce ,
        adhe_cntrt ac ,
        adhesion ad
      WHERE ad.idadhesion = P_IdAdhesion
        AND ac.numgar       = gce.numgar
        AND ad.idadhesion   = ac.idadhesion
        AND ad.numindiv     = ac.numadhe
        AND ( ad.numfor     = gce.numfor
              OR EXISTS
                (SELECT 1
                FROM grp_gar_def ggd
                WHERE numgrpgar = ad.numfor
                AND ggd.numfor  = gce.numfor)
            )
        AND P_DateRef BETWEEN ad.datapli AND NVL(ad.datper,P_DateRef)
        AND NVL(ad.datper,P_DateRef)    >= P_DateRef
        AND NVL(ad.datper,ad.datapli     +1) != ad.datapli
        AND ad.etat IN (SELECT code FROM lble WHERE mnemo='ETIN' AND sens=0)
        AND gce.Ind_Edit = 'O'
      ORDER BY
        NVL(gce.Num_Ordre,999) ASC,
        gce.Ind_Option ASC;

    R_LIBELLE C_LIBELLE%ROWTYPE;

  BEGIN

    OPEN C_LIBELLE (I_IdAdhesion, I_DateRef);
    LOOP
      FETCH C_LIBELLE INTO R_LIBELLE;
      EXIT WHEN C_LIBELLE%NOTFOUND;
      CASE
        WHEN R_LIBELLE.Ind_Option = 'N' THEN s_Result := R_LIBELLE.Lib_Garantie;
        WHEN R_LIBELLE.Ind_Option = 'O' THEN
          s_Result := s_Result || s_Sepa || R_LIBELLE.Lib_Garantie;
          IF LENGTH(s_Sepa)>2 THEN
            s_Sepa := ', ';
          END IF;
        ELSE NULL;
      END CASE;
    END LOOP;
    CLOSE C_LIBELLE;

    --Remplacement du caractère ¤ par un retour chariot
    s_Result := LTRIM(REPLACE(s_Result,'¤',CHR(10)),s_Sepa);

    RETURN s_Result;

  EXCEPTION
    WHEN OTHERS THEN
    IF C_LIBELLE%ISOPEN THEN
      CLOSE C_LIBELLE;
    END IF;
    RETURN NULL;
  END;

  -- Renvoi l'indicateur si le contrat est de type échéance glissante ou non
  FUNCTION F_CONTRAT_TYPECHGLISS(I_IdAdhesion IN ADHESION.IDADHESION%TYPE) RETURN BOOLEAN
  IS
    i_Result CONTRAT.TYPE_ECHE%TYPE;
  BEGIN

    SELECT TYPE_ECHE INTO i_Result FROM CONTRAT WHERE NumGar=F_NUMGAR(I_IdAdhesion);
    RETURN (NVL(i_Result,0) = 1);

  EXCEPTION
    WHEN OTHERS THEN RETURN FALSE;
  END;

/***Function qui renvoi un idadhesion unique***/
FUNCTION F_IDADHESION RETURN NUMBER
IS
  l_idadhesion adhesion.idadhesion%type;
BEGIN
  SELECT idadhesion.nextval
    INTO l_idadhesion
    FROM dual;

  RETURN l_idadhesion;

END F_IDADHESION;
--
-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --


END;
/
