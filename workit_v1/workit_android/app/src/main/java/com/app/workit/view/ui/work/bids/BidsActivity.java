package com.app.workit.view.ui.work.bids;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.SparseArray;
import android.view.ViewGroup;
import android.widget.ViewSwitcher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.lifecycle.ViewModelProviders;
import androidx.viewpager.widget.ViewPager;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.google.android.material.tabs.TabLayout;
import com.app.workit.R;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;

import javax.inject.Inject;

public class BidsActivity extends BaseActivity {

    @BindView(R.id.view_switcher)
    ViewSwitcher bidsViewSwitcher;
    @BindView(R.id.pager_bids)
    ViewPager bidsViewPager;
    @BindView(R.id.tabLayout)
    TabLayout tabLayout;
    @Inject
    ViewModelFactory viewModelFactory;
    private BidViewModel bidViewModel;
    private BidPagerAdapter bidPagerAdapter;

    public static Intent createIntent(Context context) {
        return new Intent(context, BidsActivity.class);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.w_my_bids_layout);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.my_bids);
        bidViewModel = ViewModelProviders.of(this, viewModelFactory).get(BidViewModel.class);
    }

    @Override
    protected void initView() {
        initBidsPager();
        bidViewModel.getAllBids(AppConstants.BID_STATUS.POSTED);
        bidViewModel.getBidsLiveData().observe(this, jobNetworkResponseList -> {
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
                    switch (bidsViewPager.getCurrentItem()) {
                        case 0:
                            ActiveBidFragment fragment = (ActiveBidFragment) bidPagerAdapter.getRegisteredFragments().get(0);
                            fragment.updateFragment(jobNetworkResponseList.response);
                            break;
                        case 1:
                            RejectedBidFragment rejectedBidFragment = (RejectedBidFragment) bidPagerAdapter.getRegisteredFragments().get(1);
                            rejectedBidFragment.updateFragment(jobNetworkResponseList.response);
                            break;
                    }
                    break;

            }
        });

    }


    public void setLoadingState(boolean state) {
        bidsViewSwitcher.setDisplayedChild(state ? 1 : 0);
    }

    private void initBidsPager() {

        bidPagerAdapter = new BidPagerAdapter(getSupportFragmentManager(), this);
        bidsViewPager.setAdapter(bidPagerAdapter);
        tabLayout.setupWithViewPager(bidsViewPager);

        bidsViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                switch (position) {
                    case 0:
                        bidViewModel.getAllBids(AppConstants.BID_STATUS.POSTED);
                        break;
                    case 1:
                        bidViewModel.getAllBids(AppConstants.BID_STATUS.REJECTED);
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    static class BidPagerAdapter extends FragmentPagerAdapter {
        private final Context context;
        private SparseArray<Fragment> registeredFragments = new SparseArray<Fragment>();


        public BidPagerAdapter(@NonNull FragmentManager fm, Context context) {
            super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
            this.context = context;
        }

        @NonNull
        @Override
        public Fragment getItem(int position) {
            switch (position) {
                default:
                case 0:
                    return ActiveBidFragment.newInstance();
                case 1:
                    return RejectedBidFragment.newInstance();
            }
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            Fragment fragment = (Fragment) super.instantiateItem(container, position);
            registeredFragments.put(position, fragment);
            return fragment;
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
            registeredFragments.remove(position);
            super.destroyItem(container, position, object);
        }

        @Override
        public int getCount() {
            return 2;
        }

        @Nullable
        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                default:
                case 0:
                    return context.getString(R.string.active_bids);
                case 1:
                    return context.getString(R.string.rejected_bids);
            }
        }

        public SparseArray<Fragment> getRegisteredFragments() {
            return registeredFragments;
        }
    }
}
