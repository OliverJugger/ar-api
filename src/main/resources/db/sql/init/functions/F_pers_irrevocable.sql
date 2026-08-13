CREATE FUNCTION ARTHUS.F_pers_irrevocable 	(
				I_Numindiv IN Number,
				I_Numgar   IN Number	Default 0
				)
  RETURN Number
  IS
--
	Loc_numgar	Number;
	L_exist		Varchar2 (1);
	O_retour	Number;
--
Cursor C_dest_prev
IS
SELECT 	'x'
FROM	Repartition_bene	A
WHERE	A.Numbene_dest = I_Numindiv
And	A.Valide = 'O'
And	A.fin is null
And	A.Irrevocable = 'O'
	;
--
Cursor C_dest_prev_gar
IS
SELECT 	'x'
FROM	Repartition_bene	A,
	Repartition		B,
	Adhe_cntrt		C
WHERE	A.Numbene_dest = I_Numindiv
And	A.Valide = 'O'
And	A.fin is null
And	A.Irrevocable = 'O'
And	A.idrepartition = B.idrepartition
And	C.idadhesion	= B.idadhesion
And	C.Numgar = Loc_numgar
	;
--
BEGIN
  --
  -- Contrôle des destinataires de règlements parmi les bénéficiaires de prestations prévoyance
  -- (table Repartition_Bene, numbene_dest = numindiv, irrevocable = 'O') --
  --
O_retour	:= 0;
Loc_numgar	:= Nvl(I_numgar,0);
If Loc_numgar = 0 Then
	Open  C_dest_prev;
	Fetch C_dest_prev INTO L_exist;
	If C_dest_prev%FOUND Then
	  O_retour:=1;
	Else
	  O_retour:=0;
	End if;
	Close C_dest_prev;
Else
	Open  C_dest_prev_gar;
	Fetch C_dest_prev_gar INTO L_exist;
	If C_dest_prev_gar%FOUND Then
	  O_retour:=1;
	Else
	  O_retour:=0;
	End if;
	Close C_dest_prev_gar;
End if;
--
RETURN (O_retour);
END;
