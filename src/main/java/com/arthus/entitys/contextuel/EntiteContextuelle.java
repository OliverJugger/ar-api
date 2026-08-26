package com.arthus.entitys.contextuel;

import com.arthus.entitys.enums.ContexteEnum;

/*
 * Contrat commun aux tables "generiques" du legacy : CORRESPONDANT, PIECES et
 * RAPPEL. Elles ne portent pas de FK vers l'objet metier concerne, mais un couple
 * (CONTEXTE, ENTITE) qui designe indifferemment un sinistre, un contrat, une
 * adhesion, un beneficiaire...
 *
 * Consequence directe : ces entites ne doivent JAMAIS etre la cible d'une
 * association JPA depuis SinistrePrevoyance, ContratRef ou AdhesionContrat.
 *   - le lien est polymorphe : une association le figerait sur un seul contexte ;
 *   - les types divergent (SNTR_PREV.NOSIN est un VARCHAR2, ENTITE un NUMBER) ;
 *   - aucune FK n'existe en base, donc rien ne garantit l'integrite.
 * L'acces passe par les services de com.arthus.services.contextuel, qui savent
 * construire la CleContexte et charger par lot.
 *
 * Cette interface est la pour que le compilateur le rappelle : une entite qui
 * l'implemente n'est pas un agregat comme les autres.
 */
public interface EntiteContextuelle {

    ContexteEnum getContexte();

    Long getEntite();

    default CleContexte getCle() {
        return new CleContexte(getContexte(), getEntite());
    }
}
