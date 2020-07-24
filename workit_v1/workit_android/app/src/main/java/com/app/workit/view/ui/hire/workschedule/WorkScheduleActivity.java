package com.app.workit.view.ui.hire.workschedule;

import android.os.Bundle;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.lifecycle.ViewModelProviders;
import androidx.viewpager.widget.ViewPager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.app.workit.R;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.ScheduleResponse;
import com.app.workit.util.Timing;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.customview.NoSwipeViewPager;
import com.whiteelephant.monthpicker.MonthPickerDialog;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class WorkScheduleActivity extends BaseActivity implements MonthPickerDialog.OnDateSetListener, WorkScheduleFragment.WorkScheduleMoreInfoCallBack {
    @BindView(R.id.pager_work_schedule)
    NoSwipeViewPager workScheduleNoSwipeViewPager;
    @BindView(R.id.monthAndYear)
    TextView monthAndyear;
    @BindView(R.id.month_filter)
    LinearLayout monthFilterContainer;
    @Inject
    ViewModelFactory viewModelFactory;
    private WorkScheduleViewModel workScheduleViewModel;
    private MonthPickerDialog picker;
    private Calendar calendarInstance;
    private WorkSchedulePagerAdapter workSchedulePagerAdapter;
    private long currentTimeStamp;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_work_schedule);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.work_schedule_title);
        workScheduleViewModel = ViewModelProviders.of(this, viewModelFactory).get(WorkScheduleViewModel.class);
    }

    @Override
    protected void initView() {
        calendarInstance = Calendar.getInstance();
        currentTimeStamp = calendarInstance.getTimeInMillis();
        monthAndyear.setText(Timing.getTimeInStringWithoutStamp(calendarInstance.getTimeInMillis(), Timing.TimeFormats.CUSTOM_MMM_YYYY));
        initPicker();
        initPager();
        String currentMonthYear = Timing.getTimeInStringWithoutStamp(calendarInstance.getTimeInMillis(), Timing.TimeFormats.CUSTOM_MMM_YYYY);
        workScheduleViewModel.getCalendarJobs(calendarInstance.getTimeInMillis() / 1000);
        workScheduleViewModel.getJobsLiveData().observe(this, jobNetworkResponseList -> {
            switch (jobNetworkResponseList.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(jobNetworkResponseList.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    if (workScheduleNoSwipeViewPager.getCurrentItem() == 0) {
                        WorkScheduleFragment workScheduleFragment = (WorkScheduleFragment) workSchedulePagerAdapter.getRegisteredFragments().get(0);
                        workScheduleFragment.updateFragment(jobNetworkResponseList.response, currentTimeStamp);
                    } else {
                        WorkScheduleInfoFragment workScheduleInfoFragment = (WorkScheduleInfoFragment) workSchedulePagerAdapter.getRegisteredFragments().get(1);
                        workScheduleInfoFragment.updateFragment(jobNetworkResponseList.response);
                    }
                    break;
            }
        });
    }

    private void initPicker() {

        MonthPickerDialog.Builder builder = new MonthPickerDialog.Builder(this, this, calendarInstance.get(Calendar.YEAR), calendarInstance.get(Calendar.MONTH));
        picker = builder.setActivatedMonth(calendarInstance.get(Calendar.MONTH))
                .setActivatedYear(calendarInstance.get(Calendar.YEAR))
                .setMinYear(1990)
                .setMaxYear(2030)
                .setTitle(getString(R.string.select_month_and_year))
                // .setMaxMonth(Calendar.OCTOBER)
                // .setYearRange(1890, 1890)
                // .setMonthAndYearRange(Calendar.FEBRUARY, Calendar.OCTOBER, 1890, 1890)
                //.showMonthOnly()
                // .showYearOnly()
                .setOnMonthChangedListener(new MonthPickerDialog.OnMonthChangedListener() {
                    @Override
                    public void onMonthChanged(int selectedMonth) {

                    }
                })
                .setOnYearChangedListener(new MonthPickerDialog.OnYearChangedListener() {
                    @Override
                    public void onYearChanged(int selectedYear) {

                    }
                })
                .build();
    }


    private void initPager() {
        workSchedulePagerAdapter = new WorkSchedulePagerAdapter(getSupportFragmentManager(), this);
        workScheduleNoSwipeViewPager.setAdapter(workSchedulePagerAdapter);
        workScheduleNoSwipeViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    monthFilterContainer.setVisibility(View.VISIBLE);
                } else {
                    monthFilterContainer.setVisibility(View.GONE);
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    public void onDateSet(int selectedMonth, int selectedYear) {
        calendarInstance.set(Calendar.MONTH, selectedMonth);
        calendarInstance.set(Calendar.YEAR, selectedYear);

        currentTimeStamp = calendarInstance.getTimeInMillis();
        monthAndyear.setText(Timing.getTimeInStringWithoutStamp(calendarInstance.getTimeInMillis(), Timing.TimeFormats.CUSTOM_MMM_YYYY));
        workScheduleViewModel.getCalendarJobs(currentTimeStamp / 1000);
    }


    @Override
    public void onMoreInfo(List<Job> jobs) {
        workScheduleNoSwipeViewPager.setCurrentItem(1);
        WorkScheduleInfoFragment workScheduleInfoFragment = (WorkScheduleInfoFragment) workSchedulePagerAdapter.getRegisteredFragments().get(1);
        List<ScheduleResponse> scheduleResponses = new ArrayList<>();
        for (Job job : jobs) {
            ScheduleResponse scheduleResponse = new ScheduleResponse();
            List<Job> jobList = new ArrayList<>();
            jobList.add(job);
            scheduleResponse.setJobData(jobList);
            scheduleResponses.add(scheduleResponse);
        }
        workScheduleInfoFragment.updateFragment(scheduleResponses);
    }

    class WorkSchedulePagerAdapter extends FragmentPagerAdapter {
        private final WorkScheduleFragment.WorkScheduleMoreInfoCallBack callBack;
        private SparseArray<Fragment> registeredFragments = new SparseArray<Fragment>();

        public WorkSchedulePagerAdapter(@NonNull FragmentManager fm, WorkScheduleFragment.WorkScheduleMoreInfoCallBack callBack) {
            super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
            this.callBack = callBack;
        }

        @NonNull
        @Override
        public Fragment getItem(int position) {
            if (position == 0) {
                WorkScheduleFragment workScheduleFragment = WorkScheduleFragment.newInstance();
                workScheduleFragment.setCallBack(callBack);
                return workScheduleFragment;
            } else {
                return WorkScheduleInfoFragment.newInstance();
            }
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            Fragment fragment = (Fragment) super.instantiateItem(container, position);
            registeredFragments.put(position, fragment);
            return fragment;
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
            registeredFragments.remove(position);
            super.destroyItem(container, position, object);
        }

        public SparseArray<Fragment> getRegisteredFragments() {
            return registeredFragments;
        }

        @Override
        public int getCount() {
            return 2;
        }
    }


    @OnClick(R.id.month_filter)
    public void onFilter() {
        picker.show();
    }

    @Override
    public void onBackPressed() {
        if (workScheduleNoSwipeViewPager.getCurrentItem() == 0) {
            super.onBackPressed();
        } else {
            workScheduleNoSwipeViewPager.setCurrentItem(workScheduleNoSwipeViewPager.getCurrentItem() - 1);
        }


    }
}
