package com.app.workit.view.ui.common.evaluation.ratereview;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.RadioGroup;
import android.widget.RatingBar;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatRatingBar;
import androidx.lifecycle.ViewModelProviders;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

import javax.inject.Inject;
import java.util.HashMap;

public class RateReviewActivity extends BaseActivity implements CommonDialog.CommonDialogCallback {

    private static final int RC_FINISHED = 41;
    @BindView(R.id.rating_bar)
    AppCompatRatingBar ratingBar;
    @BindView(R.id.rg_contact_outside)
    RadioGroup contactOutsideRadioGroup;
    @BindView(R.id.comment)
    WorkItEditText comment;
    @BindView(R.id.btnSubmit)
    Button btnSubmit;
    @Inject
    ViewModelFactory viewModelFactory;
    private RateReviewModel rateReviewModel;
    private Job jobInfo;

    public static Intent createIntent(Context context, Job job) {
        return new Intent(context, RateReviewActivity.class)
                .putExtra(AppConstants.K_JOB, job);
    }

    public static Intent createIntent(Context context, Job job, String action) {
        return new Intent(context, RateReviewActivity.class)
                .putExtra(AppConstants.K_JOB, job)
                .setAction(action);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.evaluation_screen_layout);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.evaluation_your_service);
        rateReviewModel = ViewModelProviders.of(this, viewModelFactory).get(RateReviewModel.class);
    }

    @Override
    protected void initView() {
        getToolbarBack().setVisibility(View.GONE);
        jobInfo = getIntent().getParcelableExtra(AppConstants.K_JOB);
        if (getIntent().getAction() == null) {
            showSuccessDialog(getString(R.string.job_finished), RC_FINISHED);
        }

        initButtonProgress(btnSubmit);
        ratingBar.setOnRatingBarChangeListener(new RatingBar.OnRatingBarChangeListener() {
            @Override
            public void onRatingChanged(RatingBar ratingBar, float rating, boolean fromUser) {
                if (fromUser && rating < 1.0f) {
                    ratingBar.setRating(1.0f);
                }
            }
        });
        rateReviewModel.getEvaluateLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showButtonProgress(btnSubmit);
                    break;
                case ERROR:
                    hideButtonProgress(getString(R.string.submit), btnSubmit);
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideButtonProgress(getString(R.string.submit), btnSubmit);
                    setResult(RESULT_OK);
                    finish();
                    break;
            }
        });
    }

    private void showSuccessDialog(String message, int action) {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.SUCCESS, "", message, RC_FINISHED);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }


    @OnClick(R.id.btnSubmit)
    public void onSubmit() {
        if (comment.getText().toString().trim().isEmpty()) {
            showMessage(R.string.leave_us_a_comment);
            return;
        }
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_JOB_ID, jobInfo.getJobId());
        if (userInfo.getUserId().equalsIgnoreCase(jobInfo.getUserId())) {
            params.put(AppConstants.K_RATE_FROM, userInfo.getUserId());
            params.put(AppConstants.K_RATE_FROM_NAME, userInfo.getName());
            params.put(AppConstants.K_RATE_TO, jobInfo.getJobVendorId());
            params.put(AppConstants.K_RATE_TO_NAME, jobInfo.getVendorName());
            params.put(AppConstants.K_RATE_FROM_TYPE, AppConstants.USER_TYPE.HIRE);
            params.put(AppConstants.K_RATE_TO_TYPE, AppConstants.USER_TYPE.WORK);
        } else {
            params.put(AppConstants.K_RATE_FROM, userInfo.getUserId());
            params.put(AppConstants.K_RATE_FROM_NAME, userInfo.getName());
            params.put(AppConstants.K_RATE_TO, jobInfo.getUserId());
            params.put(AppConstants.K_RATE_TO_NAME, jobInfo.getUserName());
            params.put(AppConstants.K_RATE_FROM_TYPE, AppConstants.USER_TYPE.WORK);
            params.put(AppConstants.K_RATE_TO_TYPE, AppConstants.USER_TYPE.HIRE);
        }
        params.put(AppConstants.K_RATING, ratingBar.getRating());
        params.put(AppConstants.K_CONTACT_OUTSIDE, contactOutsideRadioGroup.getCheckedRadioButtonId() == R.id.rb_yes ? AppConstants.K_YES.toUpperCase()
                : AppConstants.K_NO.toUpperCase());
        params.put(AppConstants.K_COMMENT, comment.getText().toString().trim());
        rateReviewModel.rateUser(params);
    }

    @Override
    public void onOkClicked(int action) {

    }

    @Override
    public void onCancelClicked() {

    }

    @OnClick(R.id.btnSkip)
    public void onSkip() {
        setResult(RESULT_CANCELED);
        finish();
    }
}
