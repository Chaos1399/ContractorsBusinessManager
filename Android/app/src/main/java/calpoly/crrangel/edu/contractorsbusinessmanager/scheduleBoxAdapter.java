package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;

import calpoly.crrangel.edu.contractorsbusinessmanager.ASchedule.schedBox;

public class scheduleBoxAdapter extends RecyclerView.Adapter<scheduleBoxAdapter.schedBoxVH> {
	private ArrayList<schedBox> mDataset;

	// Provide a reference to the views for each data item
	// Complex data items may need more than one view per item, and
	// you provide access to all the views for a data item in a view holder
	static class schedBoxVH extends RecyclerView.ViewHolder {
		TextView c;
		TextView l;
		TextView sd;
		TextView ed;
		TextView j;

		schedBoxVH(View v) {
			super(v);
			c = v.findViewById(R.id.asbClientLabel);
			l = v.findViewById(R.id.asbLocLabel);
			sd = v.findViewById(R.id.asbSDLabel);
			ed = v.findViewById(R.id.asbEDLabel);
			j = v.findViewById(R.id.asbJobLabel);
		}
	}

	// Provide a suitable constructor (depends on the kind of dataset)
	scheduleBoxAdapter(ArrayList<schedBox> myDataset) { mDataset = myDataset; }

	// Create new views (invoked by the layout manager)
	@NonNull
	@Override
	public schedBoxVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
		View v = LayoutInflater.from(parent.getContext())
				.inflate(R.layout.schedule_box, parent, false);

		return new schedBoxVH(v);
	}

	// Replace the contents of a view (invoked by the layout manager)
	@Override
	public void onBindViewHolder(@NonNull schedBoxVH holder, int position) {
		holder.c.setText(mDataset.get(position).client);
		holder.l.setText(mDataset.get(position).loc);
		holder.sd.setText(mDataset.get(position).startDate);
		holder.ed.setText(mDataset.get(position).endDate);
		holder.j.setText(mDataset.get(position).job);
	}

	// Return the size of your dataset (invoked by the layout manager)
	@Override
	public int getItemCount() {
		return (mDataset == null)? 0 : mDataset.size();
	}
}