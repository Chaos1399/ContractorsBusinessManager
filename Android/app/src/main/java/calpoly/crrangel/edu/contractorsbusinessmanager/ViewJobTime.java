package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
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

public class ViewJobTime extends AdminSuperclass {
	RecyclerView schedList;
	RecyclerView.Adapter schedListAdapter;
	ArrayList<schedBox> schedBoxes;
	long selectedDate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_job_time);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		selectedDate = toHere.getLongExtra("date", 0);

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
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						for (DataSnapshot s : snapshot.getChildren()) {
							Job temp = new Job(s);
							if (temp.startDate.before (refDate) && temp.endDate.after (refDate)) {
								for (String c : clientList) {
									if (snapshot.getKey().indexOf(c) == 0) {
										schedBoxes.add(new schedBox(c,
												snapshot.getKey().substring(c.length(), snapshot.getKey().length()),
												df.format(temp.startDate), df.format(temp.endDate), temp.type));
										break;
									}
								}
							}
						}
					}

					schedListAdapter = new scheduleBoxAdapter(schedBoxes);
					schedList.setAdapter(schedListAdapter);
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { }
		};

		jobBase.orderByKey().addListenerForSingleValueEvent(readJBase);
	}

	public void vjtDidPressAddJob (View view) {
		Intent intent = new Intent(ViewJobTime.this, AddJob.class);
		addExtras(intent);
		startActivity(intent);
	}
}
