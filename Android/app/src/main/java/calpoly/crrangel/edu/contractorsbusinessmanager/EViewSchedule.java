package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Date;

import calpoly.crrangel.edu.contractorsbusinessmanager.ASchedule.schedBox;

public class EViewSchedule extends EmpSuperclass {
	RecyclerView schedList;
	RecyclerView.Adapter schedListAdapter;
	ArrayList<schedBox> schedBoxes;
	long selectedDate;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_eview_schedule);

		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.selectedDate = toHere.getLongExtra("selectedDate", 0);

		// Make RecyclerView
		schedList = findViewById(R.id.evsScheduleList);
		schedList.setHasFixedSize(true);
		RecyclerView.LayoutManager schedListLayoutManager = new LinearLayoutManager(this);
		DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(schedList.getContext(),
				  LinearLayoutManager.VERTICAL);
		schedList.addItemDecoration(dividerItemDecoration);
		schedList.setLayoutManager(schedListLayoutManager);
		schedListZero();

		viewCalendar = new Intent(this, EViewCalendar.class);
		addExtras(viewCalendar);

		getScheduledList();
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				navigateUpTo(viewCalendar);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			startActivity(viewCalendar);
		}
	}

	public void getScheduledList () {
		schedBoxes = new ArrayList<>();

		ValueEventListener readSList = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						ScheduledWorkday tempSW = new ScheduledWorkday(snapshot);


						Date cmp = new Date(selectedDate);
						if (cmp.before(tempSW.startDate) || cmp.after(tempSW.endDate)) {
							continue;
						}

						schedBoxes.add(new schedBox(tempSW.client, tempSW.location, tempSW.city,
								  df.format(tempSW.startDate), df.format(tempSW.endDate), tempSW.job));
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

		scheduleBase.child(user.uid).orderByKey().addListenerForSingleValueEvent(readSList);
	}

	private void schedListZero () {
		schedBoxes = new ArrayList<>();
		schedBoxes.add(new schedBox());

		schedListAdapter = new scheduleBoxAdapter(schedBoxes);
		schedList.setAdapter(schedListAdapter);
	}
}
