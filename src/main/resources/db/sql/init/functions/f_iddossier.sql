CREATE function ARTHUS.f_iddossier (
				a_debut	In Date
				)
Return Varchar2
Is
loc_retour	Varchar2(9);
loc_nosin Number;
loc_surv  Varchar2(2);
Begin
loc_surv := to_char(a_debut, 'YY');
Select  nvl(max(to_number(substr(iddossier, 3, 5))), 0) + 1
Into    loc_nosin
From    dossier_sinistre
Where   iddossier like loc_surv || '%';
loc_retour := loc_surv || substr( to_char(loc_nosin, '09999'), 2, 5);
Return ( loc_retour );
END	f_iddossier;
