CREATE FORCE VIEW ARTHUS.V_ROLE_BIS AS
SELECT	0 role,
	numindiv,
	libelle reference,
	nom ||' '||prenom nom,
	'pe10' codapli
FROM    indvs, libelle
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
UNION
SELECT	distinct
	3 role,
	numindiv,
	libelle reference,
	nom ||' '||prenom nom,
	'gc01' codapli
FROM    indvs, libelle, grnts
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	grnts.numcli = indvs.numindiv
UNION
SELECT	4 role,
	numindiv,
	libelle reference,
	nom ||' '||prenom nom,
	'ga01' codapli
FROM    indvs, libelle
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	indvs.typassu = 1
UNION
SELECT	11 role,
	numindiv,
	libelle reference,
	nom ||' '||prenom nom,
	'ga01' codapli
FROM    indvs, libelle
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	indvs.typassu = 2
UNION
SELECT	12 role,
	numindiv,
	libelle reference,
	nom ||' '||prenom nom,
	'ga01' codapli
FROM    indvs, libelle
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	indvs.typassu in(1,2)
UNION
SELECT	6 role,
	indvs.numindiv,
	libelle.libelle reference,
	indvs.nom ||' '||indvs.prenom nom,
	'gt06' codapli
FROM    indvs, libelle, tiers
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	tiers.numindiv = indvs.numindiv
UNION
SELECT	7 role,
	indvs.numindiv,
	libelle.libelle reference,
	indvs.nom ||' '||indvs.prenom nom,
	'gt01' codapli
FROM    indvs, libelle, trpnt
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = indvs.qualite
AND	trpnt.numindiv = indvs.numindiv
UNION
SELECT	8 role,
	indvs.numindiv,
	interm.refinterm reference,
	libelle.libelle ||' '||interm.nom nom,
	'pr21' codapli
FROM    indvs, libelle, interm
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = interm.qualite
AND	interm.numindiv = indvs.numindiv
UNION
SELECT	9 role,
	indvs.numindiv,
	societe.refsoc reference,
	libelle.libelle ||' '||societe.nom nom,
	'so10' codapli
FROM    indvs, libelle, societe
WHERE   nvl(libelle.mnemo,'QLTE') = 'QLTE'
AND	libelle.code (+) = societe.qualite
AND	societe.numindiv = indvs.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ROLE_BIS FOR ARTHUS.V_ROLE_BIS
