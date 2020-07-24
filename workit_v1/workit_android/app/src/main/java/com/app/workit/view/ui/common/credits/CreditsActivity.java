package com.app.workit.view.ui.common.credits;

import android.os.Bundle;

import android.widget.TextView;
import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.app.workit.R;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.CreditListAdapter;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.customview.BaseRecyclerView;

import javax.inject.Inject;
import java.util.HashMap;

public class CreditsActivity extends BaseActivity implements CommonDialog.CommonDialogCallback {

    private static final int RC_ADD_CREDIT = 42;
    @BindView(R.id.available_credits)
    TextView availableCredits;
    @BindView(R.id.recent_credits)
    BaseRecyclerView recentCredits;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @Inject
    ViewModelFactory viewModelFactory;
    private CreditsViewModel creditsViewModel;
    private CreditListAdapter creditListAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.credits_screen_layout);
        setToolbarTitle(R.string.credits);
        ButterKnife.bind(this);
        creditsViewModel = ViewModelProviders.of(this, viewModelFactory).get(CreditsViewModel.class);
    }

    @Override
    protected void initView() {
        initCredits();
        creditsViewModel.getAddCreditLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showDialogProgress();
                    break;
                case ERROR:
                    hideDialogProgress();
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideDialogProgress();
                    creditsViewModel.getCredits();
                    break;
            }
        });
    }

    private void initCredits() {
        availableCredits.setText(getString(R.string.price_in_dollar, userInfo.getCredits()));
        recentCredits.setLayoutManager(new LinearLayoutManager(this));
        recentCredits.setEmptyView(this, emptyView, R.string.no_credits_found);
        creditListAdapter = new CreditListAdapter(this);
        recentCredits.setAdapter(creditListAdapter);

        creditsViewModel.getCredits();
        creditsViewModel.getCreditsLiveData()
                .observe(this, creditNetworkResponseList -> {
                    switch (creditNetworkResponseList.status) {
                        case LOADING:
                            showLoading();
                            break;
                        case ERROR:
                            hideLoading();
                            showErrorPrompt(creditNetworkResponseList.message);
                            break;
                        case SUCCESS:
                            hideLoading();
                            userInfo.setCredits(creditNetworkResponseList.response.getCredits());
                            availableCredits.setText(getString(R.string.price_in_dollar, creditNetworkResponseList.response.getCredits()));
                            creditListAdapter.updateList(creditNetworkResponseList.response.getTransactions());
                            dataManager.saveUser(userInfo);
                            break;
                    }
                });
    }

    @OnClick(R.id.add_credit)
    public void onAddCredit() {
        CommonDialog commonDialog = CommonDialog.newInstance(AppConstants.DIALOG_TYPE.CREDIT_ADD,
                "", getString(R.string.add_credits), RC_ADD_CREDIT);
        commonDialog.setCommonDialogCallback(this);
        commonDialog.setCancelable(true);
        commonDialog.show(getSupportFragmentManager(), CommonDialog.class.getSimpleName());
    }

    @Override
    public void onOkClicked(int action) {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_USER_ID, userInfo.getUserId());
        params.put(AppConstants.K_AMOUNT, action);
        creditsViewModel.addCredit(params);
    }

    @Override
    public void onCancelClicked() {

    }
}
