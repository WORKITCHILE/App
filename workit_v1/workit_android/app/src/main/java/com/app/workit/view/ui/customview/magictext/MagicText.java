package com.app.workit.view.ui.customview.magictext;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.SpannableString;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.util.AttributeSet;
import android.util.TypedValue;

import androidx.appcompat.widget.AppCompatTextView;

import com.app.workit.R;

public class MagicText extends AppCompatTextView {


    SpannableString spannableString;
    int pixel;
    int first = 0, last = 0;

    public String mText;

    /*For single Sub String*/
    public int mColor;
    public int mSize;
    public String mStyle = "null";
    public String mSubString = "null";

    /*For Multiple Sub String*/
    public String mMultipleColor = "null";
    public String mMultipleSize = "null";
    public String mMultipleStyle = "null";
    public String mMultipleSubString = "null";

    public String[] multi_color;
    public String[] multi_size;
    public String[] multi_style;
    public String[] multi_substring;


    public MagicText(Context context) {
        super(context);
    }

    public MagicText(Context context, AttributeSet attrs) {
        super(context, attrs);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.MagicText);
        final int N = a.getIndexCount();
        for (int i = 0; i < N; ++i) {
            int attr = a.getIndex(i);
            if (attr == R.styleable.MagicText_magic_text) {
                mText = a.getString(attr);
            } else if (attr == R.styleable.MagicText_magic_color) {
                mColor = a.getColor(attr, 0);
            } else if (attr == R.styleable.MagicText_magic_size) {
                mSize = a.getInt(attr, 0);
            } else if (R.styleable.MagicText_magic_style == attr) {
                mStyle = a.getString(attr);
            } else if (R.styleable.MagicText_magic_substring == attr) {
                mSubString = a.getString(attr);
            } else if (R.styleable.MagicText_magic_multiple_color == attr) {
                mMultipleColor = a.getString(attr);
            } else if (R.styleable.MagicText_magic_multiple_size == attr) {
                mMultipleSize = a.getString(attr);
            } else if (R.styleable.MagicText_magic_multiple_style == attr) {
                mMultipleStyle = a.getString(attr);
            } else if (R.styleable.MagicText_magic_multiple_substring == attr) {
                mMultipleSubString = a.getString(attr);
            }
        }

