CREATE FUNCTION ARTHUS."F_BENE_MODPMT" (
   a_numindiv   IN   NUMBER,
   a_codope     IN   NUMBER,
   a_numgar     IN   NUMBER,
   a_dec_enc    IN   NUMBER,
   a_devise in number default null,  /*jbn 24/03/11*/
   a_date in date default sysdate)  /*jbn 24/03/11*/
   RETURN NUMBER
AS
   loc_modpmt   NUMBER;
BEGIN
   BEGIN
      SELECT modpmt
        INTO loc_modpmt
        FROM rib
       WHERE rib.idrib =
                        f_bene_rib (a_numindiv, a_codope, a_numgar, a_dec_enc);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_modpmt := 1;
   END;

   RETURN (loc_modpmt);
END;
