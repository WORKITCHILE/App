package com.app.workit.view.adapter;

import androidx.recyclerview.widget.DiffUtil;
import com.app.workit.data.model.Category;

import java.util.List;

public class CategoryDiffCallBack extends DiffUtil.Callback {
    private List<Category> newCategories;
    private List<Category> oldCategories;

    public CategoryDiffCallBack(List<Category> newCategories, List<Category> oldCategories) {
        this.newCategories = newCategories;
        this.oldCategories = oldCategories;
    }

    @Override
    public int getOldListSize() {
        return oldCategories.size();
    }

    @Override
    public int getNewListSize() {
        return newCategories.size();
    }

    @Override
    public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
        return oldCategories.get(oldItemPosition).getCategoryId().equals(newCategories.get(newItemPosition).getCategoryId());
    }

    @Override
    public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
        return oldCategories.get(oldItemPosition).equals(newCategories.get(newItemPosition));
    }
}
