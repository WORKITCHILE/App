package com.app.workit.data.model;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Bid implements Parcelable {
    @SerializedName("job_end_time")
    @Expose
    private Integer jobEndTime;
    @SerializedName("job_description")
    @Expose
    private String jobDescription;
    @SerializedName("job_name")
    @Expose
    private String jobName;
    @SerializedName("job_approach")
    @Expose
    private String jobApproach;
    @SerializedName("initial_amount")
    @Expose
    private Integer initialAmount;
    @SerializedName("bid_show_status")
    @Expose
    private String bidShowStatus;
    @SerializedName("job_date")
    @Expose
    private String jobDate;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("user_dob")
    @Expose
    private Integer userDob;
    @SerializedName("job_day_timestamp")
    @Expose
    private Integer jobDayTimestamp;
    @SerializedName("vendor_image")
    @Expose
    private String vendorImage;
    @SerializedName("vendor_id")
    @Expose
    private String vendorId;
    @SerializedName("owner_status")
    @Expose
    private String ownerStatus;
    @SerializedName("job_id")
    @Expose
    private String jobId;
    @SerializedName("counteroffer_amount")
    @Expose
    private String counterofferAmount;
    @SerializedName("user_image")
    @Expose
    private String userImage;
    @SerializedName("job_time")
    @Expose
    private Long jobTime;
    @SerializedName("user_id")
    @Expose
    private String userId;
    @SerializedName("vendor_description")
    @Expose
    private String vendorDescription;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("vendor_occupation")
    @Expose
    private String vendorOccupation;
    @SerializedName("vendor_status")
    @Expose
    private String vendorStatus;
    @SerializedName("job_address")
    @Expose
    private String jobAddress;
    @SerializedName("vendor_dob")
    @Expose
    private Integer vendorDob;
    @SerializedName("user_occupation")
    @Expose
    private String userOccupation;
    @SerializedName("user_name")
    @Expose
    private String userName;
    @SerializedName("vendor_name")
    @Expose
    private String vendorName;
    @SerializedName("user_description")
    @Expose
    private String userDescription;
    @SerializedName("comment")
    @Expose
    private String comment;
    @SerializedName("bid_id")
    @Expose
    private String bidId;
    @SerializedName("category_name")
    @Expose
    private String categoryName;
    @SerializedName("subcategory_name")
    @Expose
    private String subCategoryName;


    protected Bid(Parcel in) {
        if (in.readByte() == 0) {
            jobEndTime = null;
        } else {
            jobEndTime = in.readInt();
        }
        jobDescription = in.readString();
        jobName = in.readString();
        jobApproach = in.readString();
        if (in.readByte() == 0) {
            initialAmount = null;
        } else {
            initialAmount = in.readInt();
        }
        bidShowStatus = in.readString();
        jobDate = in.readString();
        if (in.readByte() == 0) {
            createdAt = null;
        } else {
            createdAt = in.readLong();
        }
        if (in.readByte() == 0) {
            userDob = null;
        } else {
            userDob = in.readInt();
        }
        if (in.readByte() == 0) {
            jobDayTimestamp = null;
        } else {
            jobDayTimestamp = in.readInt();
        }
        vendorImage = in.readString();
        vendorId = in.readString();
        ownerStatus = in.readString();
        jobId = in.readString();
        counterofferAmount = in.readString();
        userImage = in.readString();
        if (in.readByte() == 0) {
            jobTime = null;
        } else {
            jobTime = in.readLong();
        }
        userId = in.readString();
        vendorDescription = in.readString();
        if (in.readByte() == 0) {
            updatedAt = null;
        } else {
            updatedAt = in.readLong();
        }
        vendorOccupation = in.readString();
        vendorStatus = in.readString();
        jobAddress = in.readString();
        if (in.readByte() == 0) {
            vendorDob = null;
        } else {
            vendorDob = in.readInt();
        }
        userOccupation = in.readString();
        userName = in.readString();
        vendorName = in.readString();
        userDescription = in.readString();
        comment = in.readString();
        bidId = in.readString();
        categoryName = in.readString();
        subCategoryName = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        if (jobEndTime == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(jobEndTime);
        }
        dest.writeString(jobDescription);
        dest.writeString(jobName);
        dest.writeString(jobApproach);
        if (initialAmount == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(initialAmount);
        }
        dest.writeString(bidShowStatus);
        dest.writeString(jobDate);
        if (createdAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(createdAt);
        }
        if (userDob == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(userDob);
        }
        if (jobDayTimestamp == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(jobDayTimestamp);
        }
        dest.writeString(vendorImage);
        dest.writeString(vendorId);
        dest.writeString(ownerStatus);
        dest.writeString(jobId);
        dest.writeString(counterofferAmount);
        dest.writeString(userImage);
        if (jobTime == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(jobTime);
        }
        dest.writeString(userId);
        dest.writeString(vendorDescription);
        if (updatedAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(updatedAt);
        }
        dest.writeString(vendorOccupation);
        dest.writeString(vendorStatus);
        dest.writeString(jobAddress);
        if (vendorDob == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(vendorDob);
        }
        dest.writeString(userOccupation);
        dest.writeString(userName);
        dest.writeString(vendorName);
        dest.writeString(userDescription);
        dest.writeString(comment);
        dest.writeString(bidId);
        dest.writeString(categoryName);
        dest.writeString(subCategoryName);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<Bid> CREATOR = new Creator<Bid>() {
        @Override
        public Bid createFromParcel(Parcel in) {
            return new Bid(in);
        }

        @Override
        public Bid[] newArray(int size) {
            return new Bid[size];
        }

    };

    public Integer getJobEndTime() {
        return jobEndTime;
    }

    public void setJobEndTime(Integer jobEndTime) {
        this.jobEndTime = jobEndTime;
    }

    public String getJobDescription() {
        return jobDescription;
    }

    public void setJobDescription(String jobDescription) {
        this.jobDescription = jobDescription;
    }

    public String getJobName() {
        return jobName;
    }

    public void setJobName(String jobName) {
        this.jobName = jobName;
    }

    public String getJobApproach() {
        return jobApproach;
    }

    public void setJobApproach(String jobApproach) {
        this.jobApproach = jobApproach;
    }

    public Integer getInitialAmount() {
        return initialAmount;
    }

    public void setInitialAmount(Integer initialAmount) {
        this.initialAmount = initialAmount;
    }

    public String getBidShowStatus() {
        return bidShowStatus;
    }

    public void setBidShowStatus(String bidShowStatus) {
        this.bidShowStatus = bidShowStatus;
    }

    public String getJobDate() {
        return jobDate;
    }

    public void setJobDate(String jobDate) {
        this.jobDate = jobDate;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getUserDob() {
        return userDob;
    }

    public void setUserDob(Integer userDob) {
        this.userDob = userDob;
    }

    public Integer getJobDayTimestamp() {
        return jobDayTimestamp;
    }

    public void setJobDayTimestamp(Integer jobDayTimestamp) {
        this.jobDayTimestamp = jobDayTimestamp;
    }

    public String getVendorImage() {
        return vendorImage;
    }

    public void setVendorImage(String vendorImage) {
        this.vendorImage = vendorImage;
    }

    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getOwnerStatus() {
        return ownerStatus;
    }

    public void setOwnerStatus(String ownerStatus) {
        this.ownerStatus = ownerStatus;
    }

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getCounterofferAmount() {
        return counterofferAmount;
    }

    public void setCounterofferAmount(String counterofferAmount) {
        this.counterofferAmount = counterofferAmount;
    }

    public String getUserImage() {
        return userImage;
    }

    public void setUserImage(String userImage) {
        this.userImage = userImage;
    }

    public Long getJobTime() {
        return jobTime;
    }

    public void setJobTime(Long jobTime) {
        this.jobTime = jobTime;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getVendorDescription() {
        return vendorDescription;
    }

    public void setVendorDescription(String vendorDescription) {
        this.vendorDescription = vendorDescription;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getVendorOccupation() {
        return vendorOccupation;
    }

    public void setVendorOccupation(String vendorOccupation) {
        this.vendorOccupation = vendorOccupation;
    }

    public String getVendorStatus() {
        return vendorStatus;
    }

    public void setVendorStatus(String vendorStatus) {
        this.vendorStatus = vendorStatus;
    }

    public String getJobAddress() {
        return jobAddress;
    }

    public void setJobAddress(String jobAddress) {
        this.jobAddress = jobAddress;
    }

    public Integer getVendorDob() {
        return vendorDob;
    }

    public void setVendorDob(Integer vendorDob) {
        this.vendorDob = vendorDob;
    }

    public String getUserOccupation() {
        return userOccupation;
    }

    public void setUserOccupation(String userOccupation) {
        this.userOccupation = userOccupation;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }

    public String getUserDescription() {
        return userDescription;
    }

    public void setUserDescription(String userDescription) {
        this.userDescription = userDescription;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getBidId() {
        return bidId;
    }

    public void setBidId(String bidId) {
        this.bidId = bidId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getSubCategoryName() {
        return subCategoryName;
    }

    public void setSubCategoryName(String subCategoryName) {
        this.subCategoryName = subCategoryName;
    }

    public static Creator<Bid> getCREATOR() {
        return CREATOR;
    }
}
