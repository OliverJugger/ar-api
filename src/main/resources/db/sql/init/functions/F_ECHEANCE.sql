CREATE FUNCTION ARTHUS.F_ECHEANCE (
                                      a_mregl      IN NUMBER,
                                      a_debut      IN DATE,
                                      a_fin        IN DATE,
                                      a_delai      IN NUMBER,
                                      a_eche_anniv IN DATE,
                                      a_fract      IN NUMBER,
                                      a_resil      IN DATE,
                                      a_type_eche  IN NUMBER,
                                      a_type_terme IN NUMBER
                                      )
RETURN DATE
IS
  loc_echeance    DATE;
  loc_jour_debut  NUMBER;
  loc_pre_date    DATE;
/*---------------------------------------------------------------------------*/
/* Nom          :  F_ECHEANCE                                                */
/* Description  :  calcul la date d'échéance de règlement                    */
/*                 sous fonction de F_ECHE_REGL (suite utilisation dans un   */
/*                 trigger de ADHE_CNTRT pour eviter mutation                */
/* Entree       :  données pour calcul date échéance de la quittance         */
/* Retour       :  date d'échéance de règlement                              */
/*---------------------------------------------------------------------------*/
BEGIN

  -- calcul de l'échéance de paiement
  IF a_mregl = 1 THEN
    -- chèque
    SELECT
            DECODE( a_type_eche, 0,
                  DECODE( a_type_terme, 1 , a_fin + a_delai, a_debut + a_delai ),
                  DECODE( a_type_terme, 1 , DECODE ( NVL(a_resil , E2D('01/01/1901') ) , a_fin , a_resil , ADD_MONTHS( a_debut , a_fract - MOD( MOD( months_between ( a_debut , a_eche_anniv ) , 12 ) , a_fract)) ) -1 + a_delai
                         , ADD_MONTHS( a_debut , - MOD( MOD( months_between ( a_debut , a_eche_anniv ) , 12 ) , a_fract)) + a_delai )
                  )
            INTO loc_echeance
            FROM dual;
  ELSE
    -- virement
    SELECT
          DECODE( a_type_eche, 0,
                DECODE( a_type_terme, 1 , a_fin, a_debut ),
                DECODE( a_type_terme, 1 , DECODE ( NVL(a_resil , E2D('01/01/1901') ) , a_fin , a_resil , ADD_MONTHS( a_debut , a_fract - MOD( MOD( months_between ( a_debut , a_eche_anniv ) , 12 ) , a_fract)) ) -1
                       , ADD_MONTHS( a_debut , - MOD( MOD( months_between ( a_debut , a_eche_anniv ) , 12 ) , a_fract)) )
                )
          INTO loc_pre_date
          FROM dual;

    loc_jour_debut := TO_NUMBER(TO_CHAR(loc_pre_date, 'dd'));

    IF ( SIGN(loc_jour_debut - a_delai) IN (0, -1) ) THEN
          loc_echeance := TRUNC(loc_pre_date, 'MM') + (a_delai - 1);
      ELSE
          loc_echeance := TRUNC(ADD_MONTHS( loc_pre_date, SIGN(a_delai) ), 'MM')
                      + ( ABS(a_delai) - 1);
      END IF;

  END IF;

  RETURN(loc_echeance);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);
END;
