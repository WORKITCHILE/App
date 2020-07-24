package com.app.workit.data.network;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class StandardResponse<T> {
    @SerializedName("status")
    @Expose
    private String status;

    @SerializedName("data")
    @Expose
    private T response;

    @SerializedName("error")
    @Expose
    private String error;
    @SerializedName("errors")
    @Expose
    private String errors;
    @SerializedName("message")
    @Expose
    private String message;


    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public T getResponse() {
        return response;
    }

    public void setResponse(T response) {
        this.response = response;
    }

    public String getMessage() {
        return message == null ? error == null ? errors : error : message;
    }
}
