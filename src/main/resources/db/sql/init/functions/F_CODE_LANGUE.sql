CREATE FUNCTION ARTHUS."F_CODE_LANGUE"
   RETURN NUMBER
AS
   code_langue   NUMBER (3);
BEGIN
   BEGIN
      -- Recherche du code de la langue en fonction du PAYS uniquement (Cas ou la monnaie est mal paramétrée)
      SELECT ALL MIN (pays_langue.codlangue)
            INTO code_langue
            FROM param, pays_langue
           WHERE (param.dfpays = pays_langue.codpays);

      IF SQL%NOTFOUND OR code_langue IS NULL
      THEN
         RETURN (1);
      END IF;
   END;

   RETURN (code_langue);
END f_code_langue;
