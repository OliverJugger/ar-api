CREATE function ARTHUS.f_gar_oblg(
                                      a_numsin sntr.numsin%type
                                      )
	return Integer
as
	loc_oblg  Integer;
BEGIN
 loc_oblg := 0;
	Begin
	select	1
	into	loc_oblg
	from	dual
	Where exists (
		      select	1
		      from	sntr_dossier,sinistre_sante
		      where	sntr_dossier.numsin_sntr=a_numsin
		      And	sntr_dossier.num_dossier=sinistre_sante.num_dossier
		      And	sntr_dossier.numligne=sinistre_sante.numligne
		      And	sinistre_sante.numorg Is Not Null
		      );
	Exception when no_data_found then loc_oblg:= 0;
	End;
return (loc_oblg);
END;
