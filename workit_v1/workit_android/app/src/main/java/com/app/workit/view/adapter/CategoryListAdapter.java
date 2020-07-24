package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.model.Category;
import com.app.workit.view.callback.IAdapterItemClickListener;

import java.util.ArrayList;
import java.util.List;

public class CategoryListAdapter extends RecyclerView.Adapter<CategoryListAdapter.CategoryHolder> {

    private Context mContext;
    private List<Category> categories;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public CategoryListAdapter(Context mContext) {
        this.mContext = mContext;
        this.categories = new ArrayList<>();
    }

    public void updateList(List<Category> newCategories) {
        DiffUtil.DiffResult diffResult = DiffUtil.calculateDiff(new CategoryDiffCallBack(newCategories, this.categories));
        diffResult.dispatchUpdatesTo(this);
        this.categories.clear();
        this.categories.addAll(newCategories);
    }

    @NonNull
    @Override
    public CategoryHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new CategoryHolder(LayoutInflater.from(mContext).inflate(R.layout.item_category, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull CategoryHolder holder, int position) {
        try {
            Category category = categories.get(position);
            holder.categoryName.setText(category.getCategoryName());
            Glide.with(mContext).load(category.getCategoryImage()).apply(new RequestOptions()
                    .error(R.drawable.no_image_available)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.categoryImage);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return categories.size();
    }

    public List<Category> getCategories() {
        return categories;
    }

    public class CategoryHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.category_image)
        ImageView categoryImage;
        @BindView(R.id.category_name)
        TextView categoryName;

        public CategoryHolder(@NonNull View itemView) {
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
