CREATE FUNCTION ARTHUS.f_is_iban_int(
      iv_clef_iban IN VARCHAR2 ,
      iv_bban      IN VARCHAR2 --,
      --ov_erreur OUT VARCHAR2
	  )
   RETURN NUMBER
IS
   b_is_iban   NUMBER :=0;
   n_nbcarbban NUMBER;
   IBAN        VARCHAR2(36);
BEGIN
   IBAN := iv_clef_iban||iv_bban;
   -- VERIFICATION SUR LA LONGUEUR DE L'IBAN ET DU BBAN   -- TLE 30/04/2014
   IF ((LENGTH (iv_bban) <> 23) AND (iv_clef_iban LIKE 'FR%' OR iv_clef_iban LIKE 'MC%'))
      OR (LENGTH (iv_clef_iban) <> 4) THEN
      b_is_iban         := 0;
--ov_erreur :='Le code IBAN <'||iv_clef_iban||iv_bban||'> est incorrect !';
RETURN b_is_iban;

   END IF;

   --ALGO VERIF IBAN:
   IBAN  := SUBSTR(IBAN,5)||SUBSTR(IBAN,1,4);
   FOR I IN 10..35
   LOOP
      IBAN := REPLACE(IBAN, CHR(I+55), I);
   END LOOP;
   IF (MOD(TO_NUMBER(IBAN), 97)) <> 1 THEN
      -- IBAN KO
      --ov_erreur :='Le code IBAN <'||iv_clef_iban||iv_bban||'> est incorrect !';
      b_is_iban :=0;
   ELSE
      -- IBAN OK
      b_is_iban :=1;
   END IF;
   RETURN b_is_iban;
END f_is_iban_int;
