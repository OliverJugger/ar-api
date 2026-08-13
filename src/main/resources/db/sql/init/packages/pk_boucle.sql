CREATE OR REPLACE Package ARTHUS.pk_boucle
IS
Procedure charge_boucle	(a_cle in pk_texte.clefs,
				 a_contexte in number,
				 a_contexte_init in number,
				t_donnee out pk_texte.donnee,
				a_retour out varchar2
			);
-- David 24/05/2004
--Pragma Restrict_References(charge_boucle, WNDS);
END pk_boucle;
/

CREATE OR REPLACE Package Body ARTHUS.pk_boucle
AS
a_fin date;
cursor curs_adhesion(a_cle pk_texte.clefs) is
	select 	adhesion.numfor
	from 	adhesion
	where 	adhesion.idadhesion=a_cle(0)
	and	adhesion.numindiv=nvl(a_cle(1),adhesion.numindiv)
	order by adhesion.numindiv,
		 adhesion.numfor;
cursor curs_affilie(a_cle pk_texte.clefs) is
	select 	adhe_cntrt_membre.numindiv
	From	adhe_cntrt_membre
	Where	adhe_cntrt_membre.idadhesion=a_cle(0)
	Order by adhe_cntrt_membre.numindiv;
cursor curs_bene(a_cle pk_texte.clefs) is
	select 	beneficiaire.numindiv,
		beneficiaire.numfor,
		beneficiaire.numbene,
		substr(pk_libelle.f_lib('FILIAT',beneficiaire.type_bene),1,15),
		beneficiaire.valide
	From 	beneficiaire
	Where	beneficiaire.idadhesion=a_cle(0)
	And	beneficiaire.numindiv=nvl(a_cle(1),beneficiaire.numindiv)
	And	beneficiaire.numfor=nvl(a_cle(2),beneficiaire.numfor);
cursor curs_cotis_bene(a_cle pk_texte.clefs) is
	select 	distinct qttc_gar.numindiv
	From	qttc_gar
	Where	qttc_gar.numquit=a_cle(0)
	And	qttc_gar.numindiv=nvl(a_cle(1),qttc_gar.numindiv);
cursor curs_cotis_gar(a_cle pk_texte.clefs) is
	select 	distinct qttc_gar.numfor
	From	qttc_gar
	Where	qttc_gar.numquit=a_cle(0)
	And	qttc_gar.numfor=nvl(a_cle(1),qttc_gar.numfor);
cursor curs_cotis_bene_gar(a_cle pk_texte.clefs) is
	select 	distinct qttc_gar.numfor,
		qttc_gar.numindiv
	From	qttc_gar
	Where	qttc_gar.numquit=a_cle(0)
	And	qttc_gar.numindiv=nvl(a_cle(1),qttc_gar.numindiv)
	And	qttc_gar.numfor=nvl(a_cle(2),qttc_gar.numfor);
cursor curs_frais(a_cle pk_texte.clefs) is
	Select	qttc_frais.type_frais
	From	qttc_frais
	Where	qttc_frais.numquit=a_cle(0)
	And	qttc_frais.type_frais=nvl(a_cle(1),qttc_frais.type_frais);
cursor curs_echeancier(a_cle pk_texte.clefs) is
	Select 	v_echeancier.numquit
	From	v_echeancier,
		qttc_global
	Where	v_echeancier.numindiv=qttc_global.numindiv
	And	v_echeancier.numquerable=qttc_global.numquerable
	And	v_echeancier.numgar=qttc_global.numgar
	And	qttc_global.numquit=a_cle(0)
	And	v_echeancier.debut between qttc_global.debut and a_fin;
Procedure charge_boucle   (a_cle in pk_texte.clefs,
				a_contexte in number,
				a_contexte_init in number,
				t_donnee out pk_texte.donnee,
				a_retour out varchar2)
is
Begin
	If (a_contexte=25)
	Then
	If not curs_adhesion%isopen then
		open curs_adhesion(a_cle);
	End if;
	fetch curs_adhesion into
		t_donnee(2);
	If curs_adhesion%notfound then
	Close curs_adhesion;
	 a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte=24) then
	If not curs_affilie%isopen then
		open curs_affilie(a_cle);
	End if;
	fetch curs_affilie into
		t_donnee(1);
	If curs_affilie%notfound then
	Close curs_affilie;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte=30) then
	If not curs_bene%isopen then
		open curs_bene(a_cle);
	End if;
	fetch curs_bene into
		t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5);
	If curs_bene%notfound then
	Close curs_bene;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte_init=33) then
	If not curs_cotis_bene%isopen then
		open curs_cotis_bene(a_cle);
	End if;
	fetch curs_cotis_bene into
		t_donnee(1);
	If curs_cotis_bene%notfound then
	Close curs_cotis_bene;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte_init=34) then
	If not curs_cotis_gar%isopen then
		open curs_cotis_gar(a_cle);
	End if;
	fetch curs_cotis_gar into
		t_donnee(1);
	If curs_cotis_gar%notfound then
	Close curs_cotis_gar;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte_init=35) then
	If not curs_cotis_bene_gar%isopen then
		open curs_cotis_bene_gar(a_cle);
	End if;
	fetch curs_cotis_bene_gar into
		t_donnee(1),
		t_donnee(2);
	If curs_cotis_bene_gar%notfound then
	Close curs_cotis_bene_gar;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte_init=36) then
	If not curs_frais%isopen then
		open curs_frais(a_cle);
	End if;
	fetch curs_frais into
		t_donnee(1);
	If curs_frais%notfound then
	Close curs_frais;
	a_retour:='fin_boucle';
	End if;
	Elsif (a_contexte_init=37) then
	If not curs_echeancier%isopen then
	Select max(qttc_global.fin)
	Into a_fin
	From qttc_global
	Where (qttc_global.numgar,qttc_global.numindiv) in
		(select a.numgar,a.numindiv
		 from qttc_global a
		 where a.numquit=a_cle(0)
		);
		open curs_echeancier(a_cle);
	End if;
	fetch curs_echeancier into
		t_donnee(1);
	If curs_echeancier%notfound then
	Close curs_echeancier;
	a_retour:='fin_boucle';
	End if;
	End if;
end charge_boucle;
end pk_boucle;
/
