package com.app.workit.view.ui.work.search;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AutoCompleteTextView;
import android.widget.SeekBar;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatSeekBar;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import com.google.android.gms.common.api.ApiException;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.google.android.libraries.places.api.net.FetchPlaceRequest;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.app.workit.R;
import com.app.workit.WorkItApp;
import com.app.workit.model.JobApproach;
import com.app.workit.model.LocationModel;
import com.app.workit.model.PlaceAutocomplete;
import com.app.workit.util.CommonUtils;
import com.app.workit.util.Helper;
import com.app.workit.util.KeyboardUtil;
import com.app.workit.view.adapter.WorkItPlaceAutoCompleteAdapter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class JobFilterDialog extends BottomSheetDialogFragment implements WorkItPlaceAutoCompleteAdapter.PlaceItemSelectListener {

    private Unbinder unbinder;
    @BindView(R.id.category_group)
    ChipGroup categoryGroup;
    @BindView(R.id.distance_seek_bar)
    AppCompatSeekBar distanceSeekBar;
    @BindView(R.id.price_seek_bar)
    AppCompatSeekBar priceSeekBar;
    @BindView(R.id.distance_progress)
    TextView distance;
    @BindView(R.id.price_progress)
    TextView price;
    @BindView(R.id.search_address)
    AutoCompleteTextView address;

    private JobFilterCallBack jobFilterCallBack;
    private ArrayList<JobApproach> jobApproach;
    private int actualPriceValue;
    private int actualDistanceValue;
    private AlertDialog loadingDialog;
    private LocationModel currentLocationModel = new LocationModel();


    public void setJobFilterCallBack(JobFilterCallBack jobFilterCallBack) {
        this.jobFilterCallBack = jobFilterCallBack;
    }

    public static JobFilterDialog newInstance() {

        Bundle args = new Bundle();

        JobFilterDialog fragment = new JobFilterDialog();
        fragment.setCancelable(false);
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.filter_layout, container, false);
        KeyboardUtil.hideKeyboard(getActivity());
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (isAdded()) {
            jobApproach = Helper.getJobApproach(getContext());
            for (JobApproach approach : jobApproach) {
                Chip chip = (Chip) LayoutInflater.from(getContext()).inflate(R.layout.single_chip_layout, categoryGroup, false);
                chip.setText(approach.getName());
                chip.setId(approach.getId());
                categoryGroup.addView(chip);
            }
        }

        initAddress();
        initSeekBars();
    }

    private void initSeekBars() {
        distanceSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    distance.setText(getString(R.string.progress, progress));
                    actualDistanceValue = progress;
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        priceSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    price.setText(getString(R.string.progress, progress));
                    actualPriceValue = progress;
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
    }

    private void initAddress() {
        WorkItPlaceAutoCompleteAdapter workItPlaceAutoCompleteAdapter = new WorkItPlaceAutoCompleteAdapter(getContext(), R.layout.item_default_spinner
                , WorkItApp.getPlacesClient(), TypeFilter.ADDRESS);
        //address.setShowClearButton(true);
        address.setAdapter(workItPlaceAutoCompleteAdapter);

        address.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PlaceAutocomplete placeAutocomplete = (PlaceAutocomplete) parent.getItemAtPosition(position);
                getPlaceMoreDetail(placeAutocomplete.getPlaceId());
            }
        });

    }


    @OnClick(R.id.btn_close)
    public void onClose() {
        dismiss();
    }

    @OnClick(R.id.btn_continue)
    public void onContinue() {
        dismiss();
        String approach = "";
        for (JobApproach job : jobApproach) {
            if (job.getId() == categoryGroup.getCheckedChipId()) {
                approach = job.getName();
                break;
            }
        }
        currentLocationModel.setAddress(address.getText().toString().trim());
        jobFilterCallBack.onJobFilterApplied(approach, actualDistanceValue, actualPriceValue, currentLocationModel);
    }

    @Override
    public void onPlaceSelected(PlaceAutocomplete placeAutocomplete) {
        address.setText(placeAutocomplete.getAddress());
        getPlaceMoreDetail(placeAutocomplete.getPlaceId());
    }

    public void getPlaceMoreDetail(String placeId) {
        // Define a Place ID.
        showLoading();
// Specify the fields to return.
        List<Place.Field> placeFields = Arrays.asList(com.google.android.libraries.places.api.model.Place.Field.ID, com.google.android.libraries.places.api.model.Place.Field.NAME,
                Place.Field.LAT_LNG);

        // Construct a request object, passing the place ID and fields array.
        FetchPlaceRequest request = FetchPlaceRequest.newInstance(placeId, placeFields);

        WorkItApp.getPlacesClient().fetchPlace(request).addOnSuccessListener((response) -> {
            hideLoading();
            try {
                com.google.android.libraries.places.api.model.Place place = response.getPlace();
                currentLocationModel.setLatitude(place.getLatLng().latitude);
                currentLocationModel.setLongitude(place.getLatLng().longitude);
                KeyboardUtil.hideKeyboard(getActivity());
            } catch (Exception e) {
                e.printStackTrace();
            }


        }).addOnFailureListener((exception) -> {
            hideLoading();
            if (exception instanceof ApiException) {
                ApiException apiException = (ApiException) exception;
                int statusCode = apiException.getStatusCode();
                // Handle error with given status code.
            }
        });

    }

    private void hideLoading() {
        if (loadingDialog.isShowing()) {
            loadingDialog.dismiss();
        }

    }

    private void showLoading() {
        if (loadingDialog != null && loadingDialog.isShowing()) {
            loadingDialog.dismiss();
        }
        loadingDialog = CommonUtils.showDialogProgressBar(getContext());
        loadingDialog.show();
    }


    public interface JobFilterCallBack {
        void onJobFilterApplied(String jobApproach, double distance, double price, LocationModel locationModel);
    }
}

