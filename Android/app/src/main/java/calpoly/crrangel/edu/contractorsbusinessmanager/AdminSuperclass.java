package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.app.LoaderManager.LoaderCallbacks;
import android.content.Context;
import android.content.Intent;
import android.content.Loader;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.DateFormat;
import java.util.ArrayList;

public class AdminSuperclass extends AppCompatActivity implements LoaderCallbacks <Cursor>{
    User user = null;
    ArrayList<String> clientList;
    ArrayList<String> employeeList;
    final DatabaseReference userBase = FirebaseDatabase.getInstance().getReference("Users");
    final DatabaseReference workdayBase = FirebaseDatabase.getInstance().getReference("Workdays");
    final DatabaseReference historyBase = FirebaseDatabase.getInstance().getReference("Pay Period Histories");
    final DatabaseReference clientBase = FirebaseDatabase.getInstance().getReference("Clients");
    final DatabaseReference locationBase = FirebaseDatabase.getInstance().getReference("Locations");
    final DatabaseReference scheduleBase = FirebaseDatabase.getInstance().getReference("Schedules");
    final DatabaseReference jobBase = FirebaseDatabase.getInstance().getReference("Jobs");
    final DatabaseReference persistenceStartup = FirebaseDatabase.getInstance().getReference("PersistenceStartup");
    Thread hiPri = new Thread();
    Intent signOut;
    Intent menu;
    Intent countHours;
    Intent aviewCalendar;
    Intent addJob;
    Intent reviseHours;
    Intent addWorker;
    Intent editWorker;
    Intent addClient;
    Intent editClient;
    DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);


    @Override
    public Loader<Cursor> onCreateLoader(int id, Bundle args) {
        return null;
    }

    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {
        hiPri.setPriority(Thread.MAX_PRIORITY);
    }

    @Override
    public void onLoaderReset(Loader<Cursor> loader) {}

    public Bundle userToBundle (User u) {
        Bundle b = new Bundle();

        b.putString("name", u.name);
        b.putString("password", u.password);
        b.putString("email", u.email);
        b.putString("toWork", u.toWork);
        b.putString("history", u.history);
        b.putBoolean("admin", u.admin);
        b.putDouble("pph", u.pph);
        b.putDouble("sickTime", u.sickTime);
        b.putDouble("vacaTime", u.vacaTime);
        b.putInt("numDaysScheduled", u.numDaysScheduled);
        b.putInt("numPeriods", u.numPeriods);

        return b;
    }

    public User bundleToUser (Bundle b) {
        String name = b.getString("name");
        String password = b.getString("password");
        String email = b.getString("email");
        String toWork = b.getString("toWork");
        String history = b.getString("history");
        boolean admin = b.getBoolean("admin");
        double pph = b.getDouble("pph");
        double sickTime = b.getDouble("sickTime");
        double vacaTime = b.getDouble("vacaTime");
        int numDaysScheduled = b.getInt("numDaysScheduled");
        int numPeriods = b.getInt("numPeriods");
        return new User(name, password, email, toWork, history, pph, sickTime, vacaTime,
                admin, numDaysScheduled, numPeriods);
    }

	public Bundle workdayToBundle (Workday w) {
		Bundle b = new Bundle();

		b.putString("date", df.format(w.date));
		b.putString("client", w.client);
		b.putString("location", w.location);
		b.putString("job", w.job);
		b.putDouble("hours", w.hours);
		b.putBoolean("done", w.clockedOut);

		return b;
	}

	public Workday bundleToWorkday (Bundle b) {
		return new Workday(b.getString("date"), b.getString("client"), b.getString("location"),
				b.getString("job"), b.getDouble("hours"), b.getBoolean("done"));
	}

    public void makeIntents (Context c) {
    	menu = new Intent(c, AMenu.class);
        signOut = new Intent(c, Login.class);
        countHours = new Intent(c, CountHours.class);
        aviewCalendar = new Intent(c, AViewCalendar.class);
        addJob = new Intent (c, AddJob.class);
        reviseHours = new Intent(c, ReviseHours.class);
        addWorker = new Intent(c, AddUser.class);
        editWorker = new Intent(c, AEditProfile.class);
        addClient = new Intent(c, AddClient.class);
        editClient = new Intent(c, EditClient.class);
    }

    public void addExtras () {
    	menu.putExtra("user", userToBundle(user));
    	menu.putExtra("cList", clientList);
    	menu.putExtra("eList", employeeList);
        countHours.putExtra("user", userToBundle(user));
        countHours.putExtra("cList", clientList);
        countHours.putExtra("eList", employeeList);
        aviewCalendar.putExtra("user", userToBundle(user));
        aviewCalendar.putExtra("cList", clientList);
        aviewCalendar.putExtra("eList", employeeList);
        reviseHours.putExtra("user", userToBundle(user));
        reviseHours.putExtra("cList", clientList);
        reviseHours.putExtra("eList", employeeList);
        addJob.putExtra("user", userToBundle(user));
        addJob.putExtra("cList", clientList);
        addJob.putExtra("eList", employeeList);
        addClient.putExtra("user", userToBundle(user));
        addClient.putExtra("cList", clientList);
        addClient.putExtra("eList", employeeList);
        editWorker.putExtra("user", userToBundle(user));
        editWorker.putExtra("cList", clientList);
        editWorker.putExtra("eList", employeeList);
        addWorker.putExtra("user", userToBundle(user));
        addWorker.putExtra("cList", clientList);
        addWorker.putExtra("eList", employeeList);
        editClient.putExtra("user", userToBundle(user));
		editClient.putExtra("cList", clientList);
		editClient.putExtra("eList", employeeList);
    }

	class threeLabelBox {
		String ht;
		String n;
		String pph;

		threeLabelBox(String name, double hours, double PPH) {
			n = name;
			ht = Double.toString(hours);
			pph = Double.toString(PPH);
		}
	}
}
