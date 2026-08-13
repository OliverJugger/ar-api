CREATE procedure ARTHUS.charge_frais ( I_cle IN pk_texte.clefs,
						O_donnee OUT pk_texte.donnee)
is
L_fin date;
CURSOR C_frais is
select qttc_frais.montant,
       libelle.libelle
From    libelle,
	qttc_global,
	qttc_frais
Where   libelle.mnemo='TYPFRAIS'
And     libelle.code=qttc_frais.type_frais
And     qttc_frais.numquit=I_cle(0)
And     qttc_frais.type_frais=I_cle(1)
And     qttc_frais.numfor=0
And     qttc_frais.numquit=qttc_global.numquit
And     qttc_global.prelev=1
Union
	Select  qttc_frais.montant,
		libelle.libelle
	From    libelle,
		qttc_global,
		qttc_global a,
		qttc_frais
	Where   libelle.mnemo='TYPFRAIS'
	And     libelle.code=qttc_frais.type_frais
	And     qttc_frais.type_frais=I_cle(1)
	And     qttc_frais.numfor=0
	And     qttc_frais.numquit=qttc_global.numquit
	And     qttc_global.prelev=2
	And     qttc_global.numgar=a.numgar
	And     qttc_global.numindiv=a.numindiv
	And     a.numquit=I_cle(0)
        And     qttc_global.debut between a.debut and L_fin
        Group By
                libelle.libelle;
rec_C_frais  C_frais%rowtype;
BEGIN
	Select max(qttc_global.fin)
	Into L_fin
	From qttc_global
	Where (qttc_global.numgar,qttc_global.numindiv) in
		(select a.numgar,a.numindiv
		 from qttc_global a
		 where a.numquit=I_cle(0)
		)
	And qttc_global.prelev=2;
        Open C_frais;
	Fetch C_frais Into rec_C_frais;
	Close C_frais;
	O_donnee(1):=rec_C_frais.montant;
	O_donnee(2):=Substr(rec_C_frais.libelle,1,15);
END charge_frais;
/
