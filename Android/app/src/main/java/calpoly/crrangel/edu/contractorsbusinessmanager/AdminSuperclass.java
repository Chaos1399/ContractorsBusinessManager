package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.DateFormat;
import java.util.ArrayList;

public class AdminSuperclass extends AppCompatActivity {
    User user = null;
    ArrayList<String> clientList;
    ArrayList<String> employeeNameList;
    ArrayList<User> employeeList;
    final DatabaseReference userBase = FirebaseDatabase.getInstance().getReference("Users");
    final DatabaseReference workdayBase = FirebaseDatabase.getInstance().getReference("Workdays");
    final DatabaseReference historyBase = FirebaseDatabase.getInstance().getReference("PayPeriodHistories");
    final DatabaseReference clientBase = FirebaseDatabase.getInstance().getReference("Clients");
    final DatabaseReference locationBase = FirebaseDatabase.getInstance().getReference("Locations");
    final DatabaseReference scheduleBase = FirebaseDatabase.getInstance().getReference("Schedules");
    final DatabaseReference jobBase = FirebaseDatabase.getInstance().getReference("Jobs");
    final DatabaseReference persistenceStartup = FirebaseDatabase.getInstance().getReference("PersistenceStartup");
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
	}

    public void makeIntents (Context c) {
    	menu = new Intent(c, AMenu.class);
        signOut = new Intent(c, Login.class);
        countHours = new Intent(c, ACountHours.class);
        aviewCalendar = new Intent(c, AViewCalendar.class);
        addJob = new Intent (c, AAddJob.class);
        reviseHours = new Intent(c, AReviseHours.class);
        addWorker = new Intent(c, AAddUser.class);
        editWorker = new Intent(c, AEditUser.class);
        addClient = new Intent(c, AAddClient.class);
        editClient = new Intent(c, AEditClient.class);
    }

    public void addExtras (Intent intent) {
    	intent.putExtra("user", this.user.toBundle());
    	intent.putExtra("cList", this.clientList);
    	intent.putExtra("eList", this.employeeNameList);
	    for (int i = 0; i < this.employeeNameList.size(); i++)
		    intent.putExtra(this.employeeNameList.get(i), this.employeeList.get(i).toBundle());
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
