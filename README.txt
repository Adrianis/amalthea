Setting up

$ git clone https://github.com/palistov/amalthea
$ git config --global user.name "Your Name"
$ git config --global user.email youremail@place.com
$ git remote add default https://github.com/palistov/amalthea

Note that the email you use should be the same as your github account, if you want contributions to be shown there.


When you make a change
$ git commit -a -m "A short message about your change"
$ git push default master
$ <enter username and password when prompted>


To get recent changes from the remote repo
$ git pull default master
$ <enter username and password if prompted>