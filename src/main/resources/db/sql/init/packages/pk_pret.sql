CREATE OR REPLACE Package ARTHUS.pk_pret
As
Function f_idarchive (
				a_numindiv in number
				)
Return varchar2;
--David 26/05/2004
--Pragma Restrict_References(f_idarchive, WNDS, WNPS);
Function f_situ_pret (
				a_idpret 	in number,
				a_date 		in date default sysdate,
				a_type		in Number Default 1
				)
Return number;
--David 26/05/2004
--Pragma Restrict_References(f_situ_pret, WNDS, WNPS);
Function f_pourc_assure (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number;
--David 26/05/2004
--Pragma Restrict_References(f_pourc_assure, WNDS, WNPS);
Function f_mt_assure (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number;
--David 26/05/2004
--Pragma Restrict_References(f_mt_assure, WNDS, WNPS);
Function f_mt_restant (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number;
--David 26/05/2004
--Pragma Restrict_References(f_mt_restant, WNDS, WNPS);
Function f_fin_pret (
				a_idpret 	in number
				)
Return Date;
--David 26/05/2004
--Pragma Restrict_References(f_fin_pret, WNDS, WNPS);
Type T_periode is table of date index by binary_integer;
Type T_nombre is table of number index by binary_integer;
END pk_pret;
/

CREATE OR REPLACE Package Body ARTHUS.pk_pret
As
Function f_idarchive (
				a_numindiv in number
				)
Return varchar2
is
loc_retour	Varchar2(10);
loc_sequence	number;
annee_mois	Varchar2(4);
emp		adhe_pret%rowtype;
BEGIN
For emp in (
	Select	idarchive
	From	adhe_pret
	Where	numindiv = a_numindiv)
Loop
	loc_retour := emp.idarchive;
	Exit;
End loop;
If ( loc_retour is Null ) then
Begin
annee_mois := to_char(sysdate, 'yymm');
Select	nvl(max(to_number(substr(idarchive, 5, 3))), 0) + 1
Into	loc_sequence
From	adhe_pret
Where	idarchive like annee_mois||'%';
End;
loc_retour := annee_mois||substr(to_char(loc_sequence, '000'), 2, 3);
End if;
Return ( loc_retour );
END	f_idarchive;
Function f_situ_pret (
				a_idpret in number,
				a_date in date default sysdate,
				a_type	in Number Default 1
				)
Return number
Is
L_date		Date := a_date;
loc_retour	number := -99;
Cursor fetch_objet is
	Select	situ_pret.debut,
		situ_pret.etat,
		situ_pret.motif
	From	situ_pret
	Where	situ_pret.idpret = a_idpret
	and	debut <= L_date
	Order by
		debut desc,
		creation asc;
loc_objet	fetch_objet%Rowtype;
BEGIN
For loc_objet in fetch_objet
loop
	If ( a_type = 1 ) then
		loc_retour := loc_objet.etat;
	Elsif ( a_type = 2 ) then
		loc_retour := loc_objet.motif;
	Elsif ( a_type = 3 ) then
		loc_retour := d2j(loc_objet.debut);
	End if;
Exit;
End loop;
If ( loc_retour = -99 ) then
	If ( a_type = 3 ) then
		loc_retour := d2j(L_date);
	End If;
End If;
Return ( loc_retour );
END	f_situ_pret;
Function f_pourc_assure (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number
Is
emp	adhe_pret%Rowtype;
pourcent	adhe_pret.pourc_assure%type;
BEGIN
For emp in (
	select	pourc_assure
	from	adhe_pret
	where	idpret = a_idpret
	and	numindiv = a_numindiv)
Loop
	pourcent := emp.pourc_assure;
	Exit;
End Loop;
Return( nvl(pourcent, 0) / 100 );
END	f_pourc_assure;
Function f_mt_assure (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number
Is
capital	pret.montant%type;
BEGIN
Select	montant
Into	capital
From	pret
Where	pret.idpret = a_idpret;
Return( round(capital * f_pourc_assure(a_idpret, a_numindiv),2) );
END	f_mt_assure;
Function f_mt_restant (
				a_idpret 	in number,
				a_numindiv 	in Number
				)
Return number
Is
capital		Number;
debut		T_periode;
mt_remb		T_nombre;
periode		T_nombre;
remb		histo_pret%Rowtype;
pourcent	adhe_pret.pourc_assure%type;
i		binary_integer := 0;
nb_periode	binary_integer := 0;
nb_remb		binary_integer := 0;
tot_remb	Number := 0;
BEGIN
capital := f_mt_assure( a_idpret, a_numindiv );
pourcent := f_pourc_assure( a_idpret, a_numindiv );
For remb in (
	select	debut,
		montant,
		periodicite
	from	histo_pret
	where	idpret = a_idpret)
Loop
	i := i + 1;
	debut(i) := remb.debut;
	mt_remb(i) := remb.montant;
	periode(i) := remb.periodicite;
End Loop;
nb_periode := i;
If ( nb_periode = 0 ) then
	Return( capital );
End if;
for i in 1 .. nb_periode - 1
Loop
	nb_remb := trunc( months_between(debut(i+1), debut(i)) / periode(i) );
	tot_remb := tot_remb + ( mt_remb(i) * nb_remb );
End Loop;
nb_remb := trunc( months_between(Sysdate, debut(nb_periode) ) / periode(nb_periode) );
tot_remb := tot_remb + ( mt_remb(nb_periode) * nb_remb );
Return( round(capital - tot_remb * pourcent,2) );
END	f_mt_restant;
Function f_fin_pret (
				a_idpret 	in number
				)
Return Date
Is
loc_fin		Date;
BEGIN
Select	Add_months( nvl(date_deblocage, date_signature ),
		duree_pret + duree_differe )
Into	loc_fin
From	pret
Where	pret.idpret = a_idpret;
Return( loc_fin );
END	f_fin_pret;
END pk_pret;
/
