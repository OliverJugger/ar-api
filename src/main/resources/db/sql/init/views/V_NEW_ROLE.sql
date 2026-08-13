CREATE FORCE VIEW ARTHUS.V_NEW_ROLE AS
Select	numindiv	numde,
	0		role,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	individu
Union
Select	distinct	numadhe,
	15,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	adhe_cntrt
Union
Select	distinct	numindiv,
	Decode(typadr, 0, 4, 11),
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	adhe_cntrt_membre
Union
Select	distinct	numindiv,
	3,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	client
Union
Select	numindiv,
	5,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_organisme
Union
Select	numindiv,
	6,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_tiers
Union
Select	numindiv,
	7,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_tierspayant
Union
Select	numindiv,
	8,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_intermediaire
Union
Select	numindiv,
	9,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_societe
Union
Select	distinct	numindiv,
	14,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	proposition
Union
Select	distinct	numbene,
	16,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	beneficiaire
Union
Select	numindiv,
	12 + Decode(assu.typassu, 1, 1, 0),
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	assu
Union
Select	distinct interlocuteur,
	17,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	interlocuteur
Union
Select	distinct numindiv,
	18,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	emprunteur
Union
Select	numindiv,
	19,
	direction	numenvers,
	''		datapli,
	''		datper
From	pers_banque
Union
Select	numreass,
	20,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	pers_reass
-- David 11/02/2005
/*
Union
select 	numindiv,
	21,
	to_number('')	numenvers,
	''		datapli,
	''		datper
from pers_centrepayeur
union
select 	numindiv,
	22,
	to_number('') 	numenvers,
	''		datapli,
	''		datper
from pers_avocat
*/
union
Select	distinct	numcli,
	10,
	to_number('')	numenvers,
	''		datapli,
	''		datper
From	adhe_collective
GO
CREATE OR REPLACE PUBLIC SYNONYM V_NEW_ROLE FOR ARTHUS.V_NEW_ROLE
