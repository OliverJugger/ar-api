CREATE function ARTHUS.f_double_quote (
				a_chaine	In Varchar2
				)
Return Varchar2
Is
BEGIN
Return ( Replace( a_chaine, '''', '''''') );
END	f_double_quote;
