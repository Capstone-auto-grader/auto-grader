Welcome to Auto Grader

This is an app designed by by Sam Stern, Eli Esrig, Zihao Wang, Calum Middlemiss.

To access our project website, please visit [Auto-grader](https://capstone-grading.herokuapp.com).

### What is Auto Grader?

The idea behind AutoGrader came from seeing the head TA in Brandeis Computer Science intro class struggle on a week-to-week basis to push out grades and grading assignments for the TA team.Before he wrote a script to automate some work, the workflow for grading was as follows: 

```markdown
1.Student submits assignment to LATTE
2.A few minutes after deadline, head TA downloads zip file of all submissions from LATTE
3.Head TA unpacks zip file and puts submissions into directories
4.Head TA replaces each student’s test suite with master test suite
5.Head TA runs tests on each student’s code
6.Head TA enters score into spreadsheet
7.repeated for (student : students)
8.After all of this, grading groups assigned and sent out to grading TAs
9.Repeat process as needed for late submissions
```
Using our project, the grading workflow will be:

```markdown
1.Student submits assignment to Auto grader
2.The server runs Junit test online 
3.Assignments send to TA evenly based on Junit result after submissions are due
4.TA grades the coding style and updates on the website
5.Professor can look the grades online and export them as csv file
```

### Key Features

# Webserver
We maintain a central webserver that all users interact with. This contains a database of assignments, student submissions, grades, grading groups, and users. All webpages are served from this webserver, and all asynchronous actions are coordinated by this webserver.

# Docker
We keep a worker server, which coordinates grading and restructuring tasks that are run in Docker containers. Docker provides a RESTful API which can be accessed through Ruby bindings, and it provides the application isolation that we specified in the second point of our desired structure. 

# Amazon S3
We use persistent storage in S3 to allow for indirect and secure file transfer between the webserver, worker server, and docker containers. We chose to use a web-based service due to its availability, fault tolerance, and security.

### Challenges 

Among the big issues that we contended against was the topological complexity of our database models. We decided early on that we had to have a single Users table, given that it makes authentication simpler and that users can have multiple roles (that is to say, a single user may be a TA for a course and a student in another course). Having three different many-to-many relations between the same pair of tables was difficult to write, and required many migrations.

### Moving Forward 

1. We would want to integrade Brandeis authentication and use database provided by Brandeis to update user information
2. Expand test languages other than Java, such as C++, Python, Ruby, etc
3. Allow TA to view codes directly on the webstie with text editor

### Support or Contact

Having trouble with Auto grader? [Contact support](sternj@brandeis.edu) and we’ll help you sort it out.
