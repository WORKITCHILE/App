package com.app.workit.view.ui.base;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import com.github.razir.progressbutton.ButtonTextAnimatorExtensionsKt;
import com.github.razir.progressbutton.DrawableButton;
import com.github.razir.progressbutton.DrawableButtonExtensionsKt;
import com.github.razir.progressbutton.ProgressButtonHolderKt;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.iid.FirebaseInstanceId;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.util.CommonUtils;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.shashank.sony.fancytoastlib.FancyToast;
import dagger.android.AndroidInjection;
import dagger.android.AndroidInjector;
import dagger.android.DispatchingAndroidInjector;
import dagger.android.HasAndroidInjector;
import kotlin.Unit;
import timber.log.Timber;

import javax.inject.Inject;

public abstract class MainBaseActivity extends AppCompatActivity implements BaseView, HasAndroidInjector {

    @Inject
    protected DataManager dataManager;
    @Inject
    protected FirebaseAuth firebaseAuth;
    @Inject
    DispatchingAndroidInjector<Object> androidInjector;
    private AlertDialog mProgressDialog;
    protected UserInfo userInfo;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        AndroidInjection.inject(this);
        super.onCreate(savedInstanceState);
        userInfo = dataManager.loadUser();

        FirebaseUser currentUser = firebaseAuth.getCurrentUser();
        if (currentUser != null) {
            currentUser.getIdToken(true).addOnCompleteListener(task -> {
                if (task.isSuccessful() && currentUser.getUid().equalsIgnoreCase(userInfo.getUserId())) {
                    userInfo.setFireAuthToken(task.getResult().getToken());
                    dataManager.saveUser(userInfo);
                }
            });
        }

        getToken();

    }

    @Override
    protected void onPostCreate(@Nullable Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        initView();
    }

    protected abstract void initView();

    @Override
    public AndroidInjector<Object> androidInjector() {
        return androidInjector;
    }

    @Override
    public void setLoadingState(boolean state) {

    }

    @Override
    public void showDialogProgress() {
        hideKeyBoard();
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
        mProgressDialog = CommonUtils.showDialogProgressBar(this);
        mProgressDialog.show();
    }

    @Override
    public void hideDialogProgress() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }

    @Override
    public void showLoading() {
        hideKeyBoard();
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
        mProgressDialog = CommonUtils.showDialogProgressBar(this);
        mProgressDialog.show();
    }

    @Override
    public void hideLoading() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }

    @Override
    public void showMessage(int resId) {
        showMessage(getString(resId));
    }

    @Override
    public void showMessage(String message) {
        FancyToast.makeText(this, message, FancyToast.LENGTH_SHORT, FancyToast.DEFAULT, false).show();
    }

    @Override
    public void initButtonProgress(Button btn) {
        ProgressButtonHolderKt.bindProgressButton(this, btn);
        ButtonTextAnimatorExtensionsKt.attachTextChangeAnimator(btn, textChangeAnimatorParams -> {
            textChangeAnimatorParams.setFadeInMills(300);
            textChangeAnimatorParams.setFadeOutMills(300);
            return Unit.INSTANCE;
        });
    }

    @Override
    public void showButtonProgress(Button btn) {
        hideKeyBoard();
        DrawableButtonExtensionsKt.showProgress(btn, progressParams -> {
            progressParams.setButtonText(getString(R.string.loading));
            progressParams.setProgressColor(Color.WHITE);
            progressParams.setGravity(DrawableButton.GRAVITY_CENTER);
            return Unit.INSTANCE;
        });
        btn.setEnabled(false);
    }


    public void hideButtonProgress(@StringRes int text, Button btn) {
        hideButtonProgress(getString(text), btn);
    }

    @Override
    public void hideButtonProgress(String text, Button btn) {
        hideKeyBoard();
        btn.setEnabled(true);
        DrawableButtonExtensionsKt.hideProgress(btn, text);
    }

    @Override
    public void hideKeyBoard() {
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    @Override
    public void showErrorPrompt(int resId) {
        showErrorPrompt(getString(resId));
    }

    @Override
    public void showErrorPrompt(String message) {
        FancyToast.makeText(this, message, FancyToast.LENGTH_SHORT, FancyToast.ERROR, false).show();
    }

    public void getToken() {
        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        Timber.d(task.getException());
                        return;
                    }

                    // Get new Instance ID token
                    String token = task.getResult().getToken();
                    dataManager.saveFireBaseToken(token);

                });

    }

    @Override
    public void showDialog(String message, int action, int type, CommonDialog.CommonDialogCallback callback) {
        CommonDialog commonDialog = CommonDialog.newInstance(type, "", message, action);
        commonDialog.setCommonDialogCallback(callback);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }
}

