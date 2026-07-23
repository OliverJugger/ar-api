package com.bdl.epbs_fund_api.services.audit;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class RevisionDTO<T> {
    private static final long serialVersionUID = 1L;

    private RevisionMetadataDTO metadata;

    private T entity;
}

