package com.app.workit.view.adapter;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

import com.app.workit.view.ui.hire.HireHomeFragment;
import com.app.workit.view.ui.work.WorkHomeFragment;

public class HomePagerAdapter extends FragmentPagerAdapter {

    private int NUM_OF_PAGER = 2;

    public HomePagerAdapter(@NonNull FragmentManager fm) {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        switch (position) {
            default:
            case 0:
                return HireHomeFragment.newInstance();
            case 1:
                return WorkHomeFragment.newInstance();
        }
    }

    @Override
    public int getCount() {
        return NUM_OF_PAGER;
    }
}
