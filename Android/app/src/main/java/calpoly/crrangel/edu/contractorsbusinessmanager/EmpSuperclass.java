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

public class EmpSuperclass extends AppCompatActivity
		implements LoaderCallbacks <Cursor> {
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

	public void makeIntents (Context c) {
		menu = new Intent(c, EMenu.class);
		signOut = new Intent(c, Login.class);
		clockIn = new Intent(c, EWork.class);
		editProfile = new Intent(c, EEditProfile.class);
		viewPPH = new Intent(c, EPayHistory.class);
		viewTB = new Intent(c, ETimeBank.class);
		schedule = new Intent(c, AViewSchedule.class);
	}

	public void addExtras (Intent intent) {
		intent.putExtra("user", this.user.toBundle());
		intent.putExtra("cList", this.clientList);
		intent.putExtra("eList", this.employeeList);
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
