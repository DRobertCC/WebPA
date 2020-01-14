package com.codecool.web.model;

public enum Role {
    REGULAR("regular"),
    GUEST("guest"),
    ADMIN("admin");

    private final String value;

    private Role(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
