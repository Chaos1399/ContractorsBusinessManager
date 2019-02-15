package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.DateFormat;
import java.util.ArrayList;

public class EmpSuperclass extends AppCompatActivity {
	User user = null;
	ArrayList<String> clientList;
	ArrayList<String> employeeNameList;
	ArrayList<User> employeeList;
	boolean isClockedIn;
	final DatabaseReference userBase = FirebaseDatabase.getInstance().getReference("Users");
	final DatabaseReference workdayBase = FirebaseDatabase.getInstance().getReference("Workdays");
	final DatabaseReference historyBase = FirebaseDatabase.getInstance().getReference("PayPeriodHistories");
	final DatabaseReference clientBase = FirebaseDatabase.getInstance().getReference("Clients");
	final DatabaseReference locationBase = FirebaseDatabase.getInstance().getReference("Locations");
	final DatabaseReference scheduleBase = FirebaseDatabase.getInstance().getReference("Schedules");
	final DatabaseReference jobBase = FirebaseDatabase.getInstance().getReference("Jobs");
	final DatabaseReference persistenceStartup = FirebaseDatabase.getInstance().getReference("PersistenceStartup");
	final String TIMER_CHANNEL = "TimerChannel";
	final int NID = 0;
	Intent signOut;
	Intent menu;
	Intent clockIn;
	Intent editProfile;
	Intent viewCalendar;
	Intent payPeriodHistory;
	Intent timeBank;
	DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
	FirebaseAuth auth;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.user = new User(toHere.getExtras().getBundle("user"));
		this.clientList = toHere.getStringArrayListExtra("cList");
		this.employeeNameList = toHere.getStringArrayListExtra("eList");
		this.employeeList = new ArrayList<>();
		for (String s : this.employeeNameList)
			this.employeeList.add(new User(toHere.getExtras().getBundle(s)));
		auth = FirebaseAuth.getInstance();
	}

	public void makeIntents (Context c) {
		menu = new Intent(c, EMenu.class);
		signOut = new Intent(c, Login.class);
		clockIn = new Intent(c, EClockIn.class);
		editProfile = new Intent(c, EEditProfile.class);
		viewCalendar = new Intent(c, EViewCalendar.class);
		payPeriodHistory = new Intent(c, EPayHistory.class);
		timeBank = new Intent(c, ETimeBank.class);
	}

	public void addExtras (Intent intent) {
		intent.putExtra("user", this.user.toBundle());
		intent.putExtra("cList", this.clientList);
		intent.putExtra("eList", this.employeeNameList);
		for (int i = 0; i < this.employeeNameList.size(); i++)
			intent.putExtra(this.employeeNameList.get(i), this.employeeList.get(i).toBundle());
	}

	public void createNotificationChannel() {
		// Create the NotificationChannel, but only on API 26+ because
		// the NotificationChannel class is new and not in the support library
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			int importance = NotificationManager.IMPORTANCE_DEFAULT;
			NotificationChannel channel = new NotificationChannel(TIMER_CHANNEL, TIMER_CHANNEL, importance);
			NotificationManager notificationManager = getSystemService(NotificationManager.class);
			if (notificationManager != null)
				notificationManager.createNotificationChannel(channel);
		}
	}
}
