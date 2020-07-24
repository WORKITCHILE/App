package com.app.workit.view.ui.common.runningjob;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import android.widget.ViewSwitcher;

import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import androidx.viewpager.widget.ViewPager;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.google.android.material.tabs.TabLayout;
import com.app.workit.R;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.JobPagerAdapter;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.hire.job.PostedJobFragment;
import com.app.workit.view.ui.hire.job.ReceivedJobFragment;
import com.app.workit.view.ui.work.bids.BidsActivity;

import javax.inject.Inject;

public class RunningJobActivity extends BaseActivity {
    @BindView(R.id.view_switcher)
    ViewSwitcher viewSwitcher;
    @BindView(R.id.pager_jobs)
    ViewPager viewPager;
    @BindView(R.id.tabLayout)
    TabLayout tabLayout;
    @Inject
    ViewModelFactory viewModelFactory;
    private JobViewModel jobViewModel;
    private JobPagerAdapter jobPagerAdapter;

    public static Intent createIntent(Context context) {
        return new Intent(context, BidsActivity.class);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_running_job);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.running_job);
        jobViewModel = ViewModelProviders.of(this, viewModelFactory).get(JobViewModel.class);

    }

    @Override
    protected void onResume() {
        super.onResume();
        jobViewModel.getJobs(viewPager.getCurrentItem() == 0 ? AppConstants.USER_TYPE.HIRE : AppConstants.USER_TYPE.WORK);
    }

    @Override
    protected void initView() {
        initJobsPager();
        jobViewModel.getJobsLiveData().observe(this, jobNetworkResponseList -> {
            switch (jobNetworkResponseList.status) {
                case LOADING:
                    setLoadingState(true);
                    break;
                case ERROR:
                    setLoadingState(false);
                    showErrorPrompt(jobNetworkResponseList.message);
                    break;
                case SUCCESS:
                    setLoadingState(false);
                    switch (viewPager.getCurrentItem()) {
                        case 0:
                            PostedJobFragment fragment = (PostedJobFragment) jobPagerAdapter.getRegisteredFragments().get(0);
                            fragment.updateFragment(jobNetworkResponseList.response);
                            break;
                        case 1:
                            ReceivedJobFragment receivedJobFragment = (ReceivedJobFragment) jobPagerAdapter.getRegisteredFragments().get(1);
                            receivedJobFragment.updateFragment(jobNetworkResponseList.response);
                            break;
                    }
                    break;
            }
        });

    }

    @Override
    public void setLoadingState(boolean state) {
        viewSwitcher.setDisplayedChild(state ? 1 : 0);
    }

    private void initJobsPager() {

        jobPagerAdapter = new JobPagerAdapter(getSupportFragmentManager(), this);
        viewPager.setAdapter(jobPagerAdapter);
        tabLayout.setupWithViewPager(viewPager);

        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                switch (position) {
                    case 0:
                        jobViewModel.getJobs(AppConstants.USER_TYPE.HIRE);
                        break;
                    case 1:
                        jobViewModel.getJobs(AppConstants.USER_TYPE.WORK);
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }


}
