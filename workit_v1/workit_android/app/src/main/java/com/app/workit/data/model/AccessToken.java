package com.app.workit.data.model;

public class AccessToken {
    private String accessToken;
    private String tokenType;

    public AccessToken(String tokenType, String accessToken) {
        this.tokenType = tokenType;
        this.accessToken = accessToken;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public String getTokenType() {
        // OAuth requires uppercase Authorization HTTP header value for token type
        if (!Character.isUpperCase(tokenType.charAt(0))) {
            tokenType =
                    Character.toString(tokenType.charAt(0)).toUpperCase() + tokenType.substring(1);
        }
        return tokenType;
    }
}
