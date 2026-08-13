CREATE function ARTHUS.f_copy_cle( fct in varchar2
                                        , code  in varchar2
					, vcle1 in out varchar2
					, vcle2 in out varchar2
					, vcle3 in out varchar2
					)
  RETURN number
 AS
 retour   number;
 cle     cle_externe.cle_unique%TYPE;
 champ   varchar2(30);
-- ---
-- vcle1     cle_externe.cle_unique%TYPE;
-- vcle2     cle_externe.cle_unique%TYPE;
-- vcle3     cle_externe.cle_unique%TYPE;
-- ---
 cursor cext is select cle_unique
 			, block||'.'||champ
		from	cle_externe
		where rtrim(upper(codapli)) = rtrim(upper( code));
--
-- -----
--
 cursor cont is select cle1
			, cle2
			, cle3
		from	v_appli_contexte
		where	rtrim(upper(fonction)) = rtrim(upper(code))
                  and   rtrim(upper(codapli)) = rtrim(upper(fct));
--
-- -----
-- -----------------
begin
   retour := 1;
   open cext;
   fetch cext into cle, champ;
   if( cext%notfound ) then
     retour := 0;
   end if;
   close cext;
-- -----------------
  open cont;
  fetch cont into vcle1, vcle2, vcle3;
  if( cont%notfound ) then
     retour := 0;
  end if;
  close cont;
-- -----------------
  if NOT ( vcle1 is not null
       or  vcle2 is not null
       or  vcle3 is not null )
      then vcle1 := null;
      		vcle2 := null;
      		vcle3 := null;
     		retour := 0;
 end if;
--
if (substr(vcle1,1,1)='#') then
  select substr(vcle1,2,length(vcle1)-1)
   into vcle1
    from dual
   where substr(vcle1,1,1) = '#';
 elsif( rtrim(vcle1) = rtrim( cle ) )
      then vcle1 := champ;
end if;
--
if (substr(vcle2,1,1)='#') then
   select substr(vcle2,2,length(vcle2)-1)
     into vcle2
     from dual
   where substr(vcle1,1,1) = '#';
 elsif( rtrim(vcle2) = rtrim( cle ) )
      then vcle2 := champ;
end if;
--
if (substr(vcle3,1,1)='#') then
   select substr(vcle3,2,length(vcle3)-1)
     into vcle3
     from dual
   where substr(vcle1,1,1) = '#';
 elsif( rtrim(vcle3) = rtrim( cle ) )
      then vcle3 := champ;
end if;
--
 return( retour );
end f_copy_cle;
