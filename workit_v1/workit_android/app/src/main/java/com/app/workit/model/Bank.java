package com.app.workit.model;

import androidx.annotation.NonNull;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Bank {
    public String bankName;
    public int id;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("RUT")
    @Expose
    private String rUT;
    @SerializedName("bank")
    @Expose
    private String bank;
    @SerializedName("user_name")
    @Expose
    private String userName;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("account_number")
    @Expose
    private String accountNumber;
    @SerializedName("user_id")
    @Expose
    private String userId;
    @SerializedName("full_name")
    @Expose
    private String fullName;
    @SerializedName("account_type")
    @Expose
    private String accountType;
    @SerializedName("bank_detail_id")
    @Expose
    private String bankDetailId;

    public Bank(String bankName, int id) {
        this.bankName = bankName;
        this.id = id;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @NonNull
    @Override
    public String toString() {
        return bankName;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getrUT() {
        return rUT;
    }

    public void setrUT(String rUT) {
        this.rUT = rUT;
    }

    public String getBank() {
        return bank;
    }

    public void setBank(String bank) {
        this.bank = bank;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getBankDetailId() {
        return bankDetailId;
    }

    public void setBankDetailId(String bankDetailId) {
        this.bankDetailId = bankDetailId;
    }
}
