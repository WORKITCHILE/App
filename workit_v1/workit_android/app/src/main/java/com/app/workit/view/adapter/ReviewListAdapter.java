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
import com.app.workit.R;
import com.app.workit.data.model.RatingReview;
import com.app.workit.util.Timing;
import com.app.workit.view.callback.IAdapterItemClickListener;
import de.hdodenhof.circleimageview.CircleImageView;

import java.util.ArrayList;
import java.util.List;

public class ReviewListAdapter extends RecyclerView.Adapter<ReviewListAdapter.ReviewHolder> {
    private final String selfUserId;
    private Context context;
    private List<RatingReview> reviews;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public ReviewListAdapter(Context context, String selfUserId) {
        this.context = context;
        this.selfUserId = selfUserId;
        reviews = new ArrayList<>();
    }

    public List<RatingReview> getReviews() {
        return reviews;
    }

    public void updateList(List<RatingReview> newRatingReviews) {
        if (reviews.isEmpty()) {
            reviews.addAll(newRatingReviews);
            notifyItemRangeInserted(0, newRatingReviews.size());
        } else {
            int oldSize = reviews.size();
            reviews.clear();
            notifyItemRangeRemoved(0, oldSize);
            reviews.addAll(newRatingReviews);
            notifyItemRangeInserted(0, newRatingReviews.size());

        }
    }


    @NonNull
    @Override
    public ReviewListAdapter.ReviewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ReviewHolder(LayoutInflater.from(context).inflate(R.layout.item_review, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ReviewHolder holder, int position) {
        try {
            RatingReview ratingReview = reviews.get(position);
            if (selfUserId.equalsIgnoreCase(ratingReview.getRateFrom())) {
                Glide.with(context).load(ratingReview.getRateToImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);
                holder.userName.setText(ratingReview.getRateToName());
            } else {
                Glide.with(context).load(ratingReview.getRateFromImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);
                holder.userName.setText(ratingReview.getRateFromName());
            }
            holder.date.setText(Timing.getTimeInString(ratingReview.getJobTime(), Timing.TimeFormats.DD_MM_YYYY));
            holder.ratingBar.setRating(Float.parseFloat(ratingReview.getRating()));
            holder.comment.setText(ratingReview.getComment());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return reviews.size();
    }

    public class ReviewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.avatar)
        CircleImageView avatar;
        @BindView(R.id.date)
        TextView date;
        @BindView(R.id.rating_bar)
        AppCompatRatingBar ratingBar;
        @BindView(R.id.comment)
        TextView comment;
        @BindView(R.id.userName)
        TextView userName;

        public ReviewHolder(@NonNull View itemView) {
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
