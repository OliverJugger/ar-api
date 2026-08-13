CREATE Procedure ARTHUS.maj_doublons(a_numindiv_orig in number,a_numindiv_desti in number)
is
Begin
	Update adhe_cntrt
	Set numquerable=a_numindiv_desti
	Where numadhe=a_numindiv_orig;
	Update qttc_global
	Set numindiv=a_numindiv_desti,
	numquerable=a_numindiv_desti
	Where numindiv=a_numindiv_orig;
	Update encaismt
	Set numcli=a_numindiv_desti
	Where numcli=a_numindiv_orig;
	Update compte_client
	Set numcli=a_numindiv_desti
	Where numcli=a_numindiv_orig;
	Update qttc_affec
	Set numindiv=a_numindiv_desti
	Where numindiv=a_numindiv_orig;
	Update facture
	Set numcli=a_numindiv_desti
	Where numcli=a_numindiv_orig;
	Commit;
End;
/
