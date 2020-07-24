package com.app.workit.view.ui.common.support;

import android.os.Bundle;

import android.widget.Button;
import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import com.app.workit.R;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

import javax.inject.Inject;
import java.util.HashMap;

public class SupportActivity extends BaseActivity implements CommonDialog.CommonDialogCallback {


    private static final int RC_SUCCESS = 3;
    @BindView(R.id.comment)
    WorkItEditText comment;
    @BindView(R.id.btnSend)
    Button btnSend;
    @Inject
     ViewModelFactory viewModelFactory;
    private SupportViewModel supportViewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_support);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.support);
        supportViewModel = ViewModelProviders.of(this, viewModelFactory).get(SupportViewModel.class);
    }

    @Override
    protected void initView() {
        supportViewModel.getSupportLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showButtonProgress(btnSend);
                    break;
                case ERROR:
                    hideButtonProgress(R.string.send, btnSend);
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideButtonProgress(R.string.send, btnSend);
                    showDialog(getString(R.string.msg_support_success), RC_SUCCESS, AppConstants.DIALOG_TYPE.SUCCESS, this);
                    break;

            }
        });
    }

    @OnTextChanged(value = R.id.comment, callback = OnTextChanged.Callback.AFTER_TEXT_CHANGED)
    public void commentChanged(CharSequence text) {
        //do stuff
        btnSend.setEnabled(!text.toString().trim().isEmpty());
    }

    @OnClick(R.id.btnSend)
    public void onSend() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_USER_ID, userInfo.getUserId());
        params.put(AppConstants.K_MESSAGE, comment.getText().toString().trim());
        supportViewModel.support(params);
    }

    @Override
    public void onOkClicked(int action) {
        if (action == RC_SUCCESS) {
            setResult(RESULT_OK);
            finish();
        }
    }

    @Override
    public void onCancelClicked() {

    }
}
