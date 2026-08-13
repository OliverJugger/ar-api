CREATE OR REPLACE package ARTHUS.pk_corrige_texte
AS
Procedure Dedouble;
Type T_tab is table of number index by Binary_integer;
T_coti02 	T_tab;
T_coti03	T_tab;
END;
/

CREATE OR REPLACE package body ARTHUS.pk_corrige_texte
AS
Procedure P_init_tab
IS
C_param_texte	param_texte%RowType;
BEGIN
For C_param_texte IN (
	Select	idtexte,
		numrelance
	From	param_texte
	Where	nom_crrr = 'COTI02'
	and	contexte = 99
	order by
	numrelance)
Loop
	T_coti02( C_param_texte.numrelance ) := C_param_texte.idtexte;
End Loop;
For C_param_texte IN (
	Select	idtexte,
		numrelance
	From	param_texte
	Where	nom_crrr = 'COTI03'
	and	contexte = 99
	order by
	numrelance)
Loop
	T_coti03( C_param_texte.numrelance ) := C_param_texte.idtexte;
End Loop;
END P_init_tab;
Procedure Dedouble
IS
Cursor	C_deleg IS
Select	numgar
From	contrat
Where	numprod in ( 22, 23 )
and	gest_cotis = 2;
Cursor	C_direct IS
Select	numgar
From	contrat
Where	numprod in ( 22, 23 )
and	gest_cotis != 2;
Rec_C_deleg	C_deleg%RowType;
Rec_C_direct	C_direct%RowType;
i		Binary_integer;
Nb_coti02	Binary_integer;
Nb_coti03	Binary_integer;
BEGIN
P_init_tab;
Open C_deleg;
Loop
	Fetch C_deleg Into Rec_C_deleg;
	Exit When C_deleg%NotFound;
	Nb_coti02 := 0;
	For i IN 0 .. 3 Loop
		Begin
		Delete 	valide_texte
		Where	contexte = 2
		and	numero = Rec_C_deleg.numgar
		and	idtexte = T_coti02( i );
		Nb_coti02 := Nb_coti02 + Sql%Rowcount;
		End;
	End Loop;
	If ( Nb_coti02 != 0 ) then
		Dbms_output.put_line( 'Contrat delegue N° '|| Rec_C_deleg.numgar
			|| 'suppression de COTI02' );
	End if;
	Nb_coti03 := 0;
	For i IN 0 .. 3 Loop
		Begin
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte)
		Select	2,
			Rec_C_deleg.numgar,
			T_coti03( i )
		From	Dual
		Where Not exists (
			Select	1
			From	valide_texte
			Where	contexte = 2
			and	numero = Rec_C_deleg.numgar
			and	idtexte = T_coti03( i ) );
		Nb_coti03 := Nb_coti03 + Sql%Rowcount;
		End;
	End Loop;
	If ( Nb_coti03 != 0 ) then
		Dbms_output.put_line( 'Contrat delegue N° '|| Rec_C_deleg.numgar
			|| Nb_coti03 || 'COTI03 insere(s)' );
	End if;
End Loop;
Close C_deleg;
Open C_direct;
Loop
	Fetch C_direct Into Rec_C_direct;
	Exit When C_direct%NotFound;
	Nb_coti03 := 0;
	For i IN 0 .. 3 Loop
		Begin
		Delete 	valide_texte
		Where	contexte = 2
		and	numero = Rec_C_direct.numgar
		and	idtexte = T_coti03( i );
		Nb_coti03 := Nb_coti03 + Sql%Rowcount;
		End;
	End Loop;
	If ( Nb_coti03 != 0 ) then
		Dbms_output.put_line( 'Contrat direct N° '|| Rec_C_direct.numgar
			|| 'suppression de COTI03' );
	End if;
	Nb_coti02 := 0;
	For i IN 0 .. 3 Loop
		Begin
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte)
		Select	2,
			Rec_C_direct.numgar,
			T_coti02( i )
		From	Dual
		Where Not exists (
			Select	1
			From	valide_texte
			Where	contexte = 2
			and	numero = Rec_C_direct.numgar
			and	idtexte = T_coti02( i ) );
		Nb_coti02 := Nb_coti02 + Sql%Rowcount;
		End;
	End Loop;
	If ( Nb_coti02 != 0 ) then
		Dbms_output.put_line( 'Contrat direct N° '|| Rec_C_direct.numgar
			|| Nb_coti02 || 'COTI02 insere(s)' );
	End if;
End Loop;
Close C_direct;
END Dedouble;
END;
/
