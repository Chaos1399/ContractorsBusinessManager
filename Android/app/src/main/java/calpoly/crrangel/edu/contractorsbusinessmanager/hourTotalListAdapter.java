package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import calpoly.crrangel.edu.contractorsbusinessmanager.AdminSuperclass.threeLabelBox;

public class hourTotalListAdapter extends RecyclerView.Adapter<hourTotalListAdapter.hourTotalVH> {
    private final int TYPE_HEADER = 0;
    private final int TYPE_ITEM = 1;
    private final int TYPE_FOOTER = 2;
    private threeLabelBox[] mDataset;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    static class hourTotalVH extends RecyclerView.ViewHolder {
        TextView ht;
        TextView n;
        TextView pph;
        int viewType;

        hourTotalVH(View v, int viewType) {
            super(v);
            ht = v.findViewById(R.id.chHoursLabel);
            n = v.findViewById(R.id.chNameLabel);
            pph = v.findViewById(R.id.chPPHLabel);
            this.viewType = viewType;
        }
    }

    @Override
	public int getItemViewType (int position) {
    	if (position == 0) {
    		return TYPE_HEADER;
		} else if (position > mDataset.length) {
    		return TYPE_FOOTER;
		}
		return TYPE_ITEM;
	}

    // Provide a suitable constructor (depends on the kind of dataset)
    hourTotalListAdapter(threeLabelBox[] myDataset) { mDataset = myDataset; }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public hourTotalVH onCreateViewHolder(@NonNull ViewGroup parent,
										  int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.hour_total_box, parent, false);

        return new hourTotalVH(v, viewType);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull hourTotalVH holder, int position) {
    	if (holder.viewType == TYPE_HEADER) {
			holder.n.setText(R.string.emp);
    		holder.ht.setText(R.string.hourTotals);
    		holder.pph.setText(R.string.pay);
		} else if (holder.viewType == TYPE_ITEM) {
			holder.n.setText(mDataset[position - 1].n);
			holder.ht.setText(mDataset[position - 1].ht);
			holder.pph.setText(mDataset[position - 1].pph);
		} else if (holder.viewType == TYPE_FOOTER) {
    		holder.n.setText(R.string.totals);
    		double ht = 0, pph = 0;
			for (threeLabelBox aMDataset : mDataset) {
				ht += Double.valueOf(aMDataset.ht);
				pph += Double.valueOf(aMDataset.pph);
			}
			holder.ht.setText(String.format("%5.2f", ht));
			holder.pph.setText(String.format("%5.2f", pph));
		}
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (mDataset == null)
            return 0;
        else
            return mDataset.length + 2;
    }
}