CREATE OR REPLACE package ARTHUS.PK_WS_WEB_MAJ_FRONT as
  /*========================================================================       */
  /* Package      : PK_WS_WEB_MAJ_FRONT.sql                                        */
  /* Domaine      : PACKAGE WEB SERVICE EDAAP                                      */
  /* Version      : V1.0                                                           */
  /* Auteur       : CLI                                                            */
  /* Création     : 09/08/2011                                                     */
  /* Description  : Package contenant les services exposés dans le cadre du projet */
  /*              : Extranet de Welcare. Package responsable des demande de        */
  /*              : modification des informations de l'assuré, rib, téléphone..    */
  /*                                                                               */
  /* Projet       : P201609004_Extranet_assuré_GEREP, modifications                */
  /* Evolution    :                                                                */
  /* Auteur       : CLI                                                            */
  /* Date         : 14/03/2017                                                     */
  /* Commentaire  :                                                                */
  /*==========================================================================     */
  /* Correction   : trigramme / date / commentaire                                 */
  /*                                                                               */
  -- variable globale de la porte
  g_grpporte                    NUMBER;

  /******************************************************************************/


  FUNCTION ADD_RIB(   numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                                        idDemande_ext IN NUMBER,
                      rib EXTR_ADD_RIB,
                      documents       IN EXT_TAB_DOCUMENT
                     )
  RETURN GENERIQUE_WS_RESP;

  /******************************************************************************/
  FUNCTION CLOSE_RIB( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                                        idDemande_ext IN NUMBER,
                                        idRib IN NUMBER,
                                        dateEffet     IN DATE
                     )
  RETURN GENERIQUE_WS_RESP;
  /******************************************************************************/
  FUNCTION ADD_CONTACT( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                        numindiv IN INDIVIDU.NUMINDIV%TYPE,
                                            idDemande_ext IN NUMBER,
                                            contact IN VARCHAR2,
                                            nature IN NUMBER,
                                            type IN NUMBER,
                                            dateEffet IN DATE    )
  RETURN GENERIQUE_WS_RESP;
  /******************************************************************************/
  FUNCTION ADD_ADRESSE( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                        numindiv IN INDIVIDU.NUMINDIV%TYPE,
                                            idDemande_ext IN NUMBER,
                                            adresse IN EXTR_ADRESSE_TR,
                                            dateEffet IN DATE

   )
  RETURN GENERIQUE_WS_RESP;
  /******************************************************************************/
  FUNCTION MAJ_INFO_PERSO(numAdherent   IN NUMBER,
                          numIndiv      IN NUMBER,
                          idDemande_ext IN NUMBER,
                          dateEffet     IN DATE,
                          infos         IN EXTR_MAJ_INFO_PERSO

                          )
  RETURN GENERIQUE_WS_RESP;
  /******************************************************************************/
  FUNCTION MAJ_CIRCUIT_INFO(numAdherent   IN NUMBER,
                            numIndiv      IN NUMBER,
                            idDemande_ext IN NUMBER,
                            typeCircuit   IN NUMBER,
                            ouverture     IN NUMBER
                          )
  RETURN GENERIQUE_WS_RESP;
  /******************************************************************************************DMNDE*************************************************************************************************/
  /******************************************************************************************DMNDE*************************************************************************************************/
  /******************************************************************************************DMNDE*************************************************************************************************/

  FUNCTION DMNDE_PEC_HOSPI (numAdherent   IN NUMBER,
                            numIndiv      IN NUMBER,
                            idDemande_ext IN NUMBER,
                            infos EXTR_DMNDE_PEC_HOSPI)
   RETURN GENERIQUE_WS_RESP;
  /******************************************************************************/

  FUNCTION ADD_BENE(  numAdherent      IN NUMBER,
                      idDemande_ext    IN NUMBER,
                      dateeffet        IN DATE,
                      infos            IN EXTR_ADD_BENE
                    )
  RETURN EXTR_R_ADD_BENEFICIAIRE;

    /******************************************************************************/
  FUNCTION ADD_NUMSS( numAdherent     IN NUMBER,
                      numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext   IN NUMBER,
                      infos           IN EXTR_ADD_NUMSS,
                      documents       IN EXT_TAB_DOCUMENT
                      )
  RETURN GENERIQUE_WS_RESP;
    /******************************************************************************/
 FUNCTION ADD_NUMSS_STE (numAdherent     IN NUMBER,
                        numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext    IN NUMBER,
                        infos             IN EXTR_ADD_NUMSS,
                        documents        IN EXT_TAB_DOCUMENT
                        )
 RETURN GENERIQUE_WS_RESP ;

  /******************************************************************************/

  FUNCTION RAD_BENE ( numAdherent     IN NUMBER,
                      numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext    IN NUMBER,
                      motif           IN NUMBER,
                      dateeffet       IN DATE,
                      documents      IN EXT_TAB_DOCUMENT
                            )
  RETURN GENERIQUE_WS_RESP;
  /*******************************************************************************/


  FUNCTION ADD_DEVIS (  numAdherent     IN NUMBER,
                          numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                          idDemande_ext   IN NUMBER,
                          mutuelleExist   IN NUMBER,
                          natureDossier   IN NUMBER,
                          documents       IN EXT_TAB_DOCUMENT

  )
  RETURN GENERIQUE_WS_RESP;
  /*******************************************************************************/


  FUNCTION ADD_REMB (  numAdherent     IN NUMBER,
                          numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                          idDemande_ext   IN NUMBER,
                          mutuelleExist   IN NUMBER,
                          natureDossier   IN NUMBER,
                          detailsoins     IN NUMBER,
                          documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP;
  /*******************************************************************************/


  FUNCTION DEPOT_PIECE (  numAdherent     IN NUMBER,
                          numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                          idDemande_ext   IN NUMBER,
                          infos           IN EXTR_DEPOT_PIECE,
                          documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP;
/*******************************************************************************/
  -- Spécialisé dans l'optionnel
  FUNCTION SUBSCRIBE (  numAdherent	  IN NUMBER,
                        idDemande_ext IN NUMBER,
                        TAB_CONTRAT	  IN EXTR_TAB_BENE_PROSPECT,
                        dateeffet	    IN DATE ,
                        MODE_PAIE	    IN NUMBER,
                        PRIX_TOT      IN NUMBER,
                        NATURE         IN NUMBER, --1 option, 2 base, 3 option via BIA
                        idadhesion_base IN NUMBER,
                        documents     IN EXT_TAB_DOCUMENT
  )
  RETURN EXTR_R_SUBCRIBE;
  /******************************************************************************/
FUNCTION ADD_DOS_CALC (   numAdherent   IN NUMBER
                          ,numindiv       IN NUMBER
                          ,idDemande_ext IN NUMBER
                          ,typeDossier   IN NUMBER
                          ,natureDossier IN NUMBER
                          ,typeFrais     IN NUMBER
                          ,documents     IN EXT_TAB_DOCUMENT
                          ,tab_act       IN EXTR_TAB_ACTS_CALC

                            )
  RETURN EXTR_R_ADD_DOS_CALC;


  /******************************************************************************/
  FUNCTION ADD_INDIVIDU(  numcli           IN NUMBER,
                          idDemande_ext    IN NUMBER,
                          infos            IN EXTR_ADD_INDIVIDU
                    )
  RETURN EXTR_R_ADD_BENEFICIAIRE;

   /******************************************************************************/
  FUNCTION VALID_SUBCRIBE(  numcli           IN NUMBER,
                            idDemande_ext    IN NUMBER,
                            infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP;

  /******************************************************************************/
  FUNCTION REJECT_SUBCRIBE(  numcli           IN NUMBER,
                             idDemande_ext    IN NUMBER,
                             infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP;

 /******************************************************************************/
  FUNCTION MAJ_SUBSCRIBE(  numcli           IN NUMBER,
                           idDemande_ext    IN NUMBER,
                           dateeffet        IN DATE,
                           infos            IN EXTR_QUALIF_SUBRIBE
                         )
  RETURN GENERIQUE_WS_RESP;

 /******************************************************************************/
  FUNCTION CHECK_HEALTH
  RETURN GENERIQUE_WS_RESP;

 /******************************************************************************/
  FUNCTION ADD_SIN_PREV( idDemande_ext    IN NUMBER,
                        i_params       IN EXTR_Q_ADD_SIN_PREV,
                       Salaires        IN EXTR_TAB_SALAIRES,
                       DocSalaire      IN EXT_TAB_DOCUMENT,
                       Documents       IN EXTR_TAB_DOCSINPREV,--EXT_TAB_DOCUMENT,
                       Maintien        IN EXTR_TAB_MAINTIEN
                         ) RETURN EXTR_TAB_ADD_SIN_PREV;
  /******************************************************************************/
  FUNCTION ADD_EVENT( idDemande_ext    IN NUMBER,
                      i_params  IN EXTR_Q_ADD_EVENT,
                      documents IN EXT_TAB_DOCUMENT ) RETURN GENERIQUE_WS_RESP;

 /******************************************************************************/
 FUNCTION RAD_ADHESION ( idDemande_ext  IN NUMBER,
                        numcli          IN NUMBER,
                        numindiv        IN INDIVIDU.NUMINDIV%TYPE,
                        typeadhesion    IN VARCHAR2,
                        etat            IN NUMBER,
                        motif           IN NUMBER,
                        debut           IN DATE,
                        risque          IN NUMBER) RETURN GENERIQUE_WS_RESP;


END PK_WS_WEB_MAJ_FRONT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_WS_WEB_MAJ_FRONT as

/*********************************************GENERIQUE**************/
  FUNCTION ADD_NUMSS_GENERIQUE
                    ( numporte        IN NUMBER,
                      id_type         IN NUMBER,
                      numAdherent     IN NUMBER,
                      numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext    IN NUMBER,
                      infos             IN EXTR_ADD_NUMSS,
                      documents        IN EXT_TAB_DOCUMENT
                    )
  RETURN GENERIQUE_WS_RESP;
  /*********************************************************/
  FUNCTION ADD_RIB( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                    numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                    idDemande_ext IN NUMBER,
                    rib EXTR_ADD_RIB  ,
                    documents       IN EXT_TAB_DOCUMENT
  ) RETURN GENERIQUE_WS_RESP
  IS
    xml_file XMLTYPE;
    beneficiaires_xml XMLTYPE;
    o_response GENERIQUE_WS_RESP;
    v_id_flux FLUX.id_flux%TYPE;
    v_cod_err NUMBER;
    v_deb NUMBER;
    v_delai NUMBER;
  BEGIN

  SELECT XMLAGG(XMLELEMENT("benficiaire",XMLELEMENT("numindiv", numindiv),XMLELEMENT("typaddr", typaddr))) into beneficiaires_xml from table(rib.beneficiaires)   ;
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAdherent",numAdherent),XMLELEMENT( "numIndiv",numIndiv),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
    XMLELEMENT( "bic",rib.bic),XMLELEMENT( "bban",rib.bban),XMLELEMENT( "clefIban",rib.clefIban),XMLELEMENT("beneficiaires", beneficiaires_xml),XMLELEMENT("documents",documents)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
  -- Historisation du flux aller
  v_deb:=DBMS_UTILITY.GET_TIME;
  v_id_flux := pk_ws.insert_flux(p_id_type       => 55,
                                 p_id_flux_tiers => 0,
                                 p_doc_xml       => xml_file,
                                 p_cod_err       => v_cod_err,
                                 p_porte         => g_grpporte );

  o_response :=   PK_WS_WEB_MAJ_BACK.ADD_RIB(g_grpporte,55,numAdherent,numIndiv, idDemande_ext, rib.bic, rib.bban, rib.clefIban, rib.typeRib, rib.domiciliation, rib.nomTitulaire, rib.dateEffet, rib.beneficiaires,documents);
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => 56,
      p_id_flux =>v_id_flux,
      p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
      p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN o_response;

  EXCEPTION
     WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'PK_EDAAP.ADD_RIB',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(sqlerrm,1,132),
          I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(55,g_grpporte),'Erreur à la reception du flux');
  END ADD_RIB;

  /*********************************************************/


  FUNCTION CLOSE_RIB( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext IN NUMBER,
                      idRib IN NUMBER,
                      dateEffet     IN DATE
                     )
  RETURN GENERIQUE_WS_RESP
   IS
        xml_file XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAdherent",numAdherent),XMLELEMENT( "numIndiv",numIndiv),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
            XMLELEMENT( "idRib",idRib),XMLELEMENT( "dateEffet",dateEffet)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 63,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.CLOSE_RIB(g_grpporte,63,numAdherent,numIndiv, idDemande_ext, idRib, dateEffet);
        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 64,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_EDAAP.ADD_RIB',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(63,g_grpporte),'Erreur à la reception du flux');
    END CLOSE_RIB;


      /******************************************************************************/
      FUNCTION ADD_CONTACT( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                            numindiv IN INDIVIDU.NUMINDIV%TYPE,
                            idDemande_ext IN NUMBER,
                            contact IN VARCHAR2,
                            nature IN NUMBER,
                            type IN NUMBER,
                            dateEffet IN DATE
      ) RETURN GENERIQUE_WS_RESP
      IS
        xml_file XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN
            SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAdherent",numAdherent),XMLELEMENT( "numIndiv",numIndiv),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
                XMLELEMENT( "contact",contact),XMLELEMENT( "nature",nature),XMLELEMENT( "type",type),XMLELEMENT( "dateEffet",dateEffet)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
                INTO xml_file
                FROM dual;
           -- Historisation du flux aller
            v_deb:=DBMS_UTILITY.GET_TIME;
            v_id_flux := pk_ws.insert_flux(p_id_type       => 57,
                                                                         p_id_flux_tiers => 0,
                                                                         p_doc_xml       => xml_file,
                                                                         p_cod_err       => v_cod_err,
                                                                         p_porte         => g_grpporte );

            o_response :=   PK_WS_WEB_MAJ_BACK.ADD_CONTACT(g_grpporte,57,numAdherent,numIndiv, idDemande_ext, contact, nature, nvl(type,2), dateEffet);
            v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
            pk_ws.add_xml(p_id_type => 58,
                    p_id_flux =>v_id_flux,
                    p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                    p_cod_err => v_cod_err);
           pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		   RETURN o_response ;
      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_EDAAP.ADD_CONTACT',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(57,g_grpporte),'Erreur à la reception du flux');
      END ADD_CONTACT;
         /*********************************************************/
      FUNCTION ADD_ADRESSE( numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                            numindiv IN INDIVIDU.NUMINDIV%TYPE,
                            idDemande_ext IN NUMBER,
                            adresse IN EXTR_ADRESSE_TR,
                            dateEffet IN DATE
      ) RETURN GENERIQUE_WS_RESP
      IS
        xml_file XMLTYPE;
        v_cod_err NUMBER;
        v_id_flux FLUX.id_flux%TYPE;
        o_response GENERIQUE_WS_RESP;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAdherent",numAdherent),XMLELEMENT( "numIndiv",numIndiv),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
            XMLELEMENT( "ADRESSE1",adresse.ADRESSE1),XMLELEMENT( "ADRESSE2",adresse.ADRESSE2),XMLELEMENT( "ADRESSE3",adresse.ADRESSE3),
        XMLELEMENT( "VILLE",adresse.VILLE),XMLELEMENT( "CODPOS",adresse.CODPOS),XMLELEMENT( "PAYS",adresse.PAYS)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 59,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=  PK_WS_WEB_MAJ_BACK.ADD_ADRESSE(g_grpporte,59,numAdherent,numIndiv, idDemande_ext,adresse,dateEffet);
        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 60,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

	   pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

	   RETURN o_response;
      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_EDAAP.ADD_ADRESSE',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);

        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(59,g_grpporte),'Erreur à la reception du flux');
      END ADD_ADRESSE;


        /********************************************************/
    FUNCTION MAJ_INFO_PERSO(numAdherent   IN NUMBER,
                            numIndiv      IN NUMBER,
                            idDemande_ext IN NUMBER,
                            dateEffet     IN DATE,
                            infos         IN EXTR_MAJ_INFO_PERSO
                        )
    RETURN GENERIQUE_WS_RESP
      IS
         xml_file XMLTYPE;
        documents_xml XMLTYPE;
          v_cod_err NUMBER;
          v_id_flux FLUX.id_flux%TYPE;
          o_response GENERIQUE_WS_RESP;
          v_deb NUMBER;
          v_delai NUMBER;
        BEGIN

            SELECT XMLAGG(XMLELEMENT("IdDoc",IdDoc)) into documents_xml from table(infos.documents);
                SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "numIndiv",numIndiv), XMLELEMENT( "idDemande_ext",idDemande_ext) , XMLELEMENT( "dateEffet",dateEffet),
                                XMLELEMENT( "nom",infos.nom) ,XMLELEMENT( "prenom",infos.prenom) ,XMLELEMENT( "dateNaissance",infos.dateNaissance), XMLELEMENT( "regimeSS",infos.regimeSS),XMLELEMENT( "caisse",infos.caisse),
                            XMLELEMENT( "centre", infos.centre), XMLELEMENT( "rangnaiss" ,infos.rangnaiss),XMLELEMENT( "Infosocialetomodif" ,infos.Infosocialetomodif),  XMLELEMENT( "nomNaiss " , infos.nomNaiss)),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
           v_deb:=DBMS_UTILITY.GET_TIME;
           v_id_flux := pk_ws.insert_flux(p_id_type       => 61,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

           o_response :=  PK_WS_WEB_MAJ_BACK.MAJ_INFO_PERSO(g_grpporte,61,numAdherent, numIndiv, idDemande_ext, infos.nom,infos.nomNaiss, infos.prenom, dateEffet, infos.dateNaissance,infos.rangnaiss, infos.regimeSS, infos.caisse, infos.centre,infos.infosocialetomodif,infos.documents);
           v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
           pk_ws.add_xml(p_id_type => 62,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

		   pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		   RETURN o_response;
        EXCEPTION
           WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'PK_EDAAP.ADD_RIB',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);

        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(61,g_grpporte),'Erreur à la reception du flux');
      END MAJ_INFO_PERSO;



  /********************************************************/
  FUNCTION MAJ_CIRCUIT_INFO(numAdherent   IN NUMBER,
                            numIndiv      IN NUMBER,
                            idDemande_ext IN NUMBER,
                            typeCircuit   IN NUMBER,
                            ouverture     IN NUMBER
                          )
  RETURN GENERIQUE_WS_RESP IS
        xml_file XMLTYPE;
        v_cod_err NUMBER;
        v_id_flux FLUX.id_flux%TYPE;
        o_response GENERIQUE_WS_RESP;
        v_deb NUMBER;
        v_delai NUMBER;
    BEGIN

      SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "numIndiv",numIndiv), XMLELEMENT( "idDemande_ext",idDemande_ext) ,
                                XMLELEMENT( "typeCircuit",typeCircuit),XMLELEMENT( "ouverture",ouverture)),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
       INTO xml_file
       FROM dual;
           -- Historisation du flux aller

      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 73,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

      o_response :=  PK_WS_WEB_MAJ_BACK.MAJ_CIRCUIT_INFO(g_grpporte,73,numAdherent, numIndiv, idDemande_ext, typeCircuit,ouverture);
	  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

      pk_ws.add_xml(p_id_type => 74,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);
	 pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

            RETURN o_response;
        EXCEPTION
           WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'PK_EDAAP.ADD_RIB',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(73,g_grpporte),'Erreur à la reception du flux');
  END MAJ_CIRCUIT_INFO;
  /******************************************************************************/


  /******************************************************************************************DMNDE*************************************************************************************************/
  /******************************************************************************************DMNDE*************************************************************************************************/
  /******************************************************************************************DMNDE*************************************************************************************************/

  FUNCTION DMNDE_PEC_HOSPI (numAdherent   IN NUMBER,
                            numIndiv      IN NUMBER,
                            idDemande_ext IN NUMBER,
                            infos EXTR_DMNDE_PEC_HOSPI)
   RETURN GENERIQUE_WS_RESP IS
          xml_file XMLTYPE;
          v_cod_err NUMBER;
          v_id_flux FLUX.id_flux%TYPE;
          o_response GENERIQUE_WS_RESP;
          v_deb NUMBER;
          v_delai NUMBER;
        BEGIN

                SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "numIndiv",numIndiv), XMLELEMENT( "idDemande_ext",idDemande_ext) ,
                                XMLELEMENT( "natHospi",infos.natHospi),XMLELEMENT( "nomEtHospi",infos.nomEtHospi),XMLELEMENT( "NNI",infos.NNI),XMLELEMENT( "codPosEtHospi",infos.codPosEtHospi),XMLELEMENT( "dateHospi",infos.dateHospi), XMLELEMENT("villeetHospi",  infos.villeetHospi),
                            XMLELEMENT("telEtHospi", infos.telEtHospi), XMLELEMENT("faxEtHospi",infos.faxEtHospi),XMLELEMENT("adresseEtHospi", infos.adresseEtHospi),
                            XMLELEMENT("emailEtHospi",   infos.emailEtHospi )),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
      -- Historisation du flux aller
      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 71,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

      o_response :=  PK_WS_WEB_MAJ_BACK.DMNDE_PEC_HOSPI(g_grpporte,71,numAdherent, numIndiv, idDemande_ext, infos.natHospi, infos.nomEtHospi, infos.NNI, infos.codPosEtHospi,
                                                        infos.dateHospi, infos.villeetHospi,infos.telEtHospi,infos.faxEtHospi, infos.adresseEtHospi,infos.emailEtHospi);
      v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
      pk_ws.add_xml(p_id_type => 72,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);
      pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

	  RETURN o_response;
      EXCEPTION
           WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'PK_EDAAP.DMNDE_PEC_HOSPI',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(71,g_grpporte),'Erreur à la reception du flux');
   END DMNDE_PEC_HOSPI;




     /******************************************************************************/

  FUNCTION ADD_BENE(numAdherent      IN NUMBER,
                    idDemande_ext    IN NUMBER,
                    dateeffet        IN DATE,
                    infos            IN EXTR_ADD_BENE
                            )
  RETURN EXTR_R_ADD_BENEFICIAIRE IS
        xml_file XMLTYPE;
        xml_retour XMLTYPE;
        v_cod_err NUMBER;
        v_id_flux FLUX.id_flux%TYPE;
        o_response EXTR_R_ADD_BENEFICIAIRE;

        v_deb NUMBER;
        v_delai NUMBER;
        BEGIN

            SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext) ,
                            XMLELEMENT("typebeneficiaire",infos.typebeneficiaire), XMLELEMENT("nom",infos.nom),XMLELEMENT("prenom",infos.prenom),XMLELEMENT("datenaiss",infos.datenaiss),
                            XMLELEMENT("rangNais",infos.rangNais), XMLELEMENT("sexe",infos.sexe),XMLELEMENT("numss",infos.numss),XMLELEMENT("regime",infos.regime),XMLELEMENT("caisse",infos.caisse),XMLELEMENT("centre",infos.centre),
                            XMLELEMENT("numss2",infos.numss2), XMLELEMENT("regime2",infos.regime2),XMLELEMENT("caisse2",infos.caisse2),XMLELEMENT("centre2",infos.centre2),XMLELEMENT("dateeffet",dateeffet),XMLELEMENT("mutuelleExist",infos.mutuelleExist),
                            XMLELEMENT("documents",infos.documents)),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_file
        FROM dual;
      -- Historisation du flux aller
      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 75,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

      o_response :=  PK_WS_WEB_MAJ_BACK.ADD_BENEFICIAIRE( g_grpporte,
                                                          75,
                                                          numAdherent,
                                                          idDemande_ext,
                                                          infos.typebeneficiaire,
                                                          infos.nom,
                                                          infos.prenom,
                                                          infos.datenaiss,
                                                          infos.rangNais,
                                                          infos.sexe,
                                                          infos.numss,
                                                          infos.regime,
                                                          infos.caisse,
                                                          infos.centre,
                                                          infos.numss2,
                                                          infos.regime2,
                                                          infos.caisse2,
                                                          infos.centre2,
                                                          dateeffet,
                                                          infos.mutuelleExist,
                                                          infos.documents);

      select XMLROOT( XMLELEMENT ("response",XMLELEMENT("o_response",o_response) ),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_retour
        FROM dual;

      v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
      pk_ws.add_xml(p_id_type => 76,
          p_id_flux =>v_id_flux,
          p_doc_xml =>xml_retour,--  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
          p_cod_err => v_cod_err);

      pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

	  RETURN o_response;
      EXCEPTION
           WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'PK_EDAAP.ADD_BENEFICIAIRE',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
        RETURN  new EXTR_R_ADD_BENEFICIAIRE(
                              pk_ws_web_maj_back.GET_RESP_KO(numAdherent,null,idDemande_ext, pk_ws_web_maj_back.get_code_demande(75,g_grpporte),'Erreur à la reception du flux')
                              , null);
END ADD_BENE;


   /********************************************************************************************************************/
  FUNCTION ADD_NUMSS_STE (numAdherent     IN NUMBER,
                          numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                          idDemande_ext    IN NUMBER,
                          infos             IN EXTR_ADD_NUMSS,
                          documents        IN EXT_TAB_DOCUMENT  )


      RETURN GENERIQUE_WS_RESP IS
          xml_file XMLTYPE;
      v_cod_err NUMBER;
      v_id_flux FLUX.id_flux%TYPE;
      o_response GENERIQUE_WS_RESP;
      v_deb NUMBER;
      v_delai NUMBER;
      BEGIN

          SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                          XMLELEMENT("typeDemande",infos.typeDemande), XMLELEMENT("numss2",infos.numss2),  XMLELEMENT("regime",infos.regime), XMLELEMENT("caisse",infos.caisse), XMLELEMENT("centre",infos.centre),
                          XMLELEMENT("dateeffet",infos.dateeffet), XMLELEMENT( "Infosocialetomodif" ,infos.Infosocialetomodif),
                          XMLELEMENT("documents",documents)),
                          VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
      INTO xml_file
      FROM dual;
       -- Historisation du flux aller
      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 99,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );



    --- APPEL DE LA FONCTION GENERIQUE
   o_response:= ADD_NUMSS_generique ( g_grpporte,
                                      99,
                                      numAdherent,
                                      numIndiv,
                                      idDemande_ext ,
                                      infos,
                                      documents
                                    );

    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.add_xml(p_id_type => 100,
        p_id_flux =>v_id_flux,
        p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
        p_cod_err => v_cod_err);

   pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

   RETURN o_response;
   EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_EDAAP.ADD_NUMSS',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);


        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(77,g_grpporte),'Erreur à la reception du flux');

    END ADD_NUMSS_STE;
 /**************************************************************************************************************************/
   FUNCTION ADD_NUMSS ( numAdherent     IN NUMBER,
                        numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext    IN NUMBER,
                        infos             IN EXTR_ADD_NUMSS,
                        documents        IN EXT_TAB_DOCUMENT    )


      RETURN GENERIQUE_WS_RESP IS
          xml_file XMLTYPE;
      v_cod_err NUMBER;
      v_id_flux FLUX.id_flux%TYPE;
      o_response GENERIQUE_WS_RESP;
      v_deb NUMBER;
      v_delai NUMBER;
      BEGIN

          SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                          XMLELEMENT("typeDemande",infos.typeDemande), XMLELEMENT("numss2",infos.numss2),  XMLELEMENT("regime",infos.regime), XMLELEMENT("caisse",infos.caisse), XMLELEMENT("centre",infos.centre),
                          XMLELEMENT("dateeffet",infos.dateeffet), XMLELEMENT( "Infosocialetomodif" ,infos.Infosocialetomodif),
                          XMLELEMENT("documents",documents)),
                          VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
      INTO xml_file
      FROM dual;
       -- Historisation du flux aller
      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 77,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );



    --- APPEL DE LA FONCTION GENERIQUE
   o_response:= ADD_NUMSS_generique ( g_grpporte,
                                      77,
                                      numAdherent,
                                      numIndiv,
                                      idDemande_ext ,
                                      infos,
                                      documents
                                    );

    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.add_xml(p_id_type => 78,
        p_id_flux =>v_id_flux,
        p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
        p_cod_err => v_cod_err);

   pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

   RETURN o_response;
   EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_EDAAP.ADD_NUMSS',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);


        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(77,g_grpporte),'Erreur à la reception du flux');

    END ADD_NUMSS;


  FUNCTION ADD_NUMSS_GENERIQUE
                    ( numporte        IN NUMBER,
                      id_type         IN NUMBER,
                      numAdherent     IN NUMBER,
                      numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext    IN NUMBER,
                      infos             IN EXTR_ADD_NUMSS,
                      documents        IN EXT_TAB_DOCUMENT
                    )
  RETURN GENERIQUE_WS_RESP IS
      o_response GENERIQUE_WS_RESP;
      BEGIN

     o_response :=  PK_WS_WEB_MAJ_BACK.ADD_NUMSS( g_grpporte,
                                                  id_type,
                                                  numAdherent,
                                                  numIndiv,
                                                  idDemande_ext,
                                                  infos.typeDemande,
                                                  infos.numss2,
                                                  infos.dateeffet,
                                                  infos.regime,
                                                  infos.caisse,
                                                  infos.centre,
                                                  infos.infosocialetomodif,
                                                  documents);


     RETURN o_response;

    END ADD_NUMSS_generique;


  /********************************************************************************************************************/
  FUNCTION RAD_BENE ( numAdherent     IN NUMBER,
                      numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext   IN NUMBER,
                      motif           IN NUMBER,
                      dateeffet       IN DATE,
                      documents       IN EXT_TAB_DOCUMENT
                            )
  RETURN GENERIQUE_WS_RESP IS
    xml_file XMLTYPE;
    v_cod_err NUMBER;
    v_id_flux FLUX.id_flux%TYPE;
    o_response GENERIQUE_WS_RESP;
    v_deb NUMBER;
    v_delai NUMBER;
    BEGIN

        SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("Motif",Motif), XMLELEMENT("dateeffet",dateeffet), XMLELEMENT("Documents",documents)
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 79,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.RAD_BENE(g_grpporte,
                                              79,
                                              numAdherent,
                                              numIndiv,
                                              idDemande_ext,
                                              motif,
                                              dateeffet,
                                              documents
                                                      );
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => 80,
                p_id_flux => v_id_flux,
                p_doc_xml => PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.RAD_BENEFICIAIRE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);

        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(79,g_grpporte),'Erreur à la reception du flux');

  END RAD_BENE;
 /****************************************************************************/
  FUNCTION ADD_DEVIS (  numAdherent     IN NUMBER,
                        numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext   IN NUMBER,
                        mutuelleExist   IN NUMBER,
                        natureDossier   IN NUMBER,
                        documents       IN EXT_TAB_DOCUMENT

  )
  RETURN GENERIQUE_WS_RESP IS

    xml_file XMLTYPE;
    v_cod_err NUMBER;
    v_id_flux FLUX.id_flux%TYPE;
    o_response GENERIQUE_WS_RESP;
    v_deb NUMBER;
    v_delai NUMBER;
    BEGIN

        SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("mutuelleExist",mutuelleExist), XMLELEMENT("natureDossier",natureDossier), XMLELEMENT("Documents",documents)
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 81,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.ADD_DEVIS( g_grpporte,
                                                81,
                                                numAdherent,
                                                numIndiv,
                                                idDemande_ext,
                                                mutuelleExist,
                                                natureDossier,
                                                documents
                                                      );
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => 82,
                p_id_flux => v_id_flux,
                p_doc_xml => PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.ADD_DEVIS',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);

        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(81,g_grpporte),'Erreur à la reception du flux');
    END ADD_DEVIS;




   /***************************************************************************/
   FUNCTION ADD_REMB (  numAdherent     IN NUMBER,
                        numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext   IN NUMBER,
                        mutuelleExist   IN NUMBER,
                        natureDossier   IN NUMBER,
                        detailsoins     IN NUMBER,
                        documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP IS
    xml_file XMLTYPE;
    v_cod_err NUMBER;
    v_id_flux FLUX.id_flux%TYPE;
    o_response GENERIQUE_WS_RESP;
    v_deb NUMBER;
    v_delai NUMBER;
    BEGIN

        SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("mutuelleExist",mutuelleExist), XMLELEMENT("natureDossier",natureDossier), XMLELEMENT("detailsoins",detailsoins)/*, XMLELEMENT("Documents",documents) */
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 83,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.ADD_REMB(g_grpporte,
                                              83,
                                              numAdherent,
                                              numIndiv,
                                              idDemande_ext,
                                              mutuelleExist,
                                              natureDossier,
                                              detailsoins,
                                              documents
                                                      );
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => 84,
                p_id_flux => v_id_flux,
                p_doc_xml => PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  RETURN o_response;

  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP_FRONT.ADD_REMB',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);


        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(83,g_grpporte),'Erreur à la reception du flux');
  END ADD_REMB;
  /*****************************************************************************/

 FUNCTION DEPOT_PIECE (  numAdherent     IN NUMBER,
                            numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                            idDemande_ext   IN NUMBER,
                            infos           IN EXTR_DEPOT_PIECE,
                            documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP IS
      xml_file XMLTYPE;
    v_cod_err NUMBER;
    v_id_flux FLUX.id_flux%TYPE;
    o_response GENERIQUE_WS_RESP;
    v_deb NUMBER;
    v_delai NUMBER;
    BEGIN

        SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("typePiece",infos.typePiece), XMLELEMENT("contexte",infos.contexte), XMLELEMENT("entite",infos.entite),XMLELEMENT("idpiece",infos.idpiece),XMLELEMENT("datedebut",infos.datedebut),XMLELEMENT("datefin",infos.datefin), XMLELEMENT("Documents",documents)
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 85,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.DEPOT_PIECE( g_grpporte,
                                                  85,
                                                  numAdherent,
                                                  numIndiv,
                                                  idDemande_ext,
                                                  infos.typePiece,
                                                  infos.contexte,
                                                  infos.entite,
                                                  infos.idpiece,
                                                  infos.datedebut,
                                                  infos.datefin,
                                                  documents
                                                      );
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => 86,
                p_id_flux => v_id_flux,
                p_doc_xml => PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.ADD_REMB',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(85,g_grpporte),'Erreur à la reception du flux');

END DEPOT_PIECE;

 /*******************************************************************************/

FUNCTION SUBSCRIBE (  numAdherent    IN NUMBER,
                      idDemande_ext  IN NUMBER,
                      TAB_CONTRAT    IN EXTR_TAB_BENE_PROSPECT,
                      dateeffet      IN DATE ,
                      MODE_PAIE      IN NUMBER,
                      PRIX_TOT       IN NUMBER,
                      NATURE         IN NUMBER, --1 option, 2 base, 3 option via BIA
                      idadhesion_base IN NUMBER,
                      documents      IN EXT_TAB_DOCUMENT
  )
  RETURN EXTR_R_SUBCRIBE
  IS
    xml_file                   XMLTYPE;
    xml_file_r                 XMLTYPE;
    v_cod_err                  NUMBER;
    v_id_flux                  FLUX.id_flux%TYPE;
    o_response                 EXTR_R_SUBCRIBE;
    v_deb                      NUMBER;
    v_delai                    NUMBER;
    v_id_type                    NUMBER;
  BEGIN

    SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent), XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("Documents",documents), XMLELEMENT("TAB_CONTRAT",TAB_CONTRAT), XMLELEMENT("date_effet",dateeffet)
                        ,XMLELEMENT("MODE_PAIE",MODE_PAIE) ,XMLELEMENT("PRIX_TOT",PRIX_TOT)
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;


    select decode(nature,
                  1,89,
                  2,111,
                  3,117,
                  89
                 )
    INTO v_id_type
    FROM DUAL;

     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => v_id_type,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );


   o_response :=  PK_WS_WEB_MAJ_BACK.SUBSCRIBE( g_grpporte,
                                                v_id_type,
                                                numAdherent,
                                                idDemande_ext,
                                                TAB_CONTRAT,
                                                dateeffet,
                                                MODE_PAIE,
                                                PRIX_TOT,
                                                NATURE, -- option
                                                idadhesion_base,
                                                documents

                                                      );
     SELECT XMLROOT( XMLELEMENT ("question",o_response ),
                      VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
  INTO xml_file_r
  FROM dual;
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.add_xml(p_id_type => v_id_type+1,
                p_id_flux => v_id_flux,
                p_doc_xml => xml_file_r,
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.SUBSCRIBE',
            I_session  => SID,
            I_niv_msg  => 1,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
        RETURN new EXTR_R_SUBCRIBE(pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numAdherent,idDemande_ext, pk_ws_web_maj_back.get_code_demande(89,g_grpporte),'Erreur à la reception du flux'),null);

END SUBSCRIBE;
  /******************************************************************************/
FUNCTION ADD_DOS_CALC (    numAdherent   IN NUMBER
                          ,numindiv       IN NUMBER
                          ,idDemande_ext IN NUMBER
                          ,typeDossier   IN NUMBER
                          ,natureDossier IN NUMBER
                          ,typeFrais     IN NUMBER
                          ,documents     IN EXT_TAB_DOCUMENT
                          ,tab_act       IN EXTR_TAB_ACTS_CALC

                            )
  RETURN EXTR_R_ADD_DOS_CALC
    IS
    xml_file                   XMLTYPE;
    xml_file_r                 XMLTYPE;
    v_cod_err                  NUMBER;
    v_id_flux                  FLUX.id_flux%TYPE;
    o_response                 EXTR_R_ADD_DOS_CALC;
    v_deb                      NUMBER;
    v_delai                    NUMBER;
  BEGIN

    SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numAdherent",numAdherent),
                        XMLELEMENT( "idDemande_ext",idDemande_ext),
                        XMLELEMENT("Documents",documents), XMLELEMENT("tab_act",tab_act),
                        XMLELEMENT("typeDossier",typeDossier) ,
                        XMLELEMENT("natureDossier",natureDossier),
                        XMLELEMENT("typeFrais",typeFrais)
                        ),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;


     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 97,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.ADD_DOS_CALC(  g_grpporte,
                                                    97,
                                                    numAdherent,
                                                    numindiv,
                                                    idDemande_ext,
                                                    typeDossier,
                                                    natureDossier,
                                                    typeFrais,
                                                    documents,
                                                    tab_act
                                                    );
   SELECT XMLROOT( XMLELEMENT ("question",o_response ),
                      VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
  INTO xml_file_r
  FROM dual;
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;


  pk_ws.add_xml(p_id_type => 98,
                p_id_flux => v_id_flux,
                p_doc_xml => xml_file_r ,--PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.ADD_DOS_CALC',
            I_session  => SID,
            I_niv_msg  => 1,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
        RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(numAdherent,numAdherent,idDemande_ext, pk_ws_web_maj_back.get_code_demande(97,g_grpporte),'Erreur à la reception du flux')
                                      , null);

END ADD_DOS_CALC;

  /******************************************************************************/

  FUNCTION ADD_INDIVIDU(  numcli           IN NUMBER,
                          idDemande_ext    IN NUMBER,
                          infos            IN EXTR_ADD_INDIVIDU
                    )
  RETURN EXTR_R_ADD_BENEFICIAIRE
  IS

        xml_file XMLTYPE;
        xml_retour XMLTYPE;
        v_cod_err NUMBER;
        v_id_flux FLUX.id_flux%TYPE;
        o_response EXTR_R_ADD_BENEFICIAIRE;

        v_deb NUMBER;
        v_delai NUMBER;
        BEGIN

            SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "numcli",numcli), XMLELEMENT( "idDemande_ext",idDemande_ext) ,
                            XMLELEMENT("infos",infos)),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_file
        FROM dual;
      -- Historisation du flux aller
      v_deb:=DBMS_UTILITY.GET_TIME;
      v_id_flux := pk_ws.insert_flux(p_id_type       => 103,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

      o_response :=  PK_WS_WEB_MAJ_BACK.ADD_INDIVIDU(     g_grpporte,
                                                          103,
                                                          idDemande_ext,
                                                          numcli,
                                                          infos.nom,
                                                          infos.prenom,
                                                          infos.datenaiss,
                                                          infos.rangNais,
                                                          infos.sexe,
                                                          infos.numss,
                                                          infos.regime,
                                                          infos.caisse,
                                                          infos.centre

                                                         );

      select XMLROOT( XMLELEMENT ("response",XMLELEMENT("o_response",o_response) ),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_retour
        FROM dual;

      v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
      pk_ws.add_xml(p_id_type => 104,
          p_id_flux =>v_id_flux,
          p_doc_xml =>xml_retour,--  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
          p_cod_err => v_cod_err);

      pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

	  RETURN o_response;
      EXCEPTION
           WHEN OTHERS THEN
                PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'PK_EDAAP.ADD_BENEFICIAIRE',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => substr(sqlerrm,1,132),
                I_idligne  => 2);
        RETURN  new EXTR_R_ADD_BENEFICIAIRE(
                              pk_ws_web_maj_back.GET_RESP_KO(numcli,null,idDemande_ext, pk_ws_web_maj_back.get_code_demande(103,g_grpporte),'Erreur à la reception du flux')
                              , null);

  END ADD_INDIVIDU;

  /****************************************************************************/

FUNCTION VALID_SUBCRIBE( numcli           IN NUMBER,
                         idDemande_ext    IN NUMBER,
                         infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP
  IS
  xml_file XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numcli",numcli),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
            XMLELEMENT( "infos",infos)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 105,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.VALID_SUBCRIBE_RH( g_grpporte,
                                                              105,
                                                             numcli        ,
                                                             idDemande_ext ,
                                                             infos
                                                            );
        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 106,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'VALID_SUBCRIBE',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numcli,infos.numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(105,g_grpporte),'Erreur à la reception du flux');
  END VALID_SUBCRIBE;

  /******************************************************************************/
  FUNCTION REJECT_SUBCRIBE(  numcli           IN NUMBER,
                             idDemande_ext    IN NUMBER,
                             infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP
   IS
  xml_file XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numcli",numcli),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
            XMLELEMENT( "infos",infos)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 107,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.REJECT_SUBCRIBE_RH( g_grpporte,
                                                              107,
                                                             numcli,
                                                             idDemande_ext,
                                                             infos
                                                            );
        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 108,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'REJECT_SUBCRIBE',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numcli,infos.numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(107,g_grpporte),'Erreur à la reception du flux');
  END REJECT_SUBCRIBE;

 /******************************************************************************/
  FUNCTION MAJ_SUBSCRIBE(  numcli           IN NUMBER,
                           idDemande_ext    IN NUMBER,
                           dateeffet        IN DATE,
                           infos            IN EXTR_QUALIF_SUBRIBE
                         )
  RETURN GENERIQUE_WS_RESP
   is xml_file XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numcli",numcli),XMLELEMENT( "idDemande_ext",idDemande_ext) ,
            XMLELEMENT( "infos",infos), XMLELEMENT( "dateeffet",dateeffet)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 109,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.MAJ_SUBSCRIBE_RH(   g_grpporte,
                                                               109,
                                                               numcli,
                                                               idDemande_ext,
                                                               dateeffet,
                                                               infos
                                                            );
        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 110,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'MAJ_SUBCRIBE',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(numcli,infos.numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(109,g_grpporte),'Erreur à la reception du flux');
  END MAJ_SUBSCRIBE;

  /******************************************************************************/
  FUNCTION CHECK_HEALTH RETURN GENERIQUE_WS_RESP
  IS
  BEGIN

      RETURN  PK_WS_WEB_MAJ_BACK.CHECK_HEALTH;

  END CHECK_HEALTH;

  /****************************************************************************/
  FUNCTION ADD_SIN_PREV( idDemande_ext    IN NUMBER,
                        i_params       IN EXTR_Q_ADD_SIN_PREV,
                       Salaires        IN EXTR_TAB_SALAIRES,
                       DocSalaire      IN EXT_TAB_DOCUMENT,
                       Documents       IN EXTR_TAB_DOCSINPREV,--EXT_TAB_DOCUMENT,
                       Maintien        IN EXTR_TAB_MAINTIEN
                         ) RETURN EXTR_TAB_ADD_SIN_PREV
  IS
       xml_file XMLTYPE;
       xml_retour XMLTYPE;
        o_response EXTR_TAB_ADD_SIN_PREV;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "i_params",i_params),XMLELEMENT( "Salaires",Salaires)
                                        ,XMLELEMENT( "DocSalaire",DocSalaire),XMLELEMENT( "Documents",Documents),XMLELEMENT( "Maintien",Maintien)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 131,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.ADD_SIN_PREV(g_grpporte,
                                                       131,
                                                       idDemande_ext,
                                                       i_params,
                                                       Salaires,
                                                       DocSalaire,
                                                       Documents ,
                                                       Maintien ) ;

        select XMLROOT( XMLELEMENT ("response",XMLELEMENT("o_response",o_response)),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_retour
        FROM dual;

        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 132,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  xml_retour,--PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'ADD_SIN_PREV',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN o_response;--pk_ws_web_maj_back.GET_RESP_KO(Numcli,Numindiv,null, pk_ws_web_maj_back.get_code_demande(131,g_grpporte),'Erreur à la reception du flux');
  END ADD_SIN_PREV;

  /****************************************************************************/
  FUNCTION ADD_EVENT( idDemande_ext    IN NUMBER,
                      i_params  IN EXTR_Q_ADD_EVENT,
                      documents IN EXT_TAB_DOCUMENT ) RETURN GENERIQUE_WS_RESP
  IS
        xml_file XMLTYPE;
        xml_retour XMLTYPE;
        o_response GENERIQUE_WS_RESP;
        v_id_flux FLUX.id_flux%TYPE;
        v_cod_err NUMBER;
        v_deb NUMBER;
        v_delai NUMBER;
      BEGIN

        SELECT XMLROOT( XMLELEMENT ("AddEvent",XMLELEMENT( "i_params",i_params),XMLELEMENT( "documents",documents)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
            INTO xml_file
            FROM dual;
           -- Historisation du flux aller
        v_deb:=DBMS_UTILITY.GET_TIME;
        v_id_flux := pk_ws.insert_flux(p_id_type       => 133,
                                     p_id_flux_tiers => 0,
                                     p_doc_xml       => xml_file,
                                     p_cod_err       => v_cod_err,
                                     p_porte         => g_grpporte );

        o_response :=   PK_WS_WEB_MAJ_BACK.ADD_EVENT(g_grpporte,
                                                     133,
                                                     idDemande_ext,
                                                     i_params,
                                                     documents
                                                      );

        select XMLROOT( XMLELEMENT ("response",XMLELEMENT("o_response",o_response) ),
                            VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
        INTO xml_retour
        FROM dual;

        v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
        pk_ws.add_xml(p_id_type => 134,
                p_id_flux =>v_id_flux,
                p_doc_xml =>  xml_retour,--PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

        pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

		RETURN o_response;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'ADD_EVENT',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
        RETURN pk_ws_web_maj_back.GET_RESP_KO(null,i_params.numindiv,null, pk_ws_web_maj_back.get_code_demande(133,g_grpporte),'Erreur à la reception du flux');

  END ADD_EVENT;

  /*-------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  RAD_ADHESION                                              */
/* Type         :  Public                                                    */
/* Description  :  permet de radier ou suspendre des adhésions santé et
                                /ou prévoyance d’un assuré                   */
/* Auteur       :  RKO                                                       */
/* Date         :  17/08/2020                                                */
/* Commentaire  :  Projet                                                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

  FUNCTION RAD_ADHESION ( idDemande_ext   IN NUMBER,
                        numcli     IN NUMBER,
                        numindiv        IN INDIVIDU.NUMINDIV%TYPE,
                        typeadhesion    IN VARCHAR2,
                        etat            IN NUMBER,
                        motif           IN NUMBER,
                        debut           IN DATE,
                        risque          IN NUMBER
                            )
  RETURN GENERIQUE_WS_RESP IS
    xml_file XMLTYPE;
    v_cod_err NUMBER;
    v_id_flux FLUX.id_flux%TYPE;
    o_response GENERIQUE_WS_RESP;
    v_deb NUMBER;
    v_delai NUMBER;
    BEGIN

        SELECT XMLROOT( XMLELEMENT ("question", XMLELEMENT( "idDemande_ext",idDemande_ext), XMLELEMENT( "numcli",numcli),
                        XMLELEMENT("numindiv",numindiv), XMLELEMENT("typeadhesion",typeadhesion), XMLELEMENT("etat",etat),XMLELEMENT("motif",motif),XMLELEMENT("debut",debut)
                        ,XMLELEMENT("risque",risque)),
                        VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
    FROM dual;
     -- Historisation du flux aller
    v_deb:=DBMS_UTILITY.GET_TIME;
    v_id_flux := pk_ws.insert_flux(p_id_type       => 137,
                                   p_id_flux_tiers => 0,
                                   p_doc_xml       => xml_file,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

   o_response :=  PK_WS_WEB_MAJ_BACK.RAD_ADHESION(g_grpporte,
                                              137,
                                              idDemande_ext,
                                              numcli,
                                              numindiv,
                                              typeadhesion,
                                              etat,
                                              motif,
                                              debut,
                                              risque
                                                      );
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

  pk_ws.add_xml(p_id_type => 138,
                p_id_flux => v_id_flux,
                p_doc_xml => PK_WS_WEB_MAJ_BACK.RESPONSE_TO_XML(o_response),
                p_cod_err => v_cod_err);

  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN o_response;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_EDAAP.RAD_ADHESION',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);

        RETURN pk_ws_web_maj_back.GET_RESP_KO(numindiv,numindiv,idDemande_ext, pk_ws_web_maj_back.get_code_demande(79,g_grpporte),'Erreur à la reception du flux');

  END RAD_ADHESION;


END PK_WS_WEB_MAJ_FRONT;
/
