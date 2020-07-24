package com.app.workit.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Transaction {
    @SerializedName("payment_option")
    @Expose
    private String paymentOption;
    @SerializedName("user_id")
    @Expose
    private String userId;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("amount")
    @Expose
    private String amount;
    @SerializedName("commission")
    @Expose
    private Object commission;
    @SerializedName("user_image")
    @Expose
    private String userImage;
    @SerializedName("transaction_for")
    @Expose
    private String transactionFor;
    @SerializedName("opposite_user")
    @Expose
    private Object oppositeUser;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("transaction_type")
    @Expose
    private String transactionType;
    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("user_name")
    @Expose
    private String userName;
    @SerializedName("job_id")
    @Expose
    private Object jobId;
    @SerializedName("transaction_id")
    @Expose
    private String transactionId;

    public String getPaymentOption() {
        return paymentOption;
    }

    public void setPaymentOption(String paymentOption) {
        this.paymentOption = paymentOption;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public Object getCommission() {
        return commission;
    }

    public void setCommission(Object commission) {
        this.commission = commission;
    }

    public String getUserImage() {
        return userImage;
    }

    public void setUserImage(String userImage) {
        this.userImage = userImage;
    }

    public String getTransactionFor() {
        return transactionFor;
    }

    public void setTransactionFor(String transactionFor) {
        this.transactionFor = transactionFor;
    }

    public Object getOppositeUser() {
        return oppositeUser;
    }

    public void setOppositeUser(Object oppositeUser) {
        this.oppositeUser = oppositeUser;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Object getJobId() {
        return jobId;
    }

    public void setJobId(Object jobId) {
        this.jobId = jobId;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }
}
