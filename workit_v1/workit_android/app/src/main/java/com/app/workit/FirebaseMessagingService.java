package com.app.workit;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;
import com.google.firebase.messaging.RemoteMessage;
import com.app.workit.util.AppConstants;
import com.app.workit.view.ui.common.SplashActivity;

import org.json.JSONObject;

import java.util.Map;

public class FirebaseMessagingService extends com.google.firebase.messaging.FirebaseMessagingService {
    private static final String CHANNEL_ID = "1";

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        try {

            Map<String, String> data = remoteMessage.getData();
            JSONObject object = new JSONObject(data);
            JSONObject jsonObjectData1 = new JSONObject(object.getString(AppConstants.K_DATA));

            String type = jsonObjectData1.getString(AppConstants.K_TYPE);


            switch (type) {
                default:
                    createNotification(remoteMessage.getNotification().getTitle(), remoteMessage.getNotification().getBody(), type, null);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void createNotification(String title, String content, String type, JSONObject jsonObjectData) {
        PendingIntent pendingIntent;
        Intent intentBuyer = new Intent(this, SplashActivity.class);
        intentBuyer.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        pendingIntent = PendingIntent.getActivity(this, 0, intentBuyer, PendingIntent.FLAG_UPDATE_CURRENT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

        Bitmap largeIcon = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(getNotificationIcon())
                .setColor(ContextCompat.getColor(this, R.color.colorDarkPurple))
                .setColorized(true)
                .setLargeIcon(largeIcon)
                .setSound(defaultSoundUri)
                .setVibrate(new long[]{0, 100, 200, 100})
                .setContentTitle(title)
                .setContentText(content)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT);


        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            CharSequence name = getString(R.string.app_name);
            String description = getString(R.string.app_name);
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            notificationManager.createNotificationChannel(channel);
            notificationManager.notify(001, builder.build());
        } else {
            NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(this);
            notificationManagerCompat.notify(001, builder.build());
        }


    }

    private int getNotificationIcon() {
        boolean useWhiteIcon = (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP);
        return useWhiteIcon ? R.drawable.ic_stat_workit : R.mipmap.ic_launcher;
    }


    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);
    }
}
