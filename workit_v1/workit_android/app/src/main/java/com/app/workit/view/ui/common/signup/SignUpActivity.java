package com.app.workit.view.ui.common.signup;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Pair;
import android.view.View;
import android.widget.*;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;

import br.com.sapereaude.maskedEditText.MaskedEditText;
import com.app.workit.util.*;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.github.florent37.singledateandtimepicker.dialog.SingleDateAndTimePickerDialog;
import com.github.razir.progressbutton.ButtonTextAnimatorExtensionsKt;
import com.github.razir.progressbutton.DrawableButton;
import com.github.razir.progressbutton.DrawableButtonExtensionsKt;
import com.github.razir.progressbutton.ProgressButtonHolderKt;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.hbb20.CountryCodePicker;
import com.app.workit.R;
import com.app.workit.WorkItApp;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.view.adapter.WorkItPlaceAutoCompleteAdapter;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.common.emailverification.EmailVerificationActivity;
import com.app.workit.view.ui.customview.edittext.WorkItAutoCompleteTextView;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.theartofdev.edmodo.cropper.CropImage;
import com.theartofdev.edmodo.cropper.CropImageView;

import java.util.*;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnFocusChange;
import dagger.android.AndroidInjection;
import kotlin.Unit;

public class SignUpActivity extends MainBaseActivity implements SingleDateAndTimePickerDialog.Listener, CommonDialog.CommonDialogCallback {


    @BindView(R.id.btn_upload_profile)
    ImageButton profilePic;
    @BindView(R.id.iv_id_image)
    ImageView document1;
    @BindView(R.id.btn_upload_document_1)
    LinearLayout containerDocument1;
    //    @BindView(R.id.btn_upload_document_2)
//    ImageButton document2;
    @BindView(R.id.et_profile_desc)
    WorkItEditText profileDesc;
    @BindView(R.id.et_name)
    WorkItEditText name;
    @BindView(R.id.et_father_name)
    WorkItEditText fatherName;
    @BindView(R.id.et_mother_name)
    WorkItEditText motherName;
    @BindView(R.id.et_occupation)
    WorkItEditText occupation;
    @BindView(R.id.et_id_number)
    WorkItEditText idNumber;
    @BindView(R.id.et_dob)
    WorkItEditText dateOfBirth;
    @BindView(R.id.et_address)
    WorkItAutoCompleteTextView address;
    @BindView(R.id.et_mobile)
    WorkItEditText mobile;
    @BindView(R.id.et_email)
    WorkItEditText email;
    @BindView(R.id.et_password)
    WorkItEditText password;
    @BindView(R.id.et_confirm_password)
    WorkItEditText confirmPassword;
    @BindView(R.id.spinner_countries)
    Spinner nationalities;
    @BindView(R.id.cb_terms_and_condition)
    CheckBox termsAndCondition;
    @BindView(R.id.btn_finish)
    Button btnFinish;
    @BindView(R.id.ccp)
    CountryCodePicker countryCodePicker;
    @Inject
    ViewModelFactory viewModelFactory;
    @Inject
    DataManager dataManager;
    private SignUpViewModel signUpViewmModel;

    private String uploadPath = "";
    private String profileImage = "";
    private String idImage1 = "";
    private String idImage2 = "";
    private int imageType;
    private SingleDateAndTimePickerDialog dobBuilder;
    private long dob;
    private String socailEmail;
    private String socailName;
    private String selectedNationality = "";

    public static Intent createIntent(Context context, String email) {
        Intent intent = new Intent(context, SignUpActivity.class);
        intent.putExtra(AppConstants.K_EMAIL, email);
        return intent;
    }

