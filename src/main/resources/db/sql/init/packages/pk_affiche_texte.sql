CREATE OR REPLACE package ARTHUS.pk_affiche_texte is
Function f_affiche_texte (a_texte in varchar2,
				a_contexte in number,
				a_contexte_base in number,
				a_cle in number,
				a_niveau in number,
				a_nombre in number default 1,
				a_test in number default 1,
				a_cle1 in number default 0,
				a_debut in date default sysdate,
				a_fin in date default sysdate,
				a_cle2 in number default 0,
				a_idtexte in number default 0,
				a_numenvoi in number default 0,
				a_numligne in number default 0)
return varchar2;
-- David 24/05/2004
--Pragma Restrict_References(f_affiche_texte, WNDS);
Function charge_sous_niveau
return varchar2;
-- David 24/05/2004
--Pragma Restrict_References(charge_sous_niveau, WNDS);
Function f_compte_ligne
Return number;
-- David 24/05/2004
--Pragma Restrict_References(f_compte_ligne, WNDS);
Function f_compte_niveau_diff
Return number;
-- David 24/05/2004
--Pragma Restrict_References(f_compte_niveau_diff, WNDS);
comm_contexte number;
comm_contexte_base number;
comm_numligne number;
comm_niveau number;
comm_idtexte number;
comm_cle number;
comm_test number;
comm_cle1 number;
comm_debut date default sysdate;
comm_fin date default sysdate;
comm_cle2 number;
comm_numenvoi number;
End pk_affiche_texte;
/

CREATE OR REPLACE package body ARTHUS.pk_affiche_texte
Is
function f_affiche_texte(a_texte in varchar2,
				a_contexte in number,
				a_contexte_base in number,
				a_cle in number,
				a_niveau in number,
				a_nombre in number default 1,
				a_test in number default 1,
				a_cle1 in number default 0,
				a_debut in date default sysdate,
				a_fin in date default sysdate,
				a_cle2 in number default 0,
				a_idtexte in number default 0,
				a_numenvoi in number default 0,
				a_numligne in number default 0)
return varchar2
is loc_texte varchar2(80);
Begin
	comm_contexte_base:=a_contexte_base;
	comm_contexte:=a_contexte;
	comm_niveau:=a_niveau;
	comm_idtexte:=a_idtexte;
	comm_numligne := a_numligne;
	comm_cle:=a_cle;
	comm_test:=a_test;
	comm_cle1:=a_cle1;
	comm_debut:=a_debut;
	comm_fin:=a_fin;
	comm_cle2:=a_cle2;
	comm_numenvoi:=a_numenvoi;
	If (a_niveau>0)
	Then
		loc_texte:=
		charge_sous_niveau;
	Else
		Begin
	loc_texte:=pk_texte.f_decode_texte(a_texte,a_contexte,a_contexte_base,
			a_cle,a_niveau,a_nombre,a_test,a_cle1,a_debut,
			a_fin,a_cle2,a_idtexte,a_numenvoi);
	return(loc_texte);
	Exception
	When no_data_found then loc_texte:='';
	Return(loc_texte);
		End;
	End if;
end;
Function f_compte_ligne
Return number
Is
	loc_ligne number;
Begin
	Select	count(*)
	Into 	loc_ligne
	From 	texte
	Where 	type=2
	And	idtexte=comm_idtexte
	And 	numligne>=comm_numligne
	And	niveau=comm_niveau
	And	f_contexte_interm(cle,comm_contexte_base)=comm_contexte;
	Return(loc_ligne);
End;
Function f_compte_niveau_diff
Return number
Is
	loc_niveau_diff number;
Begin
	Select	count(distinct niveau)
	Into 	loc_niveau_diff
	From 	texte
	Where 	type=2
	And	idtexte=comm_idtexte
	And 	numligne>=comm_numligne
	And	niveau>comm_niveau
	And	f_contexte_interm(cle,comm_contexte_base)=comm_contexte;
	Return(loc_niveau_diff);
End;
Function Charge_sous_niveau
Return varchar2
Is a_texte varchar2(80);
	nombre number;
	nombre_old number;
	nombre_ligne number;
	nombre_ligne_old number;
	a_niveau number;
	niveau_old number;
	niveau_diff number;
	contexte_old number;
	loc_fin number;
	Cursor fetch_texte is
		Select	nvl(substr(translate(texte,'.','@'),1,78),'\ ') texte,
			cle contexte,
			niveau
		From 	texte
		Where 	type=2
		And	idtexte=comm_idtexte
		And 	numligne>=comm_numligne
		And	niveau=a_niveau
		And	f_contexte_interm(cle,comm_contexte_base)=comm_contexte
		Order by numligne ;
loc_texte fetch_texte%Rowtype;
Begin
<<Debut>>
	a_niveau:=comm_niveau;
	nombre_ligne:=f_compte_ligne;
<<Retour>>
	nombre:=1;
	niveau_diff:=f_compte_niveau_diff;
	For loc_texte in fetch_texte
	Loop
		If loc_fin!=1
		Then
			if (loc_texte.texte is null)
			then
				a_texte:='';
				Return(a_texte);
				Goto fin;
			Else
				a_texte:=
			pk_texte.f_decode_texte
			(loc_texte.texte,
			loc_texte.contexte,
			comm_contexte_base,
			comm_cle,
			loc_texte.niveau,
			nombre,
			comm_test,
			comm_cle1,
			comm_debut,
			comm_fin,
			comm_cle2,
			comm_idtexte,
			comm_numenvoi);
			If (a_texte='fin_boucle')
			Then
				Goto Sortie;
			Else
				Return(a_texte);
				Goto fin;
			End if;
			End if;
		Else
			Goto fin;
		End if;
<<Sous_niveau>>
	niveau_old:=a_niveau;
	nombre_ligne_old:=nombre_ligne;
	nombre_old:=nombre;
	contexte_old:=comm_contexte;
	nombre:=1;
	a_niveau:=a_niveau+1;
	Goto debut;
	a_niveau:=niveau_old;
	nombre_ligne:=nombre_ligne_old;
	nombre:=nombre_old;
	goto fin;
<<Fin>>
	nombre:=nombre+1;
	If (nombre=nombre_ligne)
	Then
		Goto fin_niveau;
	Else
		If (niveau_diff>0)
		Then
			Goto sous_niveau;
		Else
			Goto fin_niveau;
		End if;
	End if;
<<Sortie>>
	loc_fin:=1;
	a_texte:='';
<<Fin_niveau>>
	Return(a_texte);
End loop;
	If (loc_fin=1)
	Then
		Goto Termine;
	Else
		Goto Retour;
	End if;
<<Termine>>
	loc_fin:=0;
End;
End pk_affiche_texte;
/
