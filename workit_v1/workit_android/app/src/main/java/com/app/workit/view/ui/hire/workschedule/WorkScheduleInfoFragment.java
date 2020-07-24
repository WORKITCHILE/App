package com.app.workit.view.ui.hire.workschedule;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.ScheduleResponse;
import com.app.workit.view.adapter.WorkScheduleAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseFragment;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.hire.bid.BidInfoActivity;

import java.util.List;

public class WorkScheduleInfoFragment extends MainBaseFragment implements IAdapterItemClickListener {

    @BindView(R.id.base_recycler_view)
    BaseRecyclerView workScheduleBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private WorkScheduleAdapter workScheduleAdapter;
    private Unbinder unbinder;

    public static WorkScheduleInfoFragment newInstance() {

        Bundle args = new Bundle();

        WorkScheduleInfoFragment fragment = new WorkScheduleInfoFragment();
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
        initWorkSchedule();
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_common, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    private void initWorkSchedule() {
        workScheduleBaseRecyclerView.setLayoutManager(new LinearLayoutManager(getmContext()));
        workScheduleBaseRecyclerView.setEmptyView(getmContext(), emptyView, R.string.no_scheduled_work);

        workScheduleAdapter = new WorkScheduleAdapter(getmContext());
        workScheduleAdapter.setiAdapterItemClickListener(this);
        workScheduleBaseRecyclerView.setAdapter(workScheduleAdapter);

    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        ScheduleResponse scheduleResponse = workScheduleAdapter.getWorkSchedules().get(position);
        Job job = scheduleResponse.getJobData().get(0);
        startActivity(BidInfoActivity.createIntent(getmActivity(), job.getJobId()));
    }

    public void updateFragment(List<ScheduleResponse> scheduleResponses) {
        workScheduleAdapter.updateList(scheduleResponses);
    }
}
