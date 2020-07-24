package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.app.workit.R;
import com.app.workit.model.DrawerItem;
import com.app.workit.view.callback.IAdapterItemClickListener;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.subjects.PublishSubject;

public class DrawerAdapter extends RecyclerView.Adapter<DrawerAdapter.DrawerAdapterHolder> {
    private Context mContext;
    private ArrayList<DrawerItem> mData;
    private int mResId;
    private IAdapterItemClickListener iAdapterItemClickListener;

    private PublishSubject<Integer> mItemClickSubject = PublishSubject.create();


    public DrawerAdapter(Context context, int resId, ArrayList<DrawerItem> data) {
        mContext = context;
        mData = data;
        mResId = resId;
    }

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }


    @NonNull
    @Override
    public DrawerAdapter.DrawerAdapterHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new DrawerAdapterHolder(LayoutInflater.from(mContext).inflate(mResId, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull DrawerAdapter.DrawerAdapterHolder holder, int position) {
        holder.setIsRecyclable(false);
        holder.itemName.setText(mData.get(position).getItemName());
        Glide.with(mContext)
                .load(mData.get(position).getDrawable())
                .centerCrop()
                .placeholder(R.drawable.rotate_spinner)
                .into(holder.logo);
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    public void updateList(List<DrawerItem> items) {
        mData.clear();
        mData.addAll(items);
        notifyDataSetChanged();
    }

    class DrawerAdapterHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView itemName;
        ImageView logo;

        public DrawerAdapterHolder(@NonNull View itemView) {
            super(itemView);
            itemName = itemView.findViewById(R.id.tv_nav_item_name);
            logo = itemView.findViewById(R.id.iv_logo);
            itemView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (iAdapterItemClickListener == null) return;
            iAdapterItemClickListener.onAdapterItemClick(v, getAdapterPosition());
        }
    }
}
