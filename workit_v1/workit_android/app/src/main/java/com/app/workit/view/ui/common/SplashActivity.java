package com.app.workit.view.ui.common;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.util.UIHelper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.emailverification.EmailVerificationActivity;
import com.app.workit.view.ui.common.roleselection.RoleSelectActivity;

import javax.inject.Inject;

public class SplashActivity extends MainBaseActivity {
    private UserInfo userInfo;

    @Inject
    DataManager dataManager;
    @Inject
    ViewModelFactory viewModelFactory;

    SplashViewModel splashViewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        userInfo = dataManager.loadUser();
    }

    @Override
    protected void initView() {
        splashViewModel = ViewModelProviders.of(SplashActivity.this, viewModelFactory).get(SplashViewModel.class);
        splashViewModel.getProfile(userInfo.getUserId());

        splashViewModel.getProfileLiveData().observe(this, new Observer<NetworkResponse<UserInfo>>() {
            @Override
            public void onChanged(NetworkResponse<UserInfo> response) {
                switch (response.status) {
                    case LOADING:
                        break;
                    case ERROR:
                        //showErrorPrompt(response.message);
                        switchToNext(null);
                        break;
                    case SUCCESS:
                        String localToken = userInfo.getFireAuthToken();
                        userInfo = response.response;
                        userInfo.setFireAuthToken(localToken);
                        dataManager.saveUser(response.response);
                        switchToNext(response.response);
                        break;
                }
            }
        });
    }

    private void switchToNext(UserInfo userInfo) {
        Class clazz;

        if (userInfo != null) {
            if ((userInfo.getUserId() != null && !userInfo.getUserId().isEmpty())) {

                clazz = userInfo.getIsEmailVerified() == 1 ? RoleSelectActivity.class : EmailVerificationActivity.class;
            } else {
                clazz = MainActivity.class;
            }
        } else {
            clazz = MainActivity.class;

        }
        UIHelper.getInstance().switchActivity(this, clazz, null, null, null, true);
    }


}
