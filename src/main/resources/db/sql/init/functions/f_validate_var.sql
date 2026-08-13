CREATE function ARTHUS.f_validate_var ( vidvar IN NUMBER
                                         , vchamp IN CHAR)
  RETURN number
  IS
  retour NUMBER;
   longueur libelle.sens%TYPE;
   vmnemo   def_variable.nom_variable%TYPE;
   tvar     def_variable.type%TYPE;
   dummy    varchar2(1);
--
   cursor CN is select type,nom_variable
                     from def_variable
                    where idvariable = vidvar;
--
-- -----
--
   cursor ctrl is select sens
                   from libelle
                   where mnemo = vmnemo
                     and code = -3;
--
-- -----
--
   cursor ctrlexl is select ''
                       from libelle
                      where mnemo = vmnemo
                        and code = to_number(vchamp);
--
-- -----
--
   cursor ctrlb is select sens
                   from libelle_bis
                   where mnemo = vmnemo
                     and code = '-3';
--
-- -----
--
   cursor ctrlexlb is select ''
                       from libelle_bis
                      where mnemo = vmnemo
                        and code = vchamp;
--
-- ---
--
  BEGIN
    open CN;
    retour := 1;
    fetch CN into tvar,vmnemo;
    if ( CN%NOTFOUND ) then
    	retour := -1;
     else
	if ( tvar = 'N' ) then
            open ctrlexl;
            fetch ctrlexl into dummy;
            if ( ctrlexl%NOTFOUND ) then
               retour := -6;
             else open ctrl;
                 fetch ctrl into longueur;
                 if ( ctrl%NOTFOUND ) then
                     retour := -2;
                 elsif ( length( vchamp ) > longueur ) then
                        retour := -4;
                 end if;
                 close ctrl;
             end if;
             close ctrlexl;
          else
            open ctrlexlb;
            fetch ctrlexlb into dummy;
            if ( ctrlexlb%NOTFOUND ) then
               retour := -7;
            else
		open ctrlb;
                fetch ctrlb into longueur;
                if ( ctrlb%NOTFOUND ) then
                     retour := -3;
                elsif( length( vchamp ) > longueur ) then
                     retour := -5;
                end if;
                close ctrlb;
            end if;
            close ctrlexlb;
          end if;
    end if;
    close CN;
    RETURN(retour);
  END f_validate_var;
