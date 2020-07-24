package com.app.workit.view.ui.common.login;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.emailverification.EmailVerificationActivity;
import com.app.workit.view.ui.common.roleselection.RoleSelectActivity;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import timber.log.Timber;

public class LogInActivity extends MainBaseActivity {
    @BindView(R.id.btn_email)
    public Button btnEmail;
    @BindView(R.id.et_password)
    public WorkItEditText mPassword;

    @Inject
    DataManager dataManager;
    @Inject
    FirebaseAuth firebaseAuth;
    @Inject
    ViewModelFactory viewModelFactory;
    private LogInViewModel logInViewModel;
    public String email = "";
    private String token = "";


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_with_email);
        ButterKnife.bind(this);
        logInViewModel = ViewModelProviders.of(this, viewModelFactory).get(LogInViewModel.class);
        if (getIntent().getExtras() != null) {
            email = getIntent().getStringExtra(AppConstants.K_EMAIL);
            btnEmail.setText(email);
        }
        logInViewModel.getResponseLiveData().observe(this, response -> {
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
                    UserInfo userReponse = response.response;
                    userReponse.setFireAuthToken(token);
                    dataManager.saveUser(response.response);
                    if (response.response.getIsEmailVerified() == 1) {
                        startActivity(RoleSelectActivity.createIntent(this));
                    } else {
                        startActivity(EmailVerificationActivity.createIntent(this, response.response.getEmail(), mPassword.getText().toString().trim()));
                    }
                    finishAffinity();
                    break;


            }
        });
    }

    @Override
    protected void initView() {

    }


    public static Intent createIntent(Context context, String email) {
        Intent intent = new Intent(context, LogInActivity.class);
        intent.putExtra(AppConstants.K_EMAIL, email);
        return intent;
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    @OnClick(R.id.btn_login)
    public void onLogIn() {
        if (mPassword.getText().toString().trim().isEmpty()) {
            showErrorPrompt(R.string.enter_valid_password);
            return;
        }
        showLoading();

        firebaseAuth.signInWithEmailAndPassword(email, mPassword.getText().toString().trim())
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        try {

                            // Sign in success, update UI with the signed-in user's information
                            FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
                            firebaseUser.getIdToken(true).addOnCompleteListener(new OnCompleteListener<GetTokenResult>() {
                                @Override
                                public void onComplete(@NonNull Task<GetTokenResult> task) {
                                    hideLoading();
                                    if (task.isSuccessful()) {
                                        token = task.getResult().getToken();

                                        logInViewModel.getProfile(firebaseUser.getUid());
                                    } else {
                                        showMessage(task.getException().getMessage());
                                    }

                                }
                            }).addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    hideLoading();
                                    showMessage(e.getMessage());
                                }
                            });

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

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
