package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.design.widget.TextInputEditText;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.os.Bundle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Date;

public class EPayHistory extends EmpSuperclass
        implements NavigationView.OnNavigationItemSelectedListener {
    RecyclerView historyList;
    RecyclerView.Adapter historyListAdapter;
    ArrayList<historyBox> histBoxes;
    ArrayList<Integer> yearList;

    TextInputEditText periodNum;
    TextInputEditText day;
    TextInputEditText month;
    TextInputEditText year;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_epay_history);
        Toolbar toolbar = findViewById(R.id.ephToolbar);
        setSupportActionBar(toolbar);
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();
        NavigationView navigationView = findViewById(R.id.enav_view);
        navigationView.setNavigationItemSelectedListener(this);

        periodNum = findViewById(R.id.ephPET);
        day = findViewById(R.id.ephDET);
        month = findViewById(R.id.ephMET);
        year = findViewById(R.id.ephYET);

        historyList = findViewById(R.id.historyList);
        historyList.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        DividerItemDecoration divider = new DividerItemDecoration(historyList.getContext(),
                LinearLayoutManager.VERTICAL);
        historyList.addItemDecoration(divider);
        historyList.setLayoutManager(layoutManager);

        historyListZero();
        getHistory(-1, "");
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            menu = new Intent(this, EMenu.class);
            addExtras(menu);
            navigateUpTo(menu);
        }
    }

    // Drawer Item Selected
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        Intent intent = null;

        ((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

        if (id == R.id.eLogoutMenu) {
            auth.signOut();
            intent = signOut;
        } else if (id == R.id.eMenuMenu) {
            intent = menu;
        } else if (id == R.id.editProfileMenu) {
            intent = editProfile;
        } else if (id == R.id.clockInMenu) {
            intent = clockIn;
        } else if (id == R.id.viewCalendarEMenu) {
            intent = viewCalendar;
        } else if (id == R.id.pphMenu) {
            intent = payPeriodHistory;
        } else if (id == R.id.timeBankMenu) {
            intent = timeBank;
        }

        if (intent != null) {
            addExtras(intent);
            startActivity(intent);
        }

        return true;
    }

    void getHistory (final int perNum, final String dayToSearch) {
        historyListZero();

        ValueEventListener readHistory = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot historyListSnap) {
                if (historyListSnap.exists()) {
                    for (DataSnapshot historySnap : historyListSnap.getChildren()) {
                        if (historySnap.exists()) {
                            if (perNum < 0 || historySnap.getKey().equals(perNum + "")) {
                                PayPeriod temp = new PayPeriod(historySnap);

                                if (dayToSearch.equals("") || (temp.startDate.compareTo(dayToSearch) <= 0 &&
                                        temp.endDate.compareTo(dayToSearch) >= 0)) {
                                    histBoxes.add(new historyBox(temp.period, temp.startDate, temp.endDate, temp.totalHours));
                                }
                            }
                        }
                    }

                    if (histBoxes.size() > 1) {
                        historyListAdapter = new historyBoxAdapter(histBoxes);
                        historyList.setAdapter(historyListAdapter);
                    }
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {}
        };

        historyBase.child(user.uid).orderByKey().addListenerForSingleValueEvent(readHistory);
    }

    void historyListZero() {
        histBoxes = new ArrayList<>();
        histBoxes.add(new historyBox());

        historyListAdapter = new historyBoxAdapter(histBoxes);
        historyList.setAdapter(historyListAdapter);
    }

    public void ephDidPressFilter (View view) {
        historyListZero();

        String date;
        if (month.getText().toString().isEmpty() &&
                day.getText().toString().isEmpty() &&
                year.getText().toString().isEmpty())
            date = "";
        else if (!(month.getText().toString().isEmpty() &&
                day.getText().toString().isEmpty() &&
                year.getText().toString().isEmpty())) {
            if (year.getText().toString().isEmpty()) {
                year.setError(getResources().getString(R.string.error_field_required));
            } else if (year.getText().toString().length() < 4) {
                year.setError(getResources().getString(R.string.error_short_year));
            }
            if (day.getText().toString().isEmpty()) {
                day.setError(getResources().getString(R.string.error_field_required));
            }
            if (month.getText().toString().isEmpty()) {
                month.setError(getResources().getString(R.string.error_field_required));
            }
            return;
        }
        else {
            date = month.getText().toString() + "-";
            date += day.getText().toString() + "-";
            date += year.getText().toString();
        }
        int num = (periodNum.getText().toString().equals(""))? -1 :
                Integer.valueOf(periodNum.getText().toString());
        getHistory(num, date);
    }

    static class historyBox {
        int pnum;
        String startDate;
        String endDate;
        double hours;

        historyBox () {
            this.pnum = 0;
            this.startDate = this.endDate = "None";
            this.hours = 0;
        }

        historyBox (int pnum, String startDate, String endDate, double hours) {
            this.pnum = pnum;
            this.startDate = startDate;
            this.endDate = endDate;
            this.hours = hours;
        }

        @Override
        public String toString() {
            String toret = "PNum: " + pnum;
            toret += "\nStart: " + startDate;
            toret += "\nEnd: " + endDate;
            toret += "\nHours: " + hours;

            return toret;
        }
    }
}
