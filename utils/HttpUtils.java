package com.bdl.epbs_fund_api.utils;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;

public class HttpUtils {

    public static final String X_TOTAL_COUNT = "X-Total-Count";
    public static final String X_COUNT = "X-Count";
    public static final String X_NEXT_START = "X-Next-Start";
    public static final String X_NEXT_LIMIT = "X-Next-Limit";

    private HttpUtils() {}

    public static <T> ResponseEntity<List<T>> getResponseEntityFromPage(Page<T> page) {
        HttpHeaders respHeaders = new HttpHeaders();
        respHeaders.add(X_TOTAL_COUNT, Long.toString(page.getTotalElements()));
        respHeaders.add(X_COUNT, Integer.toString(page.getNumberOfElements()));
        if (page.hasNext()) {
            respHeaders.add(X_NEXT_START, Integer.toString(page.nextPageable().getPageNumber()));
            respHeaders.add(X_NEXT_LIMIT, Integer.toString(page.nextPageable().getPageSize()));
        }

        return ResponseEntity.ok()
                .headers(respHeaders)
                .body(page.getContent());
    }
}
