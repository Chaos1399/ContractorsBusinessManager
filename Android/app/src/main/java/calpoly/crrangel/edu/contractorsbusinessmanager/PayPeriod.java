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
    public Date startDate;
    public Date endDate;
    public int period;
    public int numDays;
    public double totalHours;
    public String days;
    private DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);

    public PayPeriod () {}

    PayPeriod (DataSnapshot snap) {
        PayPeriod p = snap.getValue(PayPeriod.class);

        if (p == null) {
            System.out.println ("Error making PayPeriod with:\n" + snap.getValue());
            System.exit(1);
        }

        this.days = snap.child("days").getValue(String.class);
        this.totalHours = p.totalHours;
        this.period = p.period;
        this.numDays = p.numDays;

        try {
            this.startDate = df.parse((snap.child("start").getValue(String.class)).replace("-", "/"));
            this.endDate = df.parse((snap.child("end").getValue(String.class)).replace("-", "/"));
        } catch (ParseException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    PayPeriod (Date startDate, Date endDate, int period, int numDays, double totalHours, String days) {
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
        result.put("start", df.format(startDate).replace("/", "-"));
        result.put("end", endDate);
        result.put("period", period);
        result.put("numDays", numDays);
        result.put("hours", totalHours);
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
