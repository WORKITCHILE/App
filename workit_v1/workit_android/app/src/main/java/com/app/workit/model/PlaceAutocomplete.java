package com.app.workit.model;

import androidx.annotation.Nullable;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/**
 * Holder for Places Geo Data Autocomplete API results.
 */
public class PlaceAutocomplete {
    @SerializedName("place_id")
    @Expose()
    public String placeId;
    @SerializedName("address")
    @Expose()
    public String address;
    @SerializedName("area")
    @Expose()
    public String area;
    @SerializedName("history")
    @Expose()
    public boolean history;

    public PlaceAutocomplete() {
    }

    public PlaceAutocomplete(String placeId, String area, String address) {
        this.placeId = placeId;
        this.area = area;
        this.address = address;
    }

    public String getPlaceId() {
        return placeId;
    }

    public void setPlaceId(String placeId) {
        this.placeId = placeId;
    }

    public String getAddress() {
        return address == null ? "" : address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public boolean isHistory() {
        return history;
    }

    public void setHistory(boolean history) {
        this.history = history;
    }

    @Override
    public int hashCode() {
        int hashcode = 0;
        hashcode += placeId.hashCode();
        return hashcode;
    }

    @Override
    public boolean equals(@Nullable Object object) {
        boolean result = false;
        if (object != null && object.getClass() == getClass()) {
            PlaceAutocomplete placeAutocomplete = (PlaceAutocomplete) object;
            if (this.placeId.equals(placeAutocomplete.getPlaceId())) {
                result = true;
            }
        }
        return result;
    }
}