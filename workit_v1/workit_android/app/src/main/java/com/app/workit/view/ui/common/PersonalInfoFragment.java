package com.app.workit.view.ui.common;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.app.workit.R;
import com.app.workit.view.ui.base.MainBaseFragment;

import butterknife.ButterKnife;
import butterknife.Unbinder;

public class PersonalInfoFragment extends MainBaseFragment {
    private Unbinder unbinder;


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Override
    protected void initViewsForFragment(View view) {

    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }
}
