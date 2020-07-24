package com.app.workit.view.ui.base;

import android.widget.Button;
import com.app.workit.view.ui.common.dialog.CommonDialog;

public interface BaseView {

    void showDialogProgress();

    void hideDialogProgress();

    void showLoading();

    void hideLoading();

    void hideKeyBoard();

    void showMessage(String message);

    void showMessage(int resId);

    void showErrorPrompt(String message);

    void showErrorPrompt(int resId);

    void setLoadingState(boolean state);

    void initButtonProgress(Button btn);

    void showButtonProgress(Button btn);

    void hideButtonProgress(String text, Button btn);

    void showDialog(String message, int action, int type, CommonDialog.CommonDialogCallback callback);

}
