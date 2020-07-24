package com.app.workit.view.ui.common.history;

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

import javax.inject.Inject;

public class HistoryActivity extends BaseActivity {
    @BindView(R.id.view_switcher)
    ViewSwitcher viewSwitcher;
    @BindView(R.id.pager_history)
    ViewPager viewPager;
    @BindView(R.id.tabLayout)
    TabLayout tabLayout;
    @Inject
    ViewModelFactory viewModelFactory;
    private HistoryJobViewModel historyJobViewModel;
    private JobPagerAdapter jobPagerAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_job_history);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.history);
        historyJobViewModel = ViewModelProviders.of(this, viewModelFactory).get(HistoryJobViewModel.class);
    }

    @Override
    protected void initView() {
        initJobsPager();
        historyJobViewModel.getJobsLiveData().observe(this, jobNetworkResponseList -> {
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
    protected void onResume() {
        super.onResume();
        historyJobViewModel.getHistoryJobs(viewPager.getCurrentItem() == 0 ? AppConstants.USER_TYPE.HIRE : AppConstants.USER_TYPE.WORK);
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
                        historyJobViewModel.getHistoryJobs(AppConstants.USER_TYPE.HIRE);
                        break;
                    case 1:
                        historyJobViewModel.getHistoryJobs(AppConstants.USER_TYPE.WORK);
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    public void setLoadingState(boolean state) {
        super.setLoadingState(state);
        viewSwitcher.setDisplayedChild(state ? 0 : 1);
    }
}
