package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Date;

public class ASchedule extends AdminSuperclass
		implements AdapterView.OnItemSelectedListener{
	RecyclerView schedList;
	RecyclerView.Adapter schedListAdapter;
	ArrayList<schedBox> schedBoxes;
	Spinner selectedEmp;
	long selectedDate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aschedule);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.user = bundleToUser(toHere.getExtras().getBundle("user"));
		this.clientList = toHere.getStringArrayListExtra("cList");
		this.employeeList = toHere.getStringArrayListExtra("eList");
		this.selectedDate = toHere.getLongExtra("date", 0);

        // Make RecyclerView
        schedList = findViewById(R.id.asScheduleList);
        schedList.setHasFixedSize(true);
        RecyclerView.LayoutManager schedListLayoutManager = new LinearLayoutManager(this);
		DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(schedList.getContext(),
				LinearLayoutManager.VERTICAL);
		schedList.addItemDecoration(dividerItemDecoration);
        schedList.setLayoutManager(schedListLayoutManager);
        schedListZero();

        selectedEmp = findViewById(R.id.asE);
        String [] eList = new String[employeeList.size()];
        for (int i = 0; i < employeeList.size(); i++) {
			eList [i] = employeeList.get(i);
		}
        ArrayAdapter<String> selectedEmpAdapter = new ArrayAdapter<>(ASchedule.this, R.layout.support_simple_spinner_dropdown_item, eList);
        selectedEmpAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        selectedEmp.setAdapter(selectedEmpAdapter);
    }

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent intent = new Intent(this, ASchedule.class);
				intent.putExtra("user", userToBundle(user));
				intent.putExtra("cList", clientList);
				intent.putExtra("eList", employeeList);
				navigateUpTo(intent);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		schedListZero ();
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}

	public void asGetScheduledList (View view) {
    	schedBoxes = new ArrayList<>();

		ValueEventListener readSList = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						ScheduledWorkday tempSW = new ScheduledWorkday(snapshot);

						Date cp = new Date(selectedDate);

						if (cp.before(tempSW.startDate) || cp.after(tempSW.endDate)) {
							continue;
						}

						schedBoxes.add(new schedBox(tempSW.client, tempSW.location, df.format(tempSW.startDate),
								df.format(tempSW.endDate), tempSW.job));
					}

					if (schedBoxes.size() != 0) {
						schedListAdapter = new scheduleBoxAdapter(schedBoxes);
						schedList.setAdapter(schedListAdapter);
					} else
						schedListZero();
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		scheduleBase.child((String) selectedEmp.getSelectedItem()).orderByKey().addListenerForSingleValueEvent(readSList);
	}

    public void asDidPressAdd (View view) {
		Intent intent = new Intent(ASchedule.this, AAddToSchedule.class);
		intent.putExtra("user", userToBundle(user));
		intent.putExtra("cList", clientList);
		intent.putExtra("eList", employeeList);
		intent.putExtra("date", selectedDate);
		intent.putExtra("toSched", (String) selectedEmp.getSelectedItem());

		startActivity(intent);
	}

	private void schedListZero () {
    	schedBoxes = new ArrayList<>();
    	schedBoxes.add(new schedBox("None", "None", "None", "None", "None"));

    	schedListAdapter = new scheduleBoxAdapter(schedBoxes);
    	schedList.setAdapter(schedListAdapter);
	}

	static class schedBox {
    	String client;
    	String loc;
    	String startDate;
    	String endDate;
    	String job;

    	schedBox (String client, String loc, String startDate, String endDate, String job) {
    		this.client = client;
    		this.loc = loc;
    		this.startDate = startDate;
    		this.endDate = endDate;
    		this.job = job;
		}
	}
}
