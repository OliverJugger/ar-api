CREATE function ARTHUS.f_libgar ( I_numfor IN gar_cntrt.numfor%Type )
Return Varchar2
IS
Cursor C_gar IS
	Select	nomgar ||' - '||libelle	libgar
	From	gar_cntrt
	Where	numfor = I_numfor;
Cursor C_grp IS
	Select	grp_gar.nomgrpgar || ' - ' || grp_gar.libelle	libgar
	From	grp_gar
	Where	grp_gar.numgrpgar = I_numfor;
L_libgar	Varchar2(80);
BEGIN
Open C_gar;
Fetch C_gar Into L_libgar;
If ( C_gar%NotFound ) then
	Open C_grp;
	Fetch C_grp Into L_libgar;
	Close C_grp;
End If;
Close C_gar;
--
Return ( L_libgar );
END;
