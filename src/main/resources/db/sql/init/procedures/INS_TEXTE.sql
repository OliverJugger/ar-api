CREATE PROCEDURE ARTHUS."INS_TEXTE" (
   a_contexte   IN   NUMBER,
   a_numero     IN   NUMBER,
   a_type       IN   NUMBER,
   a_numsource IN   NUMBER DEFAULT NULL
)
IS
BEGIN
   BEGIN
    IF a_type =3 THEN
    --suppression du paramétrage courriers existant sur le produit cible
      DELETE valide_texte WHERE numero=a_numero and contexte =a_contexte;
      INSERT INTO valide_texte(contexte,
                              numero,
                              idtexte,
                              code_langue,
                              courr_dest,
                              mod_pmt,
                              numrelance,
                              type_dest)
                              SELECT a_contexte,
                              a_numero,
                              idtexte,
                              code_langue,
                              courr_dest,
                              mod_pmt,
                              numrelance,
                              type_dest
                              From valide_texte
                              Where numero = a_numsource and contexte =a_contexte
                              And a_type=3
                              ;
    ELSE
      INSERT INTO valide_texte
                  (contexte, numero, idtexte, code_langue, courr_dest,
                   mod_pmt, numrelance, type_dest)
         SELECT a_contexte, a_numero, idtexte, code_langue, courr_dest,
                mod_pmt, numrelance, type_dest
           FROM valide_texte
          WHERE contexte = 7
            AND numero = (SELECT numprod
                            FROM contrat
                           WHERE numgar = a_numero)
            AND a_type = 1;

      INSERT INTO valide_texte
                  (contexte, numero, idtexte, code_langue, courr_dest,
                   mod_pmt, numrelance, type_dest)
         SELECT a_contexte, a_numero, idtexte, code_langue, courr_dest,
                mod_pmt, numrelance, type_dest
           FROM valide_texte
          WHERE contexte = 10
            AND numero = (SELECT numfor_ref
                            FROM gar_cntrt
                           WHERE numfor = a_numero)
            AND a_type = 2;
    END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;
END;
/
