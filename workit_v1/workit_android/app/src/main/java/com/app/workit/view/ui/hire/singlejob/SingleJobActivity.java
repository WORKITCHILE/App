package com.app.workit.view.ui.hire.singlejob;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Pair;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.jakewharton.rxbinding3.widget.RxTextView;
import com.app.workit.R;
import com.app.workit.data.model.Bid;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.model.LocationModel;
import com.app.workit.mvvm.MVVMBaseView;
import com.app.workit.util.*;
import com.app.workit.view.adapter.BidsListAdapter;
import com.app.workit.view.adapter.ImageListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.common.map.MapActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.app.workit.view.ui.customview.magictext.MagicText;
import com.app.workit.view.ui.hire.bid.BidInfoActivity;
import com.app.workit.view.ui.work.bids.BidsActivity;
import de.hdodenhof.circleimageview.CircleImageView;
import io.reactivex.disposables.Disposable;

import javax.inject.Inject;
import java.util.HashMap;
import java.util.concurrent.TimeUnit;

public class SingleJobActivity extends MainBaseActivity implements MVVMBaseView, CommonDialog.CommonDialogCallback, OnMapReadyCallback, IAdapterItemClickListener {

    private static final int RC_POSTED = 123;
    private static final int RC_CANCEL = 12;
    private static final int RC_JOB_CANCELED = 13;
    private static final int RC_BID_INFO = 32;
    private static final int RC_CANCEL_BID = 44;
    private static final int RC_CANCELED = 55;
    @BindView(R.id.iv_user_icon)
    CircleImageView userAvatar;
    @BindView(R.id.tv_posted_on)
    TextView postedOn;
    @BindView(R.id.tv_posted_time)
    TextView postedTime;
    @BindView(R.id.tv_header)
    TextView header;
    @BindView(R.id.tv_job_name)
    TextView jobName;
    @BindView(R.id.tv_job_address)
    TextView jobAddress;
    @BindView(R.id.tv_price)
    TextView price;
    @BindView(R.id.tv_work_schedule)
    MagicText workSchedule;
    @BindView(R.id.tv_full_job_description)
    MagicText fullJobDescription;
    @BindView(R.id.rv_images)
    RecyclerView bidImages;
    @BindView(R.id.rv_images_worker)
    RecyclerView bidImagesWorker;
    @BindView(R.id.counter_offer)
    WorkItEditText counterOffer;
    @BindView(R.id.et_comment)
    WorkItEditText comment;
    @BindView(R.id.view_switcher)
    ViewSwitcher switcherHireAndWork;
    @BindView(R.id.base_recycler_view)
    BaseRecyclerView bidsBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @BindView(R.id.btn_post_bid)
    Button btnPostBid;
    @BindView(R.id.btn_cancel_job)
    Button btnCancelJob;
    @BindView(R.id.job_category)
    MagicText jobCategory;
    @BindView(R.id.job_sub_category)
    MagicText jobSubcategory;
    @BindView(R.id.tv_owner_name)
    TextView ownerName;
    @BindView(R.id.bid_status)
    TextView bidStatus;
    @Inject
    ViewModelFactory viewModelFactory;
    private SingleJobViewModel singleJobViewModel;
    private BidsListAdapter bidsListAdapter;
    private ImageListAdapter imageListAdapter;
    private String jobID;
    private GoogleMap mMap;
    private LocationModel currentlocation;
    private float currentOfferPrice;
    private Disposable offerDisposable;
    private boolean bidPlaced;
    private Bid bid;
    private Job job;

