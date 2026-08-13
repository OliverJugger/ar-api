CREATE function ARTHUS.f_bene_virement(
			a_numbene in number,
			a_typebene in number,
			a_numdecaismt in number default 0,
			a_codope in number default 1)
Return Varchar2
As
	loc_nom varchar2(18);
	loc_numsin number(9);
Begin
	If (f_numassu(a_numbene)=a_numbene)
	then
    		loc_nom:='';
	Elsif (a_typebene=1)
	Then
		Begin
		Select min(numsin)
		Into loc_numsin
		From sntr,dcpt,affectation,decaismt
		Where sntr.numdec=dcpt.numdec
		And dcpt.numdec=affectation.numaffec
		And affectation.numdecaismt=decaismt.numdecaismt
		And decaismt.codope=a_codope
		And decaismt.numdecaismt=a_numdecaismt;

		Select substr(indvs.nom||' '||indvs.prenom,1,18)
		Into loc_nom
		From sntr,indvs
		Where indvs.numindiv=sntr.numindiv
		And sntr.numsin=loc_numsin;

		Exception
		When no_data_found then loc_nom:='';
		End;
	Elsif (a_typebene=4) then
		Begin
		Select 'F='||substr(min(prch.numfact),1,15)
		Into loc_nom
		From prch,sntr,dcpt,affectation,decaismt
		Where prch.numpc=sntr.numpc
		And sntr.numdec=dcpt.numdec
		And dcpt.numdec=affectation.numaffec
		And affectation.numdecaismt=decaismt.numdecaismt
		And decaismt.codope=a_codope
		And decaismt.numdecaismt=a_numdecaismt;

		Exception
		When no_data_found then
		loc_nom:='';

		End;
	Else
		Begin
		Select 'F='||substr(min(sntr_ref.ref),1,15)
		Into loc_nom
		From sntr_ref,sntr,dcpt,affectation,decaismt
		Where sntr_ref.numsin=sntr.numsin
		And sntr.numdec=dcpt.numdec
		And dcpt.numdec=affectation.numaffec
		And affectation.numdecaismt=decaismt.numdecaismt
		And decaismt.codope=a_codope
		And decaismt.numdecaismt=a_numdecaismt;

		Exception
		When no_data_found then
		loc_nom:='';

		End;
	End if;
Return(loc_nom);
End;
