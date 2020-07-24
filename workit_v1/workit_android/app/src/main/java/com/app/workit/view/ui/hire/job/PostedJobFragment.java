package com.app.workit.view.ui.hire.job;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.Nullable;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.util.AppConstants;
import com.app.workit.view.adapter.PostJobListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.common.evaluation.ratereview.RateReviewActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.hire.bid.BidInfoActivity;

import java.util.List;

import static android.app.Activity.RESULT_OK;

public class PostedJobFragment extends MainBaseFragment implements IAdapterItemClickListener {
    private static final int RC_JOB_INFO = 11;
    private static final int RC_EVALUATE = 12;
    private Unbinder unbinder;
    @BindView(R.id.base_recycler_view)
    BaseRecyclerView baseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private PostJobListAdapter postJobListAdapter;
    private Job selectedJob;

    public static PostedJobFragment newInstance() {

        Bundle args = new Bundle();

        PostedJobFragment fragment = new PostedJobFragment();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Override
    protected void initViewsForFragment(View view) {
        initJobs();
    }

    private void initJobs() {
        baseRecyclerView.setEmptyView(getContext(), emptyView, R.string.no_jobs_found);
        postJobListAdapter = new PostJobListAdapter(getmContext(), userInfo, AppConstants.USER_TYPE.WORK, AppConstants.USER_TYPE.WORK_INFO);
        postJobListAdapter.setiAdapterItemClickListener(this);
        baseRecyclerView.setAdapter(postJobListAdapter);
    }


    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_common, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        selectedJob = postJobListAdapter.getCurrentJobs().get(position);
        startActivityForResult(BidInfoActivity.createIntent(getContext(), selectedJob), RC_JOB_INFO);
    }

    public void updateFragment(List<Job> response) {
        postJobListAdapter.updateList(response);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_JOB_INFO && resultCode == RESULT_OK) {
            if (data != null && data.hasExtra(AppConstants.K_STATUS)) {
                if (data.getStringExtra(AppConstants.K_STATUS).equalsIgnoreCase(AppConstants.JOB_STATUS.PAID)) {
                    startActivityForResult(RateReviewActivity.createIntent(getmActivity(), selectedJob), RC_EVALUATE);
                }
            }

        }
    }
}
