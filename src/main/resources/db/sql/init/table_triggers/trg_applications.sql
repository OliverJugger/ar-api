CREATE TRIGGER ARTHUS.trg_applications
before insert or update
on applications
for each row
begin
if ( :new.creation is null ) then
	:new.creation := trunc(sysdate);
	:new.maj := trunc(sysdate);
else
	:new.maj := trunc(sysdate);
end if;
--
Insert into profil (
	profil,
	codapli,
	acces )
Select 	'ADM',
	:new.codapli,
	:new.type -- M0004551  : MUR le 17/10/2014 : forcé à 2 avant
From	Dual
Where Not Exists (
	Select	1
	from	profil
	where	profil = 'ADM'
	and	codapli = :new.codapli
	and acces = :new.type -- M0004551  : MUR le 17/10/2014 : "and	acces = 2" avant
	)
and Not Exists (
	Select	1
	from	profil
	where	profil = 'ADM'
	and	codapli = :new.codapli
	and acces = 2 -- M0004551 le 17/11/2014 : pour pouvoir decocher un profil 'en consultation' dans GU01 pour le profil ADM
	)
 ;
End;