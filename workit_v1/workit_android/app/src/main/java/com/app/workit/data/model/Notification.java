package com.app.workit.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Notification {
    @SerializedName("job_id")
    @Expose
    private String jobId;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("sender_image")
    @Expose
    private String senderImage;
    @SerializedName("sender_name")
    @Expose
    private String senderName;
    @SerializedName("sender_id")
    @Expose
    private String senderId;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("notification_type")
    @Expose
    private Integer notificationType;
    @SerializedName("receiver_id")
    @Expose
    private String receiverId;
    @SerializedName("notification_body")
    @Expose
    private String notificationBody;
    @SerializedName("notification_id")
    @Expose
    private String notificationId;


    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getSenderImage() {
        return senderImage;
    }

    public void setSenderImage(String senderImage) {
        this.senderImage = senderImage;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getSenderId() {
        return senderId;
    }

    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(Integer notificationType) {
        this.notificationType = notificationType;
    }

    public String getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(String receiverId) {
        this.receiverId = receiverId;
    }

    public String getNotificationBody() {
        return notificationBody;
    }

    public void setNotificationBody(String notificationBody) {
        this.notificationBody = notificationBody;
    }

    public String getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(String notificationId) {
        this.notificationId = notificationId;
    }
}
