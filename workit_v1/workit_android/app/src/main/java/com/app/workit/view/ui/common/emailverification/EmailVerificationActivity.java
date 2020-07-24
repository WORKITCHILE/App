package com.app.workit.view.ui.common.emailverification;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.mukesh.OnOtpCompletionListener;
import com.mukesh.OtpView;
import com.app.workit.R;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.util.AppConstants;
import com.app.workit.util.UIHelper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.SplashActivity;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

import timber.log.Timber;

import javax.inject.Inject;
import java.util.HashMap;

public class EmailVerificationActivity extends MainBaseActivity {

    @BindView(R.id.et_email)
    WorkItEditText email;
    @BindView(R.id.otp_view)
    OtpView otpView;
    @Inject
    ViewModelFactory viewModelFactory;
    @Inject
    FirebaseAuth firebaseAuth;

    private EmailVerificationViewModel verificationViewModel;
    private String currentEmail = "";
    private String currentPassword = "";

    public static Intent createIntent(Context context, String email, String password) {
        return new Intent(context, EmailVerificationActivity.class).putExtra(AppConstants.K_EMAIL, email)
                .putExtra(AppConstants.K_PASSWORD, password);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.verify_email_layout);
        ButterKnife.bind(this);
        verificationViewModel = ViewModelProviders.of(this, viewModelFactory).get(EmailVerificationViewModel.class);
        if (getIntent().getExtras() != null) {
            currentEmail = getIntent().getStringExtra(AppConstants.K_EMAIL) == null ? "" : getIntent().getStringExtra(AppConstants.K_EMAIL);
            currentPassword = getIntent().getStringExtra(AppConstants.K_PASSWORD) == null ? "" : getIntent().getStringExtra(AppConstants.K_PASSWORD);
        }
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    @Override
    protected void initView() {
        email.setText(currentEmail);
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_EMAIL, currentEmail);
        verificationViewModel.sendVerificationOTP(params);
        verificationViewModel.getSendOtpLiveData().observe(this, new Observer<NetworkResponse<String>>() {
            @Override
            public void onChanged(NetworkResponse<String> stringNetworkResponse) {
                render(stringNetworkResponse, 1);
            }
        });

        verificationViewModel.getVerifyEmailLiveData().observe(this, new Observer<NetworkResponse<String>>() {
            @Override
            public void onChanged(NetworkResponse<String> response) {
                render(response, 2);
            }
        });
        otpView.setOtpCompletionListener(new OnOtpCompletionListener() {
            @Override
            public void onOtpCompleted(String otp) {
                signInAndVerify(otp);
            }
        });


    }

    @OnClick(R.id.resend_otp)
    public void sendOtp() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_EMAIL, userInfo.getEmail());
        verificationViewModel.sendVerificationOTP(params);
    }

    public void signInAndVerify(String otp) {
        showLoading();
        firebaseAuth.signInWithEmailAndPassword(currentEmail, currentPassword)
                .addOnCompleteListener(task -> {
                    hideLoading();
                    if (task.isSuccessful()) {
                        try {
                            // Sign in success, update UI with the signed-in user's information
                            FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
                            // logInViewModel.getProfile(firebaseUser.getUid());
                            HashMap<String, Object> params = new HashMap<>();
                            params.put(AppConstants.K_USER_ID, firebaseUser.getUid());
                            params.put(AppConstants.K_EMAIL, currentEmail);
                            params.put(AppConstants.K_VERIFICATION_CODE, otp);
                            verificationViewModel.verifyEmail(params);

                            Timber.d(firebaseUser.toString());
                        } catch (Exception e) {
                            showMessage(e.getMessage());
                        }

                    } else {
                        // showMessage(R.string.some_error);
                    }
                })
                .addOnFailureListener(e -> {
                    hideLoading();
                    showMessage(e.getMessage());
                });
    }

    private void render(NetworkResponse<String> response, int handle) {
        switch (response.status) {
            case LOADING:
                showLoading();
                break;
            case ERROR:
                hideLoading();
                showErrorPrompt(response.message);
                break;
            case SUCCESS:
                hideLoading();
                if (handle == 1) {
                    //Handle OTP
                    showMessage(response.message);
                } else {
                    UIHelper.getInstance().switchActivity(this, SplashActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, true);
                }
                break;
        }
    }
}
