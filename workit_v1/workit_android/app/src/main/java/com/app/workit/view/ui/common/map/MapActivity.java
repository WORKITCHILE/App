package com.app.workit.view.ui.common.map;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.tasks.Task;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.model.LocationModel;
import com.app.workit.util.AppConstants;
import com.app.workit.util.LocationUtil;
import com.app.workit.util.RxBus;
import com.app.workit.view.ui.base.BaseActivity;

import java.util.List;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.OnClick;

public class MapActivity extends BaseActivity implements OnMapReadyCallback, LocationListener {
    private GoogleMap mMap;
    private UserInfo userInfoModel;
    private LocationModel currentBestLocation;
    @Inject
    DataManager dataManager;
    private String action = "";

    public static Intent createIntent(Context context, double lat, double lng, String action) {
        Intent intent = new Intent(context, MapActivity.class);
        intent.putExtra(AppConstants.K_LATITUDE, lat);
        intent.putExtra(AppConstants.K_LONGITUDE, lng);
        intent.setAction(action);
        return intent;
    }

    public static Intent createIntent(Context context, double lat, double lng) {
        Intent intent = new Intent(context, MapActivity.class);
        intent.putExtra(AppConstants.K_LATITUDE, lat);
        intent.putExtra(AppConstants.K_LONGITUDE, lng);
        return intent;
    }

    public static Intent createIntent(Context context) {
        Intent intent = new Intent(context, MapActivity.class);
        return intent;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.locate_on_map_layout);
        setToolbarTitle(R.string.locate_on_map);
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
        ButterKnife.bind(this);

        currentBestLocation = new LocationModel();

        if (getIntent() != null) {
            if (getIntent().getAction() != null) {
                action = getIntent().getAction();
            }
            try {
                double lat = getIntent().getDoubleExtra(AppConstants.K_LATITUDE, 0.0);
                double lng = getIntent().getDoubleExtra(AppConstants.K_LONGITUDE, 0.0);

                currentBestLocation.setLatitude(lat);
                currentBestLocation.setLongitude(lng);

            } catch (Exception e) {
                Log.d(getClass().getSimpleName(), "error");
            }

        } else {
            currentBestLocation = new LocationModel();
        }

