package com.app.workit.model;

import android.os.Parcel;
import android.os.Parcelable;

public class LocationModel implements Parcelable {
    private String address;
    private double latitude;
    private double longitude;


    public LocationModel() {

    }

    public LocationModel(Double latitude, Double longitude) {
        this.address = "";
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public LocationModel(String address, Double latitude, Double longitude) {
        this.latitude = latitude;
        this.address = address;
        this.longitude = longitude;
    }


    protected LocationModel(Parcel in) {
        address = in.readString();
        latitude = in.readDouble();
        longitude = in.readDouble();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(address);
        dest.writeDouble(latitude);
        dest.writeDouble(longitude);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<LocationModel> CREATOR = new Creator<LocationModel>() {
        @Override
        public LocationModel createFromParcel(Parcel in) {
            return new LocationModel(in);
        }

        @Override
        public LocationModel[] newArray(int size) {
            return new LocationModel[size];
        }
    };

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }


}
