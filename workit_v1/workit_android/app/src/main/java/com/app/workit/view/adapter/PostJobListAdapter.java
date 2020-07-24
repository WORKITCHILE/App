package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatRatingBar;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.UserInfo;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Timing;
import com.app.workit.view.callback.IAdapterItemClickListener;
import de.hdodenhof.circleimageview.CircleImageView;

import java.util.ArrayList;
import java.util.List;

public class PostJobListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int TYPE_HIRE = 1;
    private static final int TYPE_WORK = 2;
    private final Context mContext;
    private final UserInfo userInfo;
    private final String type;
    private int subType;
    private List<Job> currentJobs = new ArrayList<>();
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public PostJobListAdapter(Context context, UserInfo userInfo, String type) {
        mContext = context;
        this.userInfo = userInfo;
        this.type = type;
    }

    public PostJobListAdapter(Context context, UserInfo userInfo, String type, int subType) {
        mContext = context;
        this.subType = subType;
        this.userInfo = userInfo;
        this.type = type;
    }

    public void updateList(List<Job> newJobs) {
        currentJobs.clear();
        currentJobs.addAll(newJobs);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == TYPE_HIRE) {
            return new HirePostedJobHolder(LayoutInflater.from(mContext).inflate(R.layout.item_posted_job, parent, false));
        } else {
            return new WorkPostedJobHolder(LayoutInflater.from(mContext).inflate(R.layout.item_vendor_posted_job, parent, false));
        }

    }


    @Override
    public int getItemViewType(int position) {
        if (type.equals(AppConstants.USER_TYPE.HIRE)) {
            return TYPE_HIRE;
        } else if (type.equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {
            return TYPE_WORK;
        }
        return TYPE_HIRE;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder h, int position) {
        try {
            if (getItemViewType(position) == TYPE_HIRE) {
                HirePostedJobHolder holder = (HirePostedJobHolder) h;
                Job job = currentJobs.get(position);

                holder.date.setText(job.getJobDate());
                holder.noOfBids.setText(mContext.getString(R.string.txt_no_of_bids, job.getBidCount()));
                holder.ownerName.setText(userInfo.getName());
                holder.jobName.setText(job.getJobName());
                holder.jobDescription.setText(job.getJobDescription());
                holder.jobTime.setText(Timing.getTimeInString(Long.valueOf(job.getJobTime()), Timing.TimeFormats.HH_12));
                holder.jobAmount.setText(mContext.getString(R.string.txt_job_amount, job.getInitialAmount()));
                Glide.with(mContext).load(userInfo.getProfilePicture()).apply(new RequestOptions()
                        .error(R.drawable.no_image_available)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.userIcon);

            } else {
                WorkPostedJobHolder holder = (WorkPostedJobHolder) h;
                Job job = currentJobs.get(position);

                holder.date.setText(job.getJobDate());
                holder.ratingBar.setRating(subType == AppConstants.USER_TYPE.WORK_INFO ? Float.parseFloat(job.getVendorAverageRating()) : job.getOwnerRated());
                holder.ownerName.setText(subType == AppConstants.USER_TYPE.WORK_INFO ? job.getVendorName() == null ? job.getUserName() : job.getVendorName() : job.getUserName());
                holder.jobName.setText(job.getJobName());
                holder.jobTime.setText(Timing.getTimeInString(Long.valueOf(job.getJobTime()), Timing.TimeFormats.HH_12));
                if (subType == AppConstants.USER_TYPE.WORK_INFO) {
                    holder.jobAmount.setText(mContext.getString(R.string.txt_job_amount, job.getServiceAmount().equals("0") ? job.getInitialAmount() : job.getServiceAmount()));
                } else if (subType == AppConstants.USER_TYPE.HIRE_INFO) {
                    holder.jobAmount.setText(mContext.getString(R.string.txt_job_amount, job.getServiceAmount()));
                } else {
                    holder.jobAmount.setText(mContext.getString(R.string.txt_job_amount, job.getInitialAmount()));
                }

                Glide.with(mContext).load(subType == AppConstants.USER_TYPE.WORK_INFO ? job.getVendorImage() == null ? job.getUserImage() : job.getVendorImage() : job.getUserImage()).apply(new RequestOptions()
                        .error(R.drawable.no_image_available)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.userIcon);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Job> getCurrentJobs() {
        return currentJobs;
    }

    @Override
    public int getItemCount() {
        return currentJobs.size();
    }

    public class HirePostedJobHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.iv_user_icon)
        CircleImageView userIcon;
        @BindView(R.id.tv_date)
        TextView date;
        @BindView(R.id.tv_bids)
        TextView noOfBids;
        @BindView(R.id.tv_owner_name)
        TextView ownerName;
        @BindView(R.id.tv_job_name)
        TextView jobName;
        @BindView(R.id.tv_job_description)
        TextView jobDescription;
        @BindView(R.id.tv_job_time)
        TextView jobTime;
        @BindView(R.id.tv_job_amount)
        TextView jobAmount;
        @BindView(R.id.fab_edit)
        FloatingActionButton fabEdit;

        public HirePostedJobHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            itemView.setOnClickListener(this);
            fabEdit.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (iAdapterItemClickListener == null) return;
            iAdapterItemClickListener.onAdapterItemClick(v, getAdapterPosition());
        }
    }

    public class WorkPostedJobHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.iv_user_icon)
        CircleImageView userIcon;
        @BindView(R.id.tv_date)
        TextView date;
        @BindView(R.id.tv_owner_name)
        TextView ownerName;
        @BindView(R.id.tv_job_name)
        TextView jobName;
        @BindView(R.id.tv_job_time)
        TextView jobTime;
        @BindView(R.id.tv_job_amount)
        TextView jobAmount;
        @BindView(R.id.user_rating)
        AppCompatRatingBar ratingBar;

        public WorkPostedJobHolder(@NonNull View itemView) {
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