    public static Intent createIntent(Context context, String jobId) {
        Intent intent = new Intent(context, SingleJobActivity.class);
        intent.putExtra(AppConstants.K_JOB_ID, jobId);
        return intent;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_posted_job_info);
        ButterKnife.bind(this);
        header.setText(R.string.posted_job);
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }

    @Override
    protected void initView() {

        singleJobViewModel = ViewModelProviders.of(this, viewModelFactory).get(SingleJobViewModel.class);
        jobID = getIntent().getStringExtra(AppConstants.K_JOB_ID);
        getSingleJob();
        initBidList();
        initCounterOffer();
        singleJobViewModel.getBidLiveData().observe(this, new Observer<NetworkResponse<String>>() {
            @Override
            public void onChanged(NetworkResponse<String> response) {
                render(response, String.class);
            }
        });
        singleJobViewModel.getJobCancelLiveData().observe(this, new Observer<NetworkResponse<String>>() {
            @Override
            public void onChanged(NetworkResponse<String> response) {
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
                        showSuccessDialog(getString(R.string.job_canceled_successfully), RC_JOB_CANCELED);
                        break;
                }
            }
        });
        if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
            btnPostBid.setVisibility(View.VISIBLE);
            btnCancelJob.setVisibility(View.GONE);
            switcherHireAndWork.setDisplayedChild(1);
        } else {
            btnPostBid.setVisibility(View.GONE);
            btnCancelJob.setVisibility(View.VISIBLE);
            switcherHireAndWork.setDisplayedChild(0);
        }
    }

    private void initCounterOffer() {
        offerDisposable = RxTextView.textChanges(counterOffer)
                .skip(1)
                .debounce(300, TimeUnit.MILLISECONDS)
                .filter(charSequence -> !charSequence.toString().isEmpty())
                .map(charSequence -> {
                    return charSequence.toString().trim();
                })
                .distinctUntilChanged()
                .subscribe((s -> currentOfferPrice = Float.parseFloat(s)));
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }


    @OnClick(R.id.increase_offer)
    public void onIncreaseOffer() {
        if (!bidPlaced) {
            currentOfferPrice += 1000;
            counterOffer.setText(getString(R.string.float_value, currentOfferPrice));
        }

    }

    @OnClick(R.id.decrease_offer)
    public void onDecreaseOffer() {
        if (!bidPlaced) {
            currentOfferPrice -= 1000;
            if (currentOfferPrice < 0) {
                currentOfferPrice = 100;
            }
            counterOffer.setText(getString(R.string.float_value, currentOfferPrice));

        }

    }

    private void initBidList() {
        if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
            bidImagesWorker.setLayoutManager(new LinearLayoutManager(this));
            imageListAdapter = new ImageListAdapter(this, R.layout.item_image, 3);
            bidImagesWorker.setAdapter(imageListAdapter);


        } else {
            bidImages.setLayoutManager(new LinearLayoutManager(this));
            imageListAdapter = new ImageListAdapter(this, R.layout.item_image, 3);
            bidImages.setAdapter(imageListAdapter);

            bidsBaseRecyclerView.setEmptyView(this, emptyView, R.string.no_bids_found);
            bidsListAdapter = new BidsListAdapter(this);
            bidsListAdapter.setiAdapterItemClickListener(this);
            bidsBaseRecyclerView.setAdapter(bidsListAdapter);
        }


    }

    private void getSingleJob() {
        singleJobViewModel.getJobInfoLiveData().observe(this, jobNetworkResponse -> {
            render(jobNetworkResponse, Job.class);
        });
        String jobId = getIntent().getStringExtra(AppConstants.K_JOB_ID);
        if (jobId == null) return;
        singleJobViewModel.getJobInfo(jobId, userInfo.getType());
    }

    @OnClick(R.id.btn_post_bid)
    public void onPostBid() {
        if (bidPlaced) {
            showConfirmationDialog(getString(R.string.are_you_sure_cancel_bid), RC_CANCEL_BID);
        } else {
            Pair<Boolean, EditText> formValid = FormValidatorUtil.isFormValid(counterOffer, comment);
            if (formValid.first) {
                HashMap<String, Object> params = new HashMap<>();
                params.put(AppConstants.K_JOB_ID, jobID);
                params.put(AppConstants.K_VENDOR_ID, userInfo.getUserId());
                params.put(AppConstants.K_COUNTER_OFFER_AMOUNT, counterOffer.getText().toString().trim());
                params.put(AppConstants.K_COMMENT, comment.getText().toString().trim());
                singleJobViewModel.postBid(params);
            } else {
                showMessage(getString(R.string.field_required, formValid.second.getHint()));
            }
        }


    }

    private void showConfirmationDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, "", message, action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }


    @Override
    public <T> void render(NetworkResponse<T> networkResponse, Class<T> dataType) {
        switch (networkResponse.status) {
            case LOADING:
                showLoading();
                break;
            case ERROR:
                hideLoading();
                showErrorPrompt(networkResponse.message);
                break;
            case SUCCESS:
                hideLoading();
                if (dataType.isAssignableFrom(Job.class)) {
                    job = (Job) networkResponse.response;
                    Glide.with(this).load(userInfo.getProfilePicture()).apply(new RequestOptions()
                            .error(R.drawable.no_image_available)
                            .centerCrop().placeholder(R.drawable.rotate_spinner)).into(userAvatar);
                    postedOn.setText(getString(R.string.txt_job_date, job.getJobDate()));
                    postedTime.setText(Timing.getTimeInString(Long.valueOf(job.getJobTime()), Timing.TimeFormats.HH_12));
                    jobName.setText(getString(R.string.job_name, job.getJobName()));
                    ownerName.setText(job.getUserName());

                    jobAddress.setText(job.getJobAddress());
                    price.setText(getString(R.string.txt_job_price, job.getInitialAmount()));
                    String fullWorkSchedule = getString(R.string.work_schedule, job.getJobDate());
                    workSchedule.change(fullWorkSchedule, ContextCompat.getColor(this, R.color.colorGrey), 12, "normal", job.getJobDate());
                    String jobDesc = getString(R.string.details_of_the_offer_job, job.getJobDescription());
                    fullJobDescription.change(jobDesc, ContextCompat.getColor(this, R.color.colorGrey), 12, "normal", job.getJobDescription());

                    String category = getString(R.string.job_category, job.getCategoryName());
                    jobCategory.change(category, ContextCompat.getColor(this, R.color.colorGrey), 12, "normal", job.getCategoryName());

                    String subcategory = getString(R.string.job_sub_category, job.getSubcategoryName());
                    jobSubcategory.change(subcategory, ContextCompat.getColor(this, R.color.colorGrey), 12, "normal", job.getSubcategoryName());

                    imageListAdapter.updateList(job.getImages());
                    currentlocation = new LocationModel();
                    currentlocation.setLatitude(Double.valueOf(job.getJobAddressLatitude()));
                    currentlocation.setLongitude(Double.valueOf(job.getJobAddressLongitude()));
                    bidPlaced = job.getIsBidPlaced() == 1;
                    bid = job.getMyBid();
                    showHideBidView(userInfo.getType(), job, job.getIsBidPlaced(), job.getMyBid());

                    if (bidsListAdapter != null) {
                        bidsListAdapter.updateList(job.getBids());
                    }
                    addMarker(currentlocation);

                } else {
                    //Bid Successful
                    if (!bidPlaced) {
                        showSuccessDialog(getString(R.string.bids_placed_successfully), RC_POSTED);
                    } else {
                        showSuccessDialog(getString(R.string.bids_canceled_successfully), RC_CANCELED);
                    }

                }

                break;
        }
    }

    private void showHideBidView(String type, Job job, int isBidPlaced, Bid myBid) {
        if (type.equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
            btnCancelJob.setVisibility(View.GONE);
            switcherHireAndWork.setDisplayedChild(1);
            if (isBidPlaced == 1) {
                btnPostBid.setText(R.string.cancel_bid);
                counterOffer.setText(myBid.getCounterofferAmount());
                comment.setText(myBid.getComment());
                bidStatus.setText(R.string.bid_placed);
                counterOffer.setEnabled(false);
                comment.setEnabled(false);
                if (job.getStatus().equalsIgnoreCase(AppConstants.JOB_STATUS.CLOSED)) {
                    btnPostBid.setVisibility(View.GONE);
                    if (myBid.getOwnerStatus().equalsIgnoreCase(AppConstants.BID_STATUS.REJECTED)) {
                        bidStatus.setText(R.string.bid_rejected_by_owner);
                    }
                }
            } else {
                bidStatus.setText(" ");
                btnPostBid.setText(R.string.place_bid);
            }


        } else {
            btnPostBid.setVisibility(View.GONE);
            switcherHireAndWork.setDisplayedChild(0);
            if (isBidPlaced == 1) {
                btnCancelJob.setVisibility(View.VISIBLE);
            } else {
                btnCancelJob.setVisibility(View.GONE);
            }
        }
    }

    private void addMarker(LocationModel currentlocation) {
        LatLng newLatLng = new LatLng(currentlocation.getLatitude(), currentlocation.getLongitude());
        Marker marker = mMap.addMarker(new MarkerOptions().position(newLatLng).icon(CommonUtils.bitmapDescriptorFromVector(this, R.drawable.ic_marker)));
        CameraPosition cameraPosition = new CameraPosition.Builder().target(newLatLng).zoom(16.0f).build();
        CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
        mMap.animateCamera(cameraUpdate);
    }

    private void showSuccessDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.SUCCESS, "", message, action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public <T> void render(NetworkResponseList<T> networkResponseList, Class<T> type) {

    }

    @Override
    public void onOkClicked(int action) {
        if (action == RC_POSTED) {
            startActivity(BidsActivity.createIntent(this));
            this.finishAffinity();
        } else if (action == RC_CANCEL) {
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_JOB_ID, jobID);
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            singleJobViewModel.cancelJob(params);
        } else if (action == RC_CANCEL_BID) {
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_BID_ID, bid.getBidId());
            singleJobViewModel.cancelBid(params);
        } else {
            finish();
        }


    }

    @Override
    public void onCancelClicked() {

    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.getUiSettings().setScrollGesturesEnabled(false);
    }

    @OnClick(R.id.btn_cancel_job)
    public void onCancelJob() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, "", getString(R.string.are_you_sure_cancel_job), RC_CANCEL);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        Bid bid = bidsListAdapter.getBids().get(position);
        bid.setCategoryName(job.getCategoryName());
        bid.setSubCategoryName(job.getSubcategoryName());
        startActivityForResult(BidInfoActivity.createIntent(this, bid), RC_BID_INFO);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_BID_INFO && resultCode == RESULT_OK) {
            singleJobViewModel.getJobInfo(jobID, userInfo.getType());
        }
    }

    @OnClick(R.id.view_full_screen)
    public void onMapFullScreen() {
        loateOnMap();
    }

    private void loateOnMap() {
        if (currentlocation != null) {
            startActivityForResult(MapActivity.createIntent(this, currentlocation.getLatitude(), currentlocation.getLongitude(),AppConstants.ACTIONS.VIEW_MAP), AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        offerDisposable.dispose();
    }


}
