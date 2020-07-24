package com.app.workit.data.network;

import java.util.List;

public class NetworkResponseList<T> {
    public enum Status {SUCCESS, LOADING, ERROR}


    public Status status;
    public String message;
    public List<T> response;

    public NetworkResponseList(Status status, String message, List<T> response) {
        this.status = status;
        this.message = message;
        this.response = response;
    }

    public static <T> NetworkResponseList<T> loading() {
        return new NetworkResponseList<>(Status.LOADING, null, null);
    }

    public static <T> NetworkResponseList<T> success(List<T> data, String message) {
        return new NetworkResponseList<>(Status.SUCCESS, message, data);
    }

    public static <T> NetworkResponseList<T> success(List<T> data) {
        return new NetworkResponseList<>(Status.SUCCESS, null, data);
    }

    public static <T> NetworkResponseList<T> error(String error) {
        return new NetworkResponseList<>(Status.ERROR, error, null);
    }
}



