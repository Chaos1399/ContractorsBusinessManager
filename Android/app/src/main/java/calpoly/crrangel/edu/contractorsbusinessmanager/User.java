package calpoly.crrangel.edu.contractorsbusinessmanager;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.IgnoreExtraProperties;

import java.util.HashMap;
import java.util.Map;

@IgnoreExtraProperties
public class User {
    public String name;
    public String password;
    public String email;
    public String toWork;
    public String history;
    public String uid;
    public boolean admin;
    public double pph;
    public double sickTime;
    public double vacaTime;
    public int numDaysScheduled;
    public int numPeriods;

    User() {
        // Default constructor required for calls to DataSnapshot.getValue(User.class)
        // Note, it will not set the String fields
    }

    User (DataSnapshot snap) {
        this.numPeriods = snap.child("numPeriods").getValue(Integer.class);
        this.numDaysScheduled = snap.child("numDays").getValue(Integer.class);
        this.pph = snap.child("pph").getValue(Double.class);
        this.sickTime = snap.child("sickTime").getValue(Double.class);
		this.vacaTime = snap.child("vacationTime").getValue(Double.class);
        this.admin = snap.child("admin").getValue(Boolean.class);
        this.name = snap.child("name").getValue(String.class);
        this.password = snap.child("password").getValue(String.class);
        this.email = snap.child("email").getValue(String.class);
        this.toWork = snap.child("scheduledToWork").getValue(String.class);
        this.history = snap.child("payPeriodHistory").getValue(String.class);
        this.uid = snap.getKey();
    }

    User (String name, String password, String email, String toWork, String history, String uid, double pph,
          double sickTime, double vacaTime, boolean admin, int numDaysScheduled, int numPeriods) {
        this.name = name;
        this.password = password;
        this.email = email;
        this.pph = pph;
        this.sickTime = sickTime;
        this.vacaTime = vacaTime;
        this.admin = admin;
        this.toWork = toWork;
        this.history = history;
        this.uid = uid;
        this.numDaysScheduled = numDaysScheduled;
        this.numPeriods = numPeriods;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("name", name);
        result.put("password", password);
        result.put("email", email);
        result.put("pph", pph);
        result.put("sickTime", sickTime);
        result.put("vacationTime", vacaTime);
        result.put("admin", admin);
        result.put("scheduledToWork", toWork);
        result.put("payPeriodHistory", history);
        result.put("numDays", numDaysScheduled);
        result.put("numPeriods", numPeriods);

        return result;
    }

    @Override
    public String toString() {
        String s = "";
        s += "Name: " + name;
        s += "\nUID: " + uid;
        s += "\nPassword: " + password;
        s += "\nEmail: " + email;
        s += "\nPPH: " + pph;
        s += "\nSick Time: " + sickTime;
        s += "\nVacation Time: " + vacaTime;
        s += "\nHistory: " + history;
        s += "\nToWork: " + toWork;
        s += "\nAdmin: " + admin;
        s += "\nNumDaysScheduled: " + numDaysScheduled;
        s += "\nNumPeriods: " + numPeriods;

        return s;
    }
}
