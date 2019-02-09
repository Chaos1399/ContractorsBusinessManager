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
public class PayPeriod {
    String startDate;
    String endDate;
    int period;
    int numDays;
    double totalHours;
    String days;

    PayPeriod (DataSnapshot snap) {
        this.days = snap.child("days").getValue(String.class);
        this.period = Integer.valueOf(snap.getKey());
        this.startDate = snap.child("start").getValue(String.class);
        this.endDate = snap.child("end").getValue(String.class);
        this.totalHours = snap.child("totalHours").getValue(Double.class);
        this.numDays = snap.child("numDays").getValue(Integer.class);
    }

    PayPeriod (String startDate, String endDate, int period, int numDays, double totalHours, String days) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.period = period;
        this.numDays = numDays;
        this.totalHours = totalHours;
        this.days = days;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("start", startDate);
        result.put("end", endDate);
        result.put("period", period);
        result.put("numDays", numDays);
        result.put("totalHours", totalHours);
        result.put("days", days);

        return result;
    }

    @Override
    public String toString() {
        String s;
        s = "Start: " + startDate;
        s += "\nEnd: " + endDate;
        s += "\nPeriod: " + period;
        s += "\nNumDays: " + numDays;
        s += "\nTotalHours: " + totalHours;
        s += "\nDays: " + days;

        return s;
    }
}
