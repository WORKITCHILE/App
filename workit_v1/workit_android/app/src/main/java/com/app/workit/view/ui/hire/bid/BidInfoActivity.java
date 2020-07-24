package com.app.workit.view.ui.hire.bid;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatRatingBar;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.app.workit.view.ui.common.evaluation.ratereview.RateReviewActivity;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.model.Bid;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Timing;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.banking.AddBankDialogFragment;
import com.app.workit.view.ui.common.chat.ChatActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.common.evaluation.ReviewsDialogFragment;
import com.app.workit.view.ui.hire.payment.PaymentChooserDialog;
import com.app.workit.view.ui.hire.postjob.PostJobActivity;
import de.hdodenhof.circleimageview.CircleImageView;

import javax.inject.Inject;
import java.util.HashMap;

public class BidInfoActivity extends MainBaseActivity implements PaymentChooserDialog.PaymentChooserCallback, CommonDialog.CommonDialogCallback, AddBankDialogFragment.IBankSelectionCallback {

    private static final int RC_PAY_VIA_WALLET = 32;
    private static final int RC_CANCEL_JOB_OWNER = 34;
    private static final int RC_CANCEL_JOB_WORKER = 36;
    private static final int RC_ADD_BANK_ACCOUNT = 11;
    private static final int RC_JOB_STARTED = 12;
    private static final int RC_JOB_FINISHED = 23;
    private static final int RC_CANCELED = 99;
    private static final int RC_OTHER = 100;
    private static final int RC_JOB_REPOST = 101;
    private static final int RC_CALL_TO_JOB_REPOST = 102;
    private static final int RC_RATE_USER = 103;
    @BindView(R.id.name)
    TextView name;
    @BindView(R.id.occupation)
    TextView occupation;
    @BindView(R.id.avatar)
    CircleImageView avatar;
    @BindView(R.id.job_title)
    TextView jobTitle;
    @BindView(R.id.view_switcher)
    ViewSwitcher viewSwitcher;
    @BindView(R.id.posted_by)
    TextView postedBy;
    @BindView(R.id.accepted_by)
    TextView acceptedBy;
    @BindView(R.id.offered_amount)
    TextView offeredAmount;
    @BindView(R.id.category)
    TextView category;
    @BindView(R.id.job_approach)
    TextView jobApproach;
    @BindView(R.id.job_description)
    TextView jobDescription;
    @BindView(R.id.bid_description)
    TextView bidDescription;
    @BindView(R.id.address)
    TextView address;
    @BindView(R.id.posted_on)
    TextView postedON;
    @BindView(R.id.start_date)
    TextView startDate;
    @BindView(R.id.start_time)
    TextView startTime;
    @BindView(R.id.rating_bar)
    AppCompatRatingBar ratingBar;
    @BindView(R.id.accept_bid)
    Button acceptBid;
    @BindView(R.id.reject_bid)
    Button rejectBid;
    @BindView(R.id.header)
    TextView header;
    @BindView(R.id.repost_job)
    TextView repostJob;
    @BindView(R.id.rate_user)
    TextView rateUser;
    @BindView(R.id.cance_job)
    Button cancelJob;
    @BindView(R.id.sub_category)
    TextView subCategory;
    @BindView(R.id.btn_job_start_finish)
    Button btnJobStartFinish;
    @BindView(R.id.confirm_job)
    Button confirmJob;
    @BindView(R.id.message)
    Button btnMessage;
    @BindView(R.id.release_payment)
    Button btnReleasePayment;
    @BindView(R.id.view_reviews)
    TextView viewReviews;
    @Inject
    ViewModelFactory viewModelFactory;
    private BidInfoViewModel bidInfoViewModel;
    private String jobID;
    private String bidID;
    private Bid bid;
    private Job jobInfo;
    private ReviewsDialogFragment reviewsDialogFragment;

    public static Intent createIntent(Context context, String jobID, String bidID) {
        return new Intent(context, BidInfoActivity.class)
                .putExtra(AppConstants.K_JOB_ID, jobID)
                .putExtra(AppConstants.K_BID_ID, bidID);
    }

    public static Intent createIntent(Context context, String jobID) {
        return new Intent(context, BidInfoActivity.class)
                .putExtra(AppConstants.K_JOB_ID, jobID);
    }


