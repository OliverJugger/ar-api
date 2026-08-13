CREATE FUNCTION ARTHUS."F_CPTA_DATE_DECAISMT" (i_numdecaismt IN NUMBER)
   RETURN DATE
AS
   loc_date       DATE;
   loc_bdx        NUMBER;
   loc_decaismt   decaismt%ROWTYPE;
BEGIN
   BEGIN
      SELECT *
        INTO loc_decaismt
        FROM decaismt
       WHERE numdecaismt = i_numdecaismt;
   END;

   BEGIN
      SELECT f_cpta_de (i_numdecaismt)
        INTO loc_bdx
        FROM DUAL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_bdx := 1;
   END;

   IF loc_bdx = 1
   THEN
      loc_date := loc_decaismt.datpay;
   ELSE
      BEGIN
         SELECT datdisk
           INTO loc_date
           FROM remise_op_detail, remise_op
          WHERE remise_op_detail.numdecaismt = i_numdecaismt
            AND remise_op_detail.numremise = remise_op.numremise
         UNION
         SELECT datdisk
           FROM remise_vire_detail, remise_vire
          WHERE remise_vire_detail.numdecaismt = i_numdecaismt
            AND remise_vire_detail.numremise = remise_vire.numremise;
      END;
   END IF;

   IF loc_date IS NULL
   THEN
      loc_date := (SYSDATE + 365);
   END IF;

   RETURN loc_date;
END f_cpta_date_decaismt;