    public static Intent createIntent(Context context, String email, String name, String action) {
        Intent intent = new Intent(context, SignUpActivity.class);
        intent.putExtra(AppConstants.K_EMAIL, email)
                .putExtra(AppConstants.K_NAME, name)
                .setAction(action);
        return intent;
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        AndroidInjection.inject(this);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);
        ButterKnife.bind(this);
        ProgressButtonHolderKt.bindProgressButton(this, btnFinish);
        ButtonTextAnimatorExtensionsKt.attachTextChangeAnimator(btnFinish, textChangeAnimatorParams -> {
            textChangeAnimatorParams.setFadeInMills(300);
            textChangeAnimatorParams.setFadeOutMills(300);
            return Unit.INSTANCE;
        });

    }

    @Override
    protected void initView() {
        if (getIntent().getAction() != null && getIntent().getAction().equalsIgnoreCase(AppConstants.ACTIONS.SOCIAL_SIGNUP)) {
            showMessage(R.string.msg_social_signup);
        }
        if (getIntent().getExtras() != null) {
            socailEmail = getIntent().getStringExtra(AppConstants.K_EMAIL);
            socailName = getIntent().getStringExtra(AppConstants.K_NAME);
            email.setText(socailEmail);
            name.setText(socailName);
        }
        signUpViewmModel = ViewModelProviders.of(this, viewModelFactory).get(SignUpViewModel.class);
        signUpViewmModel.getUploadMutableLiveData().observe(this, stringNetworkResponse -> render(stringNetworkResponse, 1));
        signUpViewmModel.getMutableLiveData().observe(this, response -> render(response, 2));


        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.YEAR, -18);

        dobBuilder = new SingleDateAndTimePickerDialog.Builder(this)
                .bottomSheet()
                .curved()
                .setTimeZone(TimeZone.getDefault())
                .maxDateRange(calendar.getTime())
                .defaultDate(calendar.getTime())
                .displayMinutes(false)
                .displayHours(false)
                .displayDays(false)
                .displayMonth(true)
                .displayYears(true)
                .displayDaysOfMonth(true)
                .listener(this)
                .build();

        initAddress();
        initCountries();
    }


    public void initAddress() {
        WorkItPlaceAutoCompleteAdapter workItPlaceAutoCompleteAdapter = new WorkItPlaceAutoCompleteAdapter(this, R.layout.item_default_spinner
                , WorkItApp.getPlacesClient(), TypeFilter.ADDRESS);
        address.setShowClearButton(true);
        address.setAdapter(workItPlaceAutoCompleteAdapter);
    }


    private void initCountries() {
        List<String> countries = Helper.getCountries();

        countries.add(0, getString(R.string.nationality));

        ArrayAdapter<String> countryAdapter = new ArrayAdapter<>(this, R.layout.item_default_spinner, countries);
        nationalities.setAdapter(countryAdapter);
        nationalities.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedNationality = countries.get(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    public void render(NetworkResponse networkResponse, int type) {
        if (networkResponse.status == NetworkResponse.Status.LOADING) {
            switch (type) {
                case 1:
                    showLoading();
                    break;
                case 2:
                    showBtnProgress(btnFinish);
                    break;
            }
        } else if (networkResponse.status == NetworkResponse.Status.ERROR) {
            hideLoading();
            showErrorPrompt(networkResponse.message);
            hideBtnProgress(btnFinish);
        } else {
            hideLoading();
            hideBtnProgress(btnFinish);
            switch (type) {
                case 1:
                    if (imageType == AppConstants.IMAGE_TYPE.PROFILE) {
                        profileImage = networkResponse.response.toString();
                        Glide.with(this).load(networkResponse.response).apply(new RequestOptions()
                                .error(R.drawable.rotate_spinner)
                                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(profilePic);
                    } else if (imageType == AppConstants.IMAGE_TYPE.ID_PICTURE1) {
                        containerDocument1.setVisibility(View.GONE);
                        document1.setVisibility(View.VISIBLE);
                        idImage1 = networkResponse.response.toString();
                        Glide.with(this).load(networkResponse.response).apply(new RequestOptions()
                                .error(R.drawable.rotate_spinner)
                                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(document1);
                    } else if (imageType == AppConstants.IMAGE_TYPE.ID_PICTURE2) {
                        idImage2 = networkResponse.response.toString();

                    }

                    break;
                case 2:
                    showMessage(networkResponse.message);
                    showSuccessDialog();
                    break;
            }
        }
    }

    private void showSuccessDialog() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.SUCCESS, getString(R.string.thank_you_your_account_has_been_created));
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }


    private void showBtnProgress(final Button button) {
        DrawableButtonExtensionsKt.showProgress(button, progressParams -> {
            progressParams.setButtonText(getString(R.string.loading));
            progressParams.setProgressColor(Color.WHITE);
            progressParams.setGravity(DrawableButton.GRAVITY_CENTER);
            return Unit.INSTANCE;
        });
        button.setEnabled(false);

    }

    private void hideBtnProgress(final Button button) {
        button.setEnabled(true);
        DrawableButtonExtensionsKt.hideProgress(button, R.string.finish);
    }

    @OnClick(R.id.btn_finish)
    public void onFinish() {
        Pair<Boolean, EditText> formValid = FormValidatorUtil.isFormValid(profileDesc, name, fatherName, motherName, occupation, idNumber
                , dateOfBirth, address, mobile, email, password);
        boolean isValid = formValid.first;
        EditText notValidField = formValid.second;
        if (isValid) {
            if (selectedNationality.isEmpty() || selectedNationality.equalsIgnoreCase(getString(R.string.nationality))) {
                showMessage(getString(R.string.field_required, getString(R.string.nationality)));
                return;
            }
            if (!FormValidatorUtil.isValidBothPassword(password.getText().toString().trim(), confirmPassword.getText().toString().trim())) {
                showMessage(R.string.password_mismatch);
                return;
            }
            if (!termsAndCondition.isChecked()) {
                showMessage(R.string.check_our_terms_and_conditions);
                return;
            }
            String fullNumber = countryCodePicker.getSelectedCountryCodeWithPlus() + mobile.getText().toString().trim();

            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_PROFILE_DESCRIPTION, profileDesc.getText().toString().trim());
            params.put(AppConstants.K_NAME, name.getText().toString().trim());
            params.put(AppConstants.K_FATHER_LAST_NAME, fatherName.getText().toString().trim());
            params.put(AppConstants.K_MOTHER_LAST_NAME, motherName.getText().toString().trim());
            params.put(AppConstants.K_OCCUPATION, occupation.getText().toString().trim());
            params.put(AppConstants.K_ID_NUMBER, idNumber.getText().toString().trim());
            params.put(AppConstants.K_DATE_OF_BIRTH, dob);
            params.put(AppConstants.K_ADDRESS, address.getText().toString().trim());
            params.put(AppConstants.K_MOBILE, fullNumber);
            params.put(AppConstants.K_EMAIL, email.getText().toString().trim());
            params.put(AppConstants.K_PASSWORD, password.getText().toString().trim());
            params.put(AppConstants.K_NATIONALITY, selectedNationality.trim());
            params.put(AppConstants.K_ID_IMAGE_1, idImage1);
            params.put(AppConstants.K_ID_IMAGE_2, idImage2);
            params.put(AppConstants.K_PROFILE_PICTURE, profileImage);
            params.put(AppConstants.K_FCM_TOKEN, dataManager.getFireBaseToken());
            params.put(AppConstants.K_CREDITS, 0.00);
            params.put(AppConstants.K_GOOGLE_HANDLE, " ");
            params.put(AppConstants.K_FACEBOOK_HANDLE, " ");

            signUpViewmModel.signUp(params);
        } else {
            notValidField.requestFocus();
            showErrorPrompt(getString(R.string.field_required, notValidField.getHint()));
        }

    }


    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }


    @OnClick(R.id.et_dob)
    public void onDob() {
        showDOBPicker();
    }

    @OnFocusChange(R.id.et_dob)
    public void onDob(boolean hasFocus) {
        if (hasFocus) {
            showDOBPicker();
        }
    }

    private void showDOBPicker() {
        if (!dobBuilder.isDisplaying()) {
            dobBuilder.display();
        }

    }

    @OnClick(R.id.btn_upload_profile)
    public void onUploadProfile() {
// start picker to get image for cropping and then use the image in cropping activity
        imageType = AppConstants.IMAGE_TYPE.PROFILE;
        uploadPath = AppConstants.UPLOAD_PATH.profileImagePath;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }

    @OnClick(R.id.btn_upload_document_1)
    public void onUploadDocument1() {
        uploadPath = AppConstants.UPLOAD_PATH.documentImagePath;
        imageType = AppConstants.IMAGE_TYPE.ID_PICTURE1;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }

    @OnClick(R.id.iv_id_image)
    public void onUploadIDImage1() {
        uploadPath = AppConstants.UPLOAD_PATH.documentImagePath;
        imageType = AppConstants.IMAGE_TYPE.ID_PICTURE1;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }

    @OnClick(R.id.btn_upload_document_2)
    public void onUploadDocument2() {
        uploadPath = AppConstants.UPLOAD_PATH.documentImagePath;
        imageType = AppConstants.IMAGE_TYPE.ID_PICTURE2;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CropImage.CROP_IMAGE_ACTIVITY_REQUEST_CODE) {
            CropImage.ActivityResult result = CropImage.getActivityResult(data);
            if (resultCode == RESULT_OK) {
                Uri resultUri = result.getUri();

                signUpViewmModel.uploadProfilePicture(resultUri, uploadPath);


            } else if (resultCode == CropImage.CROP_IMAGE_ACTIVITY_RESULT_ERROR_CODE) {
                Exception error = result.getError();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }


    @Override
    public void onDateSelected(Date date) {
        dateOfBirth.setText(Timing.getTimeInStringWithoutStamp(date.getTime(), Timing.TimeFormats.DD_MM_YYYY));
        dob = date.getTime() / 1000;
    }

    @Override
    public void onOkClicked(int action) {
        startActivity(EmailVerificationActivity.createIntent(this, email.getText().toString().trim(), password.getText().toString().trim()));
        this.finishAffinity();
    }

    @Override
    public void onCancelClicked() {

    }
}
