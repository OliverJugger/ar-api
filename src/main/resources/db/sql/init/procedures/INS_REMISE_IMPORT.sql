CREATE PROCEDURE ARTHUS."INS_REMISE_IMPORT" (
				a_idporte	In Number,
				a_nb_enreg	In Number,
				a_date_porte	In Date Default Null,
				a_numremiseglobal In Out Number
				)
Is
-- $Rev:: 839                                    $:  Revision du dernier commit
-- $Author:: b.cortial                           $:  Auteur du dernier commit
-- $Date: 2023-09-20 17:02:14 +0200 (mer., 20 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PROCEDURES/INS_REMISE_IMPORT.sql $:  Chemin

loc_numremise		Number;
BEGIN
  -- recherche du numéro de remise global à créér si inexistant
  IF NVL(a_numremiseglobal, 0) = 0 THEN
    Select	nvl( max(numremiseglobal), 0 ) +1
    Into	a_numremiseglobal
    From	REMISE_ECHANGE;
  END IF;
  -- recherche du numéro de remise à créer
  Select	nvl( max(numremise), 0 ) +1
  Into	loc_numremise
  From	remise_import;
  -- insertion dans remise_import
  Insert Into remise_import (
  	numremise,
  	idporte,
  	nombre,
  	enreg,
  	date_remise,
  	date_porte)
  Select	loc_numremise,
  	a_idporte,
  	count(*),
  	a_nb_enreg,
  	trunc(sysdate),
  	a_date_porte
  From	histo_import
  Where	numremise = 0
  and	idporte = a_idporte;
  -- maj numéro de remise dans histo_import
  Update	histo_import
  Set	numremise = loc_numremise
  Where	numremise = 0
  and	idporte = a_idporte;
  -- insertion de la remise dans remise_global
  Insert Into REMISE_ECHANGE(
    numremiseglobal,
    numremise,
    sens,
    type_echange,
    creation,
    numutil )
  SELECT
    a_numremiseglobal,
    loc_numremise,
    1,
    type_echange,
    trunc(sysdate),
    f_numutil
    FROM DEF_PORTE WHERE idporte = a_idporte;
END;
/
