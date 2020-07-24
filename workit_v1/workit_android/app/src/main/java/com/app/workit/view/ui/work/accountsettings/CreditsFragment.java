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
import com.app.workit.data.model.Credit;
import com.app.workit.view.adapter.CreditListAdapter;
import com.app.workit.view.adapter.PostJobListAdapter;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.customview.BaseRecyclerView;

public class CreditsFragment extends MainBaseFragment {
    @BindView(R.id.recent_credits)
    BaseRecyclerView creditsBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @BindView(R.id.available_credits)
    TextView availableCredits;
    private CreditListAdapter creditListAdapter;
    private Unbinder unbinder;
    private CreditsCallBack creditsCallBack;

    public void setCreditsCallBack(CreditsCallBack creditsCallBack) {
        this.creditsCallBack = creditsCallBack;
    }

    public static CreditsFragment newInstance() {

        Bundle args = new Bundle();

        CreditsFragment fragment = new CreditsFragment();
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
        initCredits();
    }

    private void initCredits() {
        creditsBaseRecyclerView.setEmptyView(getContext(), emptyView, R.string.no_credits_found);
        creditListAdapter = new CreditListAdapter(getmContext());
        creditsBaseRecyclerView.setAdapter(creditListAdapter);
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.credits_screen_layout, container, false);
        unbinder = ButterKnife.bind(this, view);

        return view;
    }


    public void updateFragment(Credit credit) {
        availableCredits.setText(getString(R.string.price_in_dollar, credit.getCredits()));
        creditListAdapter.updateList(credit.getTransactions());
    }

    @OnClick(R.id.add_credit)
    public void onAddCredit() {
        creditsCallBack.onAddCredit();
    }

    public interface CreditsCallBack {
        void onAddCredit();
    }
}
