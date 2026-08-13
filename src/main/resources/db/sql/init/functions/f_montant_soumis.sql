CREATE function ARTHUS.f_montant_soumis
			(a_numdecaismt in number)
Return Varchar2
As loc_texte varchar2(78);
loc_montant number(11,2);
Begin
	Begin
	Select montant*(valeur/100)
	Into loc_montant
	From decaismt,indice
	Where numdecaismt=a_numdecaismt
	And indice=14
	And sysdate between indice.datapli
		and nvl(indice.datper,sysdate)
	And decaismt.numdest in(select numbene_dest
				from repartition_bene
				where idrepartition in
					(select idrepartition from histo_calcul
					where numdec in
						(select numdec from affectation
						where numdecaismt=a_numdecaismt
						)
					 )
				and type_dest=3
				)
	;
		Exception
			When no_data_found then loc_montant:=0;
	End;
If loc_montant=0
Then
	loc_texte:='\ ';
Else
	loc_texte:='Montant soumis à cotisation : '||loc_montant||' Euros.';
End if;
Return(loc_texte);
End;
