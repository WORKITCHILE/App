package com.app.workit.data.local;

import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.app.workit.data.model.UserInfo;
import com.app.workit.di.scope.AppScope;

import javax.inject.Inject;

@AppScope
public class SharedPrefsHelper {
    public static final String FIREBASE_TOKEN = "firebase_token";
    public static String PREF_KEY_ACCESS_TOKEN = "access-token";
    public static final String COUNTRY_CODE = "country_code";
    public static final String USER_DATA = "user_data";

    private final Gson mGson;

    private SharedPreferences mSharedPreferences;

    @Inject
    public SharedPrefsHelper(SharedPreferences sharedPreferences, Gson gson) {
        mSharedPreferences = sharedPreferences;
        mGson = gson;
    }


    public void saveUser(UserInfo userInfo) {

    }

    public void put(String key, String value) {
        mSharedPreferences.edit().putString(key, value).apply();
    }

    public void put(String key, int value) {
        mSharedPreferences.edit().putInt(key, value).apply();
    }

    public void put(String key, float value) {
        mSharedPreferences.edit().putFloat(key, value).apply();
    }

    public void put(String key, boolean value) {
        mSharedPreferences.edit().putBoolean(key, value).apply();
    }

    public String get(String key, String defaultValue) {
        return mSharedPreferences.getString(key, defaultValue);
    }

    public Integer get(String key, int defaultValue) {
        return mSharedPreferences.getInt(key, defaultValue);
    }

    public Float get(String key, float defaultValue) {
        return mSharedPreferences.getFloat(key, defaultValue);
    }

    public Boolean get(String key, boolean defaultValue) {
        return mSharedPreferences.getBoolean(key, defaultValue);
    }

    public void deleteSavedData(String key) {
        mSharedPreferences.edit().remove(key).apply();
    }
}
