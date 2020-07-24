package com.app.workit.view.ui.common.dialog;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.*;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.app.workit.R;
import com.app.workit.util.AppConstants;
import com.app.workit.view.ui.base.BaseDialogFragment;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

public class CommonDialog extends BaseDialogFragment {

    private Unbinder unbinder;
    @BindView(R.id.tv_header)
    TextView header;
    @BindView(R.id.tv_sub_header)
    TextView subHeader;
    @BindView(R.id.btn_cancel)
    Button btnCancel;
    @BindView(R.id.btn_ok)
    Button btnOk;
    @BindView(R.id.iv_tick)
    ImageView tick;
    @BindView(R.id.iv_warning)
    ImageView warning;
    @BindView(R.id.edit_text)
    WorkItEditText editText;
    @BindView(R.id.iv_credit)
    ImageView credit;

    private CommonDialogCallback commonDialogCallback;
    private int action;
    private boolean isCredit;


    public void setCommonDialogCallback(CommonDialogCallback commonDialogCallback) {
        this.commonDialogCallback = commonDialogCallback;
    }

    public static CommonDialog newInstance(int type, String message, String subHeader, int action) {

        Bundle args = new Bundle();
        args.putInt(AppConstants.K_ACTION, action);
        args.putString(AppConstants.K_TITLE, message);
        args.putInt(AppConstants.K_TYPE, type);
        args.putString(AppConstants.K_SUB_TITLE, subHeader);

        CommonDialog fragment = new CommonDialog();
        fragment.setArguments(args);
        fragment.setCancelable(false);
        return fragment;
    }

    public static CommonDialog newInstance(int type, String message) {

        Bundle args = new Bundle();
        args.putString(AppConstants.K_TITLE, message);
        args.putInt(AppConstants.K_TYPE, type);

        CommonDialog fragment = new CommonDialog();
        fragment.setArguments(args);
        fragment.setCancelable(false);
        return fragment;
    }

    public static CommonDialog newInstance(int type, String message, String okBtn, String cancelBtn) {

        Bundle args = new Bundle();
        args.putString(AppConstants.K_TITLE, message);
        args.putInt(AppConstants.K_TYPE, type);
        args.putString(AppConstants.K_YES, okBtn);
        args.putString(AppConstants.K_NO, cancelBtn);

        CommonDialog fragment = new CommonDialog();
        fragment.setCancelable(false);
        fragment.setArguments(args);
        return fragment;
    }


    public static CommonDialog newInstance(int type, String message, String subTitle, String okBtn, String cancelBtn, int action) {

        Bundle args = new Bundle();
        args.putString(AppConstants.K_TITLE, message);
        args.putInt(AppConstants.K_ACTION, action);
        args.putString(AppConstants.K_SUB_TITLE, subTitle);
        args.putInt(AppConstants.K_TYPE, type);
        args.putString(AppConstants.K_YES, okBtn);
        args.putString(AppConstants.K_NO, cancelBtn);

        CommonDialog fragment = new CommonDialog();
        fragment.setCancelable(false);
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.DialogStyle);
    }

    @Override
    public void onStart() {
        super.onStart();
        getDialog().getWindow().setWindowAnimations(
                R.style.dialog_slide_animation);
    }

    //    @Override
//    public int getTheme() {
//        return R.style.DialogAnimation;
//    }

    @Override
    protected void initViewsForFragment(View view) {
        if (getArguments() != null) {
            String message = getArguments().getString(AppConstants.K_TITLE);
            String subHeaderMessage = getArguments().getString(AppConstants.K_SUB_TITLE);
            action = getArguments().getInt(AppConstants.K_ACTION, 0);
            int type = getArguments().getInt(AppConstants.K_TYPE);
            header.setText(message);
            switch (type) {
                default:
                case AppConstants.DIALOG_TYPE.SUCCESS:
                    btnCancel.setVisibility(View.GONE);
                    warning.setVisibility(View.GONE);
                    if (message.isEmpty() && subHeaderMessage != null) {
                        subHeader.setText(subHeaderMessage);
                        showSubHeader();
                    } else {
                        hideSubHeader();
                    }
                    break;
                case AppConstants.DIALOG_TYPE.CONFIRMATION:
                    tick.setVisibility(View.GONE);
                    if (message.isEmpty() && subHeaderMessage != null) {
                        subHeader.setText(subHeaderMessage);
                        showSubHeader();
                    } else {
                        hideSubHeader();
                    }
                    warning.setVisibility(View.VISIBLE);
                    btnCancel.setVisibility(View.VISIBLE);
                    String yes = getArguments().getString(AppConstants.K_YES);
                    String no = getArguments().getString(AppConstants.K_NO);
                    btnOk.setText(yes == null ? getString(R.string.yes) : yes);
                    btnCancel.setText(no == null ? getString(R.string.no) : no);
                    break;
                case AppConstants.DIALOG_TYPE.CREDIT_ADD:
                    header.setVisibility(View.GONE);
                    subHeader.setVisibility(View.VISIBLE);
                    tick.setVisibility(View.GONE);
                    warning.setVisibility(View.GONE);
                    credit.setVisibility(View.VISIBLE);
                    btnCancel.setVisibility(View.GONE);
                    editText.setVisibility(View.VISIBLE);
                    subHeader.setText(subHeaderMessage);
                    isCredit = true;
                    break;
            }
        }
    }

    private void hideSubHeader() {
        subHeader.setVisibility(View.GONE);
        header.setVisibility(View.VISIBLE);
    }

    private void showSubHeader() {
        subHeader.setVisibility(View.VISIBLE);
        header.setVisibility(View.GONE);
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.common_dialog, container, false);
        unbinder = ButterKnife.bind(this, view);
        // Set transparent background and no title
        if (getDialog() != null && getDialog().getWindow() != null) {
            getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }
        return view;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @OnClick(R.id.btn_ok)
    public void onOk() {
        if (isCredit && editText.getText().toString().trim().isEmpty()) {
            showMessage(R.string.enter_min_credit_amount);
            return;

        }
        commonDialogCallback.onOkClicked(isCredit ? Integer.parseInt(editText.getText().toString().trim()) : action);
        dismiss();
    }

    @OnClick(R.id.btn_cancel)
    public void onCancel() {
        commonDialogCallback.onCancelClicked();
        dismiss();
    }

    public interface CommonDialogCallback {
        void onOkClicked(int action);

        void onCancelClicked();
    }

}
