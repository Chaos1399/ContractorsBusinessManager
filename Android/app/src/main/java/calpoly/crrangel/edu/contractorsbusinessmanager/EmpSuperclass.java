package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Context;
import android.content.Intent;
import android.content.Loader;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.app.LoaderManager;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.DateFormat;
import java.util.ArrayList;

public class EmpSuperclass extends AppCompatActivity
		implements LoaderManager.LoaderCallbacks <Cursor> {
	User user = null;
	ArrayList<String> clientList;
	ArrayList<String> employeeList;
	DatabaseReference userBase = FirebaseDatabase.getInstance().getReference("Users");
	DatabaseReference workdayBase = FirebaseDatabase.getInstance().getReference("Workdays");
	DatabaseReference historyBase = FirebaseDatabase.getInstance().getReference("Pay Period Histories");
	DatabaseReference clientBase = FirebaseDatabase.getInstance().getReference("Clients");
	DatabaseReference locationBase = FirebaseDatabase.getInstance().getReference("Locations");
	DatabaseReference scheduleBase = FirebaseDatabase.getInstance().getReference("Schedules");
	DatabaseReference jobBase = FirebaseDatabase.getInstance().getReference("Jobs");
	Thread hiPri = new Thread();
	Intent signOut;
	Intent menu;
	Intent clockIn;
	Intent editProfile;
	Intent viewPPH;
	Intent viewTB;
	Intent schedule;
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

	public void makeIntents (Context c) {
		menu = new Intent(c, EMenu.class);
		signOut = new Intent(c, Login.class);
		clockIn = new Intent(c, ClockIn.class);
		editProfile = new Intent(c, EEditProfile.class);
		viewPPH = new Intent(c, PayHistory.class);
		viewTB = new Intent(c, TimeBank.class);
		schedule = new Intent(c, ViewSchedule.class);
	}

	public void addExtras () {
		menu.putExtra("user", userToBundle(user));
		menu.putExtra("cList", clientList);
		menu.putExtra("eList", employeeList);
		clockIn.putExtra("user", userToBundle(user));
		clockIn.putExtra("cList", clientList);
		clockIn.putExtra("eList", employeeList);
		editProfile.putExtra("user", userToBundle(user));
		editProfile.putExtra("cList", clientList);
		editProfile.putExtra("eList", employeeList);
		viewPPH.putExtra("user", userToBundle(user));
		viewPPH.putExtra("cList", clientList);
		viewPPH.putExtra("eList", employeeList);
		viewTB.putExtra("user", userToBundle(user));
		viewTB.putExtra("cList", clientList);
		viewTB.putExtra("eList", employeeList);
		schedule.putExtra("user", userToBundle(user));
		schedule.putExtra("cList", clientList);
		schedule.putExtra("eList", employeeList);
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
