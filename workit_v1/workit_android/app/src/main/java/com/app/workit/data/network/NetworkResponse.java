package com.app.workit.data.network;

public class NetworkResponse<T> {
    public enum Status {SUCCESS, LOADING, ERROR}


    public Status status;
    public String message;
    public T response;

    public NetworkResponse(Status status, String message, T response) {
        this.status = status;
        this.message = message;
        this.response = response;
    }

    public static <T> NetworkResponse<T> loading() {
        return new NetworkResponse<>(Status.LOADING, null, null);
    }

    public static <T> NetworkResponse<T> success(T data, String message) {
        return new NetworkResponse<>(Status.SUCCESS, message, data);
    }

    public static <T> NetworkResponse<T> success(T data) {
        return new NetworkResponse<>(Status.SUCCESS, null, data);
    }

    public static <T> NetworkResponse<T> success(String message) {
        return new NetworkResponse<>(Status.SUCCESS, message, null);
    }

    public static <T> NetworkResponse<T> error(String error) {
        return new NetworkResponse<>(Status.ERROR, error, null);
    }
}
