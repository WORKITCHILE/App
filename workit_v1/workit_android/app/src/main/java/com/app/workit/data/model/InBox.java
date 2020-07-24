package com.app.workit.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class InBox {

    @SerializedName("job_id")
    @Expose
    private String jobId;
    @SerializedName("sender")
    @Expose
    private String sender;
    @SerializedName("sender_name")
    @Expose
    private String senderName;
    @SerializedName("last_message")
    @Expose
    private String lastMessage;
    @SerializedName("receiver_type")
    @Expose
    private String receiverType;
    @SerializedName("receiver")
    @Expose
    private String receiver;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("receiver_name")
    @Expose
    private String receiverName;
    @SerializedName("sender_type")
    @Expose
    private String senderType;
    @SerializedName("sender_image")
    @Expose
    private String senderImage;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("last_message_by")
    @Expose
    private String lastMessageBy;
    @SerializedName("receiver_image")
    @Expose
    private String receiverImage;

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public String getReceiverType() {
        return receiverType;
    }

    public void setReceiverType(String receiverType) {
        this.receiverType = receiverType;
    }

    public String getReceiver() {
        return receiver;
    }

    public void setReceiver(String receiver) {
        this.receiver = receiver;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getSenderType() {
        return senderType;
    }

    public void setSenderType(String senderType) {
        this.senderType = senderType;
    }

    public String getSenderImage() {
        return senderImage;
    }

    public void setSenderImage(String senderImage) {
        this.senderImage = senderImage;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getLastMessageBy() {
        return lastMessageBy;
    }

    public void setLastMessageBy(String lastMessageBy) {
        this.lastMessageBy = lastMessageBy;
    }

    public String getReceiverImage() {
        return receiverImage;
    }

    public void setReceiverImage(String receiverImage) {
        this.receiverImage = receiverImage;
    }
}
