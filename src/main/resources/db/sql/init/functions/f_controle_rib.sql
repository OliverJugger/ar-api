CREATE function ARTHUS.f_controle_rib
		(
		a_codbque in varchar2,
		a_guichet in varchar2,
		a_compte in varchar2,
		a_clerib in varchar2
		)
Return number
As
	loc_retour number(1);
Begin
      select 1
      into loc_retour
      from dual
      where
      mod(to_number(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(
      translate(translate(
      a_codbque||
      a_guichet||
      a_compte||
      a_clerib
      ,'A','1')
      ,'B','2')
      ,'C','3')
      ,'D','4')
      ,'E','5')
      ,'F','6')
      ,'G','7')
      ,'H','8')
      ,'I','9')
      ,'J','1')
      ,'K','2')
      ,'L','3')
      ,'M','4')
      ,'N','5')
      ,'O','6')
      ,'P','7')
      ,'Q','8')
      ,'R','9')
      ,'S','2')
      ,'T','3')
      ,'U','4')
      ,'V','5')
      ,'W','6')
      ,'X','7')
      ,'Y','8')
      ,'Z','9')
      ,' ','0')
      ),97)=0
;
Return(loc_retour);
Exception
when no_data_found then
	loc_retour:=0;
Return(loc_retour);
end;
