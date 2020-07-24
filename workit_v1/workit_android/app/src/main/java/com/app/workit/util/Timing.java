package com.app.workit.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class Timing {
    public enum TimeFormats {
        DD_MM_YYYY("dd/MM/yyyy"),
        DD_MM_YYYY_HH_MM_A("dd/MM/yyyy hh:mm a"),
        DD_MMM_YYYY("dd MMM yyyy"),
        MMM_YYYY("MMM yyyy"),
        CUSTOM_MMM_YYYY("MMM-yyyy"),
        DD_MMMM_YYYY("dd MMMM yyyy"),
        MM_DD_YYYY("MM/dd/yyyy"),
        YYYY_MM_DD("yyyy/MM/dd"),
        YYYY_MM_DD_HH_MM_A("yyyy/MM/dd, hh:mm a"),
        CUSTOM_YYYY_MM_DD_HH_MM_A("yyyy/MM/dd hh:mm a"),
        YYYY_MM_DD_HH_MM_S("yyyy-MM-dd hh:mm:ss"),
        MONTH_NUMBER("MM"),
        DD_MMM("dd MMM"),
        EEE_MM_DD_YYYY_HH_MM("E MMM dd yyyy dd HH:mm"),
        YYYY_MM_DD_T_00("yyyy-MM-dd'T'HH:mm:ss.sssZ"),
        E_MMM_DD_HH_SS_Z_YYYY("E MMM dd HH:mm:ss Z yyyy"),
        MONTH_FULL_NAME("MMMM"),
        MONTH_SHORT_NAME("MMM"),
        MMM_dd_hh_mm_a("MMM dd, hh:mm a"),
        YEAR("yyyy"), DATE("dd"),
        HH_24("HH:mm"),
        HH_12("hh:mm a"),
        HOUR_24("HH"),
        HOUR_12("hh"),
        MINUTE("mm"),
        AM_PM("a"),
        DAY_NAME("EEEE"),
        MONTH_DD_YEAR("MMMM dd yyyy"),
        CUSTOM_DAY("EEEE-dd-MMM"),
        CUSTOM_DATE_TIME("dd-MM-yyyy hh:mm");

        private String timeFormat;

        TimeFormats(String timeFormat) {
            this.timeFormat = timeFormat;
        }

        public String getTimeFormat() {
            return timeFormat;
        }
    }

    public static long getCurrentTimeEpoch() {
        return System.currentTimeMillis() / 1000;
    }

    public static long getCurrentTimeMillis() {
        return System.currentTimeMillis();
    }

    public static String getTimeInString(long timeStamp, TimeFormats timeFormat) {
        Date date = new Date(timeStamp * 1000L);
        SimpleDateFormat sdf = new SimpleDateFormat(timeFormat.getTimeFormat(), Locale.getDefault());
        return sdf.format(date);
    }


    public static String getTimeInStringWithoutStamp(long timeStamp, TimeFormats timeFormat) {
        Date date = new Date(timeStamp);
        SimpleDateFormat sdf = new SimpleDateFormat(timeFormat.getTimeFormat(), Locale.getDefault());
        return sdf.format(date);
    }

    public static long getTimeInUnixStamp(String time, TimeFormats timeFormat) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat(timeFormat.getTimeFormat(), Locale.getDefault());
            Date date = sdf.parse(time);
            return date.getTime() / 1000;
        } catch (ParseException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public static long getTimeInMillis(String time, TimeFormats timeFormat) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat(timeFormat.getTimeFormat(), Locale.getDefault());
            Date date = sdf.parse(time);
            return date.getTime();
        } catch (ParseException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public static long weekFirstDay() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_WEEK, calendar.getFirstDayOfWeek());
        return (calendar.getTimeInMillis() / 1000);
    }

    public static long weekLastDay() {
        Calendar calendar = Calendar.getInstance(TimeZone.getDefault());
        calendar.set(Calendar.DAY_OF_WEEK, 7);
        return (calendar.getTimeInMillis() / 1000);
    }
}