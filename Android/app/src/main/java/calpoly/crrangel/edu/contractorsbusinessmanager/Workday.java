package calpoly.crrangel.edu.contractorsbusinessmanager;

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
    public String job;
    public Double hours;
    public Boolean clockedOut;
    private DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);

    public Workday () {}

    Workday (DataSnapshot snap) {
        this.client = snap.child("client").getValue(String.class);
        this.location = snap.child("location").getValue(String.class);
        this.job = snap.child("job").getValue(String.class);

        this.hours = snap.child("hours").getValue(Double.class);
        this.clockedOut = snap.child("done").getValue(Boolean.class);

        try {
            this.date = df.parse (snap.child("date").getValue(String.class).replace("-", "/"));
        } catch (ParseException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    public Workday (String date, String client, String location, String job, double hours, boolean clockedOut) {
        this.client = client;
        this.location = location;
        this.job = job;
        this.hours = hours;
        this.clockedOut = clockedOut;

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
        result.put("job", job);
        result.put("hours", hours);
        result.put("done", clockedOut);

        return result;
    }

    @Override
    public String toString() {
        String s;
        s = "Client: " + client;
        s += "\nLocation: " + location;
        s += "\nJob: " + job;
        s += "\nDate: " + date;
        s += "\nHours: " + hours;
        s += "\ndone: " + clockedOut;

        return s;
    }
}
