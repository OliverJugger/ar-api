CREATE function ARTHUS.f_cpt_etat_remise
			(
			a_numporte	IN NUMBER,
			a_numremise	IN NUMBER,
			a_etat		IN NUMBER
			)
RETURN NUMBER
AS
loc_nombre	NUMBER;
BEGIN

   begin
	SELECT	count(*)
	INTO	loc_nombre
	FROM	sinistre_porte
	WHERE	sinistre_porte.numporte = a_numporte
	and	sinistre_porte.numremise = a_numremise
	and 	sinistre_porte.etat = a_etat;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_nombre := 0;
   end;

	RETURN loc_nombre;
END f_cpt_etat_remise;
