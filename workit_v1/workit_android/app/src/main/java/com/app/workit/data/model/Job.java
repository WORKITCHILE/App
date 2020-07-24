package com.app.workit.data.model;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Job implements Parcelable {
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("already_notified_time_2_owner")
    @Expose
    private String alreadyNotifiedTime2Owner;
    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("category_id")
    @Expose
    private String categoryId;
    @SerializedName("initial_amount")
    @Expose
    private String initialAmount;
    @SerializedName("vendor_image")
    @Expose
    private String vendorImage;
    @SerializedName("job_approach")
    @Expose
    private String jobApproach;
    @SerializedName("vendor_description")
    @Expose
    private Object vendorDescription;
    @SerializedName("job_address_latitude")
    @Expose
    private String jobAddressLatitude;
    @SerializedName("vendor_occupation")
    @Expose
    private String vendorOccupation;
    @SerializedName("job_name")
    @Expose
    private String jobName;
    @SerializedName("vendor_rated")
    @Expose
    private Integer vendorRated;
    @SerializedName("start_notify_time_1_vendor")
    @Expose
    private Object startNotifyTime1Vendor;
    @SerializedName("owner_rated")
    @Expose
    private Integer ownerRated;
    @SerializedName("job_description")
    @Expose
    private String jobDescription;
    @SerializedName("user_id")
    @Expose
    private String userId;
    @SerializedName("user_name")
    @Expose
    private String userName;
    @SerializedName("start_notify_time_1_owner")
    @Expose
    private Object startNotifyTime1Owner;
    @SerializedName("vendor_dob")
    @Expose
    private Object vendorDob;
    @SerializedName("already_notified_time_1_owner")
    @Expose
    private String alreadyNotifiedTime1Owner;
    @SerializedName("already_notified_time_2_vendor")
    @Expose
    private String alreadyNotifiedTime2Vendor;
    @SerializedName("job_address_longitude")
    @Expose
    private String jobAddressLongitude;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("images")
    @Expose
    private List<String> images;
    @SerializedName("start_notify_time_2_vendor")
    @Expose
    private Object startNotifyTime2Vendor;
    @SerializedName("start_notify_time_2_owner")
    @Expose
    private Object startNotifyTime2Owner;
    @SerializedName("service_amount")
    @Expose
    private String serviceAmount;
    @SerializedName("job_time")
    @Expose
    private Long jobTime;
    @SerializedName("subcategory_name")
    @Expose
    private String subcategoryName;
    @SerializedName("job_date")
    @Expose
    private String jobDate;
    @SerializedName("job_address")
    @Expose
    private String jobAddress;
    @SerializedName("subcategory_id")
    @Expose
    private String subcategoryId;
    @SerializedName("vendor_name")
    @Expose
    private String vendorName;
    @SerializedName("job_vendor_id")
    @Expose
    private String jobVendorId;
    @SerializedName("category_name")
    @Expose
    private String categoryName;
    @SerializedName("vendor_email")
    @Expose
    private Object vendorEmail;
    @SerializedName("already_notified_time_1_vendor")
    @Expose
    private String alreadyNotifiedTime1Vendor;
    @SerializedName("job_id")
    @Expose
    private String jobId;
    @SerializedName("bids")
    @Expose
    private List<Bid> bids;

    @SerializedName("user_average_rating")
    @Expose
    private String userAverageRating;
    @SerializedName("user_occupation")
    @Expose
    private String userOccupation;
    @SerializedName("user_description")
    @Expose
    private String userDescription;
    @SerializedName("user_dob")
    @Expose
    private Integer userDob;
    @SerializedName("user_image")
    @Expose
    private String userImage;
    @SerializedName("user_email")
    @Expose
    private String userEmail;
    @SerializedName("bid_count")
    @Expose
    private int bidCount;
    @SerializedName("my_bid")
    @Expose
    private Bid myBid;
    @SerializedName("is_bid_placed")
    @Expose
    private int isBidPlaced;
    @SerializedName("comment")
    @Expose
    private String comment;
    @SerializedName("vendor_average_rating")
    @Expose
    private String vendorAverageRating;
    @SerializedName("started_by")
    @Expose
    private String startedBy;
    @SerializedName("canceled_by")
    @Expose
    private String canceledBy;


    protected Job(Parcel in) {
        if (in.readByte() == 0) {
            createdAt = null;
        } else {
            createdAt = in.readLong();
        }
        alreadyNotifiedTime2Owner = in.readString();
        status = in.readString();
        categoryId = in.readString();
        initialAmount = in.readString();
        vendorImage = in.readString();
        jobApproach = in.readString();
        jobAddressLatitude = in.readString();
        vendorOccupation = in.readString();
        jobName = in.readString();
        if (in.readByte() == 0) {
            vendorRated = null;
        } else {
            vendorRated = in.readInt();
        }
        if (in.readByte() == 0) {
            ownerRated = null;
        } else {
            ownerRated = in.readInt();
        }
        jobDescription = in.readString();
        userId = in.readString();
        userName = in.readString();
        alreadyNotifiedTime1Owner = in.readString();
        alreadyNotifiedTime2Vendor = in.readString();
        jobAddressLongitude = in.readString();
        if (in.readByte() == 0) {
            updatedAt = null;
        } else {
            updatedAt = in.readLong();
        }
        images = in.createStringArrayList();
        serviceAmount = in.readString();
        if (in.readByte() == 0) {
            jobTime = null;
        } else {
            jobTime = in.readLong();
        }
        subcategoryName = in.readString();
        jobDate = in.readString();
        jobAddress = in.readString();
        subcategoryId = in.readString();
        vendorName = in.readString();
        jobVendorId = in.readString();
        categoryName = in.readString();
        alreadyNotifiedTime1Vendor = in.readString();
        jobId = in.readString();
        bids = in.createTypedArrayList(Bid.CREATOR);
        userOccupation = in.readString();
        userDescription = in.readString();
        if (in.readByte() == 0) {
            userDob = null;
        } else {
            userDob = in.readInt();
        }
        userImage = in.readString();
        userEmail = in.readString();
        bidCount = in.readInt();
        myBid = in.readParcelable(Bid.class.getClassLoader());
        isBidPlaced = in.readInt();
        comment = in.readString();
        vendorAverageRating = in.readString();
        startedBy = in.readString();
        canceledBy = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        if (createdAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(createdAt);
        }
        dest.writeString(alreadyNotifiedTime2Owner);
        dest.writeString(status);
        dest.writeString(categoryId);
        dest.writeString(initialAmount);
        dest.writeString(vendorImage);
        dest.writeString(jobApproach);
        dest.writeString(jobAddressLatitude);
        dest.writeString(vendorOccupation);
        dest.writeString(jobName);
        if (vendorRated == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(vendorRated);
        }
        if (ownerRated == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(ownerRated);
        }
        dest.writeString(jobDescription);
        dest.writeString(userId);
        dest.writeString(userName);
        dest.writeString(alreadyNotifiedTime1Owner);
        dest.writeString(alreadyNotifiedTime2Vendor);
        dest.writeString(jobAddressLongitude);
        if (updatedAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(updatedAt);
        }
        dest.writeStringList(images);
        dest.writeString(serviceAmount);
        if (jobTime == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(jobTime);
        }
        dest.writeString(subcategoryName);
        dest.writeString(jobDate);
        dest.writeString(jobAddress);
        dest.writeString(subcategoryId);
        dest.writeString(vendorName);
        dest.writeString(jobVendorId);
        dest.writeString(categoryName);
        dest.writeString(alreadyNotifiedTime1Vendor);
        dest.writeString(jobId);
        dest.writeTypedList(bids);
        dest.writeString(userOccupation);
        dest.writeString(userDescription);
        if (userDob == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(userDob);
        }
        dest.writeString(userImage);
        dest.writeString(userEmail);
        dest.writeInt(bidCount);
        dest.writeParcelable(myBid, flags);
        dest.writeInt(isBidPlaced);
        dest.writeString(comment);
        dest.writeString(vendorAverageRating);
        dest.writeString(startedBy);
        dest.writeString(canceledBy);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<Job> CREATOR = new Creator<Job>() {
        @Override
        public Job createFromParcel(Parcel in) {
            return new Job(in);
        }

        @Override
        public Job[] newArray(int size) {
            return new Job[size];
        }
    };

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getAlreadyNotifiedTime2Owner() {
        return alreadyNotifiedTime2Owner;
    }

    public void setAlreadyNotifiedTime2Owner(String alreadyNotifiedTime2Owner) {
        this.alreadyNotifiedTime2Owner = alreadyNotifiedTime2Owner;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    public String getInitialAmount() {
        return initialAmount == null ? "0" : initialAmount;
    }

    public void setInitialAmount(String initialAmount) {
        this.initialAmount = initialAmount;
    }

    public String getVendorImage() {
        return vendorImage;
    }

    public void setVendorImage(String vendorImage) {
        this.vendorImage = vendorImage;
    }

    public String getJobApproach() {
        return jobApproach;
    }

    public void setJobApproach(String jobApproach) {
        this.jobApproach = jobApproach;
    }

    public Object getVendorDescription() {
        return vendorDescription;
    }

    public void setVendorDescription(Object vendorDescription) {
        this.vendorDescription = vendorDescription;
    }

    public String getJobAddressLatitude() {
        return jobAddressLatitude;
    }

    public void setJobAddressLatitude(String jobAddressLatitude) {
        this.jobAddressLatitude = jobAddressLatitude;
    }

    public String getVendorOccupation() {
        return vendorOccupation;
    }

    public void setVendorOccupation(String vendorOccupation) {
        this.vendorOccupation = vendorOccupation;
    }

    public String getJobName() {
        return jobName;
    }

    public void setJobName(String jobName) {
        this.jobName = jobName;
    }

    public Integer getVendorRated() {
        return vendorRated == null ? 0 : vendorRated;
    }

    public void setVendorRated(Integer vendorRated) {
        this.vendorRated = vendorRated;
    }

    public Object getStartNotifyTime1Vendor() {
        return startNotifyTime1Vendor;
    }

    public void setStartNotifyTime1Vendor(Object startNotifyTime1Vendor) {
        this.startNotifyTime1Vendor = startNotifyTime1Vendor;
    }

    public Integer getOwnerRated() {
        return ownerRated == null ? 0 : ownerRated;
    }

    public void setOwnerRated(Integer ownerRated) {
        this.ownerRated = ownerRated;
    }

    public String getJobDescription() {
        return jobDescription;
    }

    public void setJobDescription(String jobDescription) {
        this.jobDescription = jobDescription;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Object getStartNotifyTime1Owner() {
        return startNotifyTime1Owner;
    }

    public void setStartNotifyTime1Owner(Object startNotifyTime1Owner) {
        this.startNotifyTime1Owner = startNotifyTime1Owner;
    }

    public Object getVendorDob() {
        return vendorDob;
    }

    public void setVendorDob(Object vendorDob) {
        this.vendorDob = vendorDob;
    }

    public String getAlreadyNotifiedTime1Owner() {
        return alreadyNotifiedTime1Owner;
    }

    public void setAlreadyNotifiedTime1Owner(String alreadyNotifiedTime1Owner) {
        this.alreadyNotifiedTime1Owner = alreadyNotifiedTime1Owner;
    }

    public String getAlreadyNotifiedTime2Vendor() {
        return alreadyNotifiedTime2Vendor;
    }

    public void setAlreadyNotifiedTime2Vendor(String alreadyNotifiedTime2Vendor) {
        this.alreadyNotifiedTime2Vendor = alreadyNotifiedTime2Vendor;
    }

    public String getJobAddressLongitude() {
        return jobAddressLongitude;
    }

    public void setJobAddressLongitude(String jobAddressLongitude) {
        this.jobAddressLongitude = jobAddressLongitude;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    public Object getStartNotifyTime2Vendor() {
        return startNotifyTime2Vendor;
    }

    public void setStartNotifyTime2Vendor(Object startNotifyTime2Vendor) {
        this.startNotifyTime2Vendor = startNotifyTime2Vendor;
    }

    public Object getStartNotifyTime2Owner() {
        return startNotifyTime2Owner;
    }

    public void setStartNotifyTime2Owner(Object startNotifyTime2Owner) {
        this.startNotifyTime2Owner = startNotifyTime2Owner;
    }

    public String getServiceAmount() {
        return serviceAmount == null ? "0" : serviceAmount;
    }

    public void setServiceAmount(String serviceAmount) {
        this.serviceAmount = serviceAmount;
    }

    public Long getJobTime() {
        return jobTime;
    }

    public void setJobTime(Long jobTime) {
        this.jobTime = jobTime;
    }

    public String getSubcategoryName() {
        return subcategoryName;
    }

    public void setSubcategoryName(String subcategoryName) {
        this.subcategoryName = subcategoryName;
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

    public String getSubcategoryId() {
        return subcategoryId;
    }

    public void setSubcategoryId(String subcategoryId) {
        this.subcategoryId = subcategoryId;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }

    public String getJobVendorId() {
        return jobVendorId;
    }

    public void setJobVendorId(String jobVendorId) {
        this.jobVendorId = jobVendorId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Object getVendorEmail() {
        return vendorEmail;
    }

    public void setVendorEmail(Object vendorEmail) {
        this.vendorEmail = vendorEmail;
    }

    public String getAlreadyNotifiedTime1Vendor() {
        return alreadyNotifiedTime1Vendor;
    }

    public void setAlreadyNotifiedTime1Vendor(String alreadyNotifiedTime1Vendor) {
        this.alreadyNotifiedTime1Vendor = alreadyNotifiedTime1Vendor;
    }

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public List<Bid> getBids() {
        return bids;
    }

    public void setBids(List<Bid> bids) {
        this.bids = bids;
    }

    public String getUserAverageRating() {
        return userAverageRating == null ? "0f" : userAverageRating;
    }

    public void setUserAverageRating(String userAverageRating) {
        this.userAverageRating = userAverageRating;
    }

    public String getUserOccupation() {
        return userOccupation;
    }

    public void setUserOccupation(String userOccupation) {
        this.userOccupation = userOccupation;
    }

    public String getUserDescription() {
        return userDescription;
    }

    public void setUserDescription(String userDescription) {
        this.userDescription = userDescription;
    }

    public Integer getUserDob() {
        return userDob;
    }

    public void setUserDob(Integer userDob) {
        this.userDob = userDob;
    }

    public String getUserImage() {
        return userImage;
    }

    public void setUserImage(String userImage) {
        this.userImage = userImage;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public int getBidCount() {
        return bidCount;
    }

    public void setBidCount(int bidCount) {
        this.bidCount = bidCount;
    }

    public Bid getMyBid() {
        return myBid;
    }

    public void setMyBid(Bid myBid) {
        this.myBid = myBid;
    }

    public int getIsBidPlaced() {
        return isBidPlaced;
    }

    public void setIsBidPlaced(int isBidPlaced) {
        this.isBidPlaced = isBidPlaced;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getVendorAverageRating() {
        return vendorAverageRating == null ? "0f" : vendorAverageRating;
    }

    public void setVendorAverageRating(String vendorAverageRating) {
        this.vendorAverageRating = vendorAverageRating;
    }

    public String getStartedBy() {
        return startedBy == null ? "" : startedBy;
    }

    public void setStartedBy(String startedBy) {
        this.startedBy = startedBy;
    }

    public String getCanceledBy() {
        return canceledBy == null ? "" : canceledBy;
    }

    public void setCanceledBy(String canceledBy) {
        this.canceledBy = canceledBy;
    }

    public static Creator<Job> getCREATOR() {
        return CREATOR;
    }
}


