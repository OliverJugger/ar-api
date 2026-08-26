package com.arthus.entitys.converters;

import com.arthus.entitys.enums.ProfilUtilisateurEnum;

import jakarta.persistence.Converter;

@Converter
public class ProfilUtilisateurEnumConverter extends CodeLibelleTexteConverter<ProfilUtilisateurEnum> {

    public ProfilUtilisateurEnumConverter() {
        super(ProfilUtilisateurEnum::fromCode);
    }
}