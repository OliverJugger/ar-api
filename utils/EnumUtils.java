package com.bdl.epbs_fund_api.utils;

import com.bdl.utils.exceptions.ResourceNotFoundException;

import java.lang.reflect.Method;
import java.util.Optional;

import static com.bdl.epbs_fund_api.constants.Constants.ENTITY_NOT_FOUND;

public class EnumUtils {

    private EnumUtils() {
    }

    @SuppressWarnings("unchecked")
    public static <E extends Enum<E>> E mapEnumFromString(String intlId, Class<E> enumType) {
        if (intlId == null) {
            return null;
        }
        try {
            Method fromValueMethod = enumType.getMethod("fromValue", String.class);
            return (E) fromValueMethod.invoke(null, intlId);
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Failed to map intlId '" + intlId + "' to enum " + enumType.getSimpleName(), e);
        }
    }

    public static <T> T fetchEntityByIntlId(String intlId, java.util.function.Function<String, Optional<T>> fetcher, String entityName) {
        if (intlId == null) return null;
        return fetcher.apply(intlId)
                .orElseThrow(() -> new ResourceNotFoundException(String.format(ENTITY_NOT_FOUND, entityName, intlId)));
    }
}
