CREATE PROCEDURE ARTHUS.P_AFFECT_QTTC_NUMQUIT(i_numquit  IN  QTTC_GLOBAL.NUMQUIT%TYPE)
/*===========================================================================*/
/* Procedure    : P_AFFECT_QTTC_NUMQUIT.sql                                  */
/* Domaine      : Cotisation/Tresorerie                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : 19/04/2013                                                 */
/* Description  : ventilation des affectations de cotisations                */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA 08/09/2014 prise en compte commission sur cotise à 0   */              
/*                Mantis 3947 : and qttc_global.mt_ttc!=0 mis en commentaire */   
/*===========================================================================*/
/* Correction   : PHA / 13/01/2015 / Ajout filtre quittances annulées/résil. */
/*===========================================================================*/
/* Correction   : CLI / 28/12/2015 / Prise en comptes des cotisation au  	 */
/*                niveau contrat 											 */
/*===========================================================================*/
IS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PROCEDURES/P_AFFECT_QTTC_NUMQUIT.sql $:  Chemin
--
   CURSOR c_reaffec_indiv
   IS
      SELECT DISTINCT qttc_global.numquit
              FROM    emission,
                      qttc_global,
                      qttc_affec,
                      compte_client,
                      adhe_cntrt,
                      contrat,
                      contrat_ref
                  WHERE 1 = 1
                    AND    qttc_affec.numindiv    = 0
                    AND    qttc_global.numgar     = contrat.numgar
                    AND    contrat.numgar_ref     = contrat_ref.numgar
                    AND    qttc_global.mt_ttc     Is Not Null
                    -- and    qttc_global.mt_ttc     !=0
                    AND    qttc_global.numquit    = emission.numfact
                    AND    emission.codope        = 4
                    AND    emission.type_doc      = 1
                    AND    emission.numrelance    = 0
                    AND    qttc_global.comptant   !='R' 
                    -- exclure les annulations et résiliations
                    AND    NOT EXISTS(SELECT 1 FROM facture_annul fa WHERE fa.numfact = qttc_global.numquit ) 
                    AND    qttc_global.type_qttc  = 2
                    AND    qttc_global.idadhesion = adhe_cntrt.idadhesion
                    AND    qttc_global.numquit    = qttc_affec.numquit
                    AND    qttc_affec.numfor      !=0
                    AND    qttc_affec.idaffec     = compte_client.idaffec
                    AND    compte_client.codope   = 4
                    AND    compte_client.numfact  = qttc_global.numquit
                    AND    qttc_global.numquit    = i_numquit;

   CURSOR c_reaffec_coll IS
      SELECT DISTINCT qttc_global.numquit
              FROM    emission,
                      qttc_global,
                      qttc_affec,
                      compte_client,
                      contrat,
                      contrat_ref
                WHERE 1 = 1
                  AND    qttc_affec.numindiv   = 0
                  AND    qttc_global.numgar    = contrat.numgar
                  AND    contrat.numgar_ref    !=contrat.numgar
                  AND    contrat.numgar_ref    = contrat_ref.numgar
                  AND    qttc_global.mt_ttc    Is Not Null
                  -- and    qttc_global.mt_ttc    !=0
                  AND    qttc_global.numquit   = emission.numfact
                  AND    emission.codope       = 4
                  AND    emission.type_doc     = 1
                  AND    emission.numrelance   = 0
                  AND    qttc_global.comptant  !='R'  
                  -- exclure les annulations et résiliations
                  AND    NOT EXISTS(SELECT 1 FROM facture_annul fa WHERE fa.numfact = qttc_global.numquit ) 
                  AND    qttc_global.idadhesion=0
                  AND    qttc_global.numquit   = qttc_affec.numquit
                  AND    qttc_affec.numfor     !=0
                  AND    qttc_affec.idaffec    = compte_client.idaffec
                  AND    compte_client.codope  = 4
                  AND    compte_client.numfact = qttc_global.numquit
                  AND    qttc_global.numquit    = i_numquit;


