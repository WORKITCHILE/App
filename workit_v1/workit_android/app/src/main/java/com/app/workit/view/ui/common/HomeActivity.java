package com.app.workit.view.ui.common;

import android.os.Bundle;

import android.view.View;
import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import com.app.workit.R;
import com.app.workit.model.rxevent.RxRefreshAction;
import com.app.workit.util.AppConstants;
import com.app.workit.util.RxBus;
import com.app.workit.util.UIHelper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.HomePagerAdapter;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.customview.NoSwipeViewPager;
import com.app.workit.view.ui.customview.ProgressWheel;
import io.reactivex.disposables.Disposable;

import javax.inject.Inject;
import java.util.HashMap;

public class HomeActivity extends CommonDrawerActivity implements CommonDialog.CommonDialogCallback {

    private static final int RC_LOGOUT = 32;
    NoSwipeViewPager homePager;
    HomePagerAdapter homePagerAdapter;
    ProgressWheel progressWheel;
    private Disposable refreshDisposable;
    @Inject
    ViewModelFactory viewModelFactory;
    private HomeViewModel homeViewModel;

    @Override
    protected void onRoleChanged(boolean isChecked) {
        //1 WORK , 0 HIRE
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_UID, userInfoModel.getUserId());
        params.put(AppConstants.K_TYPE, isChecked ? AppConstants.USER_TYPE.WORK : AppConstants.USER_TYPE.HIRE);
        homeViewModel.changeUserRole(params);

    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.navigation_drawer_layout);
        getLayoutInflater().inflate(R.layout.activity_home, frameLayout);
        homePager = findViewById(R.id.home_pager);
        progressWheel = findViewById(R.id.progress_wheel);
        homeViewModel = ViewModelProviders.of(this, viewModelFactory).get(HomeViewModel.class);
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        refreshDisposable.dispose();

    }

    @Override
    protected void onLogOUt() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, "", getString(R.string.msg_are_you_logout),
                getString(R.string.yes), getString(R.string.no), RC_LOGOUT);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    protected void initView() {

        initViewPager();
        refreshDisposable = RxBus.getInstance().getEvents().subscribe(o -> {
            if (o instanceof RxRefreshAction) {
                if (((RxRefreshAction) o).isRefresh()) {
                    showLoading();
                } else {
                    hideLoading();
                }
            }
        });
        homeViewModel.getUserRoleLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(response.message);
                    boolean checked = !switchRole.isChecked();
                    switchRole.setChecked(checked);
                    break;
                case SUCCESS:
                    hideLoading();
                    homePager.setCurrentItem(switchRole.isChecked() ? 1 : 0);
                    break;
            }
        });
    }

    @Override
    public void showLoading() {
        progressWheel.setVisibility(View.VISIBLE);
        progressWheel.spin();
    }

    @Override
    public void hideLoading() {

        progressWheel.stopSpinning();
        progressWheel.setVisibility(View.GONE);
    }

    private void initViewPager() {

        homePagerAdapter = new HomePagerAdapter(getSupportFragmentManager());
        homePager.setAdapter(homePagerAdapter);
        if (userInfoModel.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
            homePager.setCurrentItem(0);
        } else {
            homePager.setCurrentItem(1);
        }


    }

    @Override
    public void onOkClicked(int action) {
        if (action == RC_LOGOUT) {
            dataManager.removeUser();
            firebaseAuth.signOut();
            UIHelper.getInstance().switchActivity(this, SplashActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, true);
        }
    }

    @Override
    public void onCancelClicked() {

    }
}
