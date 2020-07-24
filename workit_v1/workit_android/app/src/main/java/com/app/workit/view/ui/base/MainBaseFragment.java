package com.app.workit.view.ui.base;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import androidx.annotation.StringRes;
import com.github.razir.progressbutton.ButtonTextAnimatorExtensionsKt;
import com.github.razir.progressbutton.DrawableButton;
import com.github.razir.progressbutton.DrawableButtonExtensionsKt;
import com.github.razir.progressbutton.ProgressButtonHolderKt;
import com.app.workit.R;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import dagger.android.support.DaggerFragment;
import kotlin.Unit;

import javax.inject.Inject;

public abstract class MainBaseFragment extends DaggerFragment implements BaseView {

    private Context mContext;
    private Activity mActivity;
    @Inject
    DataManager dataManager;
    protected UserInfo userInfo;

    protected abstract void initViewsForFragment(View view);

    protected abstract View inflateFragmentView(LayoutInflater inflater, ViewGroup container);

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflateFragmentView(inflater, container);
        setupUI(view);
        return view;

    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initViewsForFragment(view);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        userInfo = dataManager.loadUser();
        if (mContext == null)
            mContext = getActivity();

        if (mActivity == null)
            mActivity = getActivity();
    }

    @Override
    public void setLoadingState(boolean state) {

    }

    public Context getmContext() {
        return mContext;
    }

    public Activity getmActivity() {
        return mActivity;
    }

    @Override
    public void showDialogProgress() {

    }

    @Override
    public void hideDialogProgress() {

    }

    @Override
    public void showLoading() {

    }

    @Override
    public void hideLoading() {

    }

    @Override
    public void showErrorPrompt(int resId) {

    }


    @Override
    public void showMessage(int resId) {
        showMessage(getString(resId));
    }

    @Override
    public void showMessage(String message) {
        if (message != null) {
            showErrorPrompt(message);
        } else {
            showErrorPrompt(getString(R.string.some_error));
        }
    }


    public void showErrorPrompt(String error) {
        Toast toast = Toast.makeText(getmActivity(), error, Toast.LENGTH_LONG);
        if (!toast.getView().isShown()) {
            toast.show();
        }
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
        View view = getmActivity().getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) getmActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    public void setupUI(View view) {
        // Set up touch listener for non-text box views to hide keyboard.
        if (!(view instanceof EditText)) {
            view.setOnTouchListener((v, event) -> {
                hideKeyBoard();
                return false;
            });
        }

        //If a layout container, iterate over children and seed recursion.
        if (view instanceof ViewGroup) {
            for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
                View innerView = ((ViewGroup) view).getChildAt(i);
                setupUI(innerView);
            }
        }
    }

    @Override
    public void showDialog(String message, int action, int type, CommonDialog.CommonDialogCallback callback) {

    }
}
