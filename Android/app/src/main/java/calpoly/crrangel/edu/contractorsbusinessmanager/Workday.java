package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.os.Bundle;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.IgnoreExtraProperties;

import java.text.DateFormat;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@IgnoreExtraProperties
public class Workday {
    public Date date;
    public String client;
    public String location;
    public String city;
    public String job;
    public Double hours;
    private DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);

    public Workday () {}

    Workday (DataSnapshot snap) {
        this.client = snap.child("client").getValue(String.class);
        this.location = snap.child("location").getValue(String.class);
        this.city = snap.child("city").getValue(String.class);
        this.job = snap.child("job").getValue(String.class);
        this.hours = snap.child("hours").getValue(Double.class);

        try {
            this.date = df.parse (snap.child("date").getValue(String.class).replace("-", "/"));
        } catch (ParseException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    Workday (Bundle b) {
        this.client = b.getString("client");
        this.location = b.getString("location");
        this.city = b.getString("city");
        this.job = b.getString("job");
        this.hours = b.getDouble("hours");

        try {
            this.date = df.parse(b.getString("date").replace("-", "/"));
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }

    Workday (String date, String client, String location, String city, String job, double hours) {
        this.client = client;
        this.location = location;
        this.city = city;
        this.job = job;
        this.hours = hours;

        try {
            this.date = df.parse(date.replace("-", "/"));
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("date", df.format(date).replace("/", "-"));
        result.put("client", client);
        result.put("location", location);
        result.put("city", city);
        result.put("job", job);
        result.put("hours", hours);

        return result;
    }

    @Override
    public String toString() {
        String s;
        s = "Client: " + client;
        s += "\nLocation: " + location;
        s += ", " + city;
        s += "\nJob: " + job;
        s += "\nDate: " + date;
        s += "\nHours: " + hours;

        return s;
    }

    public Bundle toBundle (Workday w) {
        Bundle b = new Bundle();

        b.putString("date", df.format(w.date));
        b.putString("client", w.client);
        b.putString("location", w.location);
        b.putString("city", w.city);
        b.putString("job", w.job);
        b.putDouble("hours", w.hours);

        return b;
    }
}