        generatetokens(mMultipleColor, mMultipleSize, mMultipleStyle, mMultipleSubString);
        if (multi_substring == null) {
            if (mText != null) {
                change(mText, mColor, mSize, mStyle, mSubString);
            }

        } else {
            change(mText, multi_color, multi_size, multi_style, multi_substring, mColor, mSize, mStyle);
            a.recycle();
        }

    }

    private void generatetokens(String mMultipleColor, String mMultipleSize, String mMultipleStyle, String mMultipleSubString) {
        if (!mMultipleSubString.equals("null")) {
            multi_substring = mMultipleSubString.split("\\|");
            multi_color = mMultipleColor.split("\\|");
            multi_style = mMultipleStyle.split("\\|");
            multi_size = mMultipleSize.split("\\|");
        }
    }

    public MagicText(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void change(String string, String[] color, String[] size, String[] bold_or_italic, String[] sub_string,
                       int color_single, int size_single, String style_single) {

        spannableString = new SpannableString(string);
        for (int i = 0; i < sub_string.length; i++) {
            try {


                first = string.toLowerCase().indexOf(sub_string[i].toLowerCase().trim());
                last = first + sub_string[i].length();

                if (!mMultipleColor.equals("null")) {
                    try {
                        spannableString.setSpan(new ForegroundColorSpan(Color.parseColor(color[i].trim())),
                                first, last, 0);
                    } catch (ArrayIndexOutOfBoundsException e) {

                    }
                } else if (color_single != 0) {
                    spannableString.setSpan(new ForegroundColorSpan(color_single),
                            first, last, 0);
                }

                if (!mMultipleSize.equals("null")) {
                    try {
                        pixel = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, Integer.parseInt(size[i].trim()), getContext().getResources().getDisplayMetrics());
                        spannableString.setSpan(new AbsoluteSizeSpan(pixel), first, last, 0);
                    } catch (ArrayIndexOutOfBoundsException e) {

                    }
                } else if (size_single != 0) {
                    pixel = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, Integer.parseInt(String.valueOf(size_single)), getContext().getResources().getDisplayMetrics());
                    spannableString.setSpan(new AbsoluteSizeSpan(pixel), first, last, 0);
                }

                if (!mMultipleStyle.equals("null")) {
                    try {
                        if (bold_or_italic[i].trim().equals("Bold")) {
                            spannableString.setSpan(new StyleSpan(Typeface.BOLD), first, last, 0);
                        } else if (bold_or_italic[i].trim().equals("Italic")) {
                            spannableString.setSpan(new StyleSpan(Typeface.ITALIC), first, last, 0);
                        }
                    } catch (ArrayIndexOutOfBoundsException e) {

                    }
                } else if (!style_single.equals("null")) {
                    if (style_single.trim().equals("Bold")) {
                        spannableString.setSpan(new StyleSpan(Typeface.BOLD), first, last, 0);
                    } else if (style_single.trim().equals("Italic")) {
                        spannableString.setSpan(new StyleSpan(Typeface.ITALIC), first, last, 0);
                    } else if (style_single.trim().equalsIgnoreCase("normal")) {
                        spannableString.setSpan(new StyleSpan(Typeface.NORMAL), first, last, 0);
                    }
                }
            } catch (Exception e) {

            }

        }
        super.setText(spannableString, BufferType.SPANNABLE);
    }


    public void change(String string, int color, int size, String bold_or_italic, String substring) {
        spannableString = new SpannableString(string);
        try {
            if (!substring.equals("null")) {
                int first, last;
                first = string.toLowerCase().indexOf(substring.toLowerCase());
                last = first + substring.length();

                if (color != 0) {
                    spannableString.setSpan(new ForegroundColorSpan(color), first, last, 0);
                }

                if (size != 0) {
                    pixel = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, size, getContext().getResources().getDisplayMetrics());
                    spannableString.setSpan(new AbsoluteSizeSpan(pixel), first, last, 0);
                }
                if (!bold_or_italic.equals("null")) {
                    if (bold_or_italic.equalsIgnoreCase("Bold")) {
                        spannableString.setSpan(new StyleSpan(Typeface.BOLD), first, last, 0);
                    } else if (bold_or_italic.equalsIgnoreCase("Italic")) {
                        spannableString.setSpan(new StyleSpan(Typeface.ITALIC), first, last, 0);
                    } else if (bold_or_italic.equalsIgnoreCase("normal")) {
                        spannableString.setSpan(new StyleSpan(Typeface.NORMAL), first, last, 0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        super.setText(spannableString, BufferType.SPANNABLE);
    }

    public void change(String string, String color, int size, String bold_or_italic, String substring) {
        spannableString = new SpannableString(string);
        if (!substring.equals("null")) {
            int first, last;
            first = string.toLowerCase().indexOf(substring.toLowerCase());
            last = first + substring.length();

            spannableString.setSpan(new ForegroundColorSpan(Color.parseColor(color)), first, last, 0);

            if (size != 0) {
                pixel = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, size, getContext().getResources().getDisplayMetrics());
                spannableString.setSpan(new AbsoluteSizeSpan(pixel), first, last, 0);
            }
            if (!bold_or_italic.equals("null")) {
                if (bold_or_italic.equals("Bold")) {
                    spannableString.setSpan(new StyleSpan(Typeface.BOLD), first, last, 0);
                } else if (bold_or_italic.equals("Italic")) {
                    spannableString.setSpan(new StyleSpan(Typeface.ITALIC), first, last, 0);
                }
            }
        }
        super.setText(spannableString, BufferType.SPANNABLE);
    }

}

