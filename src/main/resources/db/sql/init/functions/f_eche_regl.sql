CREATE FUNCTION ARTHUS.f_eche_regl (
                                a_mregl      IN NUMBER,
                                a_numgar     IN NUMBER,
                                a_idadhesion IN NUMBER,
                                a_debut      IN DATE,
                                a_fin        IN DATE,
                                a_regul      IN NUMBER DEFAULT 0
                                       )
RETURN DATE
IS
  loc_echeance    DATE;
  loc_debut       DATE;
  loc_jour_debut  NUMBER;
  loc_delai       NUMBER;
  loc_eche_anniv  DATE;
  loc_fract       NUMBER;
  loc_resil       DATE;
  loc_type_eche   NUMBER;
  loc_type_terme  NUMBER;
  loc_fin         DATE;
  loc_pre_date    DATE;
/*---------------------------------------------------------------------------*/
/* Nom          :  f_eche_regl                                               */
/* Description  :  calcul la date d'échéance de règlement                    */
/* Entree       :  NUMGAR      numéro de contrat/adhésion collective         */
/*                 IDADHESION  numéro adhésion individuelle                  */
/*                 DEBUT       date de début de quittance                    */
/*                 FIN         date de fin de quittance, à calculer si null  */
/* Retour       :  date d'échéance de règlement                              */
/*---------------------------------------------------------------------------*/
/* MUR M0006151 : prise ne compte étas non annulés dans le curseur           */
/* ABO M0006666 : détermintation de l'échéance d'une régularisation          */
/*---------------------------------------------------------------------------*/
CURSOR c_etat_contrat (v_numgar NUMBER, v_fin DATE) IS
SELECT etat, debut
FROM histo_contrat
WHERE numgar = v_numgar AND debut <= v_fin
and annul != 'O'  -- M0006151 exclusion etats annulés
ORDER BY datsai DESC;
r_etat_contrat c_etat_contrat%ROWTYPE;

BEGIN
  loc_fin := a_fin;

  IF NVL(a_idadhesion, 0) = 0 THEN
    -- contrat ou adhésion collective
    SELECT delai, eche_anniv, fract, type_eche, type_terme
      INTO loc_delai, loc_eche_anniv, loc_fract, loc_type_eche, loc_type_terme
        FROM contrat WHERE numgar = a_numgar;

    IF a_fin IS NULL THEN
      SELECT ADD_MONTHS(a_debut, loc_fract)-1 INTO loc_fin FROM dual ;
    END IF;

    -- récupération de la date de résiliation
    loc_resil := NULL;

    BEGIN
      OPEN c_etat_contrat(a_numgar, a_fin);
      LOOP
        FETCH c_etat_contrat INTO r_etat_contrat;
        EXIT WHEN c_etat_contrat%NOTFOUND;
          IF r_etat_contrat.etat = 3 THEN
            loc_resil := r_etat_contrat.debut;
          END IF;
        EXIT;
      END LOOP;

      CLOSE c_etat_contrat;

      EXCEPTION
        WHEN OTHERS THEN
          CLOSE c_etat_contrat;
          RETURN(NULL);
    END;
  ELSE
    -- adhésion individuelle
    SELECT a.delai, a.eche_anniv, a.fract, c.type_eche, c.type_terme, a.date_fin_adhe
      INTO loc_delai, loc_eche_anniv, loc_fract, loc_type_eche, loc_type_terme, loc_resil
        FROM adhe_cntrt a, contrat c WHERE a.idadhesion = a_idadhesion
                                       AND a.numgar = c.numgar;

    IF a_fin IS NULL THEN
      SELECT ADD_MONTHS(a_debut, loc_fract)-1 INTO loc_fin FROM dual ;
    END IF;
  END IF;




  loc_echeance := F_ECHEANCE (
                              a_mregl,
                              a_debut,
                              loc_fin,
                              loc_delai,
                              loc_eche_anniv,
                              loc_fract,
                              loc_resil,
                              loc_type_eche,
                              loc_type_terme
                              );

   --M0006666 En cas de régul ajout à date de régul de délai
   --ARTGEREP-651 : prise en compte du délai paramétré sur les contrats et adhésions indiv dans la RG GEREP
  IF a_regul =1 THEN
    CASE
      -- WELCARE: si jour entre le 15 et 31
      --  => prélèvement le 15 du mois suivant (exemple : régul jour 31/07 => prélèvement le 15/08)
      WHEN f_client = 12 AND a_mregl = 2 AND TO_NUMBER(TO_CHAR(sysdate,'DD')) BETWEEN 15 AND 31 THEN
        loc_echeance := greatest(loc_echeance, ADD_MONTHS(TRUNC(sysdate,'MM') + 14, 1));
      -- WELCARE: si jour entre le 1 et 14
      --  => prélèvement le 1er du mois suivant (exemple : régul jour 14/07 => prélèvement le 01/08)
      WHEN f_client = 12 AND a_mregl = 2 THEN
        loc_echeance := greatest(loc_echeance, ADD_MONTHS(TRUNC(sysdate,'MM'), 1));
      -- WELCARE: autres cas
      WHEN f_client = 12 THEN
        loc_echeance := greatest(loc_echeance, sysdate + 20);
      -- Autres Clients
      -- pour un échéance au 15 alors jour entre le 10 et 31
      -- pour un échéance au 7  alors jour entre le 2 et 31
      --  => échéance du mois suivant (exemple : régul jour 31/07 =>  15/08)
      WHEN TO_NUMBER(TO_CHAR(sysdate,'DD')) BETWEEN loc_delai-5 AND 31 THEN
        loc_echeance := greatest(loc_echeance, ADD_MONTHS(TRUNC(sysdate,'MM') + loc_delai-1, 1));
      -- si jour entre le 1 et 10 pour un échéance au 15
      -- si jour entre au 1 pour un échéance au 7
      --  => échéance 15 du mois en cours (exemple : régul jour 09/07 => 15/07)
      ELSE
        loc_echeance := greatest(loc_echeance, TRUNC(sysdate,'MM') + loc_delai-1);
    END CASE;
  END IF;

  RETURN(loc_echeance);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);
END;
