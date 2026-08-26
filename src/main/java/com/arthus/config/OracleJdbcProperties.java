package com.arthus.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.boot.context.properties.ConfigurationProperties;

import lombok.Getter;
import lombok.Setter;

@Configuration
@ConfigurationProperties(prefix= "oracle.jdbc")
@Getter
@Setter
public class OracleJdbcProperties {
    private String urlPrefix;
    private String host;
    private String port;
    private String service;
}
