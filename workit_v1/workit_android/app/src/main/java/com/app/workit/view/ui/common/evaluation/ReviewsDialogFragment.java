package com.app.workit.view.ui.common.evaluation;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.app.workit.R;
import com.app.workit.data.model.RatingReview;
import com.app.workit.util.AppConstants;
import com.app.workit.view.adapter.ReviewListAdapter;
import com.app.workit.view.ui.customview.BaseRecyclerView;

import java.util.List;

public class ReviewsDialogFragment extends BottomSheetDialogFragment {
    @BindView(R.id.base_recycler_view)
    BaseRecyclerView reviewsBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @BindView(R.id.view_switcher)
    ViewSwitcher viewSwitcher;

    private Unbinder unbinder;
    private String userID = "";
    private ReviewListAdapter reviewListAdapter;


    public static ReviewsDialogFragment newInstance(String selfUserId) {

        Bundle args = new Bundle();
        args.putString(AppConstants.K_USER_ID, selfUserId);
        ReviewsDialogFragment fragment = new ReviewsDialogFragment();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_reviews, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        userID = getArguments().getString(AppConstants.K_USER_ID);
        initReviews();
    }

    private void initReviews() {
        reviewsBaseRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        reviewsBaseRecyclerView.setEmptyView(getContext(), emptyView, R.string.no_reviews_found);

        reviewListAdapter = new ReviewListAdapter(getContext(), userID);
        reviewsBaseRecyclerView.setAdapter(reviewListAdapter);
    }

    public void updateFragment(List<RatingReview> ratingReviews) {
        viewSwitcher.setDisplayedChild(1);
        reviewListAdapter.updateList(ratingReviews);
    }
}
