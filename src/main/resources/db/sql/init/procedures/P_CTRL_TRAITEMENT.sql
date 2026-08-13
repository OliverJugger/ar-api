CREATE PROCEDURE ARTHUS.P_CTRL_TRAITEMENT(I_numedit IN file_edition.numedit%TYPE, I_batchid IN file_edition.batchid%TYPE, I_valdeb1 IN param_dmnde.valdeb1%TYPE,
                            I_valfin1 IN param_dmnde.valfin1%TYPE, I_valdeb2 IN param_dmnde.valdeb2%TYPE, I_valfin2 IN param_dmnde.valfin2%TYPE,
                            I_valdeb3 IN param_dmnde.valdeb3%TYPE, I_valfin3 IN param_dmnde.valfin3%TYPE, I_valdeb4 IN param_dmnde.valdeb4%TYPE,
                            I_valfin4 IN param_dmnde.valfin4%TYPE, I_valdeb5 IN param_dmnde.valdeb5%TYPE, I_valfin5 IN param_dmnde.valfin5%TYPE,
                            I_valdeb6 IN param_dmnde.valdeb6%TYPE, I_valfin6 IN param_dmnde.valfin6%TYPE, I_valdeb7 IN param_dmnde.valdeb7%TYPE,
                            I_valfin7 IN param_dmnde.valfin7%TYPE, I_valdeb8 IN param_dmnde.valdeb8%TYPE, I_valfin8 IN param_dmnde.valfin8%TYPE,
                            I_valdeb9 IN param_dmnde.valdeb9%TYPE, I_valfin9 IN param_dmnde.valfin9%TYPE, I_valdeb10 IN param_dmnde.valdeb10%TYPE,
                            I_valfin10 IN param_dmnde.valfin10%TYPE, o_retour OUT file_edition.numedit%TYPE)
/*===========================================================================*/
/* Procedure    : P_CTRI_TRAITEMENT.sql                                      */
/* Domaine      : Editique                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : 24/09/2015                                                 */
/* Description  : Recherche de traitement concurrentiel                      */
/* Renvoie le numéro d'édition concurrentiel qui est en cours                */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* TRAITEMENTS  : GDP8T Tt. constit. dde de rembt prestations soins santé    */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/*===========================================================================*/
/* Correction   : PHA 08/02/2017 0005257: Limiter le message de traitement   */
/*                          concurrent aux traitements des 5 derniers jours  */
/*===========================================================================*/

      -- 
IS
-- prendre en compte que les traitements à tester
  CURSOR c_file_edition
  IS
    SELECT numedit, numdmnde
      FROM file_edition
      WHERE batchid             IN ('GDP8T', 'GS19T', 'NO06T')   
        AND file_edition.status IN (4)                           -- on prend les traitements en cours.
        AND batchid             = I_batchid                      -- on prend les traitements en cours.
        AND date_demande        > SYSDATE - 5                    -- que les traitements des 5 derniers jours.
      ORDER BY numedit DESC;                                     -- ordonné du plus récent au plus ancien

  r_file_edition  c_file_edition%ROWTYPE;

  v_valdeb1	  	param_dmnde.valdeb1%TYPE;
  v_valfin1	  	param_dmnde.valfin1%TYPE;
  v_valdeb2	  	param_dmnde.valdeb2%TYPE;
  v_valfin2	  	param_dmnde.valfin2%TYPE;
  v_valdeb3	  	param_dmnde.valdeb3%TYPE;
  v_valfin3	  	param_dmnde.valfin3%TYPE;
  v_valdeb4	  	param_dmnde.valdeb4%TYPE;
  v_valfin4	  	param_dmnde.valfin4%TYPE;
  v_valdeb5	  	param_dmnde.valdeb5%TYPE;
  v_valfin5	  	param_dmnde.valfin5%TYPE;
  v_valdeb6	  	param_dmnde.valdeb6%TYPE;
  v_valfin6	  	param_dmnde.valfin6%TYPE;
  v_valdeb7	  	param_dmnde.valdeb7%TYPE;
  v_valfin7	  	param_dmnde.valfin7%TYPE;
  v_valdeb8	  	param_dmnde.valdeb8%TYPE;
  v_valfin8	  	param_dmnde.valfin8%TYPE;
  v_valdeb9	  	param_dmnde.valdeb9%TYPE;
  v_valfin9	  	param_dmnde.valfin9%TYPE;
  v_valdeb10	  param_dmnde.valdeb10%TYPE;
  v_valfin10	  param_dmnde.valfin10%TYPE;

BEGIN

  o_retour := 0;

  -- recherche des traitements en cours
  FOR r_file_edition IN c_file_edition
  LOOP
    -- récupération des paramètres du traitement en cours
    SELECT valdeb1, valfin1, valdeb2, valfin2, valdeb3, valfin3, valdeb4, valfin4, valdeb5, valfin5,
           valdeb6, valfin6, valdeb7, valfin7, valdeb8, valfin8, valdeb9, valfin9, valdeb10, valfin10
      INTO v_valdeb1, v_valfin1, v_valdeb2, v_valfin2, v_valdeb3, v_valfin3, v_valdeb4, v_valfin4,
           v_valdeb5, v_valfin5, v_valdeb6, v_valfin6, v_valdeb7, v_valfin7, v_valdeb8, v_valfin8,
           v_valdeb9, v_valfin9, v_valdeb10, v_valfin10
            FROM param_dmnde
            WHERE numdmnde = r_file_edition.numdmnde;


    -- DEBUT test par traitement
    IF I_batchid = 'GDP8T' THEN
        -- Pas de contrôle possible sur la période
        -- pour ce traitement, on contrôle 1 la société 2 Organisme assureur et 4 contrat
        -- 1 la société
      IF ((v_valdeb1 IS NULL OR I_valdeb1 IS NULL) OR (v_valdeb1 IS NOT NULL AND I_valdeb1 IS NOT NULL AND v_valdeb1 = I_valdeb1)) THEN
        -- 2 Organisme assureur
        IF ((v_valdeb2 IS NULL OR I_valdeb2 IS NULL) OR (v_valdeb2 IS NOT NULL AND I_valdeb2 IS NOT NULL
                                       AND v_valdeb2 <= NVL(I_valfin2, I_valdeb2)
                                        AND NVL(v_valfin2, v_valdeb2) >= I_valdeb2)) THEN
          -- 4 contrat
          IF ((v_valdeb4 IS NULL OR I_valdeb4 IS NULL) OR (v_valdeb4 IS NOT NULL AND I_valdeb4 IS NOT NULL
                                         AND v_valdeb4 <= NVL(I_valfin4, I_valdeb4)
                                          AND NVL(v_valfin4, v_valdeb4) >= I_valdeb4)) THEN
            o_retour := r_file_edition.numedit;
          END IF;
        END IF;
      END IF;

    ELSIF I_batchid = 'GS19T' THEN
      IF (v_valdeb1 <= (NVL(I_valfin1, I_valdeb1))) AND (NVL(v_valfin1, v_valdeb1) >= I_valdeb1) THEN
        -- traitement sur même remise (on ne regarde pas la porte car les numremise sont unique sans dépendance de porte)
        -- pour ce traitement, on bloque
        o_retour := r_file_edition.numedit;
      END IF;

    ELSIF I_batchid = 'NO06T' THEN
      IF (v_valdeb1 = I_valdeb1) THEN
        -- traitement sur même porte
        -- pour ce traitement, on bloque
        o_retour := r_file_edition.numedit;
      END IF;

    END IF;
    -- FIN test par traitement
    IF o_retour > 0 THEN
      EXIT;
    END IF;
  END LOOP;

END;
/
