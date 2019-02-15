package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Locale;

import calpoly.crrangel.edu.contractorsbusinessmanager.EPayHistory.historyBox;

public class historyBoxAdapter extends RecyclerView.Adapter<historyBoxAdapter.histBoxVH> {
	private final int TYPE_HEADER = 0;
	private final int TYPE_ITEM = 1;
	private ArrayList<historyBox> mDataset;

	historyBoxAdapter(ArrayList<historyBox> myDataset) { mDataset = myDataset; }

	public void updateData(ArrayList<historyBox> dataset) {
		mDataset.clear();
		mDataset.addAll(dataset);
		notifyDataSetChanged();
	}

	@Override
	public int getItemViewType (int position) { return (position == 0)? TYPE_HEADER : TYPE_ITEM; }

	// Create new views (invoked by the layout manager)
	@NonNull
	@Override
	public histBoxVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
		View v = LayoutInflater.from(parent.getContext())
				.inflate(R.layout.history_box, parent, false);

		return new histBoxVH(v, viewType);
	}

	// Replace the contents of a view (invoked by the layout manager)
	@Override
	public void onBindViewHolder(@NonNull histBoxVH holder, int position) {
		if (holder.viewType == TYPE_HEADER) {
			holder.p.setText(R.string.pay_period);
			holder.s.setText(R.string.start_date);
			holder.e.setText(R.string.end_date);
			holder.h.setText(R.string.hours);
		} else {
			holder.p.setText(String.format(Locale.getDefault(),
					  "%3d", mDataset.get(position).pnum));
			holder.s.setText(mDataset.get(position).startDate);
			holder.e.setText(mDataset.get(position).endDate);
			holder.h.setText(String.format(Locale.getDefault(),
					  "%5.2f", mDataset.get(position).hours));
		}
	}

	// Return the size of your dataset (invoked by the layout manager)
	@Override
	public int getItemCount() { return (mDataset == null)?  0 : mDataset.size(); }

	// Provide a reference to the views for each data item
	// Complex data items may need more than one view per item, and
	// you provide access to all the views for a data item in a view holder
	static class histBoxVH extends RecyclerView.ViewHolder {
		TextView p;
		TextView s;
		TextView e;
		TextView h;
		int viewType;

		histBoxVH(View v, int viewType) {
			super(v);
			p = v.findViewById(R.id.ehbPNLabel);
			s = v.findViewById(R.id.ehbSDLabel);
			e = v.findViewById(R.id.ehbEDLabel);
			h = v.findViewById(R.id.ehbHLabel);
			this.viewType = viewType;
		}
	}
}