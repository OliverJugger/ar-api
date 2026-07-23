package com.bdl.epbs_fund_api.utils;

import com.bdl.epbs_fund_api.constants.Constants;
import org.springframework.util.ReflectionUtils;

import java.lang.reflect.Field;

public class ValidationUtils {

    private ValidationUtils() {

    }

    public static void validateIntlIdElement(String intlIdElement) {
        final ReflectionUtils.FieldFilter filterByElementIntlId = field -> field.getName().startsWith("INTL_ID_ELEM_") && !field.getName().equals("INTL_ID_ELEM_NA");
        Field field = org.springframework.data.util.ReflectionUtils.findField(Constants.class, filterByElementIntlId);

        if (field == null)
            throw new IllegalArgumentException(String.format("Unknown or invalid entity type argument: %s", intlIdElement));
    }

    public static void validateAccessProfile(String profile) {
        final ReflectionUtils.FieldFilter filterByEpbsProfile = field -> field.getName().startsWith("INTL_ID_EPBS_PROFILE");
        Field field = org.springframework.data.util.ReflectionUtils.findField(Constants.class, filterByEpbsProfile);

        if (field == null)
            throw new IllegalArgumentException(String.format("Unknown or invalid access profile argument: %s", profile));
    }
}