-- quittances niveau contrat	M0005021  
	CURSOR c_reaffec_cntrt IS
		  SELECT DISTINCT qttc_global.numquit
				  FROM    emission,
						  qttc_global,
						  qttc_affec,
						  compte_client,
						  contrat,
						  contrat_ref
					WHERE 1 = 1
					  AND    qttc_affec.numindiv   = 0
					  AND    qttc_global.numgar    = contrat.numgar
					  AND    contrat.numgar_ref    = contrat.numgar
					  AND    contrat.numgar_ref    = contrat_ref.numgar
					  AND    qttc_global.mt_ttc    Is Not Null
					  AND    qttc_global.numquit   = emission.numfact
					  AND    emission.codope       = 4
					  AND    emission.type_doc     = 1
					  AND    emission.numrelance   = 0
					  AND    qttc_global.comptant  !='R'  
					  -- exclure les annulations et résiliations
					  AND    NOT EXISTS(SELECT 1 FROM facture_annul fa WHERE fa.numfact = qttc_global.numquit ) 
					  AND    qttc_global.idadhesion=0
					  AND    qttc_global.numquit   = qttc_affec.numquit
					  AND    qttc_affec.numfor     !=0
					  AND    qttc_affec.idaffec    = compte_client.idaffec
					  AND    compte_client.codope  = 4
					  AND    compte_client.numfact = qttc_global.numquit
					  AND    qttc_global.numquit    = i_numquit;

r_reaffec_indiv   c_reaffec_indiv%ROWTYPE;

r_reaffec_coll   c_reaffec_coll%ROWTYPE;

r_reaffec_cntrt   c_reaffec_cntrt%ROWTYPE;

--
BEGIN

--
/*DBMS_OUTPUT.PUT_LINE( 'Debut, affectation au niveau adhésion individuelle');*/

  OPEN c_reaffec_indiv;

  LOOP
    FETCH c_reaffec_indiv INTO r_reaffec_indiv;

    EXIT WHEN c_reaffec_indiv%NOTFOUND;
    /*DBMS_OUTPUT.PUT_LINE( 'Numquit = '|| r_reaffec_indiv.numquit );*/
    BEGIN
      qttc_ventil(r_reaffec_indiv.numquit);
      qttc_reventil (r_reaffec_indiv.numquit, r_reaffec_indiv.numquit);
    EXCEPTION WHEN OTHERS THEN
       null;
      /*DBMS_OUTPUT.PUT_LINE( 'Erreur = 1');*/
    END;

  END LOOP;

  CLOSE c_reaffec_indiv;

--
/*DBMS_OUTPUT.PUT_LINE( 'Affectation au niveau adhesion collective');*/
--

  OPEN c_reaffec_coll;

  LOOP
    FETCH c_reaffec_coll INTO r_reaffec_coll;

    EXIT WHEN c_reaffec_coll%NOTFOUND;
    --DBMS_OUTPUT.PUT_LINE( 'Numquit = '|| r_reaffec_coll.numquit );
    BEGIN
    qttc_ventil(r_reaffec_coll.numquit);
    qttc_reventil (r_reaffec_coll.numquit, r_reaffec_coll.numquit);
    EXCEPTION WHEN OTHERS THEN
       null;
      /*DBMS_OUTPUT.PUT_LINE( 'Erreur = 1');*/
    END;

  END LOOP;
  CLOSE c_reaffec_coll;


/*  DBMS_OUTPUT.PUT_LINE( 'Affectation au niveau contrat');*/

  OPEN c_reaffec_cntrt;
  LOOP
    FETCH c_reaffec_cntrt INTO r_reaffec_cntrt;

    EXIT WHEN c_reaffec_cntrt%NOTFOUND;
    /*DBMS_OUTPUT.PUT_LINE( 'Numquit = '|| r_reaffec_cntrt.numquit );*/
    BEGIN
    qttc_ventil(r_reaffec_cntrt.numquit);
    qttc_reventil (r_reaffec_cntrt.numquit, r_reaffec_cntrt.numquit);
    EXCEPTION WHEN OTHERS THEN
       null;
      /*DBMS_OUTPUT.PUT_LINE( 'Erreur = 1');*/
    END;
  END LOOP;
  CLOSE c_reaffec_cntrt;

/*DBMS_OUTPUT.PUT_LINE( 'Fin des affectations');*/


EXCEPTION WHEN OTHERS THEN NULL;

END P_AFFECT_QTTC_NUMQUIT;
/
