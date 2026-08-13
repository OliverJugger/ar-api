CREATE FORCE VIEW ARTHUS.V_ROLE AS
SELECT	role,
	numindiv,
	libelle.libelle qualite,
	nom cle,
	nom,
	prenom,
	indvs.typassu typassu,
	decode(role, 0, 'pe10', 3, 'pe19', 5, 'gr05', 6, 'gt06', 7, 'gt01', 8, 'pr21', 9, 'so10', 14, 'fa10', 15, 'pe22', 'ga01') codapli
FROM    v_new_role, indvs, libelle
WHERE   libelle.mnemo(+) = 'CODC1'
AND	libelle.code(+) = indvs.codcourrier1
AND	indvs.numindiv = v_new_role.numde
/*
union
SELECT	0,
	numindiv,
	a.libelle qualite,
	nom cle,
	nom,
	prenom,
	indvs.typassu typassu,
	'pe10'
FROM    indvs, libelle a
WHERE   a.mnemo (+) = 'CODC1'
AND	a.code (+) = indvs.codcourrier1
*/
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ROLE FOR ARTHUS.V_ROLE
