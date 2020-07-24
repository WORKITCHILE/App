package com.app.workit.view.ui.base;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.android.material.snackbar.Snackbar;
import com.app.workit.R;
import com.app.workit.view.ui.customview.ProgressWheel;
import com.shashank.sony.fancytoastlib.FancyToast;

public abstract class BaseActivity extends MainBaseActivity implements BaseView {


    private TextView toolbarTitle;
    private ImageButton toolbarBack;
    private ProgressWheel mProgressWheel;
    private AlertDialog mAlertDialogProgressBar;
    private SwipeRefreshLayout swipeRefreshLayout;
    protected Snackbar mSnackbar;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void setContentView(int layoutResID) {

        View inflateView = LayoutInflater.from(this).inflate(R.layout.activity_base, null);

        mProgressWheel = inflateView.findViewById(R.id.progress_wheel);
        swipeRefreshLayout = inflateView.findViewById(R.id.swipe_refresh);
        // Configure the refreshing colors
        swipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,

                android.R.color.holo_green_light,

                android.R.color.holo_orange_light,

                android.R.color.holo_red_light);

        FrameLayout toolbarContainer = inflateView.findViewById(R.id.fl_toolbar_container);

        switch (userInfo.getType()) {
            default:
                LayoutInflater.from(this).inflate(R.layout.toolbar_common, toolbarContainer, true);

        }

        toolbarBack = inflateView.findViewById(R.id.iv_back);
        toolbarTitle = inflateView.findViewById(R.id.tv_header);

        toolbarBack.setOnClickListener(v -> onBackPressed());
        swipeRefreshLayout.setEnabled(false);

        FrameLayout mainContainer = inflateView.findViewById(R.id.fl_main_container);
        LayoutInflater.from(this).inflate(layoutResID, mainContainer, true);


        super.setContentView(inflateView);

    }


    @Override
    public void showLoading() {
        if (mProgressWheel.getVisibility() == View.GONE) {
            mProgressWheel.setVisibility(View.VISIBLE);
            mProgressWheel.spin();
        }
    }

    @Override
    public void hideLoading() {
        if (mProgressWheel.getVisibility() == View.VISIBLE) {
            mProgressWheel.setVisibility(View.GONE);
            mProgressWheel.stopSpinning();
        }
    }

    public SwipeRefreshLayout getSwipeRefreshLayout() {
        return swipeRefreshLayout;
    }

    protected void setToolbarTitle(@StringRes int title) {
        toolbarTitle.setText(getString(title));
    }

    protected void setToolbarTitle(String title) {
        toolbarTitle.setText(title);
    }

    protected ImageButton getToolbarBack() {
        return toolbarBack;
    }


    @Override
    public void showMessage(String message) {
        FancyToast.makeText(this, message, FancyToast.LENGTH_SHORT, FancyToast.DEFAULT, false).show();

    }

    public void showErrorPrompt(String error) {
        Toast toast = FancyToast.makeText(this, error, FancyToast.LENGTH_SHORT, FancyToast.ERROR, false);
        if (!toast.getView().isShown()) {
            toast.show();
        }
    }

    @Override
    public void showMessage(int resId) {
        showMessage(getString(resId));
    }


}
