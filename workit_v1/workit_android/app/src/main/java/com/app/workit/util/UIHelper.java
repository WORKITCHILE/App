package com.app.workit.util;

import android.app.Activity;
import android.app.ActivityOptions;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.app.workit.R;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class UIHelper {

    private static volatile UIHelper fragmentSingleton;


    public enum ActivityAnimations {
        LEFT_TO_RIGHT,
        RIGHT_TO_LEFT,
        BOTTOM_TO_TOP,
        TOP_TO_BOTTOM,
        CROSS_FADE,
        NONE
    }

    private UIHelper() {
    }

    //Using Synchronized thread safe singleton
    public static UIHelper getInstance() {
        if (fragmentSingleton == null) {
            fragmentSingleton = new UIHelper();
        }

        synchronized (fragmentSingleton) {
            return fragmentSingleton;
        }
    }

    //Action
    public void switchFragment(final AppCompatActivity activity, int id, final Fragment fragment, String fragmentTag, final Bundle dataToPass, boolean addToBackStack) {
        fragment.setArguments(dataToPass);
        switchFragment(activity, id, fragment, fragmentTag, addToBackStack);

    }

    public void switchFragment(final AppCompatActivity activity, int id, final Fragment fragment, final ActivityAnimations animations, String fragmentTag, boolean addToBackStack) {
        if (animations == ActivityAnimations.LEFT_TO_RIGHT) {
            switchFragment(activity, id, fragment, fragmentTag, addToBackStack);
        } else if (animations == ActivityAnimations.CROSS_FADE) {
            if (addToBackStack) {
                activity.getSupportFragmentManager().beginTransaction().
                        setCustomAnimations(R.anim.fade_in, R.anim.fade_out, R.anim.fade_in,
                                R.anim.fade_out).replace(id, fragment, fragmentTag).
                        addToBackStack(null).commit();
            } else {
                activity.getSupportFragmentManager().beginTransaction().
                        setCustomAnimations(R.anim.fade_in, R.anim.fade_out, R.anim.fade_in,
                                R.anim.fade_out).replace(id, fragment, fragmentTag).
                        commit();
            }
        } else if (animations == ActivityAnimations.NONE) {
            if (addToBackStack) {
                activity.getSupportFragmentManager().beginTransaction().
                        replace(id, fragment, fragmentTag).
                        addToBackStack(null).commit();
            } else {
                activity.getSupportFragmentManager().beginTransaction().
                        replace(id, fragment, fragmentTag).
                        commit();
            }
        }
    }


    public void switchFragment(final AppCompatActivity activity, int id, final Fragment fragment, String fragmentTag, boolean addToBackStack) {


        if (addToBackStack) {
            activity.getSupportFragmentManager().beginTransaction().
                    setCustomAnimations(R.anim.frg_slide_in_left, R.anim.frg_slide_out_left, R.anim.frg_slide_out_right,
                            R.anim.frg_slide_in_right).replace(id, fragment, fragmentTag).
                    addToBackStack(null).commit();
        } else {
            activity.getSupportFragmentManager().beginTransaction().
                    setCustomAnimations(R.anim.frg_slide_in_left, R.anim.frg_slide_out_left, R.anim.frg_slide_out_right,
                            R.anim.frg_slide_in_right).replace(id, fragment, fragmentTag).
                    commit();
        }

    }


    public void hideFragment(AppCompatActivity activity, Fragment currentFragment, Fragment nextFragment) {
        activity.getSupportFragmentManager().beginTransaction().
                setCustomAnimations(R.anim.frg_slide_in_left, R.anim.frg_slide_out_left,
                        R.anim.frg_slide_out_right, R.anim.frg_slide_in_right).
                hide(currentFragment).show(nextFragment).
                addToBackStack(null).commit();
    }

    public void switchActivity(final Activity From, final Class<?> ToActivityType, final ActivityAnimations animation, final Serializable DataToPass,
                               final String DataKey, final boolean ClearActivityStackHistory) {
        try {
            Intent intent = new Intent(From, ToActivityType);
            if (DataToPass != null && DataKey != null) {
                intent.putExtra(DataKey, DataToPass);

            }

            if (ClearActivityStackHistory) {
                //clear stack
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }

            From.startActivity(intent);

            if (animation == ActivityAnimations.RIGHT_TO_LEFT) {
                From.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_right);
            }

            if (animation == ActivityAnimations.LEFT_TO_RIGHT) {
                From.overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
            }
            if (animation == ActivityAnimations.BOTTOM_TO_TOP) {
                From.overridePendingTransition(R.anim.pop_in_up, R.anim.pop_out_up);
            }

            if (ClearActivityStackHistory) {
                From.finishAffinity();
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void switchActivity(final Activity From, final Class<?> ToActivityType, final ActivityAnimations animation, final String DataToPass,
                               final String DataKey, final boolean ClearActivityStackHistory) {
        try {
            Intent intent = new Intent(From, ToActivityType);
            if (DataToPass != null && DataKey != null) {
                intent.putExtra(DataKey, DataToPass);
            }

            if (ClearActivityStackHistory) {
                //clear stack
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }

            From.startActivity(intent);

            if (animation == ActivityAnimations.RIGHT_TO_LEFT) {
                From.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_right);
            }

            if (animation == ActivityAnimations.LEFT_TO_RIGHT) {
                From.overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
            }
            if (animation == ActivityAnimations.BOTTOM_TO_TOP) {
                From.overridePendingTransition(R.anim.pop_in_up, R.anim.pop_out_up);
            }

            if (ClearActivityStackHistory) {
                From.finishAffinity();
            }
        } catch (Exception ex) {
            throw ex;
        }
    }


    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void switchActivityWithTransition(final Activity From, final Class<?> ToActivityType, final String DataToPass,
                                             final String DataKey, final boolean ClearActivityStackHistory) {
        try {
            Intent intent = new Intent(From, ToActivityType);
            if (DataToPass != null && DataKey != null) {
                intent.putExtra(DataKey, DataToPass);
            }

            if (ClearActivityStackHistory) {
                //clear stack
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }

            ActivityOptions activityOptions = null;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activityOptions = ActivityOptions.makeSceneTransitionAnimation(From);
            }
            From.startActivity(intent, activityOptions.toBundle());
            if (ClearActivityStackHistory) {
                From.finishAffinity();
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    public void switchActivity(final Activity From, final Class<?> ToActivityType, final ActivityAnimations animation, final HashMap<String, String> dataHashMap, final boolean ClearActivityStackHistory) {
        try {
            From.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Intent intent = new Intent(From, ToActivityType);

                    for (Map.Entry<String, String> entry : dataHashMap.entrySet()) {
                        String DataToPass = entry.getValue();
                        String DataKey = entry.getKey();

                        if (DataToPass != null && DataKey != null) {
                            intent.putExtra(DataKey, DataToPass);
                        }
                    }

                    if (ClearActivityStackHistory) {
                        //clear stack
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    }

                    From.startActivity(intent);

                    if (animation == ActivityAnimations.RIGHT_TO_LEFT) {
                        From.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_right);
                    }

                    if (animation == ActivityAnimations.LEFT_TO_RIGHT) {
                        From.overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_left);
                    }
                    if (animation == ActivityAnimations.BOTTOM_TO_TOP) {
                        From.overridePendingTransition(R.anim.pop_in_up, R.anim.pop_out_up);
                    }

                    if (ClearActivityStackHistory) {
                        From.finishAffinity();
                    }
                }
            });
        } catch (Exception ex) {
            throw ex;
        }
    }

}

