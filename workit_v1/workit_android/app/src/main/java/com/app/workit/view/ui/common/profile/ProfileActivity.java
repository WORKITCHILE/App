package com.app.workit.view.ui.common.profile;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.*;

import androidx.annotation.Nullable;

import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.app.workit.R;
import com.app.workit.WorkItApp;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Helper;
import com.app.workit.util.Timing;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.WorkItPlaceAutoCompleteAdapter;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.customview.edittext.WorkItAutoCompleteTextView;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.app.workit.view.ui.customview.magictext.MagicText;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.theartofdev.edmodo.cropper.CropImage;
import com.theartofdev.edmodo.cropper.CropImageView;
import de.hdodenhof.circleimageview.CircleImageView;
import timber.log.Timber;

public class ProfileActivity extends MainBaseActivity {


    @BindView(R.id.tv_credits)
    MagicText credits;
    @BindView(R.id.tv_email)
    MagicText email;
    @BindView(R.id.tv_id_number)
    MagicText idNumber;
    @BindView(R.id.iv_profile_pic)
    CircleImageView profilePic;
    @BindView(R.id.iv_id_pic)
    ImageButton idPic;
    @BindView(R.id.tv_name)
    TextView name;
    @BindView(R.id.tv_age)
    TextView age;
    @BindView(R.id.et_father_name)
    WorkItEditText fatherName;
    @BindView(R.id.et_mother_name)
    WorkItEditText motherName;
    @BindView(R.id.et_occupation)
    WorkItEditText occupation;
    @BindView(R.id.et_profile_desc)
    WorkItEditText profileDesc;
    @BindView(R.id.et_address)
    WorkItAutoCompleteTextView address;
    @BindView(R.id.edit_profile)
    FloatingActionButton fabProfile;
    @BindView(R.id.save_profile)
    TextView saveProfile;
    @BindView(R.id.spinner_countries)
    Spinner countries;


    @Inject
    ViewModelFactory viewModelFactory;
    @Inject
    DataManager dataManager;
    UserInfo userInfo;

