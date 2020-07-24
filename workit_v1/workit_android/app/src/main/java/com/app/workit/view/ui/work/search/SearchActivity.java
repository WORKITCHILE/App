package com.app.workit.view.ui.work.search;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.net.FindCurrentPlaceRequest;
import com.google.android.libraries.places.api.net.FindCurrentPlaceResponse;
import com.app.workit.R;
import com.app.workit.WorkItApp;
import com.app.workit.data.model.Job;
import com.app.workit.model.LocationModel;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.PostJobListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.app.workit.view.ui.hire.singlejob.SingleJobActivity;
import pub.devrel.easypermissions.AfterPermissionGranted;
import pub.devrel.easypermissions.EasyPermissions;
import pub.devrel.easypermissions.PermissionRequest;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class SearchActivity extends MainBaseActivity implements JobFilterDialog.JobFilterCallBack, EasyPermissions.PermissionCallbacks, IAdapterItemClickListener {

    private static final int RC_LOCATION = 22;
    private static final int RC_SHOW_JOB = 21;
    @BindView(R.id.et_search)
    public WorkItEditText search;
    @BindView(R.id.view_switcher)
    public ViewSwitcher viewSwitcher;
    @BindView(R.id.rv_search_results)
    public BaseRecyclerView searchResultRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @BindView(R.id.permission_view)
    LinearLayout permissionViewLayout;
    @Inject
    public ViewModelFactory viewModelFactory;
    private SearchViewModel searchViewModel;
    private ArrayList<String> subCategoryIds;
    private PostJobListAdapter postJobListAdapter;
    private JobFilterDialog jobFilterDialog;
    private LocationModel searchLocationModel = new LocationModel();

    public static Intent createIntent(Context context, ArrayList<String> subCategoryIds) {
        return new Intent(context, SearchActivity.class)
                .putExtra(AppConstants.K_SUB_CATEGORY_ID, subCategoryIds);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search_filter_layout);
        ButterKnife.bind(this);
        searchViewModel = ViewModelProviders.of(this, viewModelFactory).get(SearchViewModel.class);
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    @Override
    protected void initView() {
        //Init Filter Dialog
        jobFilterDialog = JobFilterDialog.newInstance();
        jobFilterDialog.setJobFilterCallBack(this);

        subCategoryIds = getIntent().getStringArrayListExtra(AppConstants.K_SUB_CATEGORY_ID);
        checkLocationAndSearch();
        searchViewModel.getJobsLiveData().observe(this, jobNetworkResponseList -> {
            switch (jobNetworkResponseList.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(jobNetworkResponseList.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    postJobListAdapter.updateList(jobNetworkResponseList.response);
                    break;
            }
        });

        initJobListView();
    }


    @AfterPermissionGranted(RC_LOCATION)
    private void checkLocationAndSearch() {
        String[] perms = {Manifest.permission.ACCESS_FINE_LOCATION};
        if (EasyPermissions.hasPermissions(this, perms)) {
            // Already have permission, do the thing
            initCurrentPlaceSearch();
        } else {
            // Do not have permissions, request them now
            EasyPermissions.requestPermissions(
                    new PermissionRequest.Builder(this, RC_LOCATION, perms)
                            .setRationale(R.string.allow_to_access_your_location)
                            .setPositiveButtonText(R.string.ok)
                            .setNegativeButtonText(R.string.cancel)
                            .build());
        }
    }

    public void initCurrentPlaceSearch() {
        showLoading();
        List<Place.Field> placeFields = Arrays.asList(com.google.android.libraries.places.api.model.Place.Field.ID, com.google.android.libraries.places.api.model.Place.Field.NAME,
                Place.Field.LAT_LNG);
        FindCurrentPlaceRequest findCurrentPlaceRequest = FindCurrentPlaceRequest.newInstance(placeFields);
        WorkItApp.getPlacesClient().findCurrentPlace(findCurrentPlaceRequest).addOnCompleteListener(new OnCompleteListener<FindCurrentPlaceResponse>() {
            @Override
            public void onComplete(@NonNull Task<FindCurrentPlaceResponse> task) {
                hideLoading();
                if (task.isSuccessful()) {
                    FindCurrentPlaceResponse response = task.getResult();
                    if (!response.getPlaceLikelihoods().isEmpty()) {
                        Place place = response.getPlaceLikelihoods().get(0).getPlace();
                        try {
                            searchLocationModel.setAddress(place.getAddress());
                            searchLocationModel.setLatitude(place.getLatLng().latitude);
                            searchLocationModel.setLongitude(place.getLatLng().longitude);
                        } catch (Exception e) {

                        }
                        searchJob(searchLocationModel);
                    } else {
                        searchJob(null);
                    }
                } else {
                    Exception exception = task.getException();
                    if (exception instanceof ApiException) {
                        ApiException apiException = (ApiException) exception;
                        showMessage(apiException.getMessage());
                    }
                }

            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                hideLoading();
                showMessage(e.getMessage());
            }
        });
    }

    public void searchJob(LocationModel address) {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_CURRENT_LATITUDE, address.getLatitude());
        params.put(AppConstants.K_CURRENT_LONGITUDE, address.getLongitude());
        params.put(AppConstants.K_USER_ID, userInfo.getUserId());
        params.put(AppConstants.K_SUB_CATEGORY_ID, subCategoryIds);
        searchViewModel.getPostedJobs(params);
    }

    private void initJobListView() {
        searchResultRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        searchResultRecyclerView.setEmptyView(this, emptyView, R.string.no_data_found);
        postJobListAdapter = new PostJobListAdapter(this, null, AppConstants.USER_TYPE.WORK);
        postJobListAdapter.setiAdapterItemClickListener(this);
        searchResultRecyclerView.setAdapter(postJobListAdapter);
    }

    @OnClick(R.id.btn_filter)
    public void onFilter() {
        jobFilterDialog.show(getSupportFragmentManager(), JobFilterDialog.class.getSimpleName());
    }

    @Override
    public void onJobFilterApplied(String jobApproach, double distance, double price, LocationModel locationModel) {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_APPROACH, jobApproach);
        params.put(AppConstants.K_SUB_CATEGORY_ID, subCategoryIds);
        params.put(AppConstants.K_USER_ID, userInfo.getUserId());
        params.put(AppConstants.K_ADDRESS, locationModel.getAddress());
        params.put(AppConstants.K_ADDRESS_LATITUDE, locationModel.getLatitude() == 0.0 ? null : locationModel.getLatitude());
        params.put(AppConstants.K_ADDRESS_LONGITUDE, locationModel.getLongitude() == 0.0 ? null : locationModel.getLongitude());
        params.put(AppConstants.K_PRICE, price == 0.0 ? null : price);
        params.put(AppConstants.K_DISTANCE, distance == 0.0 ? null : distance);
        params.put(AppConstants.K_SEARCH, search.getText().toString().trim().isEmpty() ? null : search.getText().toString().trim().isEmpty());

        searchViewModel.getPostedJobs(params);
    }

    @OnClick(R.id.iv_search)
    public void onSearch() {
        hideKeyBoard();
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_SEARCH, search.getText().toString().trim());
        params.put(AppConstants.K_SUB_CATEGORY_ID, subCategoryIds);
        searchViewModel.getPostedJobs(params);
    }

    @Override
    public void showLoading() {
        viewSwitcher.setDisplayedChild(0);
    }

    @Override
    public void hideLoading() {
        viewSwitcher.setDisplayedChild(1);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
        if (requestCode == RC_LOCATION) {
            viewSwitcher.setVisibility(View.VISIBLE);
            permissionViewLayout.setVisibility(View.GONE);
        }
    }

    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        if (requestCode == RC_LOCATION) {
            viewSwitcher.setVisibility(View.GONE);
            permissionViewLayout.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.btn_try_again)
    public void onTryAgain() {
        checkLocationAndSearch();
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        Job job = postJobListAdapter.getCurrentJobs().get(position);
        startActivityForResult(SingleJobActivity.createIntent(this, job.getJobId()), RC_SHOW_JOB);
    }
}
