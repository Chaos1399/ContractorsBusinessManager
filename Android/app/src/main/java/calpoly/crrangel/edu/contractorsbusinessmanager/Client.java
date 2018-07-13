package calpoly.crrangel.edu.contractorsbusinessmanager;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.Exclude;
import com.google.firebase.database.IgnoreExtraProperties;

import java.util.HashMap;
import java.util.Map;

@IgnoreExtraProperties
public class Client {
    public String name;
    public String address;
    public String email;
    public String properties;
    public int numProps;

    public Client () {}

    public Client (DataSnapshot snap) {
        this.name = snap.child("name").getValue(String.class);
        this.address = snap.child("billingAddress").getValue(String.class);
        this.email = snap.child("email").getValue(String.class);
        this.properties = snap.child("heldProperties").getValue(String.class);
        //noinspection ConstantConditions
        this.numProps = snap.child("size").getValue(int.class);
    }

    public Client (String name, String address, String email, String properties, int numProps) {
        this.name = name;
        this.address = address;
        this.email = email;
        this.properties = properties;
        this.numProps = numProps;
    }

    public Client (Client copy) {
    	this.name = copy.name;
    	this.address = copy.address;
    	this.email = copy.email;
    	this.properties = copy.properties;
    	this.numProps = copy.numProps;
	}

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("name", name);
        result.put("billingAddress", address);
        result.put("email", email);
        result.put("heldProperties", properties);
        result.put("size", numProps);

        return result;
    }

    @Override
    public String toString () {
        String s;
        s = "Name: " + name;
        s += "\nAddress: " + address;
        s += "\nEmail: " + email;
        s += "\nProperties: " + properties;
        s += "\nNumProps: " + numProps;

        return s;
    }
}
