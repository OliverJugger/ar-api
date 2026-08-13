CREATE function ARTHUS.f_intermediaire(a_etendue in number,
					a_cle in number,
					a_type in number,
					a_date in date default sysdate)
	RETURN NUMBER
	AS
		loc_intermediaire number default 0;

	Cursor fetch_apporteur is
	SELECT	nvl(numindiv,0)
	FROM	apporteur
	WHERE	apporteur.etendue=a_etendue
	AND	apporteur.cle=a_cle
	AND apporteur.TYPE_APPORT=a_type
	AND	apporteur.debut<=a_date;
BEGIN
	open fetch_apporteur;
	fetch fetch_apporteur into loc_intermediaire;
	if (fetch_apporteur%NOTFOUND) then
	loc_intermediaire:=0;
	end if;
	close fetch_apporteur;
   return loc_intermediaire;
END f_intermediaire;
