package com.app.workit.view.adapter;

import android.content.Context;
import android.graphics.Typeface;
import android.text.style.CharacterStyle;
import android.text.style.StyleSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.android.libraries.places.api.model.AutocompletePrediction;
import com.google.android.libraries.places.api.model.AutocompleteSessionToken;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest;
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsResponse;
import com.google.android.libraries.places.api.net.PlacesClient;
import com.app.workit.model.PlaceAutocomplete;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class WorkItPlaceAutoCompleteAdapter extends ArrayAdapter<PlaceAutocomplete> implements Filterable {

    private final PlacesClient placesClient;
    private TypeFilter typeFilter;
    private Context mContext;
    private int mResId;
    private List<PlaceAutocomplete> mResultList;
    private List<PlaceAutocomplete> resultList;
    private ListFilter mListFilter;
    private CharacterStyle STYLE_BOLD;
    private CharacterStyle STYLE_NORMAL;
    private PlaceItemSelectListener placeItemSelectListener;

    public interface PlaceItemSelectListener {
        void onPlaceSelected(PlaceAutocomplete placeAutocomplete);
    }


    public void setPlaceItemSelectListener(PlaceItemSelectListener placeItemSelectListener) {
        this.placeItemSelectListener = placeItemSelectListener;
    }

    public WorkItPlaceAutoCompleteAdapter(Context context, int resource, PlacesClient placesClient, TypeFilter typeFilter) {
        super(context, resource);
        mContext = context;
        mResId = resource;
        this.placesClient = placesClient;
        STYLE_BOLD = new StyleSpan(Typeface.BOLD);
        STYLE_NORMAL = new StyleSpan(Typeface.NORMAL);
        this.typeFilter = typeFilter;
        mResultList = new ArrayList<>();
        resultList = new ArrayList<>();
    }

    public WorkItPlaceAutoCompleteAdapter(Context context, int resource, PlacesClient placesClient) {
        super(context, resource);
        mContext = context;
        mResId = resource;
        this.placesClient = placesClient;
        STYLE_BOLD = new StyleSpan(Typeface.BOLD);
        STYLE_NORMAL = new StyleSpan(Typeface.NORMAL);
        mResultList = new ArrayList<>();
        resultList = new ArrayList<>();
    }


    public List<PlaceAutocomplete> getmResultList() {
        return mResultList;
    }

    @Override
    public int getCount() {
        return mResultList.size();
    }

    @Nullable
    @Override
    public PlaceAutocomplete getItem(int position) {
        if (position > mResultList.size()) {
            return new PlaceAutocomplete();
        } else {
            return resultList.get(position);

        }
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getDropDownView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {

        return rowview(convertView, position);
    }

    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        return rowview(convertView, position);
    }


    private View rowview(View convertView, int position) {

        PlaceAutocomplete rowItem = getItem(position);

        ViewHolder holder;
        View rowview = convertView;
        if (rowview == null) {

            holder = new ViewHolder();
            rowview = LayoutInflater.from(mContext).inflate(mResId, null, false);

            holder.txtTitle = rowview.findViewById(android.R.id.text1);
            rowview.setTag(holder);
        } else {
            holder = (ViewHolder) rowview.getTag();
        }
        try {
            holder.txtTitle.setText(rowItem.getAddress());
        } catch (Exception e) {
            Log.d(getClass().getSimpleName(), e.getMessage());
        }


        return rowview;
    }

    private class ViewHolder {
        TextView txtTitle;
    }

    @NonNull
    @Override
    public Filter getFilter() {
        if (mListFilter == null) {
            mListFilter = new ListFilter();
        }
        return mListFilter;
    }

    private class ListFilter extends Filter {
        private Object lock = this;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            FilterResults results = new FilterResults();
            // Skip the autocomplete query if no constraints are given.


            if (constraint != null) {
                // Query the autocomplete API for the (constraint) search string.
                //mResultList = getPredictions(constraint);
                mResultList.clear();


                mResultList.addAll(getPredictions(constraint.toString().trim()));
                if (mResultList != null) {

                    // The API successfully returned results.
                    results.values = mResultList;
                    results.count = mResultList.size();
                }

            }
            return results;
        }

        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            if (results != null && results.count > 0) {
                // The API returned at least one result, update the data.
                notifyDataSetChanged();
            } else {
                // The API did not return any results, invalidate the data set.
                mResultList.clear();
                notifyDataSetChanged();
            }
        }

        @Override
        public CharSequence convertResultToString(Object resultValue) {
            PlaceAutocomplete spinnerItem = (PlaceAutocomplete) resultValue;
            return spinnerItem.getAddress();
        }
    }

    private synchronized List<PlaceAutocomplete> getPredictions(CharSequence constraint) {
        resultList.clear();
        // Create a new token for the autocomplete session. Pass this to FindAutocompletePredictionsRequest,
        // and once again when the user makes a selection (for example when calling fetchPlace()).
        AutocompleteSessionToken token = AutocompleteSessionToken.newInstance();

        //https://gist.github.com/graydon/11198540
        // Use the builder to create a FindAutocompletePredictionsRequest.

        FindAutocompletePredictionsRequest request = FindAutocompletePredictionsRequest.builder()
                // Call either setLocationBias() OR setLocationRestriction().
                //.setLocationBias(bounds)
                .setTypeFilter(typeFilter)
                .setSessionToken(token)
                .setQuery(constraint.toString())
                .build();

        Task<FindAutocompletePredictionsResponse> autocompletePredictions = placesClient.findAutocompletePredictions(request);

        // This method should have been called off the main UI thread. Block and wait for at most
        // 60s for a result from the API.
        try {
            Tasks.await(autocompletePredictions, 60, TimeUnit.SECONDS);
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            e.printStackTrace();
        }

        if (autocompletePredictions.isSuccessful()) {
            FindAutocompletePredictionsResponse findAutocompletePredictionsResponse = autocompletePredictions.getResult();
            if (findAutocompletePredictionsResponse != null)
                for (AutocompletePrediction prediction : findAutocompletePredictionsResponse.getAutocompletePredictions()) {
                    resultList.add(new PlaceAutocomplete(prediction.getPlaceId(), prediction.getPrimaryText(STYLE_NORMAL).toString(), prediction.getFullText(STYLE_BOLD).toString()));
                }


            return resultList;
        } else {

            return resultList;
        }

    }
}

