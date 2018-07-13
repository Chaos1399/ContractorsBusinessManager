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
public class ScheduledWorkday {
    public String client;
    public String location;
    public String job;
    public Date startDate;
    public Date endDate;
    public DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);

    public ScheduledWorkday () {}

    ScheduledWorkday (DataSnapshot snap) {
        this.client = snap.child("client").getValue(String.class);
        this.location = snap.child("location").getValue(String.class);
        this.job = snap.child("job").getValue(String.class);

        try {
			this.startDate = df.parse (snap.child("start").getValue(String.class).replace("-", "/"));
			this.endDate = df.parse (snap.child("end").getValue(String.class).replace("-", "/"));
		} catch (ParseException e) {
        	e.printStackTrace();
        	System.exit(1);
		}
    }

    ScheduledWorkday (String client, String location, String job, Date startDate, Date endDate) {
        this.client = client;
        this.location = location;
        this.job = job;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
		String sd = df.format(startDate).replace("/", "-");
		String ed = df.format(endDate).replace("/", "-");

        result.put("client", client);
        result.put("location", location);
        result.put("job", job);
        result.put("start", sd);
        result.put("end", ed);

        return result;
    }

    @Override
    public String toString() {
        String s;
        s = "Client: " + client;
        s += "\nLocation: " + location;
        s += "\nJob: " + job;
        s += "\nStart: " + startDate;
        s += "\nend: " + endDate;

        return s;
    }
}
