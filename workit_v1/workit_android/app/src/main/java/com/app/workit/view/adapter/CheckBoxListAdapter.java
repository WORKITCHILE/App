package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.data.model.CommonCheckBoxItem;
import com.app.workit.view.callback.IAdapterItemCheckChangeListener;

import java.util.ArrayList;
import java.util.List;

public class CheckBoxListAdapter extends RecyclerView.Adapter<CheckBoxListAdapter.CheckBoxHolder> {

    private Context mContext;
    private List<CommonCheckBoxItem> commonCheckBoxItems;
    private IAdapterItemCheckChangeListener iCheckChangeListener;

    public void setiCheckChangeListener(IAdapterItemCheckChangeListener iCheckChangeListener) {
        this.iCheckChangeListener = iCheckChangeListener;
    }

    public CheckBoxListAdapter(Context mContext) {
        this.mContext = mContext;
        commonCheckBoxItems = new ArrayList<>();
    }

    public List<CommonCheckBoxItem> getCommonCheckBoxItems() {
        return commonCheckBoxItems;
    }

    public void updateList(List<CommonCheckBoxItem> newCommonCheckBoxItems) {
        commonCheckBoxItems.clear();
        commonCheckBoxItems.addAll(newCommonCheckBoxItems);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public CheckBoxHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new CheckBoxHolder(LayoutInflater.from(mContext).inflate(R.layout.item_checkbox, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull CheckBoxHolder holder, int position) {
        try {
            CommonCheckBoxItem commonCheckBoxItem = commonCheckBoxItems.get(position);
            holder.title.setText(commonCheckBoxItem.getTitle());
            holder.title.setChecked(commonCheckBoxItem.isChecked());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return commonCheckBoxItems.size();
    }

    public class CheckBoxHolder extends RecyclerView.ViewHolder implements CompoundButton.OnCheckedChangeListener {
        @BindView(R.id.cb_title)
        CheckBox title;

        public CheckBoxHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            title.setOnCheckedChangeListener(this);
        }

        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (iCheckChangeListener == null) return;
            if (buttonView.isPressed()) {
                iCheckChangeListener.onItemCheckChange(buttonView, getAdapterPosition(), isChecked);
            }
        }
    }
}
