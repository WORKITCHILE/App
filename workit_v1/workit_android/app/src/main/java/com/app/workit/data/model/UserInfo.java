package com.app.workit.data.model;

import android.os.Parcel;
import android.os.Parcelable;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class UserInfo implements Parcelable {
    @SerializedName("mother_last_name")
    @Expose
    private String motherLastName;
    @SerializedName("average_rating")
    @Expose
    private String averageRating;
    @SerializedName("address")
    @Expose
    private String address;
    @SerializedName("is_bank_details_added")
    @Expose
    private Integer isBankDetailsAdded;
    @SerializedName("facebook_handle")
    @Expose
    private Object facebookHandle;
    @SerializedName("nationality")
    @Expose
    private String nationality;
    @SerializedName("date_of_birth")
    @Expose
    private Long dateOfBirth;
    @SerializedName("profile_picture")
    @Expose
    private String profilePicture;
    @SerializedName("google_handle")
    @Expose
    private Object googleHandle;
    @SerializedName("contact_number")
    @Expose
    private String contactNumber;
    @SerializedName("credits")
    @Expose
    private String credits;
    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("occupation")
    @Expose
    private String occupation;
    @SerializedName("email")
    @Expose
    private String email;
    @SerializedName("name")
    @Expose
    private String name;
    @SerializedName("profile_description")
    @Expose
    private String profileDescription;
    @SerializedName("created_at")
    @Expose
    private Long createdAt;
    @SerializedName("id_image1")
    @Expose
    private String idImage1;
    @SerializedName("id_number")
    @Expose
    private String idNumber;
    @SerializedName("updated_at")
    @Expose
    private Long updatedAt;
    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("father_last_name")
    @Expose
    private String fatherLastName;
    @SerializedName("fire_auth_toke")
    @Expose
    private String fireAuthToken;
    @SerializedName("fcm_token")
    @Expose
    private List<String> fcmToken;
    @SerializedName("user_id")
    @Expose
    private String userId;
    @SerializedName("is_email_verified")
    @Expose
    private int isEmailVerified;


    public UserInfo() {
    }

    protected UserInfo(Parcel in) {
        motherLastName = in.readString();
        averageRating = in.readString();
        address = in.readString();
        if (in.readByte() == 0) {
            isBankDetailsAdded = null;
        } else {
            isBankDetailsAdded = in.readInt();
        }
        nationality = in.readString();
        if (in.readByte() == 0) {
            dateOfBirth = null;
        } else {
            dateOfBirth = in.readLong();
        }
        profilePicture = in.readString();
        contactNumber = in.readString();
        credits = in.readString();
        status = in.readString();
        occupation = in.readString();
        email = in.readString();
        name = in.readString();
        profileDescription = in.readString();
        if (in.readByte() == 0) {
            createdAt = null;
        } else {
            createdAt = in.readLong();
        }
        idImage1 = in.readString();
        idNumber = in.readString();
        if (in.readByte() == 0) {
            updatedAt = null;
        } else {
            updatedAt = in.readLong();
        }
        type = in.readString();
        fatherLastName = in.readString();
        fireAuthToken = in.readString();
        fcmToken = in.createStringArrayList();
        userId = in.readString();
        isEmailVerified = in.readInt();
    }

    public static final Creator<UserInfo> CREATOR = new Creator<UserInfo>() {
        @Override
        public UserInfo createFromParcel(Parcel in) {
            return new UserInfo(in);
        }

        @Override
        public UserInfo[] newArray(int size) {
            return new UserInfo[size];
        }
    };

    public int getIsEmailVerified() {
        return isEmailVerified;
    }

    public void setIsEmailVerified(int isEmailVerified) {
        this.isEmailVerified = isEmailVerified;
    }

    public String getMotherLastName() {
        return motherLastName;
    }

    public void setMotherLastName(String motherLastName) {
        this.motherLastName = motherLastName;
    }

    public String getAverageRating() {
        return averageRating == null ? "0.0f" : averageRating;
    }

    public void setAverageRating(String averageRating) {
        this.averageRating = averageRating;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Integer getIsBankDetailsAdded() {
        return isBankDetailsAdded == null ? 0 : isBankDetailsAdded;
    }

    public void setIsBankDetailsAdded(Integer isBankDetailsAdded) {
        this.isBankDetailsAdded = isBankDetailsAdded;
    }

    public Object getFacebookHandle() {
        return facebookHandle;
    }

    public void setFacebookHandle(Object facebookHandle) {
        this.facebookHandle = facebookHandle;
    }

    public String getNationality() {
        return nationality;
    }

    public void setNationality(String nationality) {
        this.nationality = nationality;
    }

    public Long getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Long dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }

    public Object getGoogleHandle() {
        return googleHandle;
    }

    public void setGoogleHandle(Object googleHandle) {
        this.googleHandle = googleHandle;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getCredits() {
        return credits == null ? "0" : credits;
    }

    public void setCredits(String credits) {
        this.credits = credits;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getOccupation() {
        return occupation;
    }

    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getProfileDescription() {
        return profileDescription;
    }

    public void setProfileDescription(String profileDescription) {
        this.profileDescription = profileDescription;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public String getIdImage1() {
        return idImage1;
    }

    public void setIdImage1(String idImage1) {
        this.idImage1 = idImage1;
    }

    public String getIdNumber() {
        return idNumber;
    }

    public void setIdNumber(String idNumber) {
        this.idNumber = idNumber;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getFatherLastName() {
        return fatherLastName;
    }

    public void setFatherLastName(String fatherLastName) {
        this.fatherLastName = fatherLastName;
    }

    public List<String> getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(List<String> fcmToken) {
        this.fcmToken = fcmToken;
    }

    public String getFireAuthToken() {
        return fireAuthToken;
    }

    public void setFireAuthToken(String fireAuthToken) {
        this.fireAuthToken = fireAuthToken;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(motherLastName);
        dest.writeString(averageRating);
        dest.writeString(address);
        if (isBankDetailsAdded == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeInt(isBankDetailsAdded);
        }
        dest.writeString(nationality);
        if (dateOfBirth == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(dateOfBirth);
        }
        dest.writeString(profilePicture);
        dest.writeString(contactNumber);
        dest.writeString(credits);
        dest.writeString(status);
        dest.writeString(occupation);
        dest.writeString(email);
        dest.writeString(name);
        dest.writeString(profileDescription);
        if (createdAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(createdAt);
        }
        dest.writeString(idImage1);
        dest.writeString(idNumber);
        if (updatedAt == null) {
            dest.writeByte((byte) 0);
        } else {
            dest.writeByte((byte) 1);
            dest.writeLong(updatedAt);
        }
        dest.writeString(type);
        dest.writeString(fatherLastName);
        dest.writeString(fireAuthToken);
        dest.writeStringList(fcmToken);
        dest.writeString(userId);
        dest.writeInt(isEmailVerified);
    }
}
