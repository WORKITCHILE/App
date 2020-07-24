package com.app.workit.di.module;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.NoModuleExclusionStrategy;
import com.app.workit.data.network.RetrofitConvertorFactory;
import com.app.workit.data.network.RxErrorHandlingCallAdapterFactory;
import com.app.workit.di.scope.AppScope;
import com.app.workit.util.AppConstants;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import dagger.Module;
import dagger.Provides;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

@Module
public class RetrofitModule {

    @Provides
    @AppScope
    APIService getAPIService(Retrofit retrofit) {
        return retrofit.create(APIService.class);
    }

    @Provides
    @AppScope
    Retrofit getRetroFit(OkHttpClient httpClient, Gson gson) {

        return new Retrofit.Builder()
                .baseUrl(AppConstants.BASE_URL)
                .addConverterFactory(new RetrofitConvertorFactory())
                .addConverterFactory(GsonConverterFactory.create(gson))
                .addCallAdapterFactory(RxErrorHandlingCallAdapterFactory.create())
                .client(httpClient)
                .build();
    }

    @Provides
    @AppScope
    OkHttpClient getOkHttpCleint(HttpLoggingInterceptor httpLoggingInterceptor, Interceptor interceptor) {

        return new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .addInterceptor(httpLoggingInterceptor)
                .addInterceptor(interceptor)
                .build();
    }


    @Provides
    @AppScope
    Gson getGson() {
        return new GsonBuilder()
                .addSerializationExclusionStrategy(new NoModuleExclusionStrategy(false))
                .addDeserializationExclusionStrategy(new NoModuleExclusionStrategy(true))
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
                .create();
    }

    @Provides
    @AppScope
    HttpLoggingInterceptor getHttpLoggingInterceptor() {
        HttpLoggingInterceptor httpLoggingInterceptor = new HttpLoggingInterceptor();
        httpLoggingInterceptor.level(HttpLoggingInterceptor.Level.BODY);
        return httpLoggingInterceptor;
    }

    @Provides
    @AppScope
    Interceptor getIntercaptor(DataManager dataManager) {
        return new Interceptor() {
            @Override
            public Response intercept(Chain chain) throws IOException {
                Request original = chain.request();

                Request.Builder requestBuilder = original.newBuilder()
                        .header("Accept", "application/json")
                        .header("client-id", "WorkIt-android")
                        .header("Authorization", AppConstants.K_BEARER + " " + dataManager.getFirebaseAuthToken())
                        .method(original.method(), original.body());

                Request request = requestBuilder.build();
                Log.d("Header Content", requestBuilder.toString());
                return chain.proceed(request);
            }
        };
    }


}
