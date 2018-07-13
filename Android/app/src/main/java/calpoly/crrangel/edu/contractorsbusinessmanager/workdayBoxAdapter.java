package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;

import calpoly.crrangel.edu.contractorsbusinessmanager.ReviseHours.workdayBox;

public class workdayBoxAdapter extends RecyclerView.Adapter<workdayBoxAdapter.workdayBoxVH>{
	private ArrayList<workdayBox> mDataset;
	private OnItemClickListener mListener;

	// Provide a suitable constructor (depends on the kind of dataset)
	workdayBoxAdapter(ArrayList<workdayBox> myDataset, OnItemClickListener listener) {
		mDataset = myDataset;
		mListener = listener;
	}

	public void updateData(ArrayList<workdayBox> dataset) {
		mDataset.clear();
		mDataset.addAll(dataset);
		notifyDataSetChanged();
	}

	public void printData () {
		System.out.println (mDataset);
	}

	// Create new views (invoked by the layout manager)
	@NonNull
	@Override
	public workdayBoxVH onCreateViewHolder(@NonNull ViewGroup parent,
										 int viewType) {
		// create a new view
		View v = LayoutInflater.from(parent.getContext())
				.inflate(R.layout.workday_box, parent, false);

		return new workdayBoxVH(v, mListener);
	}

	// Replace the contents of a view (invoked by the layout manager)
	@Override
	public void onBindViewHolder(@NonNull workdayBoxVH holder, int position) {
		holder.c.setText(mDataset.get(position).client);
		holder.l.setText(mDataset.get(position).loc);
		holder.j.setText(mDataset.get(position).job);
		holder.h.setText(mDataset.get(position).hours);
	}

	// Return the size of your dataset (invoked by the layout manager)
	@Override
	public int getItemCount() {
		if (mDataset == null)
			return 0;
		else
			return mDataset.size();
	}

	// Provide a reference to the views for each data item
	// Complex data items may need more than one view per item, and
	// you provide access to all the views for a data item in a view holder
	static class workdayBoxVH extends RecyclerView.ViewHolder
			implements View.OnClickListener{
		TextView c;
		TextView l;
		TextView j;
		TextView h;
		OnItemClickListener mListener;

		workdayBoxVH(View v, OnItemClickListener listener) {
			super(v);
			c = v.findViewById(R.id.wbClientLabel);
			l = v.findViewById(R.id.wbLocationLabel);
			j = v.findViewById(R.id.wbJobLabel);
			h = v.findViewById(R.id.wbHoursLabel);
			this.mListener = listener;
			v.setOnClickListener(this);
		}

		@Override
		public void onClick (View view) {
			mListener.onItemClick(getAdapterPosition());
		}
	}

	public interface OnItemClickListener {
		void onItemClick (int position);
	}
}