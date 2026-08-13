CREATE FUNCTION ARTHUS."F_FRANCHISE" (
   a_type         IN   NUMBER DEFAULT 1,
   a_idadhesion   IN   NUMBER,
   a_numfor       IN   NUMBER,
   a_numassu      IN   NUMBER,
   a_numindiv     IN   NUMBER,
   a_codfrais     IN   VARCHAR2,
   a_rubrique     IN   VARCHAR2,
   a_datsin       IN   DATE,
   a_numdossier   IN   VARCHAR2 DEFAULT '0'
)
   RETURN NUMBER
AS
   loc_retour      NUMBER;
   loc_frequence   NUMBER;
   loc_datapli     DATE;
   loc_datper      DATE;
   loc_etendue     NUMBER;
   loc_nummath     NUMBER;
   loc_typfran     NUMBER;
   loc_codfrais    VARCHAR2 (5) := a_codfrais;
   loc_type        NUMBER (2)   := 0;
                       -- type de franchise 1=dossier, 2= Acte, 3=fam, 4= gar
BEGIN
   /* recherche d'une franchise sur dossier */
   BEGIN
      SELECT 1, date_deb, date_fin, etendue, NVL (nummath, 0),
             frequence, typfran
        INTO loc_type, loc_datapli, loc_datper, loc_etendue, loc_nummath,
             loc_frequence, loc_typfran
        FROM frandoss
       WHERE num_dossier = a_numdossier
         AND a_datsin BETWEEN date_deb AND NVL (date_fin, a_datsin);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_type := 2;

         <<retour>>
         BEGIN
            SELECT franact.datapli, franact.datper, franact.etendue,
                   NVL (franact.nummath, 0), franact.frequence,
                   franact.typfran
              INTO loc_datapli, loc_datper, loc_etendue,
                   loc_nummath, loc_frequence,
                   loc_typfran
              FROM franact, gar_cntrt
             WHERE a_numfor = gar_cntrt.numfor
               AND franact.numfor =
                      pk_qttc.f_sel_numfor (gar_cntrt.numgar,
                                            gar_cntrt.numfor)
               AND franact.codfrais = loc_codfrais
               AND franact.datapli !=
                                     NVL (franact.datper, franact.datapli + 1)
               AND a_datsin BETWEEN franact.datapli
                                AND NVL (franact.datper, a_datsin);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_type := 3;

               IF (loc_codfrais != a_rubrique)
               THEN
                  loc_codfrais := a_rubrique;
                  GOTO retour;
               ELSE
                  BEGIN
                     loc_type := 4;

                     SELECT franfor.datapli, franfor.datper,
                            franfor.etendue, NVL (franfor.nummath, 0),
                            franfor.frequence, franfor.typfran
                       INTO loc_datapli, loc_datper,
                            loc_etendue, loc_nummath,
                            loc_frequence, loc_typfran
                       FROM franfor, gar_cntrt
                      WHERE a_numfor = gar_cntrt.numfor
                        AND franfor.numfor =
                               pk_qttc.f_sel_numfor (gar_cntrt.numgar,
                                                     gar_cntrt.numfor
                                                    )
                        AND franfor.datapli !=
                                     NVL (franfor.datper, franfor.datapli + 1)
                        AND a_datsin BETWEEN franfor.datapli
                                         AND NVL (franfor.datper, a_datsin);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        loc_retour := 0;
                        RETURN (loc_retour);
                  END;
               END IF;
         END;
   END;                                                   -- exception dossier

   IF (a_type = 1)
   THEN
      loc_retour := loc_type;
   ELSIF (a_type = 2)
   THEN
      IF (loc_type = 1)
      THEN                                          -- franchises sur dossier
         SELECT SUM (NVL (sntr.mtprest, 0))
           INTO loc_retour
           FROM sntr, sntr_dossier
          WHERE sntr_dossier.numsin_sntr = sntr.numsin
            AND sntr_dossier.num_dossier = a_numdossier
            AND sntr.numannul IS NULL
            AND sntr.datsin BETWEEN loc_datapli AND NVL (loc_datper,
                                                         sntr.datsin
                                                        )
            AND (   (    loc_frequence = 2
                     AND TO_CHAR (a_datsin, 'YY') =
                                                   TO_CHAR (sntr.datsin, 'YY')
                    )
                 OR (loc_frequence = 1)
                )
            AND NOT EXISTS (SELECT 1
                              FROM sntr a
                             WHERE a.numannul = sntr.numsin);
      ELSE                                       -- franchise sur acte/fam/gar
         SELECT SUM (NVL (sntr.mtprest, 0))
           INTO loc_retour
           FROM sntr, calcul
          WHERE sntr.codfrais = calcul.codfrais
            AND (   (loc_etendue = 1 AND sntr.numindiv = a_numindiv)
                 OR (loc_etendue = 2 AND sntr.numassu = a_numassu)
                )
            AND sntr.codfrais =
                               DECODE (loc_type,
                                       2, a_codfrais,
                                       sntr.codfrais
                                      )
            AND calcul.rubrique =
                         DECODE (loc_type,
                                 3, loc_codfrais,
                                 calcul.rubrique
                                )
            AND calcul.numfor   =  pk_qttc.f_sel_numfor (sntr.numgar,sntr.numfor)
            AND calcul.datapli <= sntr.datsin
            AND NVL(calcul.datper, sntr.datsin) >= sntr.datsin
            AND sntr.idadhesion = a_idadhesion
            AND sntr.numfor + 0 = a_numfor
            AND NOT EXISTS (
                   SELECT 1
                     FROM sntr a, calcul
                    WHERE a.numindiv =
                               DECODE (loc_etendue,
                                       1, a_numindiv,
                                       a_numindiv
                                      )
                      AND a.numassu =
                                 DECODE (loc_etendue,
                                         2, a_numassu,
                                         a.numassu
                                        )
                      AND a.codfrais = calcul.codfrais
                      AND a.codfrais =
                                  DECODE (loc_type,
                                          2, a_codfrais,
                                          a.codfrais
                                         )
                      AND calcul.rubrique =
                             DECODE (loc_type,
                                     3, loc_codfrais,
                                     calcul.rubrique
                                    )
                      AND calcul.numfor   = pk_qttc.f_sel_numfor (sntr.numgar,sntr.numfor)
                      AND calcul.datapli <= sntr.datsin
                      AND NVL(calcul.datper, sntr.datsin) >= sntr.datsin
                      AND a.idadhesion = a_idadhesion
                      AND a.numfor + 0 = a_numfor
                      AND a.numannul = sntr.numsin)
            AND sntr.numannul IS NULL
            AND sntr.datsin BETWEEN loc_datapli AND NVL (loc_datper,
                                                         sntr.datsin
                                                        )
            AND (   (    loc_frequence = 2
                     AND TO_CHAR (a_datsin, 'YY') =
                                                   TO_CHAR (sntr.datsin, 'YY')
                    )
                 OR (loc_frequence = 1)
                );
      END IF;                                                  -- fin dossiers
   ELSIF (a_type = 3)
   THEN
      IF (loc_type = 1)
      THEN                                           -- franchise sur dossier
         SELECT SUM (NVL (travsn.mtprest, 0))
           INTO loc_retour
           FROM travsn
          WHERE travsn.numindiv = a_numindiv
            AND travsn.datsin BETWEEN loc_datapli
                                  AND NVL (loc_datper, travsn.datsin)
            AND (   (    loc_frequence = 2
                     AND TO_CHAR (a_datsin, 'YY') =
                                                 TO_CHAR (travsn.datsin, 'YY')
                    )
                 OR (loc_frequence = 1)
                );
      ELSE
         SELECT SUM (NVL (travsn.mtprest, 0))
           INTO loc_retour
           FROM travsn, calcul
          WHERE travsn.codfrais = calcul.codfrais
            AND (   (loc_etendue = 1 AND travsn.numindiv = a_numindiv)
                 OR (loc_etendue = 2 AND travsn.numassu = a_numassu)
                )
            AND travsn.codfrais =
                             DECODE (loc_type,
                                     2, a_codfrais,
                                     travsn.codfrais
                                    )
            AND calcul.rubrique =
                         DECODE (loc_type,
                                 3, loc_codfrais,
                                 calcul.rubrique
                                )
            AND travsn.idadhesion  = a_idadhesion
            AND travsn.numpopu + 0 = a_numfor
            AND calcul.numfor      = pk_qttc.f_sel_numfor (travsn.numgar,travsn.numpopu)
            AND calcul.datapli    <= travsn.datsin
            AND NVL(calcul.datper, travsn.datsin) >= travsn.datsin
            AND travsn.datsin BETWEEN loc_datapli
                                  AND NVL (loc_datper, travsn.datsin)
            AND (   (    loc_frequence = 2
                     AND TO_CHAR (a_datsin, 'YY') =
                                                 TO_CHAR (travsn.datsin, 'YY')
                    )
                 OR (loc_frequence = 1)
                );
      END IF;                                                   -- fin dossier
   ELSIF (a_type = 4)
   THEN
      loc_retour := loc_nummath;
   ELSIF (a_type = 5)
   THEN
      loc_retour := loc_typfran;
   END IF;

   RETURN (loc_retour);
END;
