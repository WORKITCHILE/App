package com.app.workit.view.ui.work.bids;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.view.ui.base.MainBaseFragment;

public class RunningJobFragment extends MainBaseFragment {

    public static RunningJobFragment newInstance() {

        Bundle args = new Bundle();

        RunningJobFragment fragment = new RunningJobFragment();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    protected void initViewsForFragment(View view) {

    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_common, container, false);
        ButterKnife.bind(this, view);
        return view;
    }
}
