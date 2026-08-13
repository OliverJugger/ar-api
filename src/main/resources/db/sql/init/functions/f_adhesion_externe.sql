CREATE FUNCTION ARTHUS.f_adhesion_externe (
   a_numgar     IN   NUMBER,
   a_numindiv   IN   NUMBER,
   a_toute      IN   VARCHAR2 DEFAULT 'N'
)
   RETURN pk_types.t_table
IS
   retour        pk_types.t_table;
   ouverte       NUMBER;
   loc_ouverte   NUMBER;
   numreg        NUMBER;
   numsoc        NUMBER;
   numorg        NUMBER;
   numdpt        VARCHAR2 (2);
   numcaisse     VARCHAR2 (5);
   numporte      NUMBER;
   i             BINARY_INTEGER   := 0;
BEGIN
   FOR porte IN (SELECT porte_contrat.numporte, contrat_ref.numinterm numsoc,
                        contrat_ref.numorg numorg, indvs.regime numreg,
                        trpnt.caisse numcaisse,
                        SUBSTR (trpnt.codpos, 1, 2) numdpt
                   FROM porte_contrat, contrat_ref, indvs, trpnt
                  WHERE porte_contrat.numgar =
                                              pk_qttc.f_sel_numgar (a_numgar)
                    AND contrat_ref.numgar_ref = porte_contrat.numgar
                    AND indvs.numindiv = a_numindiv
                    AND trpnt.numtp = f_caisse (a_numindiv))
   LOOP
      numreg := porte.numreg;
      numsoc := porte.numsoc;
      numorg := porte.numorg;
      numdpt := porte.numdpt;
      numcaisse := porte.numcaisse;
      numporte := porte.numporte;
      -- Recherche en global
      ouverte := -1;
      --
      loc_ouverte := f_sel_parporte (numreg, numsoc, 0, '00', '0', numporte);

      SELECT DECODE (loc_ouverte, -1, -1, 0, ouverte, 1, 1, -1)
        INTO ouverte
        FROM DUAL;

      --
      loc_ouverte :=
                   f_sel_parporte (numreg, numsoc, numorg, '00', '0', numporte);

      SELECT DECODE (loc_ouverte, -1, -1, 0, ouverte, 1, 1, -1)
        INTO ouverte
        FROM DUAL;

      --
      loc_ouverte :=
                f_sel_parporte (numreg, numsoc, numorg, numdpt, '0', numporte);

      SELECT DECODE (loc_ouverte, -1, -1, 0, ouverte, 1, 1, -1)
        INTO ouverte
        FROM DUAL;

      --
      loc_ouverte :=
             f_sel_parporte (numreg, numsoc, numorg, '00', numcaisse, numporte);

      SELECT DECODE (loc_ouverte, -1, -1, 0, ouverte, 1, 1, -1)
        INTO ouverte
        FROM DUAL;

      --
      loc_ouverte :=
          f_sel_parporte (numreg, numsoc, numorg, numdpt, numcaisse, numporte);

      SELECT DECODE (loc_ouverte, -1, -1, 0, ouverte, 1, 1, -1)
        INTO ouverte
        FROM DUAL;

      -- relation d'ordre dans la table parporte
      -- 1 -
      -- 2 -
      -- 3 -
      -- 4 -
      -- 5 -
      -- 6 -
      -- 7 -
      -- Allons voir si la porte courante (numporte) est ouverte dans le contxte
      -- ou nous nous trouvons.
      IF (ouverte = 1)
      THEN
         i := i + 1;
         retour (i) := numporte;
      END IF;
   END LOOP;                            /* on boucle sur la porte suivante  */

   --
   retour (i + 1) := 0;              /* On ferme le tableau par la valeur 0 */
   --
   RETURN (retour);
--
END f_adhesion_externe;
--;
