CREATE function ARTHUS.f_apporteur(a_etendue in number,
					a_cle in number,
					a_date in date default sysdate)
	RETURN NUMBER
	AS
		loc_apporteur number default 0;
	Cursor fetch_apporteur is
	SELECT	nvl(numindiv,0)
	FROM	apporteur
	WHERE	apporteur.etendue=a_etendue
	AND	apporteur.cle=a_cle
	AND	apporteur.debut<=a_date;
BEGIN
	open fetch_apporteur;
	fetch fetch_apporteur into loc_apporteur;
	if (fetch_apporteur%NOTFOUND) then
	loc_apporteur:=0;
	end if;
	close fetch_apporteur;
   return loc_apporteur;
END f_apporteur;
