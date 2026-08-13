CREATE procedure ARTHUS.P_MAJ_numero
IS
      I_numero number;
      o_numtr traite.numtr%TYPE;
      p_numav avenant.numav%TYPE;
      Rec_avenant avenant%ROWTYPE;
      Rec_trait avenant%ROWTYPE;
      BEGIN
        FOR Rec_trait IN (
             Select distinct numtr
                FROM avenant
                ORDER BY numtr)
          LOOP
           o_numtr := Rec_trait.numtr;
           I_numero := 0;
           For Rec_avenant IN (
                Select  numav
                From    AVENANT
                Where   numtr = o_numtr
                order by numav)
            LOOP
              p_numav := Rec_avenant.numav;
            UPDATE avenant SET numero = I_numero
            WHERE numtr =  o_numtr
            AND numav = p_numav;
            I_numero := I_numero + 1;
            END LOOP;
         END LOOP;
END;
/
