package com.app.workit.view.ui.work.accountsettings;

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
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import androidx.viewpager.widget.ViewPager;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.data.model.Credit;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.model.Bank;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.banking.AddBankDialogFragment;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.google.android.material.tabs.TabLayout;

import javax.inject.Inject;
import java.util.HashMap;

public class AccountSettingsActivity extends BaseActivity implements CreditsFragment.CreditsCallBack, AccountSettingsFragment.AccountSettingCallBack, CommonDialog.CommonDialogCallback, AddBankDialogFragment.IBankSelectionCallback {
    private static final int RC_ADD_CREDIT = 11;
    @BindView(R.id.view_switcher)
    ViewSwitcher viewSwitcher;
    @BindView(R.id.pager_credits)
    ViewPager viewPager;
    @BindView(R.id.tabLayout)
    TabLayout tabLayout;
    @Inject
    ViewModelFactory viewModelFactory;
    private AccountSettingsViewModel accountSettingsViewModel;
    private AccountSettingPagerAdapter accountSettingPagerAdapter;

    public static Intent createIntent(Context context) {
        return new Intent(context, AccountSettingsActivity.class);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_account_settings);
        setToolbarTitle(R.string.account_settings);
        ButterKnife.bind(this);
        accountSettingsViewModel = ViewModelProviders.of(this, viewModelFactory).get(AccountSettingsViewModel.class);
    }

    @Override
    protected void initView() {
        initPager();
        accountSettingsViewModel.getBankDetails();
        accountSettingsViewModel.getBankLiveData().observe(this, bankNetworkResponse -> {
            switch (bankNetworkResponse.status) {
                case LOADING:
                    setLoadingState(true);
                    break;
                case ERROR:
                    setLoadingState(false);
                    showErrorPrompt(bankNetworkResponse.message);
                    break;
                case SUCCESS:
                    setLoadingState(false);
                    break;
            }
        });
        accountSettingsViewModel.getCreditsLiveData().observe(this, creditNetworkResponse -> {
            switch (creditNetworkResponse.status) {
                case LOADING:
                    setLoadingState(true);
                    break;
                case ERROR:
                    setLoadingState(false);
                    showErrorPrompt(creditNetworkResponse.message);
                    break;
                case SUCCESS:
                    setLoadingState(false);
                    CreditsFragment creditsFragment = (CreditsFragment) accountSettingPagerAdapter.getRegisteredFragments().get(1);
                    creditsFragment.updateFragment(creditNetworkResponse.response);
                    break;
            }
        });
        accountSettingsViewModel.getAddCreditLiveData().observe(this, stringNetworkResponse -> {
            switch (stringNetworkResponse.status) {
                case LOADING:
                    showDialogProgress();
                    break;
                case ERROR:
                    hideDialogProgress();
                    showErrorPrompt(stringNetworkResponse.message);
                    break;
                case SUCCESS:
                    hideDialogProgress();
                    accountSettingsViewModel.getCredits();
                    break;
            }
        });
    }

    private void initPager() {
        accountSettingPagerAdapter = new AccountSettingPagerAdapter(getSupportFragmentManager(), this, this, this);
        viewPager.setAdapter(accountSettingPagerAdapter);
        tabLayout.setupWithViewPager(viewPager);

        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    accountSettingsViewModel.getBankDetails();
                } else {
                    accountSettingsViewModel.getCredits();
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    public void setLoadingState(boolean state) {
        viewSwitcher.setDisplayedChild(state ? 0 : 1);

    }

    @Override
    public void onAddCredit() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CREDIT_ADD,
                "", getString(R.string.add_credits), RC_ADD_CREDIT);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.setCancelable(true);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public void onAddBankAccount() {
        AddBankDialogFragment addBankDialogFragment = AddBankDialogFragment.newInstance();
        addBankDialogFragment.setiBankSelectionCallback(this);
        addBankDialogFragment.show(getSupportFragmentManager(), AddBankDialogFragment.class.getSimpleName());
    }

    @Override
    public void onOkClicked(int action) {
        if (action == RC_ADD_CREDIT) {
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            params.put(AppConstants.K_AMOUNT, action);
            accountSettingsViewModel.addCredit(params);
        }
    }

    @Override
    public void onCancelClicked() {

    }

    @Override
    public void onBankAdded() {
        accountSettingsViewModel.getBankDetails();
    }

    static class AccountSettingPagerAdapter extends FragmentPagerAdapter {
        private final Context context;
        private final AccountSettingsFragment.AccountSettingCallBack accountSettingCallback;
        private final CreditsFragment.CreditsCallBack creditsCallback;
        private SparseArray<Fragment> registeredFragments = new SparseArray<Fragment>();


        public AccountSettingPagerAdapter(@NonNull FragmentManager fm, Context context, AccountSettingsFragment.AccountSettingCallBack accountSettingCallBack,
                                          CreditsFragment.CreditsCallBack creditsCallBack) {
            super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
            this.context = context;
            this.accountSettingCallback = accountSettingCallBack;
            this.creditsCallback = creditsCallBack;
        }

        @NonNull
        @Override
        public Fragment getItem(int position) {
            switch (position) {
                default:
                case 0:
                    AccountSettingsFragment accountSettingsFragment = AccountSettingsFragment.newInstance();
                    accountSettingsFragment.setAccountSettingCallBack(accountSettingCallback);
                    return accountSettingsFragment;
                case 1:
                    CreditsFragment creditsFragment = CreditsFragment.newInstance();
                    creditsFragment.setCreditsCallBack(creditsCallback);
                    return creditsFragment;
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
                    return context.getString(R.string.accounts);
                case 1:
                    return context.getString(R.string.credits);
            }
        }

        public SparseArray<Fragment> getRegisteredFragments() {
            return registeredFragments;
        }
    }
}
