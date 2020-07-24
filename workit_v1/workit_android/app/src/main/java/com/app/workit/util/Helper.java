package com.app.workit.util;

import android.content.Context;
import android.content.pm.PackageManager;

import androidx.core.content.ContextCompat;

import com.google.gson.Gson;
import com.app.workit.R;
import com.app.workit.model.Bank;
import com.app.workit.model.BankAccountType;
import com.app.workit.model.DrawerItem;
import com.app.workit.model.JobApproach;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.*;

public class Helper {
    public static final ArrayList<String> languages = new ArrayList<>();
    public static Map<String, String> countriesISOMap = new HashMap<String, String>();
    private static Helper helper;
    private Context context;

    private Helper(Context context) {
        this.context = context;

    }


    public static ArrayList<String> getAllMaterial(Context context) {
        ArrayList<String> category = new ArrayList<>();
        category.add("Metal");
        return category;
    }


    public static ArrayList<String> getCountry(Context context) {
        ArrayList<String> status = new ArrayList<>();
        status.add("Select Manufacturer's Country");
        status.add("England");
        return status;
    }


    public static ArrayList<Bank> getBanks(Context context) {
        ArrayList<Bank> banks = new ArrayList<>();
        banks.add(new Bank(context.getString(R.string.select_your_bank), 0));
        banks.add(new Bank("Banco de Chile / Banco Edwards / Citi", 1));
        banks.add(new Bank("Banco Internacional", 2));
        banks.add(new Bank("Scotiabank Chile", 3));
        banks.add(new Bank("Banco de Crédito e Inversiones", 4));
        banks.add(new Bank("Corpbanca", 5));
        banks.add(new Bank("Banco Bice", 6));
        banks.add(new Bank("HSBC Bank", 7));
        banks.add(new Bank("Banco Santander", 8));
        banks.add(new Bank("Banco Itaú Chile", 9));
        banks.add(new Bank("Banco Security", 10));
        banks.add(new Bank("Banco Falabella", 11));
        banks.add(new Bank("Deutsche Bank", 12));
        banks.add(new Bank("Banco RIpley", 13));
        banks.add(new Bank("Rabobank Chile", 14));
        banks.add(new Bank("Banco Consorcio", 15));
        banks.add(new Bank("Banco Penta", 16));
        banks.add(new Bank("Banco Paris", 17));
        banks.add(new Bank("BBVA", 18));
        return banks;
    }

    public static List<String> getCountries() {
        ArrayList<String> countries = new ArrayList<>();
        String[] isoCountryCodes = Locale.getISOCountries();
        for (String countryCode : isoCountryCodes) {
            Locale locale = new Locale("", countryCode);
            String countryName = locale.getDisplayCountry();
            countries.add(countryName);
        }
        return countries;
    }

    public static ArrayList<BankAccountType> getAccountTypes(Context context) {
        ArrayList<BankAccountType> bankAccountTypes = new ArrayList<>();
        bankAccountTypes.add(new BankAccountType(context.getString(R.string.account_type), 0));
        bankAccountTypes.add(new BankAccountType("Current", 1));
        bankAccountTypes.add(new BankAccountType("Saving", 2));
        return bankAccountTypes;
    }

    public static ArrayList<JobApproach> getJobApproach(Context context) {
        ArrayList<JobApproach> jobApproaches = new ArrayList<>();
        jobApproaches.add(new JobApproach(context.getString(R.string.all), 1));
        jobApproaches.add(new JobApproach(context.getString(R.string.in_person), 2));
        jobApproaches.add(new JobApproach(context.getString(R.string.come_and_get_id), 3));
        jobApproaches.add(new JobApproach(context.getString(R.string.take_it_to_workplace), 4));
        return jobApproaches;
    }