    ProfileViewModel profileViewModel;
    boolean profileEditable;
    private String selectedCountry = "";
    private String uploadPath = "";
    private String profileImage;
    private List<String> countriesList;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        ButterKnife.bind(this);
        userInfo = dataManager.loadUser();
        profileViewModel = ViewModelProviders.of(this, viewModelFactory).get(ProfileViewModel.class);
    }

    @Override
    protected void initView() {
        try {
            countriesList = Helper.getCountries();
            profilePic.setClickable(false);
            initCountries();
            initAddress();

            profileViewModel.getProfile();

            profileViewModel.getUploadMutableLiveData().observe(this, new Observer<NetworkResponse<String>>() {
                @Override
                public void onChanged(NetworkResponse<String> response) {
                    render(response, 1);
                }
            });

            profileViewModel.getGetProfileLiveData().observe(this, new Observer<NetworkResponse<UserInfo>>() {
                @Override
                public void onChanged(NetworkResponse<UserInfo> userInfoNetworkResponse) {
                    render(userInfoNetworkResponse, 2);
                }
            });
            profileViewModel.getUpdateProfileLiveData().observe(this, new Observer<NetworkResponse<String>>() {
                @Override
                public void onChanged(NetworkResponse<String> response) {
                    render(response, 3);
                }
            });

        } catch (Exception e) {
            Timber.d(e);
        }


    }

    private void render(NetworkResponse response, int handle) {
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
                try {
                    if (handle == 1) {
                        profileImage = response.response.toString();
                        Glide.with(this).load(response.response).apply(new RequestOptions()
                                .error(R.drawable.rotate_spinner)
                                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(profilePic);
                    } else if (handle == 2) {
                        String fireAuthToken = userInfo.getFireAuthToken();
                        userInfo = (UserInfo) response.response;
                        userInfo.setFireAuthToken(fireAuthToken);
                        dataManager.saveUser((UserInfo) response.response);
                        String fullCredits = getString(R.string.txt_credits, userInfo.getCredits());
                        credits.change(fullCredits, ContextCompat.getColor(this, R.color.colorGrey), 14, "normal", userInfo.getCredits());

                        String fullEmail = getString(R.string.txt_email, userInfo.getEmail());
                        email.change(fullEmail, ContextCompat.getColor(this, R.color.colorGrey), 14, "normal", userInfo.getEmail());

                        String fullIDNumber = getString(R.string.txt_id_number, userInfo.getIdNumber());
                        idNumber.change(fullIDNumber, ContextCompat.getColor(this, R.color.colorGrey), 14, "normal", userInfo.getIdNumber());

                        Glide.with(this).load(userInfo.getProfilePicture()).apply(new RequestOptions()
                                .error(R.drawable.no_image_available)
                                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(profilePic);

                        Glide.with(this).load(userInfo.getIdImage1()).apply(new RequestOptions()
                                .error(R.drawable.no_image_available)
                                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(idPic);

                        fatherName.setText(userInfo.getFatherLastName());
                        motherName.setText(userInfo.getMotherLastName());
                        occupation.setText(userInfo.getOccupation());
                        profileDesc.setText(userInfo.getProfileDescription());

                        name.setText(userInfo.getName());
                        age.setText(getString(R.string.txt_age, getAge(Timing.getTimeInString(userInfo.getDateOfBirth(), Timing.TimeFormats.DD_MM_YYYY))));
                        countries.setSelection(getSelectedCountry(userInfo.getNationality()));
                        profileImage = userInfo.getProfilePicture();
                    } else if (handle == 3) {
                        showMessage(response.message);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                break;
        }
    }

    private int getSelectedCountry(String toCompare) {
        int i = -1;
        for (String name : countriesList) {
            i++;
            if (name.equalsIgnoreCase(toCompare) || name.contains(toCompare)) {
                return i;
            }
        }
        return i;
    }

    private void initAddress() {
        address.setHideUnderline(true);
        address.setText(userInfo.getAddress());
        WorkItPlaceAutoCompleteAdapter workItPlaceAutoCompleteAdapter = new WorkItPlaceAutoCompleteAdapter(this, R.layout.item_default_spinner
                , WorkItApp.getPlacesClient(), TypeFilter.ADDRESS);
        address.setShowClearButton(true);
        address.setAdapter(workItPlaceAutoCompleteAdapter);

    }


    private void initCountries() {

        ArrayAdapter<String> countryAdapter = new ArrayAdapter<>(this, R.layout.item_default_spinner, countriesList);
        countries.setAdapter(countryAdapter);
        countries.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedCountry = countriesList.get(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        countries.setEnabled(false);
    }

    @OnClick(R.id.iv_profile_pic)
    public void onProfile() {
        uploadPath = AppConstants.UPLOAD_PATH.profileImagePath;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }


    @OnClick(R.id.edit_profile)
    public void editProfile() {
        fabProfile.hide();
        saveProfile.setVisibility(View.VISIBLE);
        profileEditable = true;
        enableDisableProfile(true);

    }

    @OnClick(R.id.save_profile)
    public void saveProfile() {
        saveProfile.setVisibility(View.GONE);
        fabProfile.show();
        profileEditable = false;
        enableDisableProfile(false);
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_EMAIL, userInfo.getEmail());
        params.put(AppConstants.K_USER_ID, userInfo.getUserId());
        params.put(AppConstants.K_NAME, userInfo.getName());
        params.put(AppConstants.K_DATE_OF_BIRTH, userInfo.getDateOfBirth());
        params.put(AppConstants.K_ADDRESS, address.getText().toString());
        params.put(AppConstants.K_PROFILE_PICTURE, profileImage);
        params.put(AppConstants.K_MOBILE, userInfo.getContactNumber());
        params.put(AppConstants.K_ID_NUMBER, userInfo.getIdNumber());
        params.put(AppConstants.K_ID_IMAGE_1, userInfo.getIdImage1());
        params.put(AppConstants.K_FATHER_LAST_NAME, fatherName.getText().toString().trim());
        params.put(AppConstants.K_MOTHER_LAST_NAME, motherName.getText().toString().trim());
        params.put(AppConstants.K_OCCUPATION, occupation.getText().toString().trim());
        params.put(AppConstants.K_PROFILE_DESCRIPTION, profileDesc.getText().toString().trim());
        params.put(AppConstants.K_NATIONALITY, selectedCountry);

        profileViewModel.saveProfile(params);
    }

    public void enableDisableProfile(boolean state) {
        address.setEnabled(state);
        fatherName.setEnabled(state);
        motherName.setEnabled(state);
        occupation.setEnabled(state);
        profileDesc.setEnabled(state);
        countries.setEnabled(state);
        profilePic.setClickable(state);
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    private int getAge(String dobString) {

        Date date = null;
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        try {
            date = sdf.parse(dobString);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        if (date == null) return 0;

        Calendar dob = Calendar.getInstance();
        Calendar today = Calendar.getInstance();

        dob.setTime(date);

        int year = dob.get(Calendar.YEAR);
        int month = dob.get(Calendar.MONTH);
        int day = dob.get(Calendar.DAY_OF_MONTH);

        dob.set(year, month + 1, day);

        int age = today.get(Calendar.YEAR) - dob.get(Calendar.YEAR);

        if (today.get(Calendar.DAY_OF_YEAR) < dob.get(Calendar.DAY_OF_YEAR)) {
            age--;
        }


        return age;
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CropImage.CROP_IMAGE_ACTIVITY_REQUEST_CODE) {
            CropImage.ActivityResult result = CropImage.getActivityResult(data);
            if (resultCode == RESULT_OK) {
                Uri resultUri = result.getUri();

                profileViewModel.uploadProfilePicture(resultUri, uploadPath);


            } else if (resultCode == CropImage.CROP_IMAGE_ACTIVITY_RESULT_ERROR_CODE) {
                Exception error = result.getError();
            }
        }
    }
}
