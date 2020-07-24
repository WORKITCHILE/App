package com.app.workit.view.ui.common;

import android.content.Intent;
import android.os.Bundle;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.util.AppConstants;
import com.app.workit.util.FormValidatorUtil;
import com.app.workit.util.UIHelper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.login.LogInActivity;
import com.app.workit.view.ui.common.signup.SignUpActivity;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import com.google.android.material.snackbar.Snackbar;
import com.google.firebase.auth.*;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.List;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class MainActivity extends MainBaseActivity {

    @BindView(R.id.et_email)
    WorkItEditText email;

    @Inject
    DataManager dataManager;
    @Inject
    ViewModelFactory viewModelFactory;
    @Inject
    FirebaseAuth firebaseAuth;
    private GoogleSignInClient mGoogleSignInClient;
    private int RC_GOOGLE_SIGN_IN = 12;
    private CallbackManager callbackManager;
    private List<String> fbPermissionNeeds;
    private MainViewModel mainViewModel;
    private int socialLoginType;
    private String socialName;
    private String socailEmail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup_login);
        ButterKnife.bind(this);
        mainViewModel = ViewModelProviders.of(this, viewModelFactory).get(MainViewModel.class);

    }

    @Override
    protected void initView() {
        // Configure sign-in to request the user's ID, email address, and basic
        // profile. ID and basic profile are included in DEFAULT_SIGN_IN.
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(getString(R.string.google_sign_in_token))
                .requestEmail()
                .build();
        // Build a GoogleSignInClient with the options specified by gso.
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso);
        mGoogleSignInClient.signOut();
        //For Facebook
        callbackManager = CallbackManager.Factory.create();
        fbPermissionNeeds = Arrays.asList("user_photos", "email",
                "user_birthday", "public_profile", "AccessToken");
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                fetchFacebookData(loginResult);
            }


            @Override
            public void onCancel() {

            }

            @Override
            public void onError(FacebookException error) {
                showMessage(R.string.facebook_error);
            }
        });

        mainViewModel.getLoginLiveData().observe(this, stringNetworkResponse -> {
            switch (stringNetworkResponse.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(stringNetworkResponse.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    if (stringNetworkResponse.response.getUserId() != null) {

                    } else {
                        startActivity(SignUpActivity.createIntent(this, socailEmail, socialName, AppConstants.ACTIONS.SOCIAL_SIGNUP));
                    }

                    break;
            }
        });
    }

    private void fetchFacebookData(LoginResult loginResult) {
        GraphRequest request = GraphRequest.newMeRequest(
                loginResult.getAccessToken(),
                new GraphRequest.GraphJSONObjectCallback() {
                    @Override
                    public void onCompleted(JSONObject object,
                                            GraphResponse response) {
                        try {
                            String token;
                            token = object.getString("id");
                            //                            URL profile_pic = new URL(
//                                    "http://graph.facebook.com/" + id + "/picture?type=large");

                            //name = object.getString("name");
                            // email = object.getString("email");
                            // gender = object.getString("gender");
                            // birthday = object.getString("birthday");
                            socailEmail = object.getString(AppConstants.K_EMAIL);
                            socialName = object.getString(AppConstants.K_NAME);
                            mainViewModel.socialLogin(AppConstants.LOGIN_TYPE.FACEBOOK, token);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
    }

    @OnClick(R.id.btn_create_account)
    public void onCreateAccount() {

        UIHelper.getInstance().switchActivity(this, SignUpActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
    }

    @OnClick(R.id.btn_login)
    public void onLogin() {
        if (!FormValidatorUtil.isValidEmail(email.getText().toString().trim())) {
            email.setError(getString(R.string.please_enter_valid_email));
            return;
        }
        startActivity(LogInActivity.createIntent(this, email.getText().toString()));
        //    UIHelper.getInstance().switchActivity(this, LogInActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
    }

    @OnClick(R.id.login_with_google)
    public void loginWithGoogle() {
        signInWithGoogle();
    }

    @OnClick(R.id.login_with_facebook)
    public void loginWithFacebook() {
        LoginManager.getInstance().logInWithReadPermissions(
                this,
                fbPermissionNeeds
        );
    }


    private void signInWithGoogle() {
        Intent signInIntent = mGoogleSignInClient.getSignInIntent();
        startActivityForResult(signInIntent, RC_GOOGLE_SIGN_IN);
    }

    private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
        try {
            GoogleSignInAccount account = completedTask.getResult(ApiException.class);

            // Signed in successfully, show authenticated UI.
            //  updateUI(account);
//            firebaseAuthWithGoogle(account.getIdToken());
            socialLoginType = AppConstants.LOGIN_TYPE.GOOGLE;
            socailEmail = account.getEmail();
            socialName = account.getDisplayName();
            mainViewModel.socialLogin(AppConstants.LOGIN_TYPE.GOOGLE, account.getIdToken());
        } catch (ApiException e) {
            // The ApiException status code indicates the detailed failure reason.
            // Please refer to the GoogleSignInStatusCodes class reference for more information.
            showMessage(e.getMessage());
//            updateUI(null);
        }
    }

    private void firebaseAuthWithGoogle(String idToken) {
        // [START_EXCLUDE silent]
        showLoading();
        // [END_EXCLUDE]
        AuthCredential credential = GoogleAuthProvider.getCredential(idToken, null);
        firebaseAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        hideLoading();
                        if (task.isSuccessful()) {
                            // Sign in success, update UI with the signed-in user's information
                            showMessage(getString(R.string.msg_google_login_success));
                            // FirebaseUser user = mAuth.getCurrentUser();
                            //updateUI(user);
                        } else {
                            // If sign in fails, display a message to the user.
                            //updateUI(null);
                        }
                    }
                });
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        // Result returned from launching the Intent from GoogleSignInClient.getSignInIntent(...);
        if (requestCode == RC_GOOGLE_SIGN_IN) {
            // The Task returned from this call is always completed, no need to attach
            // a listener.
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            handleSignInResult(task);
        } else {
            callbackManager.onActivityResult(requestCode, resultCode, data);
        }
    }
}
