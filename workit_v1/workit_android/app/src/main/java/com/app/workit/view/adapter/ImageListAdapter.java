package com.app.workit.view.adapter;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.view.callback.IAdapterItemClickListener;

import java.util.ArrayList;
import java.util.List;

public class ImageListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private int type = 0;
    private Context mContext;
    private int mResId;
    private List<String> mData;
    private IAdapterItemClickListener iAdapterItemClickListener;


    public ImageListAdapter(Context context, int resId, int type) {
        mContext = context;
        mResId = resId;
        mData = new ArrayList<>();
        this.type = type;
    }

    public void updateList(List<String> newImages) {
        mData.clear();
        mData.addAll(newImages);
        notifyDataSetChanged();
    }

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (type == 1) {
            return new ImageHolder2(LayoutInflater.from(mContext).inflate(mResId, parent, false));
        } else {
            return new ImageHolder1(LayoutInflater.from(mContext).inflate(mResId, parent, false));
        }

    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        try {
            if (type == 1) {
                ImageHolder2 imageHolder2 = (ImageHolder2) holder;
                imageHolder2.image.setImageURI(Uri.parse(mData.get(position)));

            } else {
                ImageHolder1 imageHolder1 = (ImageHolder1) holder;
                imageHolder1.image.setImageURI(Uri.parse(mData.get(position)));
                if (type == 3) {
                    Glide.with(mContext).load(mData.get(position)).apply(new RequestOptions()
                            .error(R.drawable.no_image_available)
                            .centerCrop().placeholder(R.drawable.rotate_spinner)).diskCacheStrategy(DiskCacheStrategy.RESOURCE).into(imageHolder1.image);
                }
            }


        } catch (Exception e) {
            Log.d(getClass().getSimpleName(), "Error");
        }
    }


    @Override
    public int getItemCount() {
        return mData.size();
    }

    public class ImageHolder1 extends RecyclerView.ViewHolder {
        ImageView image;

        public ImageHolder1(@NonNull View itemView) {
            super(itemView);
            image = itemView.findViewById(R.id.iv_preview_image);
        }
    }

    public class ImageHolder2 extends RecyclerView.ViewHolder implements View.OnClickListener {
        ImageView image;
        ImageButton remove;

        public ImageHolder2(@NonNull View itemView) {
            super(itemView);
//            image = itemView.findViewById(R.id.iv_preview_image);
//            remove = itemView.findViewById(R.id.btn_remove);
            remove.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (iAdapterItemClickListener == null) return;
            iAdapterItemClickListener.onAdapterItemClick(v, getAdapterPosition());
        }
    }

}
