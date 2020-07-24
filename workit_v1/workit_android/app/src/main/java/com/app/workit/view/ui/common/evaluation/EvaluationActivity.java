package com.app.workit.view.ui.common.evaluation;

import android.os.Bundle;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import com.app.workit.R;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.EvaluationListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.BaseActivity;

import butterknife.ButterKnife;

import com.app.workit.view.ui.customview.BaseRecyclerView;

import javax.inject.Inject;

public class EvaluationActivity extends BaseActivity implements IAdapterItemClickListener {

    @BindView(R.id.base_recycler_view)
    BaseRecyclerView evaluationBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @Inject
    ViewModelFactory viewModelFactory;
    private EvaluationViewModel evaluationViewModel;
    private EvaluationListAdapter evaluationListAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_common);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.evaluations);
        evaluationViewModel = ViewModelProviders.of(this, viewModelFactory).get(EvaluationViewModel.class);
    }

    @Override
    protected void onResume() {
        super.onResume();
        evaluationViewModel.getRatings();
    }

    @Override
    protected void initView() {
        initEvaluations();
        evaluationViewModel.getRatingsLiveData().observe(this, ratingReviewNetworkResponseList -> {
            switch (ratingReviewNetworkResponseList.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(ratingReviewNetworkResponseList.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    evaluationListAdapter.updateList(ratingReviewNetworkResponseList.response);
                    break;
            }

        });
    }

    private void initEvaluations() {
        evaluationBaseRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        evaluationBaseRecyclerView.setEmptyView(this, emptyView, R.string.no_evaluations_found);

        evaluationListAdapter = new EvaluationListAdapter(this,userInfo.getUserId());
        evaluationListAdapter.setiAdapterItemClickListener(this);
        evaluationBaseRecyclerView.setAdapter(evaluationListAdapter);
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        //RatingReview ratingReview = evaluationListAdapter.getReviews().get(position);
      //  startActivity(BidInfoActivity.createIntent(this,));
    }
}
