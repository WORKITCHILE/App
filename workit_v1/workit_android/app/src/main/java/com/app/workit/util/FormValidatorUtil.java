package com.app.workit.util;

import android.text.TextUtils;
import android.util.Pair;
import android.util.Patterns;
import android.widget.EditText;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class FormValidatorUtil {
    private static String emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+";
    private static String namePattern = "[a-zA-Z][a-zA-Z ]*";

    public static Boolean isValidBothPassword(String password, String confirmPassword) {
        if (password.isEmpty() && confirmPassword.isEmpty()) {
            return false;
        }
        return password.equals(confirmPassword);
    }

    public static boolean isValidName(String name) {
        return name.matches(namePattern);
    }

    public static boolean isValidEmail(String s) {
        if (s.isEmpty()) {
            return false;
        }
        return s.matches(emailPattern);
    }

    public static boolean isValidPassword(String s) {
        Pattern PASSWORD_PATTERN
                = Pattern.compile(
                "[a-zA-Z0-9!@#$]{8,12}");

        return !TextUtils.isEmpty(s) && PASSWORD_PATTERN.matcher(s).matches();
    }


    public static boolean isValidPhone(String value) {
        return Patterns.PHONE.matcher(value).matches();
    }

    public static Pair<Boolean, EditText> isFormValid(EditText... args) {
        List<EditText> items = new ArrayList<>();
        for (EditText editText : args) {
            if (editText.getText().toString().trim().isEmpty()) {
                items.add(editText);
            }
        }
        //If items empty form is valid
        return new Pair<>(items.isEmpty(), items.isEmpty() ? null : items.get(0));
    }
}
