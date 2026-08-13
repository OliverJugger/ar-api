CREATE function ARTHUS.f_delimite (
				a_chaine 	in varchar2,
				a_delimiteur 	in varchar2 default '"',
				a_type 		in varchar2 default 'C'
				)
Return varchar2
As
BEGIN
If ( a_type != 'N' ) then
	Return ( a_delimiteur || a_chaine || a_delimiteur );
Else
	Return ( a_chaine );
End if;
END	f_delimite;