        userInfoModel = dataManager.getUserModel();
        fetchCurrentLocation();

    }

    @Override
    protected void initView() {

    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        if (checkMapPermission()) {
            mMap.setMyLocationEnabled(true);
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}
                    , AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
        }
        mMap.setOnCameraMoveListener(() -> {
            currentBestLocation.setLatitude(mMap.getCameraPosition().target.latitude);
            currentBestLocation.setLongitude(mMap.getCameraPosition().target.longitude);
        });
        if (action.equalsIgnoreCase(AppConstants.ACTIONS.VIEW_MAP)) {
            mMap.setMyLocationEnabled(false);
            mMap.getUiSettings().setScrollGesturesEnabled(false);
        }

        try {
            if (currentBestLocation.getLatitude() != 0.0) {

                zoomToCurrentLocation(currentBestLocation);
            } else {
                LocationModel location = fetchCurrentLocation();

                if (location != null) {
                    currentBestLocation.setLatitude(location.getLatitude());
                    currentBestLocation.setLongitude(location.getLongitude());
                    zoomToCurrentLocation(location);
                }
            }

        } catch (Exception e) {

        }
    }

    private boolean checkMapPermission() {
        return ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }

    private void zoomToCurrentLocation(LocationModel location) {
        //Zoom to that location
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(location.getLatitude(), location.getLongitude()), 16));
    }


    @OnClick(R.id.btn_done)
    public void onDone() {
        if (currentBestLocation != null) {
            RxBus.getInstance().setEvent(currentBestLocation);
            setResult(RESULT_OK);
        } else {
            setResult(RESULT_CANCELED);
        }
        finish();
    }

    public LocationModel fetchCurrentLocation() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}
                    , AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
            return null;
        } else {
            LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
            LocationSettingsRequest.Builder builder = LocationUtil.showLocationRequestPopUp(this);
            if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                //Ask user to enable GPS
                Task<LocationSettingsResponse> result = LocationServices.getSettingsClient(this).checkLocationSettings(builder.build());
                result.addOnCompleteListener(task -> {
                    try {
                        LocationSettingsResponse response = task.getResult(ApiException.class);
                        // All location settings are satisfied. The client can initialize location
                        // requests here.
                    } catch (ApiException e) {
                        switch (e.getStatusCode()) {
                            case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                                // Location settings are not satisfied. But could be fixed by showing the
                                // user a dialog.
                                try {
                                    // Cast to a resolvable exception.
                                    ResolvableApiException resolvable = (ResolvableApiException) e;
                                    // Show the dialog by calling startResolutionForResult(),
                                    // and check the result in onActivityResult().
                                    resolvable.startResolutionForResult(
                                            MapActivity.this,
                                            AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION);
                                } catch (IntentSender.SendIntentException e1) {
                                    // Ignore the error.
                                } catch (ClassCastException e2) {
                                    // Ignore, should be an impossible error.
                                }
                                break;
                            case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                                // Location settings are not satisfied. However, we have no way to fix the
                                // settings so we won't show the dialog.

                                break;
                        }

                    }
                });

                return null;

            } else {
                locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, AppConstants.LOCATION_UPDATE_TIME_INTERVAL, AppConstants.LOCATION_UPDATE_MIN_DISTANCE, this);
                locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, AppConstants.LOCATION_UPDATE_TIME_INTERVAL, AppConstants.LOCATION_UPDATE_MIN_DISTANCE, this);

                Criteria criteria = new Criteria();
                int currentapiVersion = android.os.Build.VERSION.SDK_INT;

                if (currentapiVersion >= android.os.Build.VERSION_CODES.HONEYCOMB) {

                    criteria.setPowerRequirement(Criteria.POWER_MEDIUM);
                    criteria.setSpeedAccuracy(Criteria.ACCURACY_HIGH);
                    criteria.setAccuracy(Criteria.ACCURACY_FINE);
                    criteria.setAltitudeRequired(true);
                    criteria.setBearingRequired(true);
                    criteria.setSpeedRequired(true);

                }
                String provider = locationManager.getBestProvider(criteria, true);
                List<String> providers = locationManager.getProviders(true);
                Location bestLocation = null;
                for (String currentProvider : providers) {
                    Location l = locationManager.getLastKnownLocation(currentProvider);
                    if (l == null) {
                        continue;
                    }
                    if (bestLocation == null || l.getAccuracy() < bestLocation.getAccuracy()) {
                        // Found best last known location: %s", l);
                        bestLocation = l;
                    }
                }
                //Sets Places api to return only for radius
                //    Location currentBestLocation = locationManager.getLastKnownLocation(provider);
                if (bestLocation != null) {
                    return new LocationModel(bestLocation.getLatitude(), bestLocation.getLongitude());
                } else {
                    return null;
                }

            }

        }
    }


    @Override
    protected void onStop() {
        super.onStop();
        // stop location updates
        try {
            LocationManager locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
            locationManager.removeUpdates(this);
        } catch (Exception e) {

        }

    }

    @Override
    public void onLocationChanged(Location location) {

    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION) {
            if (resultCode == Activity.RESULT_OK) {
                mMap.setMyLocationEnabled(true);
                LocationModel loc = fetchCurrentLocation();

                if (loc != null) {
                    currentBestLocation.setLatitude(loc.getLatitude());
                    currentBestLocation.setLongitude(loc.getLongitude());
                    zoomToCurrentLocation(loc);
                }

            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case AppConstants.REQUEST_CODES.REQUEST_ACCESS_LOCATION:
// If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.
                    mMap.setMyLocationEnabled(true);
                    LocationModel loc = fetchCurrentLocation();
                    if (currentBestLocation.getLatitude() != 0.0) {
                        zoomToCurrentLocation(currentBestLocation);
                    } else {
                        if (loc != null) {
                            currentBestLocation.setLatitude(loc.getLatitude());
                            currentBestLocation.setLongitude(loc.getLongitude());
                            zoomToCurrentLocation(loc);
                        }
                    }

                } else {
                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;

        }
    }
}
