CREATE function ARTHUS.inferer_sex (i_prenom individu.PRENOM%type) return number

is 
sex_moyen number;
begin 

select sum(sexe)/ count(*) into sex_moyen from individu where prenom = i_prenom;

If sex_moyen > 1.5 then return 2; end if;
return 1;
exception when others then return 1; -- le masculin l'emporte 
end inferer_sex;
