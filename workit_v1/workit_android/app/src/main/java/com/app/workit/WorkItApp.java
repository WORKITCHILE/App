package com.app.workit;


import android.app.Application;

import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.net.PlacesClient;
import com.app.workit.di.component.DaggerAppComponent;

import javax.inject.Inject;

import dagger.android.AndroidInjector;
import dagger.android.DispatchingAndroidInjector;
import dagger.android.HasAndroidInjector;

public class WorkItApp extends Application implements HasAndroidInjector {
    private static PlacesClient placesClient;
    private AndroidInjector<WorkItApp> appComponent;

    @Inject
    DispatchingAndroidInjector<Object> dispatchingAndroidInjector;


    @Override
    public void onCreate() {
        super.onCreate();
//        appComponent = DaggerAppComponent.builder().application(this).build();
        DaggerAppComponent.builder().application(this).build().inject(this);

        // Initialize the SDK
        Places.initialize(getApplicationContext(), getString(R.string.google_maps_key));
        placesClient = Places.createClient(this);


    }

    public static PlacesClient getPlacesClient() {
        return placesClient;
    }

    @Override
    public AndroidInjector<Object> androidInjector() {
        return dispatchingAndroidInjector;
    }
}
