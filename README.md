Project Title: Rangel Enterprises Inc. Business Manager
   (To be revised at a later date)

Special Info:

There are two versions of the app, the admin version and the employee version.
The admin version allows for more managerial functions, such as changing the hourly pay for employees, or
   counting the hours spent working at a certain client, at a certain location, at a certain job.
The employee version allows for employee ease-of-use things like hour tracking, and a schedule to avoid confusion.

Here are the logins for both:
Admin:
   Username: A
   Password: a
Employee:
   Username: Jose Rangel
   Password: hoblet


API's I use:

Firebase
Firebase/Core
Firebase/Database
JTAppleCalendar

I imported GeoFire, but I ended up not needing it

What follows is the state of development of my project, I list the things I have built to full functionality,
   what I have only partially done, and what I have not yet gotten to at all, as well as a few bugs that I
   know occur during usage, but will put off correcting them until I first have basic functionality for everything.


Full Functionality:

Login
Sign Up
Employee Edit Profile
Admin Edit Profile
Admin Add Client
Admin Add Job
Page navigation
Employee clock in / out


Partial Functionality:

Employee sick / vacation time bank usage
Employee version view calendar


No Functionality:

Employee version view pay period history
Admin version count hours
Admin version view calendar
Admin version schedule employee view
Admin version view estimated job time
Admin version revise hours


Known Bugs:

- When editing a job, it simply adds an edited duplicate job, it doesn't actually replace the old one
- When submit is pressed on the Add Job page, it duplicates all jobs present in FireBase as well
   as adding the new ones
- Cannot currently add new locations for a client. It would be in the add job page, but for now,
   an error is signaled
- Cannot select a day in any month other than the current month.
- On the employee version clock in / out page, components 1 and 2 don't show until you move them
   as if to select one. (or if you just move component 2) They are actually loaded, though




