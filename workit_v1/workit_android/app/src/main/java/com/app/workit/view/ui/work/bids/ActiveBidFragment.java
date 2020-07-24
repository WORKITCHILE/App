package com.app.workit.view.ui.work.bids;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.view.adapter.PostJobListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.hire.singlejob.SingleJobActivity;

import java.util.List;

public class ActiveBidFragment extends MainBaseFragment implements IAdapterItemClickListener {
    private static final int RC_JOB_INFO = 45;
    @BindView(R.id.base_recycler_view)
    BaseRecyclerView bidsBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private PostJobListAdapter bidsListAdapter;
    private Unbinder unbinder;


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    public static ActiveBidFragment newInstance() {

        Bundle args = new Bundle();

        ActiveBidFragment fragment = new ActiveBidFragment();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    protected void initViewsForFragment(View view) {
        initBids();
    }

    private void initBids() {
        bidsBaseRecyclerView.setEmptyView(getContext(), emptyView, R.string.no_bids_found);
        bidsListAdapter = new PostJobListAdapter(getmContext(), userInfo, userInfo.getType());
        bidsListAdapter.setiAdapterItemClickListener(this);
        bidsBaseRecyclerView.setAdapter(bidsListAdapter);
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_common, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        Job job = bidsListAdapter.getCurrentJobs().get(position);
        startActivityForResult(SingleJobActivity.createIntent(getContext(), job.getJobId()), RC_JOB_INFO);
    }

    public void updateFragment(List<Job> response) {
        bidsListAdapter.updateList(response);
    }
}