    public static ArrayList<DrawerItem> getDrawerOptionsHire(Context context) {
        ArrayList<DrawerItem> baseItemSelects = new ArrayList<>();
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.NOTIFICATIONS, context.getString(R.string.notifications), R.drawable.ic_notification));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.WORK_SCHEDULE, context.getString(R.string.work_schedule_title), R.drawable.ic_calendar));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.RUNNING_JOBS, context.getString(R.string.running_job), R.drawable.ic_running_job));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.HISTORY, context.getString(R.string.history), R.drawable.ic_history));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.INBOX, context.getString(R.string.inbox), R.drawable.ic_inbox));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.SHARE_APP, context.getString(R.string.share_app), R.drawable.ic_share));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.SUPPORT, context.getString(R.string.support), R.drawable.ic_support));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.CREDITS, context.getString(R.string.account_settings), R.drawable.ic_credits));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.TERMS_OF_SERVICE, context.getString(R.string.terms_of_service), R.drawable.ic_tos));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.LOGOUT, context.getString(R.string.logout), R.drawable.ic_logout));

        return baseItemSelects;
    }

    public static ArrayList<DrawerItem> getDrawerOptionsWork(Context context) {
        ArrayList<DrawerItem> baseItemSelects = new ArrayList<>();
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.NOTIFICATIONS, context.getString(R.string.notifications), R.drawable.ic_notification));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.EVALUATIONS, context.getString(R.string.evaluations), R.drawable.ic_evaluation));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.MY_BIDS, context.getString(R.string.my_bids), R.drawable.ic_bids));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.RUNNING_JOBS, context.getString(R.string.running_job), R.drawable.ic_running_job));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.HISTORY, context.getString(R.string.history), R.drawable.ic_history));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.INBOX, context.getString(R.string.inbox), R.drawable.ic_inbox));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.SHARE_APP, context.getString(R.string.share_app), R.drawable.ic_share));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.SUPPORT, context.getString(R.string.support), R.drawable.ic_support));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.ACCOUNT_SETTINGS, context.getString(R.string.account_settings), R.drawable.ic_account_settings));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.TERMS_OF_SERVICE, context.getString(R.string.terms_of_service), R.drawable.ic_tos));
        baseItemSelects.add(new DrawerItem(AppConstants.DrawerOptions.LOGOUT, context.getString(R.string.logout), R.drawable.ic_logout));
        return baseItemSelects;
    }


    public static int getMonth() {
        Date currentDate = new Date(System.currentTimeMillis());
        Calendar c = Calendar.getInstance();
        c.setTime(currentDate);
        return c.get(Calendar.MONTH);
    }

    public static int getDay() {
        Date currentDate = new Date(System.currentTimeMillis());
        Calendar c = Calendar.getInstance();
        c.setTime(currentDate);
        return c.get(Calendar.DAY_OF_MONTH);
    }

    public static int getYear() {
        Date currentDate = new Date(System.currentTimeMillis());
        Calendar c = Calendar.getInstance();
        c.setTime(currentDate);
        return c.get(Calendar.YEAR);
    }

    public static Helper getInstance(Context context) {
        if (helper == null) {
            helper = new Helper(context);
        }
        synchronized (helper) {
            return helper;
        }
    }

    public static boolean checkPermissions(Context context, String[] permissions) {
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    public static void requestPermissions(Context context, String[] permissions) {
        //       ActivityCompat.requestPermissions((Activity) context, permissions, AppConstant.REQUESTS.USER_PERMISSION);
    }

    public <T> void writeToJson(String fileName, T data) {
        Gson gson = new Gson();
        String s = gson.toJson(data);

        FileOutputStream outputStream;
        try {
            outputStream = context.openFileOutput(fileName, Context.MODE_PRIVATE);
            outputStream.write(s.getBytes());
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public <T> T readFromJson(String fileName, Class<T> type) {
        FileInputStream fis;
        try {
            fis = context.openFileInput(fileName);
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader bufferedReader = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                sb.append(line);
            }

            String json = sb.toString();
            Gson gson = new Gson();
            return gson.fromJson(json, type);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

}
