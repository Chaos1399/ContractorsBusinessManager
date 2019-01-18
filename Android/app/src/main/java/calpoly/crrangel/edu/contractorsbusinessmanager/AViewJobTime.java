package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;
import android.view.View;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import calpoly.crrangel.edu.contractorsbusinessmanager.ASchedule.schedBox;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;

public class AViewJobTime extends AdminSuperclass {
	RecyclerView schedList;
	RecyclerView.Adapter schedListAdapter;
	ArrayList<schedBox> schedBoxes;
	HashMap<String, Location> locList;
	long selectedDate;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_view_job_time);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		selectedDate = toHere.getLongExtra("date", 0);
		fetchLocs();

		// Make RecyclerView
		schedList = findViewById(R.id.vjtJobList);
		schedList.setHasFixedSize(true);
		RecyclerView.LayoutManager schedListLayoutManager = new LinearLayoutManager(this);
		DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(schedList.getContext(),
				  LinearLayoutManager.VERTICAL);
		schedList.addItemDecoration(dividerItemDecoration);
		schedList.setLayoutManager(schedListLayoutManager);
		schedListCreate();
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent intent = new Intent(this, ASchedule.class);
				addExtras(intent);
				navigateUpTo(intent);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	private void schedListCreate () {
		schedBoxes = new ArrayList<>();
		final Date refDate = new Date (selectedDate);

		ValueEventListener readJBase = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				for (DataSnapshot clientLvlSnapshot : dataSnapshot.getChildren()) {
					String cKey = clientLvlSnapshot.getKey();
					for (DataSnapshot locLvlSnapshot : clientLvlSnapshot.getChildren()) {
						String lKey = locLvlSnapshot.getKey();
						for (DataSnapshot jobLvlSnapshot : locLvlSnapshot.getChildren()) {
							Job tempJob = new Job(jobLvlSnapshot);
							Location tempLoc = locList.get(cKey + "/" + lKey);

							if ((tempJob.startDate.compareTo(refDate) <= 0) && (tempJob.endDate.compareTo(refDate) >= 0)) {
								schedBoxes.add(new schedBox(clientList.get(Integer.parseInt(cKey)),
										  tempLoc.address, tempLoc.city, df.format(tempJob.startDate),
										  df.format(tempJob.endDate), tempJob.type));
							}
						}
					}
				}

				schedListAdapter = new scheduleBoxAdapter(schedBoxes);
				schedList.setAdapter(schedListAdapter);
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { }
		};

		jobBase.orderByKey().addListenerForSingleValueEvent(readJBase);
	}

	private void fetchLocs () {
		locList = new HashMap<>();

		// locList will have the format { "ClientNum/LocationNum" : Location }
		ValueEventListener getLocs = new ValueEventListener() {
			@Override
			public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
				for (DataSnapshot clientLvlSnap : dataSnapshot.getChildren())
					for (DataSnapshot loclLvlSnap : clientLvlSnap.getChildren())
						locList.put(clientLvlSnap.getKey() + "/" + loclLvlSnap.getKey(), new Location(loclLvlSnap));
			}

			@Override
			public void onCancelled(@NonNull DatabaseError databaseError) {}
		};

		locationBase.orderByKey().addListenerForSingleValueEvent(getLocs);
	}

	public void vjtDidPressAddJob (View view) {
		Intent intent = new Intent(AViewJobTime.this, AAddJob.class);
		addExtras(intent);
		startActivity(intent);
	}
}
