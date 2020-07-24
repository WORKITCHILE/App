package com.app.workit.view.ui.common.termsofservice;

import android.os.Bundle;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;

import javax.inject.Inject;

public class TermsOfServiceActivity extends BaseActivity {

    @BindView(R.id.termsOfService)
    TextView termsOfService;
    @Inject
    ViewModelFactory viewModelFactory;
    private TermsOfServiceViewModel termsOfServiceViewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_terms_of_service);
        setToolbarTitle(R.string.terms_of_service);
        ButterKnife.bind(this);
        termsOfServiceViewModel = ViewModelProviders.of(this, viewModelFactory).get(TermsOfServiceViewModel.class);
    }

    @Override
    protected void initView() {
        termsOfServiceViewModel.getTermsOfService();
        termsOfServiceViewModel.getTermsAndConditionLiveData().observe(this, termsAndConditionNetworkResponse -> {
            switch (termsAndConditionNetworkResponse.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(termsAndConditionNetworkResponse.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    termsOfService.setText(termsAndConditionNetworkResponse.response.getTermsAndCondition());
                    break;
            }
        });
    }
}
