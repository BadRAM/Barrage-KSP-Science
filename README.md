# Barrage Multiplayer - Science Edition

## What is this?
This is a variant of [Barrage-Multiplayer](https://github.com/BadRAM/Barrage-Multiplayer), a bash script which automates sharing a KSP save between multiple computers and players. The Science Edition of Barrage has a special trick that lets it keep science experiments and tech tree progress separate between different players.

## How does it work?
Barrage is a script that automates save synchronization through a git repo. When you start the script, it downloads the latest state of the saved game and then locks the git repository in your name, so that nobody else can play. Once you're done, it uploads the changes you made and unlocks the repository. Science Edition performs an extra step of storing and retrieving science and tech tree progress in user specific .sci files.

## Client Setup Instructions:
1. Make sure you have git installed. If you are on windows, install git from [git-scm.com](https://git-scm.com/). The following instructions are intended to be followed in git for windows' git bash terminal, but should work in any bash environment with git installed.
2. Get the owner of the repo you're hosting your barrage game in to add you as a contributor, and make sure you're signed in to git in the terminal you're using.
3. At the top of this page, click "Code" and select "Download Zip" Extract Barrage-KSP-Science-main.zip to an appropriate new folder and navigate to it in git bash. run `sh barrage.sh`
4. Follow the script's instructions. It will ask for the clone link of the repo you were added to in step 2, as well as the path to your KSP save folder.
5. Once the setup is complete, you can run `sh barrage.sh` again to start a session. If everything's worked it should say "Save locked and loaded! you may now load the game." At this point you should be able to load and play the shared save from KSP. Remember to finish your session in barrage after you're done playing!

## Simulator
Simulator.sh will create a copy of the save that you can use to design craft, plan missions, or check in on other's progress without locking the save or making any changes.

## Host Setup Instructions:
1. Create a new git repository, copy savename.txt and .gitignore from your barrage folder into the repo and push.
2. Create a new science mode save in KSP, then move it into the repo.
3. In savename.txt, replace the example string with the filename of your save.
4. Commit and Push changes. You are now ready to run barrage first time setup. Follow the client setup instructions.