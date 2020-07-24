package com.app.workit.data.local;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.google.gson.Gson;
import com.app.workit.data.model.AccessToken;
import com.app.workit.data.model.UserInfo;
import com.app.workit.di.ApplicationContext;
import com.app.workit.util.AppConstants;

import javax.inject.Inject;

import static com.app.workit.data.local.SharedPrefsHelper.COUNTRY_CODE;


public class DataManager {

    private static AccessToken accessToken;
    private final Context mContext;
    private final SharedPrefsHelper mSharedPrefsHelper;
    private final Gson mGson;


    private UserInfo userModel;


    @Inject
    public DataManager(@ApplicationContext Context context,
                       SharedPrefsHelper sharedPrefsHelper, Gson gson) {
        mContext = context;
        mSharedPrefsHelper = sharedPrefsHelper;
        mGson = gson;
    }


    public static AccessToken getAccessToken() {
        return accessToken;
    }


    public UserInfo getUserModel() {
        return userModel;
    }

    public void setUserModel(UserInfo userModel) {
        this.userModel = userModel;
    }

    public String getToken() {
        UserInfo userInfo = loadUser();
        return userInfo.getUserId();
    }


    public String getFirebaseAuthToken() {
        UserInfo userInfo = loadUser();
        return userInfo.getFireAuthToken();
    }


    public void saveCountryCode(Context context, String countryCode) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(COUNTRY_CODE, countryCode);
        editor.apply();
    }

    public String getCountryCode(Context context) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        return preferences.getString(COUNTRY_CODE, "");
    }


    public void saveFireBaseToken(String token) {
        mSharedPrefsHelper.put(SharedPrefsHelper.FIREBASE_TOKEN, token);
    }


    public void saveUser(UserInfo userModel) {
        this.userModel = userModel;
        this.setAccessToken(userModel.getUserId());
        String json = mGson.toJson(userModel);
        mSharedPrefsHelper.put(SharedPrefsHelper.USER_DATA, json);
    }


    private void setAccessToken(String accessToken) {
        if (DataManager.accessToken == null) {
            DataManager.accessToken = new AccessToken(AppConstants.K_BEARER, accessToken);
        } else {
            DataManager.accessToken.setAccessToken(accessToken);
        }
    }


    public String getFireBaseToken() {
        return mSharedPrefsHelper.get(SharedPrefsHelper.FIREBASE_TOKEN, "");
    }

    public void removeUser() {
        accessToken = null;
        userModel = null;
        mSharedPrefsHelper.deleteSavedData(SharedPrefsHelper.USER_DATA);

    }

    public UserInfo loadUser() {
        try {
            String userJson = mSharedPrefsHelper.get(SharedPrefsHelper.USER_DATA, null);
            if (userJson != null) {
                UserInfo userModel = mGson.fromJson(userJson, UserInfo.class);
                if (userModel != null) {
                    this.setAccessToken(userModel.getUserId());
                    this.userModel = userModel;
                    return userModel;
                }
            }
        } catch (Exception e) {
            Log.e("exception: ", e.getMessage());
        }
        return new UserInfo();
    }

//    public void saveFirebaseToken(Context context, FirebaseToken token) {
//        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
//        SharedPreferences.Editor editor = preferences.edit();
//        String json = new Gson().toJson(token);
//        editor.putString(AppConstants.K_FIREBASE_TOKEN, json);
//        editor.apply();
//    }

//    public FirebaseToken loadFirebaseToken(Context context) {
//        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
//        String data = sharedPreferences.getString(AppConstants.K_FIREBASE_TOKEN, "");
//        if (!data.isEmpty()) {
//            return new Gson().fromJson(data, FirebaseToken.class);
//        } else {
//            return new FirebaseToken("", 1);
//        }
//    }
//
//    public void removeFireBasetoken(Context context) {
//
//        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
//        SharedPreferences.Editor editor = preferences.edit();
//        editor.remove(AppConstants.K_FIREBASE_TOKEN);
//        editor.apply();
//    }
//
//    public void removeUserData(Context context) {
//        SharedPreferences preferences = context.getSharedPreferences(USER_DATA, Context.MODE_PRIVATE);
//        SharedPreferences.Editor editor = preferences.edit();
//        editor.remove(USER_DETAIL);
//        editor.apply();
//    }

}

