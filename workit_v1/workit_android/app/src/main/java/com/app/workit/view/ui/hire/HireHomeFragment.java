package com.app.workit.view.ui.hire;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;

import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.UserInfo;
import com.app.workit.model.rxevent.RxRefreshAction;
import com.app.workit.util.AppConstants;
import com.app.workit.util.RxBus;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.PostJobListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.hire.postjob.PostJobActivity;

import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;

import com.app.workit.view.ui.hire.singlejob.SingleJobActivity;

import javax.inject.Inject;

import static android.app.Activity.RESULT_OK;

public class HireHomeFragment extends MainBaseFragment implements IAdapterItemClickListener, CommonDialog.CommonDialogCallback {

    private Unbinder unbinder;
    @BindView(R.id.btn_post_job_now)
    Button btnPostJobNow;
    @BindView(R.id.job_list_view)
    BaseRecyclerView jobRecyclerView;
    @BindView(R.id.empty_view)
    LinearLayout containerEmptyView;
    @BindView(R.id.list_view)
    RelativeLayout containerListView;
    private PostJobListAdapter postJobListAdapter;

    @Inject
    DataManager dataManager;
    @Inject
    ViewModelFactory viewModelFactory;
    private HireViewModel hireViewModel;
    private UserInfo userInfo;
    private Job selectedJob;


    public static HireHomeFragment newInstance() {

        Bundle args = new Bundle();

        HireHomeFragment fragment = new HireHomeFragment();
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
        hireViewModel = ViewModelProviders.of(this, viewModelFactory).get(HireViewModel.class);
        userInfo = dataManager.loadUser();
        initPostJobList();


    }

    private void initPostJobList() {
        jobRecyclerView.setLayoutManager(new LinearLayoutManager(getmContext()));
        postJobListAdapter = new PostJobListAdapter(getmContext(), userInfo, AppConstants.USER_TYPE.HIRE);
        postJobListAdapter.setiAdapterItemClickListener(this);
        jobRecyclerView.setAdapter(postJobListAdapter);

        hireViewModel.getPostedJobsLiveData().observe(getViewLifecycleOwner(), jobNetworkResponseList -> {
            switch (jobNetworkResponseList.status) {
                case LOADING:
                    RxBus.getInstance().setEvent(new RxRefreshAction(0, true));
                    break;
                case ERROR:
                    RxBus.getInstance().setEvent(new RxRefreshAction(0, false));
                    showErrorPrompt(jobNetworkResponseList.message);
                    break;
                case SUCCESS:
                    RxBus.getInstance().setEvent(new RxRefreshAction(0, false));
                    containerEmptyView.setVisibility(jobNetworkResponseList.response.isEmpty() ? View.VISIBLE : View.GONE);
                    containerListView.setVisibility(jobNetworkResponseList.response.isEmpty() ? View.GONE : View.VISIBLE);
                    postJobListAdapter.updateList(jobNetworkResponseList.response);

                    break;
            }
        });
        hireViewModel.getPostedJobs();
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_hire_home, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @OnClick(R.id.btn_post_job_now)
    public void onPostJobNow() {
        postJobNow();
    }

    @OnClick(R.id.btn_post_job)
    public void onPostJob() {
        postJobNow();
    }

    private void postJobNow() {
        startActivityForResult(PostJobActivity.createIntent(getActivity()), AppConstants.REQUEST_CODES.POST_JOB);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == AppConstants.REQUEST_CODES.POST_JOB && resultCode == RESULT_OK) {
            hireViewModel.getPostedJobs();
        }
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        selectedJob = postJobListAdapter.getCurrentJobs().get(position);
        if (v.getId() == R.id.fab_edit) {
            showConfirmationDialog();
        } else {
            startActivityForResult(SingleJobActivity.createIntent(getmContext(), selectedJob.getJobId()), AppConstants.REQUEST_CODES.SINGLE_JOB);
        }

    }

    private void showConfirmationDialog() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CONFIRMATION, getString(R.string.are_you_sure_edit_job),
                getString(R.string.yes), getString(R.string.no));
        commonDialog.setCommonDialogCallback(this);
        commonDialog.show(getChildFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public void onOkClicked(int action) {
        if (selectedJob != null) {
            startActivityForResult(PostJobActivity.createIntent(getmContext(), selectedJob.getJobId()), AppConstants.REQUEST_CODES.EDIT_JOB);
        }
    }

    @Override
    public void onCancelClicked() {

    }

    @Override
    public void onResume() {
        super.onResume();
        hireViewModel.getPostedJobs();
    }
}
