CREATE PROCEDURE ARTHUS.P_INS_calcul
IS
-- Variable de reconnaissance SCCS
-- %W%    %E%
--
-- -- CONSTANTES  ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes  --
-- -- EXCEPTIONS  ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions  --
-- -- TYPE -------------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types  --
-- -- VARIABLES  -------------------------------------------------------
Rec_frmls	frmls%Rowtype;
Rec_gar_cntrt	gar_cntrt%Rowtype;
Rec_calcul	calcul%Rowtype;
Rec_defrub	defrub%Rowtype;
Nb_rows		Number;
L_numgar	Number;
-- ----------------------------------------------- Fin des variables  --
BEGIN
For Rec_frmls IN (
	Select	numfor
	From	frmls
	Where	numprod != 5)
Loop
	For Rec_gar_cntrt IN (
		Select	numfor,
			numgar
		From	gar_cntrt
		Where	numfor_ref = Rec_frmls.numfor)
	Loop
		Nb_rows := 0;
		Insert Into calcul (
			Numfor,
			Codfrais,
			Datapli,
			Datper,
			Numorg,
			Nummath,
			X)
		Select	Rec_gar_cntrt.numfor,
			calcul.codfrais,
			calcul.datapli,
			calcul.datper,
			calcul.numorg,
			calcul.nummath,
			x
		From	calcul
		Where	numfor = Rec_frmls.numfor
		and Not Exists (
			Select	1
			From	calcul	pcalcul
			Where	pcalcul.numfor = Rec_gar_cntrt.numfor
			and	pcalcul.codfrais = calcul.codfrais);
		Insert Into defrub (
			Numfor,
			Codfrais,
			Datapli,
			Datper)
		Select  Rec_gar_cntrt.numfor,
			Codfrais,
			Datapli,
			Datper
		From	defrub
		Where   numfor = Rec_frmls.numfor
		and Not Exists (
			Select  1
			From    defrub  pdefrub
			Where   pdefrub.numfor = Rec_gar_cntrt.numfor
			and     pdefrub.codfrais = defrub.codfrais);
		Nb_rows := Sql%Rowcount;
		Dbms_output.put_line( 'Contrat ' || Rec_gar_cntrt.numgar ||
			' Garantie ' || Rec_gar_cntrt.numfor ||
			' ' || Nb_rows || ' ligne(s) inseree(s)' );
	End Loop;
End Loop;
END;
/
