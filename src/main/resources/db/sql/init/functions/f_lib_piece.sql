CREATE function ARTHUS.f_lib_piece(a_numfact in number,a_codope in number)
Return varchar2 is
loc_libelle varchar2(78);
BEGIN
Begin
select
	decode(facture.codope,
	4,
	'Contrat '||qttc_global.numgar||' Ech. '||to_char(qttc_global.debut,'dd/mm/yy') ,
	7,
	'Commissions à percevoir Bx '||reversement.idrevers||' '||
		indvs.nom||' - '||
		to_char(reversement.datrevers,'DD/MM/YY'),
	12,
	'Remb. prestations ' ||decode(dcptcie.type,1,'Mal. ',2,'Prev. ')||
		indvs.nom||' - '||
		to_char(dcptcie.datedeb,'DD/MM/YY')||
		' au '||to_char(dcptcie.datefin,'dd/mm/yy')
	) libelle
Into	loc_libelle
from	qttc_global,
	indvs,
	reversement,
	dcptcie,
	facture
where	qttc_global.numquit(+) = facture.numfact
and	reversement.idrevers(+) = facture.numfact
and	dcptcie.numdcptcie(+) = facture.numfact
and	indvs.numindiv = facture.numcli
and not exists 	(select 1
		 from 	facture_regul
		 where	facture_regul.codope = facture.codope
		 and	facture_regul.numfact_regul = facture.numfact)
and	facture.numfact=a_numfact
and	facture.codope=a_codope
union
select
	'Régul° par pièce N° '||facture_regul.numfact||
		' le '||to_char(facture_regul.datope,'dd/mm/yy') libelle
from	indvs,
	facture_regul,
	facture
where	facture_regul.codope = facture.codope
and	facture_regul.numfact_regul = facture.numfact
and	indvs.numindiv = facture.numcli
and	facture.numfact=a_numfact
and	facture.codope=a_codope
union
select
	decode(affectation.codope,
	1,
	'Trop perçu decpte maladie'||' No '||
		affectation.numaffec||' du '||
		to_char(affectation.dataffec,'dd/mm/yy'),
	2,
	'Trop perçu decpte prevoyance No '||
		affectation.numaffec||' du '||
		to_char(affectation.dataffec,'dd/mm/yy')
	) libelle
from	indvs,
	affectation
where	affectation.montant < 0
and	indvs.numindiv = affectation.numcli
and	affectation.numaffec=a_numfact
and	affectation.codope=a_codope;
Exception
	When no_data_found then loc_libelle:='';
	Return(loc_libelle);
End;
	Return(loc_libelle);
END;
