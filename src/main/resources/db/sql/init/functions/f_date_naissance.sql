CREATE function ARTHUS.f_date_naissance (a_numindiv IN NUMBER)
RETURN DATE
AS
loc_datnais date;
BEGIN
begin
SELECT  datnais
INTO    loc_datnais
FROM    indvs
WHERE   indvs.numindiv = a_numindiv;

Exception WHEN OTHERS then loc_datnais := null;

end;
return loc_datnais;
END f_date_naissance;
