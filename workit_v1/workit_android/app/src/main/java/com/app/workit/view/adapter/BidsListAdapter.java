package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.model.Bid;
import com.app.workit.view.callback.IAdapterItemClickListener;
import de.hdodenhof.circleimageview.CircleImageView;

import java.util.ArrayList;
import java.util.List;

public class BidsListAdapter extends RecyclerView.Adapter<BidsListAdapter.BidHolder> {

    private Context context;
    private List<Bid> bids;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public BidsListAdapter(Context context) {
        this.context = context;
        bids = new ArrayList<>();
    }

    public void updateList(List<Bid> newBids) {
        bids.clear();
        bids.addAll(newBids);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public BidHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new BidHolder(LayoutInflater.from(context).inflate(R.layout.item_bid, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull BidHolder holder, int position) {
        try {
            Bid bid = bids.get(position);
            holder.name.setText(bid.getVendorName());
            holder.bidOffer.setText(context.getString(R.string.countered_bid, Float.parseFloat(bid.getCounterofferAmount())));
            Glide.with(context).load(bid.getVendorImage()).apply(new RequestOptions()
                    .error(R.drawable.rotate_spinner)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);
            holder.occupation.setText(context.getString(R.string.user_occupation, bid.getVendorOccupation()));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Bid> getBids() {
        return bids;
    }

    @Override
    public int getItemCount() {
        return bids.size();
    }

    public class BidHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.name)
        TextView name;
        @BindView(R.id.bid_offer)
        TextView bidOffer;
        @BindView(R.id.occupation)
        TextView occupation;
        @BindView(R.id.avatar)
        CircleImageView avatar;

        public BidHolder(@NonNull View itemView) {
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
