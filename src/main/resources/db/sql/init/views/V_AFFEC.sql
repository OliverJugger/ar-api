CREATE FORCE VIEW ARTHUS.V_AFFEC AS
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	'Dcpte santé'||' n° '||
		affectation.numaffec||
		' du '||
		to_char(dcpt.datpay,'dd/mm/yyyy')||
		' Contrat n° '||
		grnts.numgar					lib_affec,
	affectation.montant + nvl(f_totaffec(affectation.numaffec,1),0)	montant,
	affectation.montant_d + nvl(f_totaffec_d(affectation.numaffec,1),0)	montant_d,
	monnaie.symbole,
	'gd01' codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	dcpt,
	grnts,
	monnaie, monnaie monnaie_d
where	affectation.codope	= 1
and	dcpt.numdec		= affectation.numaffec
and 	grnts.numgar		= dcpt.numgar
and	monnaie.codmon		= affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	'Dcpte prévoyance'||' n° '||
		affectation.numaffec||
		' du '||
		to_char(decompte_prev.datpay,'dd/mm/yyyy')||
		' Contrat n° '||
		grnts.numgar					lib_affec,
	affectation.montant + nvl(f_totaffec(affectation.numaffec,2),0)	montant,
	affectation.montant_d + nvl(f_totaffec_d(affectation.numaffec,2),0)	montant_d,
	monnaie.symbole,
	'gdp1'							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	decompte_prev,
	contrat grnts,
	adhe_cntrt,
	monnaie, monnaie monnaie_d
where	affectation.codope	= 2
and	decompte_prev.numdec		= affectation.numaffec
and 	grnts.numgar		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= decompte_prev.idadhesion
and	monnaie.codmon		= affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	decaismt.codope,
	affectation_annul.numaffec,
	decaismt.numbene,
	decaismt.numdecaismt,
	'Annulé le '||
		to_char(pnul.datannul,'dd/mm/yyyy')||
		' '||
		libelle.libelle,
	decaismt.montant,
	decaismt.montant_d,
	monnaie.symbole,
	'' codapli,
	decaismt.monnaie,
	decaismt.monnaie_d,
	monnaie_d.symbole symbole_d
from	pnul,
	monnaie, monnaie monnaie_d,
	decaismt,
	libelle,
	affectation_annul
where	pnul.numdecaismt = decaismt.numdecaismt
and	affectation_annul.numdecaismt = decaismt.numdecaismt
and 	libelle.mnemo	= 'PNUL'
and 	libelle.code	= pnul.motif
and	monnaie.codmon	= decaismt.monnaie
and monnaie_d.codmon   = decaismt.monnaie_d
and pnul.codope is not null
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	'Bdx revers. URSSAF n° '||dcptdedu.numdec		lib_affec,
	affectation.montant,
	affectation.montant_d,
	monnaie.symbole,
	'gdd1'							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	dcptdedu,
	monnaie, monnaie monnaie_d
where	affectation.codope = 11
and	dcptdedu.numdec = affectation.numaffec
and	monnaie.codmon = affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	Decode( compte.type,
		1, 'Règl. fournisseur n° '||
                	affectation.numaffec||
                	' du '||
                	to_char(affectation.dataffec,'dd/mm/yyyy'),
		2, 'Opération sur '||compte.libcompte||' '||compte.cmpt_gene),
	affectation.montant,
	affectation.montant_d,
	monnaie.symbole,
	'de54'							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	decaismt,
	compte,
	monnaie, monnaie monnaie_d
where	affectation.codope = 10
and	compte.numcpte = decaismt.numcpte
and	decaismt.numdecaismt = affectation.numdecaismt
and	monnaie.codmon = affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	'Bdx revers. de taxes n° '||reversement.idrevers||' '||orgns.nom,
	affectation.montant,
	affectation.montant_d,
	monnaie.symbole,
	''							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	reversement,
	orgns,
	monnaie, monnaie monnaie_d
where	affectation.codope = 6
and	reversement.idrevers = affectation.numaffec
and	orgns.numorg = reversement.numorg
and	orgns.role = 2
and	monnaie.codmon = affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	Decode( compte.type,
		1, 'Remboursé à '||affectation.numcli||' '||indvs.nom||' '||indvs.prenom,
		2, 'Opération sur '||compte.libcompte||' '||compte.cmpt_gene),
	affectation.montant,
	affectation.montant_d,
	monnaie.symbole,
	'en16'							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	compte,
	decaismt,
	affectation,
	indvs,
	monnaie, monnaie monnaie_d
where	compte.numcpte = decaismt.numcpte
and	decaismt.numdecaismt = affectation.numdecaismt
and	affectation.codope = 8
and	indvs.numindiv = affectation.numcli
and	monnaie.codmon = affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
UNION
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	'Bdx revers. de cotis. n°'||reversement.idrevers||' '||orgns.nom,
	affectation.montant,
	affectation.montant_d,
	monnaie.symbole,
	'qg12'							codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	monnaie_d.symbole symbole_d
from	affectation,
	reversement,
	orgns,
	monnaie, monnaie monnaie_d
where	affectation.codope = 5
and	reversement.idrevers = affectation.numaffec
and	orgns.numorg = reversement.numorg
and	orgns.role = 2
and	monnaie.codmon = affectation.monnaie
and monnaie_d.codmon   = affectation.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFEC FOR ARTHUS.V_AFFEC
