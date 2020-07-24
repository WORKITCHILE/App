package com.app.workit.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class RatingReview {
    @SerializedName("job_amount")
    @Expose
    private String jobAmount;
    @SerializedName("rate_to")
    @Expose
    private String rateTo;
    @SerializedName("rate_from_type")
    @Expose
    private String rateFromType;
    @SerializedName("rate_from")
    @Expose
    private String rateFrom;
    @SerializedName("rate_from_image")
    @Expose
    private String rateFromImage;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("rate_from_name")
    @Expose
    private String rateFromName;
    @SerializedName("rate_to_name")
    @Expose
    private String rateToName;
    @SerializedName("job_time")
    @Expose
    private Integer jobTime;
    @SerializedName("rating")
    @Expose
    private String rating;
    @SerializedName("job_approach")
    @Expose
    private String jobApproach;
    @SerializedName("job_date")
    @Expose
    private String jobDate;
    @SerializedName("job_address")
    @Expose
    private String jobAddress;
    @SerializedName("job_id")
    @Expose
    private String jobId;
    @SerializedName("job_vendor_id")
    @Expose
    private String jobVendorId;
    @SerializedName("job_name")
    @Expose
    private String jobName;
    @SerializedName("job_owner_id")
    @Expose
    private String jobOwnerId;
    @SerializedName("rate_to_image")
    @Expose
    private String rateToImage;
    @SerializedName("comment")
    @Expose
    private String comment;
    @SerializedName("rate_to_type")
    @Expose
    private String rateToType;
    @SerializedName("contact_outside")
    @Expose
    private String contactOutside;
    @SerializedName("job_description")
    @Expose
    private String jobDescription;
    @SerializedName("rating_id")
    @Expose
    private String ratingId;


    public String getJobAmount() {
        return jobAmount;
    }

    public void setJobAmount(String jobAmount) {
        this.jobAmount = jobAmount;
    }

    public String getRateTo() {
        return rateTo;
    }

    public void setRateTo(String rateTo) {
        this.rateTo = rateTo;
    }

    public String getRateFromType() {
        return rateFromType;
    }

    public void setRateFromType(String rateFromType) {
        this.rateFromType = rateFromType;
    }

    public String getRateFrom() {
        return rateFrom;
    }

    public void setRateFrom(String rateFrom) {
        this.rateFrom = rateFrom;
    }

    public String getRateFromImage() {
        return rateFromImage;
    }

    public void setRateFromImage(String rateFromImage) {
        this.rateFromImage = rateFromImage;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getRateFromName() {
        return rateFromName;
    }

    public void setRateFromName(String rateFromName) {
        this.rateFromName = rateFromName;
    }

    public String getRateToName() {
        return rateToName;
    }

    public void setRateToName(String rateToName) {
        this.rateToName = rateToName;
    }

    public Integer getJobTime() {
        return jobTime;
    }

    public void setJobTime(Integer jobTime) {
        this.jobTime = jobTime;
    }

    public String getRating() {
        return rating == null ? "0" : rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public String getJobApproach() {
        return jobApproach;
    }

    public void setJobApproach(String jobApproach) {
        this.jobApproach = jobApproach;
    }

    public String getJobDate() {
        return jobDate;
    }

    public void setJobDate(String jobDate) {
        this.jobDate = jobDate;
    }

    public String getJobAddress() {
        return jobAddress;
    }

    public void setJobAddress(String jobAddress) {
        this.jobAddress = jobAddress;
    }

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getJobVendorId() {
        return jobVendorId;
    }

    public void setJobVendorId(String jobVendorId) {
        this.jobVendorId = jobVendorId;
    }

    public String getJobName() {
        return jobName;
    }

    public void setJobName(String jobName) {
        this.jobName = jobName;
    }

    public String getJobOwnerId() {
        return jobOwnerId;
    }

    public void setJobOwnerId(String jobOwnerId) {
        this.jobOwnerId = jobOwnerId;
    }

    public String getRateToImage() {
        return rateToImage;
    }

    public void setRateToImage(String rateToImage) {
        this.rateToImage = rateToImage;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getRateToType() {
        return rateToType;
    }

    public void setRateToType(String rateToType) {
        this.rateToType = rateToType;
    }

    public String getContactOutside() {
        return contactOutside;
    }

    public void setContactOutside(String contactOutside) {
        this.contactOutside = contactOutside;
    }

    public String getJobDescription() {
        return jobDescription;
    }

    public void setJobDescription(String jobDescription) {
        this.jobDescription = jobDescription;
    }

    public String getRatingId() {
        return ratingId;
    }

    public void setRatingId(String ratingId) {
        this.ratingId = ratingId;
    }
}
