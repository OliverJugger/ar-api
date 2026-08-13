CREATE OR REPLACE Package ARTHUS.pk_def
IS
Function f_cle (
			a_nom in varchar2
			)
Return number;
--Pragma Restrict_References(f_cle, WNDS);

Function f_niveau(a_nom in varchar2,a_contexte in number,a_mnemo in varchar2 default 'TYPE_CRRR')
Return number;
--Pragma Restrict_References(f_niveau, WNDS);

Function f_donnee(a_enreg in varchar2,a_complete in number)
Return varchar2;
--Pragma Restrict_References(f_donnee, WNDS);

Function f_verif(a_enreg in varchar2,a_niveau in number,a_code in number)
Return Number;
--Pragma Restrict_References(f_verif, WNDS);

comm_cle number;

END pk_def;
/

CREATE OR REPLACE Package Body ARTHUS.pk_def
IS
Function f_cle (
			a_nom in varchar2
			)
Return number
IS
loc_cle number;
Begin
	Select sens
	Into loc_cle
	From libelle_bis
	Where mnemo='DON_BASE'
	And code=a_nom;

Return(loc_cle);

End f_cle;

Function f_niveau(a_nom in varchar2,a_contexte in number,a_mnemo in varchar2 default 'TYPE_CRRR')
Return number
IS
loc_niveau number;
Begin
comm_cle:=pk_def.f_cle(a_nom);
        Select nvl(to_number(libelle.tableau),0)
        Into loc_niveau
        From libelle
        Where libelle.mnemo='CLE_BASE'
	And libelle.code=comm_cle
	;

	Return(loc_niveau);

	Exception
		When  no_data_found then loc_niveau:=0;
		Return(loc_niveau);

End f_niveau;

Function f_donnee(a_enreg in varchar2,a_complete in number)
Return varchar2
IS
loc_donnee varchar2(78);
loc_nombre number :=0;
Begin

	loc_donnee:=a_enreg;

	While (loc_nombre<a_complete)

	Loop
		Select loc_donnee||'x'
		Into loc_donnee
		From dual;

	loc_nombre:=loc_nombre+1;

	End loop;
Return(loc_donnee);
End f_donnee;
Function f_verif(a_enreg in varchar2,a_niveau in number,a_code in number)
Return Number
IS
loc_nombre number :=0;
loc_niveau Number :=0;
Begin
	 loc_niveau:=pk_def.f_niveau(a_enreg,a_code,'TYPE_CRRR');

	If (a_niveau!=loc_niveau)
	Then
		loc_nombre:=-1;
	Else
		loc_nombre:=1;
	End if;
Return(loc_nombre);
End f_verif;
End pk_def;
/
