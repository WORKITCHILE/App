package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.ScheduleResponse;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Timing;
import com.app.workit.view.callback.IAdapterItemClickListener;

import java.util.ArrayList;
import java.util.List;

public class WorkScheduleAdapter extends RecyclerView.Adapter<WorkScheduleAdapter.WorkScheduleHolder> {
    private Context mContext;
    private List<ScheduleResponse> workSchedules;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public WorkScheduleAdapter(Context mContext) {
        this.mContext = mContext;
        workSchedules = new ArrayList<>();
    }

    public List<ScheduleResponse> getWorkSchedules() {
        return workSchedules;
    }

    public void updateList(List<ScheduleResponse> newWorkSchedules) {
        if (workSchedules.isEmpty()) {
            workSchedules.addAll(newWorkSchedules);
            notifyItemRangeInserted(0, newWorkSchedules.size());
        } else {
            int oldSize = workSchedules.size();
            workSchedules.clear();
            notifyItemRangeRemoved(0, oldSize);
            workSchedules.addAll(newWorkSchedules);
            notifyItemRangeInserted(0, newWorkSchedules.size());

        }
    }

    @NonNull
    @Override
    public WorkScheduleHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new WorkScheduleHolder(LayoutInflater.from(mContext).inflate(R.layout.item_work_schedule, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull WorkScheduleHolder holder, int position) {
        try {
            ScheduleResponse scheduleResponse = workSchedules.get(position);
            long currentTime = scheduleResponse.getTime();
            holder.date.setText(Timing.getTimeInStringWithoutStamp(currentTime, Timing.TimeFormats.DD_MMM_YYYY));
            holder.viewSwitcher.setDisplayedChild(scheduleResponse.getJobData().isEmpty() ? 0 : 1);

            if (!scheduleResponse.getJobData().isEmpty()) {
                List<Job> jobData = scheduleResponse.getJobData();
                holder.viewSwitcherMoreJobInfo.setDisplayedChild(jobData.size() > 1 ? 0 : 1);

                holder.noOfJobsScheduled.setText(mContext.getString(R.string.txt_no_of_jobs_scheduled, jobData.size()));
                holder.jobMoreInfo.setText(R.string.txt_click_here);

                if (jobData.size() == 1) {
                    Job job = jobData.get(0);
                    holder.jobStatus.setTextColor(ContextCompat.getColor(mContext, job.getStatus().equalsIgnoreCase(AppConstants.JOB_STATUS.PAID)
                            ? R.color.colorGreen : R.color.textColorRed));
                    holder.jobStatus.setText(job.getStatus());
                    holder.jobName.setText(job.getJobName());
                    holder.jobAddress.setText(job.getJobAddress());
                    holder.date.setText(Timing.getTimeInString(job.getJobTime(), Timing.TimeFormats.DD_MMM_YYYY));
                    holder.time.setText(Timing.getTimeInString(job.getJobTime(), Timing.TimeFormats.HH_12));
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return workSchedules.size();
    }

    public class WorkScheduleHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.date)
        public TextView date;
        @BindView(R.id.view_switcher)
        ViewSwitcher viewSwitcher;
        @BindView(R.id.view_switcher_job_info)
        ViewSwitcher viewSwitcherMoreJobInfo;
        @BindView(R.id.noOfJobs)
        TextView noOfJobsScheduled;
        @BindView(R.id.jobMoreInfo)
        TextView jobMoreInfo;
        @BindView(R.id.jobStatus)
        TextView jobStatus;
        @BindView(R.id.jobName)
        TextView jobName;
        @BindView(R.id.jobAddress)
        TextView jobAddress;
        @BindView(R.id.time)
        TextView time;

        public WorkScheduleHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            itemView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (iAdapterItemClickListener == null) return;
            iAdapterItemClickListener.onAdapterItemClick(v, getAdapterPosition());
        }
    }
}
