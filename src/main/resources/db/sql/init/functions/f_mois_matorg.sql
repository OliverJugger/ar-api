CREATE function ARTHUS.f_mois_matorg(a_numindiv IN NUMBER)
RETURN NUMBER
AS
loc_f_mois_matorg number default 0;
BEGIN

begin
SELECT  substr(matorg,4,2)
INTO    loc_f_mois_matorg
FROM    indvs
WHERE   indvs.numindiv = a_numindiv
and     indvs.type = 1
and     indvs.typassu in (1,2);

Exception WHEN OTHERS then loc_f_mois_matorg := 0;

end;
return loc_f_mois_matorg;
END f_mois_matorg;
