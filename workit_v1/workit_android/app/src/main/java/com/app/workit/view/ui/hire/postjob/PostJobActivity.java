package com.app.workit.view.ui.hire.postjob;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.Pair;
import android.view.View;
import android.widget.*;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.github.florent37.singledateandtimepicker.dialog.SingleDateAndTimePickerDialog;
import com.github.razir.progressbutton.ButtonTextAnimatorExtensionsKt;
import com.github.razir.progressbutton.DrawableButton;
import com.github.razir.progressbutton.DrawableButtonExtensionsKt;
import com.github.razir.progressbutton.ProgressButtonHolderKt;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.google.android.libraries.places.api.net.FetchPlaceRequest;
import com.app.workit.R;
import com.app.workit.WorkItApp;
import com.app.workit.data.model.Category;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.SubCategory;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.model.JobApproach;
import com.app.workit.model.LocationModel;
import com.app.workit.model.PlaceAutocomplete;
import com.app.workit.mvvm.MVVMBaseView;
import com.app.workit.util.*;
import com.app.workit.util.map.MapHelper;
import com.app.workit.view.adapter.ImageListAdapter;
import com.app.workit.view.adapter.WorkItPlaceAutoCompleteAdapter;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.common.map.MapActivity;
import com.app.workit.view.ui.customview.ProgressWheel;
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
import io.reactivex.disposables.Disposable;
import kotlin.Unit;

public class PostJobActivity extends BaseActivity implements MVVMBaseView, OnMapReadyCallback, CommonDialog.CommonDialogCallback {

    private static final int RC_POSTED_SUCCESS = 12;
    @BindView(R.id.et_name_of_the_work)
    WorkItEditText nameOfTheWork;
    @BindView(R.id.et_job_desc)
    WorkItEditText jobDescription;
    @BindView(R.id.et_address)
    WorkItAutoCompleteTextView address;
    @BindView(R.id.spinner_categories)
    Spinner spinnerCategories;
    @BindView(R.id.spinner_sub_categories)
    Spinner spinnerSubCategories;
    @BindView(R.id.spinner_job_approach)
    Spinner spinnerJobApproach;
    @BindView(R.id.et_work_date)
    WorkItEditText workDate;
    @BindView(R.id.et_work_time)
    WorkItEditText workTime;
    @BindView(R.id.et_amount)
    WorkItEditText amount;
    @BindView(R.id.rv_images)
    RecyclerView imagesRecyclerView;
    @BindView(R.id.image_loading)
    ProgressWheel imageLoading;
    @BindView(R.id.btn_post_job)
    Button btnPostjob;
    @BindView(R.id.switcher_upload_photo)
    ViewSwitcher switcherUploadPhoto;
    @BindView(R.id.tv_add_image)
    public TextView addImage;

    @Inject
    ViewModelFactory viewModelFactory;

    PostJobViewModel postJobViewModel;
    private List<Category> categories = new ArrayList<>();
    private List<SubCategory> subCategories = new ArrayList<>();
    private Category selectedCategory;
    private ArrayAdapter<Category> categoryArrayAdapter;
    private ArrayAdapter<SubCategory> subCategoryArrayAdapter;
    private List<JobApproach> jobApproaches;
    private ArrayAdapter<JobApproach> jobArrayAdapter;
    private JobApproach selectedJobApproach;
    private SubCategory selectedSubCategory;
    private long jobDate;
    private long jobTime;
    private List<String> images = new ArrayList<>();
    private ImageListAdapter imageListAdapter;
    private String uploadPath;
    private SingleDateAndTimePickerDialog datePicker;
    private SingleDateAndTimePickerDialog timePicker;
    private LocationModel currentlocation;
    private Disposable currentDisposable;
    private GoogleMap mMap;
    private String actionType = "";
    private String currentJobId = "";
    private boolean isRepost;
    private MapHelper mapHelper;


    public static Intent createIntent(Context context) {
        return new Intent(context, PostJobActivity.class).setAction(AppConstants.ACTIONS.POST_JOB);
    }

    public static Intent createIntent(Context context, String jobId) {
        return new Intent(context, PostJobActivity.class).putExtra(AppConstants.K_JOB_ID, jobId).setAction(AppConstants.ACTIONS.EDIT_JOB);
    }

