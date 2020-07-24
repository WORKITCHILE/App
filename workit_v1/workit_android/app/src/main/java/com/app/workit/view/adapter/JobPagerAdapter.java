package com.app.workit.view.adapter;

import android.content.Context;
import android.util.SparseArray;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import com.app.workit.R;
import com.app.workit.view.ui.hire.job.PostedJobFragment;
import com.app.workit.view.ui.hire.job.ReceivedJobFragment;

public class JobPagerAdapter extends FragmentPagerAdapter {
    private final Context context;
    private SparseArray<Fragment> registeredFragments = new SparseArray<Fragment>();


    public JobPagerAdapter(@NonNull FragmentManager fm, Context context) {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        this.context = context;
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        switch (position) {
            default:
            case 0:
                return PostedJobFragment.newInstance();
            case 1:
                return ReceivedJobFragment.newInstance();
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
                return context.getString(R.string.posted_jobs);
            case 1:
                return context.getString(R.string.received_jobs);
        }
    }

    public SparseArray<Fragment> getRegisteredFragments() {
        return registeredFragments;
    }
}