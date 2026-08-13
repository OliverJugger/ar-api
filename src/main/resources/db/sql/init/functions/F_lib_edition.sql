CREATE Function ARTHUS.F_lib_edition(I_numedit In number )
Return Varchar2
Is
L_libelle      lib_edition.editlib%type;

BEGIN
        select	distinct
	        nvl(lib_edition.editlib, typ_edition.editlib) editlib
        Into    L_libelle
        From	file_edition,typ_edition,lib_edition
        Where	file_edition.numedit = I_numedit
        AND	file_edition.status  = 2
        AND     typ_edition.editid = file_edition.editid
        AND	file_edition.numedit = lib_edition.numedit(+);
        If Sql%NotFound Then
  	   L_libelle:=Null;
        End If;
        Return(L_libelle);
END;
