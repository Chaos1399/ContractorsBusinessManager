package calpoly.crrangel.edu.contractorsbusinessmanager;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.IgnoreExtraProperties;

import java.text.DateFormat;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@IgnoreExtraProperties
public class Job {
	public String type;
	public String details;
	public Date startDate;
	public Date endDate;
	DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);

	public Job () {}

	Job (DataSnapshot snap) {
		this.type = snap.child("type").getValue(String.class);
		this.details = snap.child("details").getValue(String.class);

		try {
			this.startDate = df.parse (snap.child("start").getValue(String.class).replace("-", "/"));
			this.endDate = df.parse (snap.child("end").getValue(String.class).replace("-", "/"));
		} catch (ParseException e) {
			e.printStackTrace();
			System.exit(1);
		}
	}

	public Job (String type, String details, Date startDate, Date endDate) {
		this.type = type;
		this.details = details;
		this.startDate = startDate;
		this.endDate = endDate;
	}

	@Exclude
	public Map<String, Object> toMap() {
		HashMap<String, Object> result = new HashMap<>();

		result.put("type", type);
		result.put("details", details);
		result.put("start", df.format(startDate).replace("/", "-"));
		result.put("end", df.format(endDate).replace("/", "-"));

		return result;
	}

	@Override
	public String toString() {
		String s;
		s = "Type: " + type;
		s += "\nStart: " + startDate;
		s += "\nEnd: " + endDate;
		if (details != null)
			s += "\nDetails: " + details;

		return s;
	}

}
