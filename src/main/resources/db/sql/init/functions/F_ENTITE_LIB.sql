CREATE FUNCTION ARTHUS."F_ENTITE_LIB" (
				a_etendue 		in number,
				a_cle_unique        in number)
        RETURN    varchar2
is
    loc_lib    varchar2(70);
begin

   if ( a_etendue = 0)
   then
    loc_lib := f_nom( a_cle_unique );
   end if;

   if ( a_etendue = 1)
   then
    select    v_gar.numfor||' Contrat : '||v_gar.refcie
    into    loc_lib
    from    v_gar
    where    v_gar.etendue = 2
    and    v_gar.numfor    = a_cle_unique;
   end if;

   if ( a_etendue = 2)
   then
    select    'Contrat : '||grnts.refcie
    into    loc_lib
    from    grnts
    where    grnts.numgar = a_cle_unique;
   end if;

   if ( a_etendue = 3)
   then
    select    indvs.nom||' '||indvs.prenom
    into    loc_lib
    from    indvs
    where    indvs.numindiv = a_cle_unique
    and    exists (select    1
            from    client
            where    indvs.numindiv = client.numindiv);
   end if;

   if ( a_etendue = 4)
   then
    loc_lib := 'Assuré : '||f_nom( a_cle_unique );
   end if;

   if ( a_etendue = 5)
   then
    select    orgns.nom
    into    loc_lib
    from    orgns
    where    orgns.numorg = a_cle_unique;
   end if;

   if ( a_etendue = 6)
   then
    select    v_gar.clef||' (No de Produit)'
    into    loc_lib
    from    v_gar
    where    v_gar.etendue = 7
    and    v_gar.numfor  = a_cle_unique;
   end if;

   if ( a_etendue = 7)
   then
    select    'Produit ' || produit.libelle
    into    loc_lib
    from    produit
    where    produit.numprod = a_cle_unique;
   end if;

   if ( a_etendue = 8)
   then
    select    'Intermédiaire ' || interm.nom
    into    loc_lib
    from    interm
    where    interm.numindiv = a_cle_unique;
   end if;

   if ( a_etendue = 9)
   then
    select    'Société ' || societe.nom
    into    loc_lib
    from    societe
    where    societe.numsoc = a_cle_unique;
   end if;

   if ( a_etendue = 10)
   then
    select    societe.entete
    into    loc_lib
    from    societe
    where    societe.numsoc = a_cle_unique;
   end if;

   if ( a_etendue = 11)
   then
    loc_lib := 'Assuré : ' ||f_nom( a_cle_unique );
   end if;

   if ( a_etendue = 12)
   then
    loc_lib := 'Ayant droit : '||f_nom( a_cle_unique );
   end if;

   if ( a_etendue = 13)
   then
    select    'Adhésion : '||adhe_cntrt.idadhesion||' - '||adhe_cntrt.ref_ext
    into    loc_lib
    from    adhe_cntrt
    where    adhe_cntrt.idadhesion = a_cle_unique;
   end if;

   if ( a_etendue = 14)
   then
    select    'Proposition : '||proposition.idpropo||' '||proposition.refext
    into    loc_lib
    from    proposition
    where    proposition.idpropo = a_cle_unique;
   end if;

   if ( a_etendue = 15)
   then
    select    'Dossier : '||sin_prev.nosin
    into    loc_lib
    from    sin_prev
    where    sin_prev.nosin= a_cle_unique;
   end if;

   if ( a_etendue = 17)
   then
    select    'Bénéf. : '||to_char(indvs.numindiv)||' - '||
        indvs.nom||' '||indvs.prenom
    into    loc_lib
    from    indvs
    where    indvs.numindiv= a_cle_unique;

    -- RECOURS
   elsif ( a_etendue = 16)
   then
    select    recours.ref_ext
    into    loc_lib
    from    recours
    where    recours.numrecours     = a_cle_unique;
   end if;

return loc_lib;

end f_entite_lib;
