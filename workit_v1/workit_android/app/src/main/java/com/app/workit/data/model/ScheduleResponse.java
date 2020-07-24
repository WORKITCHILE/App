package com.app.workit.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ScheduleResponse {

    @SerializedName("job_data")
    @Expose
    private List<Job> jobData;
    private long time;


    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public List<Job> getJobData() {
        return jobData;
    }

    public void setJobData(List<Job> jobData) {
        this.jobData = jobData;
    }
}
