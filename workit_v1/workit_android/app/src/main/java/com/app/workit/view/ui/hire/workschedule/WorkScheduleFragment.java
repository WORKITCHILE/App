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

import java.text.DateFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

public class WorkScheduleFragment extends MainBaseFragment implements IAdapterItemClickListener {

    @BindView(R.id.base_recycler_view)
    BaseRecyclerView workScheduleBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private WorkScheduleAdapter workScheduleAdapter;
    private Unbinder unbinder;
    private Calendar calendarInstance;
    private WorkScheduleMoreInfoCallBack callBack;

    public void setCallBack(WorkScheduleMoreInfoCallBack callBack) {
        this.callBack = callBack;
    }

    public static WorkScheduleFragment newInstance() {

        Bundle args = new Bundle();

        WorkScheduleFragment fragment = new WorkScheduleFragment();
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
        calendarInstance = Calendar.getInstance();
        initWorkSchedule();
    }

    private void initWorkSchedule() {
        workScheduleBaseRecyclerView.setLayoutManager(new LinearLayoutManager(getmContext()));
        workScheduleBaseRecyclerView.setEmptyView(getmContext(), emptyView, R.string.no_scheduled_work);


        workScheduleAdapter = new WorkScheduleAdapter(getmContext());
        workScheduleAdapter.setiAdapterItemClickListener(this);
        workScheduleBaseRecyclerView.setAdapter(workScheduleAdapter);
    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_common, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        ScheduleResponse scheduleResponse = workScheduleAdapter.getWorkSchedules().get(position);
        if (scheduleResponse.getJobData().size() > 1) {
            callBack.onMoreInfo(scheduleResponse.getJobData());
        } else if (scheduleResponse.getJobData().size() == 1) {
            Job job = scheduleResponse.getJobData().get(0);
            startActivity(BidInfoActivity.createIntent(getmActivity(), job.getJobId()));
        }
    }

    public void updateFragment(List<ScheduleResponse> scheduleResponses, long currentTimeStamp) {
        int dayOfMonth = 0;
        calendarInstance.setTimeInMillis(currentTimeStamp);
        for (ScheduleResponse scheduleResponse : scheduleResponses) {
            calendarInstance.set(Calendar.DAY_OF_MONTH, dayOfMonth + 1);
            scheduleResponse.setTime(calendarInstance.getTimeInMillis());
            dayOfMonth++;
        }
        workScheduleAdapter.updateList(scheduleResponses);
    }


    public void getDayOfMonth() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.MONTH, 1);
        cal.set(Calendar.DAY_OF_MONTH, 1);
        int maxDay = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        System.out.print(df.format(cal.getTime()));
        for (int i = 1; i < maxDay; i++) {
            cal.set(Calendar.DAY_OF_MONTH, i + 1);

            System.out.print(", " + df.format(cal.getTime()));
        }
    }

    String getMonthForInt(int num) {
        String month = "wrong";
        DateFormatSymbols dfs = new DateFormatSymbols();
        String[] months = dfs.getMonths();
        if (num >= 0 && num <= 11) {
            month = months[num];
        }
        return month;
    }

    public interface WorkScheduleMoreInfoCallBack {
        void onMoreInfo(List<Job> jobs);
    }
}
