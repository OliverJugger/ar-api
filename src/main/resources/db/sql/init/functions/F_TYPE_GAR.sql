CREATE function ARTHUS.F_TYPE_GAR
								(
								I_NUMFOR GAR_CNTRT_REf.NUMFOR%TYPE
								)
RETURN NUMBER
	AS
		loc_gar_cntrt_ref_type GAR_CNTRT_REf.TYPE%TYPE DEFAULT 0;
BEGIN

  SELECT TYPE INTO loc_gar_cntrt_ref_type from GAR_CNTRT where
  NUMFOR = I_NUMFOR;

   RETURN loc_gar_cntrt_ref_type;
EXCEPTION
    WHEN no_data_found THEN
     RETURN 0;
    WHEN OTHERS THEN
     RETURN 0;
END F_TYPE_GAR;
