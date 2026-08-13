CREATE function ARTHUS.F_CPTA_LIB_REGLT
								(
								I_codope	     In Number,
								I_numdecaismt    In Number,
								I_type           In Number 	default 1,
								I_longueur       In Number 	default 15
								)
Return 		VARCHAR2 IS
/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CPTA_LIB_REGLT                                          */
/* Type         :  Publique                                                  */
/* Description  :  Constitution de l'entete de la reponse du flux XML        */
/* Entree       :  i_codope, code opération comptable                        */
/*                 i_numdecaismt                                             */
/*                 i_type : 1 référence, 2 type, 3 nom du bénéficiaire       */
/*                 i_longueur, taille de la chaine de caratère retourné      */
/*---------------------------------------------------------------------------*/
-- ABO 15/11/12  M0003881 : correction de la référence de paiement pour les décaisssements
--				 hors codope = 1 dont la référence n'est pas saisie sur l'écran d'EC
/*---------------------------------------------------------------------------*/

loc_op		Number;
--loc_op_numvir 	remise_op_detail.NUMVIREMENT%TYPE;
loc_refpmt    	TRAV_COMPTA.VAR01%TYPE;
loc_nom 		TRAV_COMPTA.VAR01%TYPE;
loc_decaismt  	decaismt%ROWTYPE;
loc_typ_val   	compta_lib_reglt.valeur%TYPE;
loc_nb_refpmt   number;


BEGIN

  BEGIN
    select 	*
    into 		loc_decaismt
    from 		decaismt
    where 	numdecaismt= I_numdecaismt;

    Exception When No_data_found then Return 'DECAISMT_INC';
  END;


  loc_op := f_cpta_op(I_numdecaismt);

  IF loc_op = 1 THEN
      IF loc_decaismt.modpmt =2 THEN

        select 	substr('0000000' || to_char(remise_vire_detail.numremise),-7,7), to_char(remise_vire.datrem, 'DD/MM/YY')
        into 		loc_refpmt, loc_nom
        from 		remise_vire_detail,remise_vire
        where 	remise_vire_detail.numremise=remise_vire.numremise
        and     remise_vire_detail.numdecaismt= I_numdecaismt;

      ELSE
        loc_refpmt 	:= substr('0000000' || to_char(loc_decaismt.refpmt),-7,7);
      END IF;

  END IF;


  IF 	I_type = 1 THEN
    IF loc_op=2 THEN
      BEGIN
        select 	to_char(r.reference)
        into 		loc_refpmt
        from 		releve_compte r ,remise_op_detail o
        where 	r.num_ecriture= o.numvirement
        and     o.numdecaismt = I_numdecaismt;

        EXCEPTION
        WHEN No_data_found THEN
          loc_refpmt:= to_char(i_numdecaismt);
        WHEN too_many_rows THEN
          RETURN 'MULTI_REF';
      END;
    END IF;
    RETURN ( SUBSTR(loc_refpmt,1,I_longueur) );

  ELSIF I_type = 2 THEN

    BEGIN
      select 	COMPTA_LIB_REGLT.valeur
      into   	loc_typ_val
      from   	COMPTA_LIB_REGLT,
          COMPTE
      where  	COMPTE.NUMCPTE 			= loc_decaismt.NUMCPTE
      and    	COMPTA_LIB_REGLT.NUMSOC 	= COMPTE.NUMSOC
      and    	COMPTA_LIB_REGLT.CODOPE 	= I_codope
      and    	COMPTA_LIB_REGLT.TYPE_PMT 	= 0
      and    	COMPTA_LIB_REGLT.MODE_PMT 	= loc_decaismt.modpmt
      and    	COMPTA_LIB_REGLT.TYPE_DEV 	= f_cpta_type_pmt(1,I_numdecaismt);

      Exception When No_data_found then loc_typ_val := 'INC';
    END;
    RETURN ( SUBSTR(loc_typ_val,1,I_longueur) );

  ELSIF I_type = 3 THEN
    IF loc_op =1 AND  loc_decaismt.modpmt <>2  THEN --chèque non compris dans ordre de paiement
      loc_nom := pk_personne.f_nom(loc_decaismt.numbene,I_longueur,2);

	ELSIF (loc_op = 2 AND loc_decaismt.modpmt <>2) THEN  --chèque dans ordre de paiement
      loc_nom := pk_personne.f_nom(loc_decaismt.numbene,I_longueur,2);

    END IF;

    RETURN ( SUBSTR(loc_nom,1,I_longueur) );

  END IF;

END	F_CPTA_LIB_REGLT;
