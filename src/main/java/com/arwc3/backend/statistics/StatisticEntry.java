package com.arwc3.backend.statistics;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "STATISTIC_ENTRY", uniqueConstraints = @UniqueConstraint(columnNames = {"STAT_GROUP", "NAME"}))
public class StatisticEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "STAT_GROUP", nullable = false, length = 20)
    private StatGroup statGroup;

    @Column(name = "NAME", nullable = false, length = 200)
    private String name;

    @Column(name = "VALUE", nullable = false)
    private Double value;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public StatGroup getStatGroup() {
        return statGroup;
    }

    public void setStatGroup(StatGroup statGroup) {
        this.statGroup = statGroup;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }
}
