Project Title: Rangel Enterprises Inc. Business Manager
   (To be revised at a later date)
   
Developer Name: Cristian Rangel

Overview:

There are two versions of the app, the admin version and the employee version.

Admin version functionality:

Count all the hours worked at a job, and sum up the labor cost of them all
Schedule employees to work at a given place on a given day or set of days, doing a certain job
View all concurrent jobs for any given day
Revise the hours of any employee on any day, in case they forgot to clock in / out or were sick / on vacation
Add clients to the database
Add locations for a client to the database
Add jobs for a client & location to the database
Add employees to the database
Edit employee information (name, email, hourly pay, sick time, vacation time, admin status)

Employee version functionality:

View where you are scheduled to work for any given day
Clock in and out
View how much sick / vacation time you have accumulated
Use up to 4 days of sick / vacation time at once
View your hour totals for previous pay periods
Search through previous pay periods by period number or date to view your hours for that pay period
Edit your information (name, email, and password)


Here are the logins for both:
Admin:
   Username: A
   Password: a
Employee:
   Username: Jose Rangel
   Password: hoblet



Special Notes:

Both Versions:
- The Change Page button works, and so does the tab bar

Employee Version:
- For view schedule, click on March 9 to see the labelschange. Jose is scheduled to work on that day
- For view schedule, you can click on the arrows or swipe the calendar to the side to change months
- For the clock in / out page, tapping clock out will update FireBase according to today's date and the client /
   location / job you pick when you tap the button
- For the time bank, pressing the use button doesn't currently do anything for sick time, but if you set it to
   vacation, it will show how many workdays it will put you down as vacationing for

Admin Version:
- For add job, you have to type in a valid client and location. Type in Bea as the client and 60 Casa
   or Mission School as the location
- For add job, once you have typed in a valid client and location the TableView populates. You can tap on
   one of the entries to go to the job detail page. Currently editing a job doesn't replace the one you
   tapped on (see bug below)
- Pressing cancel on a page that has a tab bar will bring you to the menu



API's I use:

Firebase
Firebase/Core
Firebase/Database
JTAppleCalendar



What follows is the state of development of my project, I list the things I have built to full functionality, and what I plan to do in the future.

Full Functionality:

Page Navigation
Login
Sign Up
Employee Edit Profile
Admin Edit Profile
Admin Add Client
Admin Add Job
Page navigation
Employee ClockInOut
Employee ViewSchedule (see bug below)
Employee Timebank
Employee PayPeriodHistory
Admin ViewCalendar
Admin Schedule
Admin ViewJobTime
Admin Revise Hours

Future Functionality:

Android App
Web-based App

Admin version:

Upload invoices to edit and email to clients
Alert system to send important news to employees with notifications and / or email
View job timelines graphically on the schedule calendar

Employee version:

Over 9 hour workday notification
Ability to request schedule changes

Project Title: Rangel Enterprises Inc. Business Manager
   (To be revised at a later date)

Special Info:

There are two versions of the app, the admin version and the employee version.

Admin version functionality:
   - Count all the hours worked at a job, and sum up the labor cost of them all
   - Schedule employees to work at a given place on a given day or set of days, doing a certain job
   - View all concurrent jobs for any given day
   - Revise the hours of any employee on any day, in case they forgot to clock in / out or were sick / on vacation
   - Add clients do the database
   - Add locations for a client to the database
   - Add jobs for a client & location to the database
   - Add employees to the database
   - Edit employee information (name, email, hourly pay, sick time, vacation time, admin status)


Employee version functionality:
   - View where you are scheduled to work for any given day
   - Clock in and out
   - View how much sick / vacation time you have saved up
   - Use up to 4 days of sick / vacation time at once
   - View your hour totals for previous pay periods
   - Search through previous pay periods by period number or date to view your hours for that pay period
   - Edit your information (name, email, and password)


API's I use:


   - Firebase
   - Firebase/Core
   - Firebase/Database
   - JTAppleCalendar

What follows is the state of development of my project, I list the things I have built to full functionality, and what I plan to do in the future.


Full Functionality:

   - Page navigation
   - Login
   - Sign Up
   - Admin version count hours
   - Admin version view calendar
   - Admin version schedule employee view
   - Admin version view estimated job time
   - Admin version revise hours
   - Admin Edit Profile
   - Admin Add Client
   - Admin Add Job
   - Employee Edit Profile
   - Employee clock in / out
   - Employee sick / vacation time bank usage
   - Employee version view calendar
   - Employee version view pay period history


Future Functionality:

   - Android App
   - Web-based App

Admin version:

   - Upload invoices to edit and email to clients
   - Alert system to send important news to employees with notifications and / or email
   - View job timelines graphically on the schedule calendar

Employee version:

   - Over 9 hour workday notification
   - Ability to request schedule changes