    public static Intent createIntent(Context context, Bid bid) {
        return new Intent(context, BidInfoActivity.class)
                .putExtra(AppConstants.K_BID, bid);
    }

    public static Intent createIntent(Context context, Job job) {
        return new Intent(context, BidInfoActivity.class)
                .putExtra(AppConstants.K_JOB, job);
    }

    @Override
    public void setLoadingState(boolean state) {
        viewSwitcher.setDisplayedChild(state ? 0 : 1);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.woker_bid_info_layout);
        ButterKnife.bind(this);
        bidInfoViewModel = ViewModelProviders.of(this, viewModelFactory).get(BidInfoViewModel.class);
    }

    @Override
    protected void initView() {
        jobID = getIntent().getStringExtra(AppConstants.K_JOB_ID);
        bidID = getIntent().getStringExtra(AppConstants.K_BID_ID);
        bid = getIntent().getParcelableExtra(AppConstants.K_BID);
        jobInfo = getIntent().getParcelableExtra(AppConstants.K_JOB);
        initBidInfo();
        bidInfoViewModel.getJobInfoLiveData().observe(this, jobNetworkResponse -> {
            switch (jobNetworkResponse.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(jobNetworkResponse.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    jobInfo = jobNetworkResponse.response;
                    initBidWithJobInfo(jobNetworkResponse.response);
                    break;

            }
        });
    }

    private void initBidInfo() {
        setLoadingState(false);
        viewReviews.setVisibility(bid == null ? View.GONE : View.VISIBLE);
        if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
            if (jobInfo != null) {
                jobID = jobInfo.getJobId();
                initBidWithJobInfo(jobInfo);
            } else {
                bidInfoViewModel.getJobInfo(jobID);
            }

            //            bidInfoViewModel.getBidInfo(jobID, bidID);
        } else {
            if (bid != null) {
                jobID = bid.getJobId();
                bidID = bid.getBidId();
                initBid(bid);
            } else {
                if (jobInfo != null) {
                    jobID = jobInfo.getJobId();
                    initBidWithJobInfo(jobInfo);

                } else {
                    bidInfoViewModel.getJobInfo(jobID);
                }
            }

        }
        bidInfoViewModel.getBidInfoLiveData().observe(this, bidNetworkResponse -> {
            switch (bidNetworkResponse.status) {
                case LOADING:
                    setLoadingState(true);
                    break;
                case ERROR:
                    setLoadingState(false);
                    showErrorPrompt(bidNetworkResponse.message);
                    break;
                case SUCCESS:
                    setLoadingState(false);
                    initBid(bidNetworkResponse.response);
                    break;
            }
        });
        bidInfoViewModel.getAcceptBidLiveData().observe(this, response -> {
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
                    setResult(RESULT_OK);
                    finish();
                    break;
            }
        });
        bidInfoViewModel.getPaymentLiveData().observe(this, new Observer<NetworkResponse<String>>() {
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
                        HashMap<String, Object> params = new HashMap<>();
                        params.put(AppConstants.K_JOB_ID, jobID);
                        params.put(AppConstants.K_BID_ID, bidID);
                        params.put(AppConstants.K_STATUS, AppConstants.BID_STATUS.ACCEPTED);
                        bidInfoViewModel.bidAction(params);
                        break;

                }
            }
        });

        //This is Job Action By Worker
        bidInfoViewModel.getJobActionLiveData().observe(this, response -> {
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
                    if (jobInfo.getStatus().equalsIgnoreCase(AppConstants.JOB_STATUS.ACCEPTED)) {
                        showSuccessDialog(getString(R.string.your_job_has_been_starte), RC_JOB_STARTED);
                    } else {
                        showSuccessDialog(getString(R.string.your_job_has_been_finished), RC_JOB_FINISHED);
                    }

                    break;
            }
        });
        bidInfoViewModel.getStartJobOwnerLiveData().observe(this, response -> {
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
                    setResult(RESULT_OK);
                    finish();
                    break;
            }
        });
        //Release Payment
        bidInfoViewModel.getReleaseLiveData().observe(this, response -> {
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
                    Intent intent = new Intent();
                    intent.putExtra(AppConstants.K_STATUS, AppConstants.JOB_STATUS.PAID);
                    setResult(RESULT_OK, intent);
                    finish();
                    break;
            }
        });
        //Cancel Job
        bidInfoViewModel.getJobCancelLiveData().observe(this, response -> {
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
                    showDialog(getString(R.string.job_canceled_successfully), RC_CANCELED, AppConstants.DIALOG_TYPE.SUCCESS, this);
                    break;
            }
        });
        //Get Reviews
        bidInfoViewModel.getReviewsLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    if (reviewsDialogFragment != null) {
                        reviewsDialogFragment.updateFragment(response.response);
                    }
                    break;
            }
        });
    }

    private void initBidWithJobInfo(Job jobInfo) {
        try {
            jobTitle.setText(jobInfo.getJobName());
            postedBy.setText(jobInfo.getUserName());
            acceptedBy.setText(jobInfo.getVendorName());
            offeredAmount.setText(getString(R.string.price_in_dollar, jobInfo.getServiceAmount()));
            jobApproach.setText(jobInfo.getJobApproach());
            jobDescription.setText(jobInfo.getJobDescription());
            address.setText(jobInfo.getJobAddress());
            bidDescription.setText(jobInfo.getComment());
            postedON.setText(Timing.getTimeInStringWithoutStamp(jobInfo.getCreatedAt(), Timing.TimeFormats.DD_MM_YYYY));
            startDate.setText(jobInfo.getJobDate());
            startTime.setText(Timing.getTimeInString(jobInfo.getJobTime(), Timing.TimeFormats.HH_12));
            category.setText(jobInfo.getCategoryName());
            subCategory.setText(jobInfo.getSubcategoryName());
            switch (jobInfo.getStatus()) {
                case AppConstants.JOB_STATUS.POSTED:
                    acceptBid.setVisibility(View.VISIBLE);
                    rejectBid.setVisibility(View.VISIBLE);
                    break;
                case AppConstants.JOB_STATUS.ACCEPTED:
                    hideAllButton();
                    header.setText(R.string.job_accepted);
                    cancelJob.setVisibility(View.VISIBLE);
                    if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                        //For Hire
                        btnJobStartFinish.setVisibility(View.GONE);
                    } else {
                        //For Work
                        if (userInfo.getUserId().equalsIgnoreCase(jobInfo.getJobVendorId())) {
                            btnJobStartFinish.setVisibility(View.VISIBLE);
                        }
                    }

                    break;
                case AppConstants.JOB_STATUS.REJECTED:
                    acceptBid.setVisibility(View.GONE);
                    rejectBid.setVisibility(View.GONE);
                    if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                        header.setText(getString(R.string.bid_rejected_by, getString(R.string.you)));
                    } else {
                        header.setText(getString(R.string.bid_rejected_by, getString(R.string.owner)));
                    }
                    break;
                case AppConstants.JOB_STATUS.STARTED:
                    hideAllButton();
                    if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                        if (jobInfo.getStartedBy().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                            header.setText(R.string.waiting_for_client_to_confirm);
                        } else if (jobInfo.getStartedBy().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                            header.setText(R.string.job_started);
                            confirmJob.setVisibility(View.GONE);
                            btnMessage.setBackgroundColor(Color.TRANSPARENT);
                            btnMessage.setTextColor(ContextCompat.getColor(this, R.color.colorBlack));
                            btnMessage.setVisibility(View.VISIBLE);

                            btnJobStartFinish.setVisibility(View.VISIBLE);
                            btnJobStartFinish.setText(R.string.finish_job);
                        } else {
                            confirmJob.setVisibility(View.VISIBLE);
                        }
                    } else {
                        if (!userInfo.getUserId().equalsIgnoreCase(jobInfo.getJobVendorId())) {
                            if (jobInfo.getStartedBy().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                                //Worker has Already started
                                header.setText(R.string.please_confirm_to_start_job);
                                confirmJob.setVisibility(View.VISIBLE);
                                cancelJob.setVisibility(View.VISIBLE);
                            } else if (jobInfo.getStartedBy().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                                header.setText(R.string.job_started);
                                confirmJob.setVisibility(View.GONE);
                                btnMessage.setVisibility(View.VISIBLE);
                            } else {
                                confirmJob.setVisibility(View.GONE);
                                //Worker hasn't started
                                header.setText(R.string.waiting_for_vendor_to_confirm);
                            }
                        }


                    }
                    break;
                case AppConstants.JOB_STATUS.FINISHED:
                    hideAllButton();
                    if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                        header.setText(R.string.waiting_for_client_to_release_amount);
                    } else {
                        if (userInfo.getUserId().equalsIgnoreCase(jobInfo.getUserId())) {
                            btnReleasePayment.setVisibility(View.VISIBLE);
                            header.setText(R.string.job_finished_release_payment);
                        }
                    }
                    break;
                case AppConstants.JOB_STATUS.PAID:
                    hideAllButton();
                    header.setText(R.string.job_finished);

                    if (userInfo.getUserId().equalsIgnoreCase(jobInfo.getJobVendorId()) && jobInfo.getVendorRated() == 0) {
                        rateUser.setVisibility(View.VISIBLE);
                    } else if (userInfo.getUserId().equalsIgnoreCase(jobInfo.getUserId()) && jobInfo.getOwnerRated() == 0) {
                        rateUser.setVisibility(View.VISIBLE);
                    }
                    break;
                case AppConstants.JOB_STATUS.CANCELED:
                case AppConstants.JOB_STATUS.CLOSED:
                    hideAllButton();
                    header.setText(R.string.job_canceled);
                    if (jobInfo.getCanceledBy().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                        repostJob.setVisibility(View.VISIBLE);
                    }
                    break;
            }
            //Init with user type
            if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
                name.setText(jobInfo.getUserName());
                Glide.with(this).load(jobInfo.getUserImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(avatar);
                occupation.setText(jobInfo.getUserOccupation());
                ratingBar.setRating(Float.parseFloat(jobInfo.getUserAverageRating()));
            } else {
                name.setText(jobInfo.getVendorName());
                Glide.with(this).load(jobInfo.getVendorImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(avatar);
                occupation.setText(jobInfo.getVendorOccupation());
                ratingBar.setRating(Float.parseFloat(jobInfo.getVendorAverageRating()));
            }


        } catch (Exception e) {
            showMessage(e.getMessage());
        }
    }

    private void hideAllButton() {
        btnReleasePayment.setVisibility(View.GONE);
        acceptBid.setVisibility(View.GONE);
        rejectBid.setVisibility(View.GONE);
        btnJobStartFinish.setVisibility(View.GONE);
        cancelJob.setVisibility(View.GONE);
        confirmJob.setVisibility(View.GONE);
        btnMessage.setVisibility(View.GONE);
    }


    private void initBid(Bid bid) {
        try {
            jobTitle.setText(bid.getJobName());
            postedBy.setText(bid.getUserName());
            acceptedBy.setText(bid.getOwnerStatus().equalsIgnoreCase(AppConstants.BID_STATUS.ACCEPTED) ? bid.getVendorName() : "-");
            offeredAmount.setText(getString(R.string.price_in_dollar, bid.getCounterofferAmount()));
            jobApproach.setText(bid.getJobApproach());
            jobDescription.setText(bid.getJobDescription());
            address.setText(bid.getJobAddress());
            bidDescription.setText(bid.getComment());
            postedON.setText(Timing.getTimeInStringWithoutStamp(bid.getCreatedAt(), Timing.TimeFormats.DD_MM_YYYY));
            startDate.setText(bid.getJobDate());
            startTime.setText(Timing.getTimeInString(bid.getJobTime(), Timing.TimeFormats.HH_12));
            name.setText(bid.getVendorName());
            category.setText(bid.getCategoryName());
            subCategory.setText(bid.getSubCategoryName());
            Glide.with(this).load(bid.getVendorImage()).apply(new RequestOptions()
                    .error(R.drawable.rotate_spinner)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(avatar);
            occupation.setText(bid.getVendorOccupation());
            switch (bid.getOwnerStatus()) {
                case AppConstants.BID_STATUS.POSTED:
                    acceptBid.setVisibility(View.VISIBLE);
                    rejectBid.setVisibility(View.VISIBLE);
                    break;
                case AppConstants.BID_STATUS.ACCEPTED:
                    header.setText(R.string.job_accepted);
                    acceptBid.setVisibility(View.GONE);
                    rejectBid.setVisibility(View.GONE);
                    cancelJob.setVisibility(View.VISIBLE);
                    break;
                case AppConstants.BID_STATUS.REJECTED:
                    acceptBid.setVisibility(View.GONE);
                    rejectBid.setVisibility(View.GONE);
                    if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                        header.setText(getString(R.string.bid_rejected_by, getString(R.string.you)));
                    } else {
                        header.setText(getString(R.string.bid_rejected_by, getString(R.string.owner)));
                    }
                    break;
            }

        } catch (Exception e) {
            showMessage(e.getMessage());
        }
    }


    @OnClick(R.id.rate_user)
    public void onRateUser() {
        startActivityForResult(RateReviewActivity.createIntent(this, jobInfo, AppConstants.ACTIONS.RATE_USER), RC_RATE_USER);
    }

    @OnClick(R.id.accept_bid)
    public void onAcceptBid() {
        PaymentChooserDialog paymentChooserDialog = PaymentChooserDialog.newInstance(userInfo.getCredits());
        paymentChooserDialog.setPaymentChooserCallback(this);
        paymentChooserDialog.show(getSupportFragmentManager(), PaymentChooserDialog.class.getSimpleName());
    }


    @Override
    public void onWalletSelected() {
        showConfirmationDialog(getString(R.string.msg_are_you_sure_you_want), RC_PAY_VIA_WALLET);
    }


    private void showSuccessDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.SUCCESS, "", message, action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    private void showConfirmationDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, "", message
                , getString(R.string.yes), getString(R.string.no), action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    private void showConfirmationDialog(String message, String btnOk, String btnCancel, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, "", message
                , btnOk, btnCancel, action);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }


    @Override
    public void onOkClicked(int action) {
        if (action == RC_PAY_VIA_WALLET) {
            if (Integer.parseInt(userInfo.getCredits()) < bid.getInitialAmount()) {
                showMessage(R.string.not_enough_credits);
            } else {
                HashMap<String, Object> params = new HashMap<>();
                params.put(AppConstants.K_USER_ID, userInfo.getUserId());
                params.put(AppConstants.K_VENDOR_NAME, bid.getVendorName());
                params.put(AppConstants.K_JOB_AMOUNT, bid.getInitialAmount());
                params.put(AppConstants.K_JOB_ID, jobID);
                params.put(AppConstants.K_PAYMENT_OPTION, AppConstants.PAYMENT_OPTION.WALLET);
                params.put(AppConstants.K_TRANSACTIOON_ID, "W" + System.currentTimeMillis() / 1000);
                bidInfoViewModel.paymentForJob(params);


            }
        } else if (action == RC_CANCEL_JOB_OWNER) {
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_JOB_ID, jobID);
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            bidInfoViewModel.cancelJob(params, AppConstants.USER_TYPE.HIRE);
        } else if (action == RC_CANCEL_JOB_WORKER) {
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_JOB_ID, jobID);
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            bidInfoViewModel.cancelJob(params, AppConstants.USER_TYPE.WORK);
        } else if (action == RC_ADD_BANK_ACCOUNT) {
            AddBankDialogFragment addBankDialogFragment = AddBankDialogFragment.newInstance();
            addBankDialogFragment.setiBankSelectionCallback(this);
            addBankDialogFragment.show(getSupportFragmentManager(), AddBankDialogFragment.class.getSimpleName());
        } else if (action == RC_JOB_STARTED) {
            jobInfo.setStatus(AppConstants.JOB_STATUS.STARTED);
            showHideActionView(AppConstants.JOB_STATUS.STARTED);
        } else if (action == RC_JOB_FINISHED) {
            jobInfo.setStatus(AppConstants.JOB_STATUS.FINISHED);
            showHideActionView(AppConstants.JOB_STATUS.FINISHED);
            setResult(RESULT_OK);
            finish();
        } else if (action == RC_JOB_REPOST) {
            startActivityForResult(PostJobActivity.createIntent(this, jobID, true), RC_CALL_TO_JOB_REPOST);
        } else if (action == RC_CANCELED) {
            setResult(RESULT_OK);
            finish();
        } else if (action == RC_OTHER) {
            setResult(RESULT_OK);
            finish();
        }

    }

    private void showHideActionView(String status) {
        if (status.equalsIgnoreCase(AppConstants.JOB_STATUS.STARTED)) {
            acceptBid.setVisibility(View.GONE);
            rejectBid.setVisibility(View.GONE);
            confirmJob.setVisibility(View.GONE);
            cancelJob.setVisibility(View.GONE);
            if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
                btnMessage.setBackground(null);
                btnMessage.setTextColor(R.color.colorBlack);
            }
            btnMessage.setVisibility(View.VISIBLE);
        } else if (status.equalsIgnoreCase(AppConstants.JOB_STATUS.FINISHED)) {

        }
    }


    @OnClick(R.id.release_payment)
    public void onReleasePayment() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_ID, jobID);
        bidInfoViewModel.releaseJobPayment(params);
    }

    @OnClick(R.id.confirm_job)
    public void confirmJob() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_ID, jobID);
        bidInfoViewModel.approveJobOwner(params);
    }

    @OnClick(R.id.btn_job_start_finish)
    public void onStartJob() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_ID, jobID);
        params.put(AppConstants.K_VENDOR_ID, jobInfo.getJobVendorId());
        if (jobInfo.getStatus().equalsIgnoreCase(AppConstants.JOB_STATUS.STARTED)) {
            params.put(AppConstants.K_STATUS, AppConstants.JOB_STATUS.FINISHED);
        } else {
            if (userInfo.getIsBankDetailsAdded() == 1) {
                params.put(AppConstants.K_STATUS, AppConstants.JOB_STATUS.STARTED);
            } else {
                //Add bank details
                showConfirmationDialog(getString(R.string.please_add_you_bank_account), RC_ADD_BANK_ACCOUNT);
                return;
            }

        }
        bidInfoViewModel.jobAction(params);
    }

    @OnClick(R.id.reject_bid)
    public void onBidReject() {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_ID, jobID);
        params.put(AppConstants.K_BID_ID, bidID);
        params.put(AppConstants.K_STATUS, AppConstants.BID_STATUS.REJECTED);
        bidInfoViewModel.bidAction(params);
    }

    @OnClick(R.id.cance_job)
    public void onCancelJob() {
        if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
            showConfirmationDialog(getString(R.string.msg_job_cancel_warning), RC_CANCEL_JOB_OWNER);
        } else {
            showConfirmationDialog(getString(R.string.msg_cancel_job), RC_CANCEL_JOB_WORKER);
        }

    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    @Override
    public void onCancelClicked() {

    }

    @OnClick(R.id.message)
    public void onMessage() {
        if (userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
            startActivity(ChatActivity.createIntent(this, jobInfo.getJobId(), jobInfo.getJobVendorId(), jobInfo.getVendorName()
                    , jobInfo.getVendorImage(), jobInfo.getJobName()));
        } else {
            startActivity(ChatActivity.createIntent(this, jobInfo.getJobId(), jobInfo.getUserId()
                    , jobInfo.getUserName(), jobInfo.getUserImage(), jobInfo.getJobName()));
        }

    }

    @OnClick(R.id.view_reviews)
    public void onReview() {
        String vendorId;
        if (bid != null) {
            vendorId = bid.getVendorId();

        } else {
            vendorId = jobInfo.getJobVendorId();

        }

        bidInfoViewModel.getRatings(vendorId);
        reviewsDialogFragment = ReviewsDialogFragment.newInstance(vendorId);
        reviewsDialogFragment.show(getSupportFragmentManager(), ReviewsDialogFragment.class.getSimpleName());
    }

    @OnClick(R.id.repost_job)
    public void onRepostJob() {
        showConfirmationDialog(getString(R.string.msg_repost_job, jobInfo.getVendorName()), getString(R.string.repost_job), getString(R.string.cancel), RC_JOB_REPOST);
    }

    @Override
    public void onBankAdded() {
        userInfo.setIsBankDetailsAdded(1);
        dataManager.saveUser(userInfo);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_CALL_TO_JOB_REPOST && resultCode == RESULT_OK) {
            showDialog(getString(R.string.job_reposted_successfully), RC_OTHER, AppConstants.DIALOG_TYPE.SUCCESS, this);
        } else if (requestCode == RC_RATE_USER && resultCode == RESULT_OK) {
            showDialog(getString(R.string.msg_rate_successfully), RC_OTHER, AppConstants.DIALOG_TYPE.SUCCESS, this);
        }
    }
}
