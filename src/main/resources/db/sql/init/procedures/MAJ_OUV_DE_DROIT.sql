CREATE PROCEDURE ARTHUS."MAJ_OUV_DE_DROIT" (a_numindiv IN NUMBER)
IS
   loc_numassu   NUMBER (9);
   loc_type      NUMBER (2);
   loc_etat      NUMBER (2);


-- M0005488
loc_matorg VARCHAR2(15 BYTE) ;
loc_test_matorg2_individu VARCHAR2(15 BYTE) ;
loc_test_matorg2_noemie number(3) ;


BEGIN
/* Recherche ouvreur de droits */
   BEGIN
      SELECT ouvreur.numindiv , indvs.matorg -- M0005488
        INTO loc_numassu , loc_matorg
        FROM indvs, indvs ouvreur
       WHERE ouvreur.matorg = indvs.matorg
         AND ouvreur.natur = 1
         AND indvs.numindiv = a_numindiv;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_etat := 6;
         loc_numassu := 0;
         loc_type := 20;
         loc_matorg := '' ;
      WHEN TOO_MANY_ROWS
      THEN
         loc_etat := 6;
         loc_numassu := 0;
         loc_type := 20;
         loc_matorg := '' ;
   END;

   IF (loc_numassu != 0)
   THEN
      BEGIN
         UPDATE noemie
            SET numassu = loc_numassu
          WHERE numindiv = a_numindiv AND numremise = 0 AND mouvement != 'A'
          and    matorg = loc_matorg --- M0005488
          ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   ELSIF (loc_numassu = 0)
   THEN
      BEGIN
         UPDATE porte_adhesion
            SET transmis = loc_etat,
                TYPE = loc_type
          WHERE numporte = 1
            AND numindiv = a_numindiv
            AND numremise = 0
            AND mouvement != 'A'
          -- M0005488
          and idporte = (select idporte
                         from noemie
                         Where  numindiv = a_numindiv
                         and    numremise = 0
                         and    mouvement != 'A'
                         and    matorg = loc_matorg --- M0005488
                         )
          ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;


/* Recherche ouvreur de droits - sur matorg2 */
  begin

    select matorg2 into loc_test_matorg2_individu from individu where numindiv = a_numindiv and matorg2 is not null ;

    begin

      select count(*) into loc_test_matorg2_noemie from noemie
      Where  numindiv = a_numindiv
      and    numremise = 0
      and    mouvement != 'A'
      and    matorg = loc_test_matorg2_individu;

      begin
      Select  ouvreur.numindiv , indvs.matorg2 -- M0005488
      Into    loc_numassu , loc_matorg
      From    indvs,
      	indvs	ouvreur
      Where   ouvreur.matorg = indvs.matorg2
      and     ouvreur.natur = 1
      and	indvs.numindiv = a_numindiv;
      Exception
      When no_data_found then
              loc_etat := 6; loc_numassu := 0; loc_type := 20; loc_matorg := '' ;
      When too_many_rows then
              loc_etat := 6; loc_numassu := 0; loc_type := 20; loc_matorg := '' ;
      end;

      if (loc_numassu != 0) then
              begin
              Update noemie
              Set    numassu = loc_numassu
              Where  numindiv = a_numindiv
              and    numremise = 0
              and    mouvement != 'A'
              and    matorg = loc_matorg --- M0005488
              ;
              Exception When No_data_found then null;
              end;
      elsif (loc_numassu = 0) then
              begin
                Update  porte_adhesion
                Set     transmis = loc_etat,
                        type = loc_type
                Where   numporte = 1
                and     numindiv = a_numindiv
                and    numremise = 0
                and    mouvement != 'A'
                -- M0005488
                and idporte = (select idporte
                               from noemie
                               Where  numindiv = a_numindiv
                               and    numremise = 0
                               and    mouvement != 'A'
                               and    matorg = loc_matorg --- M0005488
                               )

                ;
              Exception When No_data_found then null;
              end;
      end if;
    exception
      when no_data_found then null ;
    end ;

  exception
    when no_data_found then null ;
  end ;



END;
/
