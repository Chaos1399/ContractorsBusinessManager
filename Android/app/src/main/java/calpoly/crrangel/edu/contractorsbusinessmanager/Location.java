package calpoly.crrangel.edu.contractorsbusinessmanager;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.IgnoreExtraProperties;

import java.util.HashMap;
import java.util.Map;

@IgnoreExtraProperties
public class Location {
    public String address;
    public String city;
    public String jobs;
    public int numJobs;

    public Location () {}

    Location (DataSnapshot snap) {
        this.address = snap.child("address").getValue(String.class);
        this.city = snap.child("city").getValue(String.class);
        this.jobs = snap.child("jobs").getValue(String.class);
        this.numJobs = snap.child("numJobs").getValue(Integer.class);
    }

    public Location (String address, String city, String jobs, int numJobs) {
        this.address = address;
        this.city = city;
        this.jobs = jobs;
        this.numJobs = numJobs;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("address", address);
        result.put("city", city);
        result.put("jobs", jobs);
        result.put("numJobs", numJobs);

        return result;
    }

    @Override
    public String toString() {
        String s;
        s = "Address: " + address;
        s += ", " + city;
        s += "\nJobs: " + jobs;
        s += "\nnumJobs: " + numJobs;

        return s;
    }
}