    public static Intent createIntent(Context context, String jobId, boolean repost) {
        return new Intent(context, PostJobActivity.class).putExtra(AppConstants.K_JOB_ID, jobId)
                .putExtra(AppConstants.K_REPOST, repost).setAction(AppConstants.ACTIONS.EDIT_JOB);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_a_job);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.post_a_job);
        postJobViewModel = ViewModelProviders.of(this, viewModelFactory).get(PostJobViewModel.class);
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        ProgressButtonHolderKt.bindProgressButton(this, btnPostjob);
        ButtonTextAnimatorExtensionsKt.attachTextChangeAnimator(btnPostjob, textChangeAnimatorParams -> {
            textChangeAnimatorParams.setFadeInMills(300);
            textChangeAnimatorParams.setFadeOutMills(300);
            return Unit.INSTANCE;
        });

    }

    @Override
    protected void initView() {
        if (getIntent().getAction() != null) {
            actionType = getIntent().getAction();
        }
        isRepost = getIntent().hasExtra(AppConstants.K_REPOST);
        if (actionType.equalsIgnoreCase(AppConstants.ACTIONS.EDIT_JOB)) {
            btnPostjob.setText(R.string.save);
            currentJobId = getIntent().getStringExtra(AppConstants.K_JOB_ID);
            initGetJob(currentJobId);
        } else {
            btnPostjob.setText(R.string.post);
        }


        datePicker = new SingleDateAndTimePickerDialog.Builder(this)
                .bottomSheet()
                .curved()
                .setTimeZone(TimeZone.getDefault())
                .mustBeOnFuture()
                .displayMinutes(false)
                .displayHours(false)
                .displayDays(false)
                .displayMonth(true)
                .displayYears(true)
                .displayDaysOfMonth(true)
                .listener(date -> {
                    jobDate = date.getTime();
                    workDate.setText(Timing.getTimeInStringWithoutStamp(date.getTime(), Timing.TimeFormats.YYYY_MM_DD));
                })
                .build();

        timePicker = new SingleDateAndTimePickerDialog.Builder(this)
                .bottomSheet()
                .curved()
                .setTimeZone(TimeZone.getDefault())
                .mustBeOnFuture()
                .displayMonth(false)
                .displayYears(false)
                .displayDaysOfMonth(false)
                .displayDays(false)
                .displayMinutes(true)
                .displayHours(true)
                .listener(date -> {
                    jobTime = date.getTime();
                    workTime.setText(Timing.getTimeInStringWithoutStamp(jobTime, Timing.TimeFormats.HH_12));
                })
                .build();
        initCategories();
        initSubCategories();
        initJobApproach();
        initImages();
        initAddress();

        currentDisposable = RxBus.getInstance().getEvents().subscribe(o -> {

            if (o instanceof LocationModel) {
                currentlocation = (LocationModel) o;
                mMap.clear();
                addMarker(currentlocation);
            }
        });

        postJobViewModel.getPostJobLiveData().observe(this, stringNetworkResponseList -> render(stringNetworkResponseList, String.class));
        postJobViewModel.getRepostJobLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showBtnProgress(btnPostjob);
                    break;
                case ERROR:
                    hideLoading();
                    hideBtnProgress(btnPostjob);
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    hideBtnProgress(btnPostjob);
                    setResult(RESULT_OK);
                    finish();
            }
        });
    }

    private void initGetJob(String jobId) {
        postJobViewModel.getJobInfo(jobId);
        postJobViewModel.getJobInfoLiveData().observe(this, new Observer<NetworkResponse<Job>>() {
            @Override
            public void onChanged(NetworkResponse<Job> jobNetworkResponse) {
                render(jobNetworkResponse, Job.class);
            }
        });
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
        DrawableButtonExtensionsKt.hideProgress(button, R.string.post);
    }


    private void addMarker(LocationModel currentlocation) {
        LatLng newLatLng = new LatLng(currentlocation.getLatitude(), currentlocation.getLongitude());
        Marker marker = mMap.addMarker(new MarkerOptions().position(newLatLng).icon(bitmapDescriptorFromVector(this, R.drawable.ic_marker)));
        CameraPosition cameraPosition = new CameraPosition.Builder().target(newLatLng).zoom(16.0f).build();
        CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
        mMap.animateCamera(cameraUpdate);
    }

    private BitmapDescriptor bitmapDescriptorFromVector(Context context, int vectorResId) {
        Drawable vectorDrawable = ContextCompat.getDrawable(context, vectorResId);
        vectorDrawable.setBounds(0, 0, vectorDrawable.getIntrinsicWidth(), vectorDrawable.getIntrinsicHeight());
        Bitmap bitmap = Bitmap.createBitmap(vectorDrawable.getIntrinsicWidth(), vectorDrawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        vectorDrawable.draw(canvas);
        return BitmapDescriptorFactory.fromBitmap(bitmap);
    }


    private void initAddress() {
        WorkItPlaceAutoCompleteAdapter workItPlaceAutoCompleteAdapter = new WorkItPlaceAutoCompleteAdapter(this, R.layout.item_default_spinner
                , WorkItApp.getPlacesClient(), TypeFilter.ADDRESS);
        address.setShowClearButton(true);
        address.setAdapter(workItPlaceAutoCompleteAdapter);
        address.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PlaceAutocomplete item = (PlaceAutocomplete) parent.getItemAtPosition(position);
                findPositionOnMap(item.getPlaceId(), item.getAddress());
            }
        });

    }

    private void findPositionOnMap(String placeId, String address) {
        // Define a Place ID.
        showLoading();
        // Specify the fields to return.
        List<com.google.android.libraries.places.api.model.Place.Field> placeFields = Arrays.asList(com.google.android.libraries.places.api.model.Place.Field.ID, com.google.android.libraries.places.api.model.Place.Field.NAME,
                Place.Field.LAT_LNG);

        // Construct a request object, passing the place ID and fields array.
        FetchPlaceRequest request = FetchPlaceRequest.newInstance(placeId, placeFields);

        WorkItApp.getPlacesClient().fetchPlace(request).addOnSuccessListener((response) -> {
            hideLoading();
            try {
                com.google.android.libraries.places.api.model.Place place = response.getPlace();
                mMap.clear();
                mapHelper.addMarker(place.getLatLng().latitude, place.getLatLng().longitude, R.drawable.marker, 16, true);
                currentlocation = new LocationModel();
                currentlocation.setLatitude(place.getLatLng().latitude);
                currentlocation.setLongitude(place.getLatLng().longitude);
                currentlocation.setAddress(address);
            } catch (Exception e) {
                showMessage(e.getMessage());
            }


        }).addOnFailureListener((exception) -> {
            hideLoading();
            if (exception instanceof ApiException) {
                ApiException apiException = (ApiException) exception;
                int statusCode = apiException.getStatusCode();
                // Handle error with given status code.
            }
        });


    }

    private void initImages() {
        postJobViewModel.getUploadMutableLiveData().observe(this, stringNetworkResponse -> render(stringNetworkResponse, String.class));
        imagesRecyclerView.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        imageListAdapter = new ImageListAdapter(this, R.layout.item_image, 3);
        imagesRecyclerView.setAdapter(imageListAdapter);


    }

    private void initJobApproach() {
        jobApproaches = Helper.getJobApproach(this);
        jobArrayAdapter = new ArrayAdapter<>(this, R.layout.item_default_spinner, jobApproaches);
        spinnerJobApproach.setAdapter(jobArrayAdapter);
        spinnerJobApproach.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedJobApproach = jobApproaches.get(position);
                // selectedCategory = categories.get(position);
                // postJobViewModel.getSubCategories(selectedCategory.getCategoryId());

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }


    private void initCategories() {
        postJobViewModel.getCategories();
        postJobViewModel.getCategoryLiveData().observe(this, categoryNetworkResponseList -> render(categoryNetworkResponseList, Category.class));
        categoryArrayAdapter = new ArrayAdapter<>(this, R.layout.item_default_spinner, categories);
        spinnerCategories.setAdapter(categoryArrayAdapter);
        spinnerCategories.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedCategory = categories.get(position);
                postJobViewModel.getSubCategories(selectedCategory.getCategoryId());

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }


    private void initSubCategories() {
        postJobViewModel.getSubCategoryLiveData().observe(this, subCategoryNetworkResponseList -> render(subCategoryNetworkResponseList, SubCategory.class));
        subCategoryArrayAdapter = new ArrayAdapter<>(this, R.layout.item_default_spinner, subCategories);
        spinnerSubCategories.setAdapter(subCategoryArrayAdapter);
        spinnerSubCategories.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedSubCategory = subCategories.get(position);

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private int getSubCategorySelection(String toCompare) {
        int i = -1;
        for (SubCategory category : subCategories) {
            i++;
            if (category.getSubcategoryId().equalsIgnoreCase(toCompare)) {
                return i;
            }
        }
        return 0;
    }

    private int getCategorySelection(String toCompare) {
        int i = -1;
        for (Category category : categories) {
            i++;
            if (category.getCategoryId().equalsIgnoreCase(toCompare)) {
                return i;
            }
        }
        return 0;
    }


    private int getJobApproach(String toCompare) {
        int i = -1;
        for (JobApproach jobApproach : jobApproaches) {
            i++;
            if (jobApproach.getName().equalsIgnoreCase(toCompare) || jobApproach.getName().contains(toCompare)) {
                return i;
            }
        }
        return i;
    }


    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mapHelper = new MapHelper(this, mMap);

    }

    private void showImageLoadingProgress() {
        imageLoading.spin();
        imageLoading.setVisibility(View.VISIBLE);
        imagesRecyclerView.setVisibility(View.GONE);
    }

    private void hideImageLoadingProgress() {
        imageLoading.stopSpinning();
        imageLoading.setVisibility(View.GONE);
        imagesRecyclerView.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        currentDisposable.dispose();
    }

    @OnClick(R.id.tv_add_image)
    public void onAddImage() {
        uploadDocumentPhoto();
    }

    private void uploadDocumentPhoto() {
        uploadPath = AppConstants.UPLOAD_PATH.jobImagePath;
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }

    @OnClick(R.id.et_work_time)
    public void onTimeClick() {
        showTimePicker();
    }

    @OnFocusChange(R.id.et_work_time)
    public void onTimeClick(boolean hasFocus) {
        if (hasFocus) {
            showTimePicker();
        }
    }

    @OnClick(R.id.et_work_date)
    public void onDateClick() {
        showDatePicker();
    }


    @OnFocusChange(R.id.et_work_date)
    public void onDateClick(boolean hasFocus) {
        if (hasFocus) {
            showDatePicker();
        }
    }

    private void showDatePicker() {
        if (!datePicker.isDisplaying()) {
            datePicker.display();
        }
    }

    private void showTimePicker() {
        if (!timePicker.isDisplaying()) {
            timePicker.display();
        }
    }

    @OnClick(R.id.btn_post_job)
    public void onPostJob() {
        Pair<Boolean, EditText> formValid = FormValidatorUtil.isFormValid(nameOfTheWork, jobDescription, workDate, workTime, amount);
        boolean isValid = formValid.first;
        EditText invalidField = formValid.second;
        if (isValid) {

            String totalTime = workDate.getText().toString().trim() + " " + workTime.getText().toString().trim();
            long timeInUnixStamp = Timing.getTimeInUnixStamp(totalTime.trim(), Timing.TimeFormats.CUSTOM_YYYY_MM_DD_HH_MM_A);
            long currentTimePlusTwoHour = System.currentTimeMillis() / 1000 + (60 * 60 * 1000);

            if (currentTimePlusTwoHour < timeInUnixStamp) {
                showMessage(R.string.msg_job_cancel_warning);
                return;
            }

            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_JOB_ID, currentJobId);
            params.put(AppConstants.K_JOB_NAME, nameOfTheWork.getText().toString().trim());
            params.put(AppConstants.K_JOB_DESCRIPTION, jobDescription.getText().toString().trim());
            params.put(AppConstants.K_JOB_ADDRESS, address.getText().toString().trim());
            params.put(AppConstants.K_JOB_APPROACH, selectedJobApproach.getName());
            params.put(AppConstants.K_CATEGORY_NAME, selectedCategory.getCategoryName());
            params.put(AppConstants.K_CATEGORY_ID, selectedCategory.getCategoryId());
            params.put(AppConstants.K_SUB_CATEGORY_NAME, selectedSubCategory.getSubcategoryName());
            params.put(AppConstants.K_SUB_CATEGORY_ID, selectedSubCategory.getSubcategoryId());
            params.put(AppConstants.K_WORK_DATE, workDate.getText().toString());
            params.put(AppConstants.K_JOB_TIME, timeInUnixStamp);
            params.put(AppConstants.K_INITIAL_AMOUNT, Double.valueOf(amount.getText().toString().trim()));
            params.put(AppConstants.K_IMAGES, images);
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            if (currentlocation != null) {
                params.put(AppConstants.K_JOB_LATITUDE, currentlocation.getLatitude());
                params.put(AppConstants.K_JOB_LOGITUDE, currentlocation.getLongitude());
            }
            if (actionType.equalsIgnoreCase(AppConstants.ACTIONS.POST_JOB)) {

                postJobViewModel.postJob(params);
            } else {
                if (isRepost) {
                    postJobViewModel.repostJob(params);
                } else {
                    postJobViewModel.editJob(params);
                }

            }

        } else {
            invalidField.requestFocus();
            showErrorPrompt(getString(R.string.field_required, invalidField.getHint()));
        }


    }


    @OnClick(R.id.btn_zoom)
    public void onZoomMap() {
        if (currentlocation != null) {
            startActivityForResult(MapActivity.createIntent(this, currentlocation.getLatitude(), currentlocation.getLongitude()), AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
        } else {
            startActivityForResult(MapActivity.createIntent(this), AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
        }

    }

    @OnClick(R.id.upload_document_photo)
    public void onUploadDocumentPhoto() {
        uploadDocumentPhoto();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CropImage.CROP_IMAGE_ACTIVITY_REQUEST_CODE) {
            CropImage.ActivityResult result = CropImage.getActivityResult(data);
            if (resultCode == RESULT_OK) {
                Uri resultUri = result.getUri();
                switcherUploadPhoto.setDisplayedChild(1);
                addImage.setVisibility(View.VISIBLE);
                postJobViewModel.uploadImage(resultUri, uploadPath);

            } else if (resultCode == CropImage.CROP_IMAGE_ACTIVITY_RESULT_ERROR_CODE) {
                Exception error = result.getError();
            }
        }
    }

    @Override
    public <T> void render(NetworkResponse<T> networkResponse, Class<T> clazz) {
        switch (networkResponse.status) {
            case LOADING:
                if (clazz.isAssignableFrom(String.class)) {
                    showImageLoadingProgress();
                } else {
                    showLoading();
                }
                break;
            case ERROR:
                hideLoading();
                hideImageLoadingProgress();
                showErrorPrompt(networkResponse.message);
                break;
            case SUCCESS:
                hideLoading();
                hideImageLoadingProgress();
                if (clazz.isAssignableFrom(String.class)) {
                    images.add((String) networkResponse.response);
                    imageListAdapter.updateList(images);
                } else {
                    try {
                        Job job = (Job) networkResponse.response;
                        nameOfTheWork.setText(job.getJobName());
                        jobDescription.setText(job.getJobDescription());
                        address.setText(job.getJobAddress());
                        spinnerJobApproach.setSelection(getJobApproach(job.getJobApproach()));
                        spinnerCategories.setSelection(getCategorySelection(job.getCategoryId()));
                        spinnerSubCategories.setSelection(getSubCategorySelection(job.getSubcategoryId()));
                        imageListAdapter.updateList(job.getImages());
                        workDate.setText(job.getJobDate());
                        workTime.setText(Timing.getTimeInString(Long.valueOf(job.getJobTime()), Timing.TimeFormats.HH_12));
                        amount.setText(job.getInitialAmount());
                        currentlocation = new LocationModel();
                        currentlocation.setLatitude(Double.valueOf(job.getJobAddressLatitude()));
                        currentlocation.setLongitude(Double.valueOf(job.getJobAddressLongitude()));
                        addMarker(currentlocation);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
                break;
        }
    }

    @Override
    public <T> void render(NetworkResponseList<T> networkResponseList, Class<T> clazz) {
        switch (networkResponseList.status) {
            case LOADING:

                if (clazz.isAssignableFrom(String.class)) {
                    showBtnProgress(btnPostjob);
                } else {
                    showLoading();
                }
                break;
            case ERROR:
                hideLoading();
                hideBtnProgress(btnPostjob);
                showErrorPrompt(networkResponseList.message);
                break;
            case SUCCESS:
                hideLoading();
                hideBtnProgress(btnPostjob);
                if (clazz.isAssignableFrom(Category.class)) {
                    //Category
                    categories.clear();
                    categories.addAll((Collection<? extends Category>) networkResponseList.response);
                    categoryArrayAdapter.notifyDataSetChanged();
                } else if (clazz.isAssignableFrom(String.class)) {

                    if (actionType.equalsIgnoreCase(AppConstants.ACTIONS.EDIT_JOB)) {
                        showSuccessDialog(getString(R.string.msg_job_edited), RC_POSTED_SUCCESS);

                    } else {
                        showSuccessDialog(getString(R.string.msg_job_posted), RC_POSTED_SUCCESS);
                    }

                } else {
                    subCategories.clear();
                    subCategories.addAll((Collection<? extends SubCategory>) networkResponseList.response);
                    subCategoryArrayAdapter.notifyDataSetChanged();
                }
        }
    }

    private void showSuccessDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.SUCCESS, "", message, action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public void onOkClicked(int action) {
        if (action == RC_POSTED_SUCCESS) {
            setResult(RESULT_OK);
            finish();
        }
    }

    @Override
    public void onCancelClicked() {

    }
}
