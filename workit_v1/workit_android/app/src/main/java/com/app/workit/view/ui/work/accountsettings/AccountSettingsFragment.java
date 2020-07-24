package com.app.workit.view.ui.work.accountsettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import com.app.workit.R;
import com.app.workit.view.adapter.BankListAdapter;
import com.app.workit.view.adapter.CreditListAdapter;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.customview.BaseRecyclerView;

public class AccountSettingsFragment extends MainBaseFragment {
    @BindView(R.id.base_recycler_view)
    BaseRecyclerView baseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private Unbinder unbinder;
    private AccountSettingCallBack accountSettingCallBack;
    private BankListAdapter bankListAdapter;

    public void setAccountSettingCallBack(AccountSettingCallBack accountSettingCallBack) {
        this.accountSettingCallBack = accountSettingCallBack;
    }

    public static AccountSettingsFragment newInstance() {

        Bundle args = new Bundle();

        AccountSettingsFragment fragment = new AccountSettingsFragment();
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

    }

    private void initAccounts() {
        baseRecyclerView.setEmptyView(getContext(), emptyView, R.string.no_credits_found);
        //creditListAdapter = new CreditListAdapter(getmContext());
        //creditsBaseRecyclerView.setAdapter(creditListAdapter);
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_account_settings, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @OnClick(R.id.btn_add_account)
    public void onAddAccount() {
        accountSettingCallBack.onAddBankAccount();
    }

    public interface AccountSettingCallBack {
        void onAddBankAccount();
    }
}

