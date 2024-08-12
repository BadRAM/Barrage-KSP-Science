# Git based save game sharing script for succession games

if [ ! -f "./local-settings.cfg" ]; then
    echo "No local-settings.cfg detected, running first time setup."
    echo ""
    echo "Please enter your save repo URL. example: https://github.com/name/title.git"
    echo "Use right click to paste, as ctrl+v usually doesn't work in terminals"
    read -rp "> " REPOURL

    git clone $REPOURL data
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo ""
        echo "+============================================+"
        echo "| Error detected while cloning repo. Please  |"
        echo "| read git's error message above and resolve |"
        echo "| the issue before trying this script again. |"
        echo "+============================================+"
        exit $retVal
    fi

    echo ""
    echo "Please enter the full path to your game's saves folder. Example:"
    echo "C:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\saves"
    read -rp "> " GAMEDIR

    echo ""
    echo "Please enter your desired username."
    echo "If you want to share progress with another player, enter the same name as them."
    read -rp "> " USERNAME

    echo ""
	echo "generating local-settings.cfg..."
	printf '%s\n' "GAMEDIR=\"${GAMEDIR}\"" "USERNAME=\"${USERNAME}\"" > local-settings.cfg
	echo "setup complete. re-run this script to start playing."
	exit 1
fi

source ./local-settings.cfg
cd data
source ./game-settings.cfg

git pull

# Check for lockfile
if [ -f "./locked.txt" ]; then
	cat ./locked.txt
    exit 1
fi

# =========
# MAIN BODY
# =========

# Create USERNAME.sci if it doesn't exist yet
if [ ! -f "${USERNAME}.sci" ]; then
    cat sci.default > "${USERNAME}.sci"
    echo "${USERNAME}.sci not detected. Generating..."
fi

# insert USERNAME.sci into persistent.sfs
echo "inserting ${USERNAME}.sci into persistent.sfs..."
awk -v new_content="$(<"${USERNAME}.sci")" '
BEGIN {
    capture = 0
    depth = 0
    replacement_printed = 0
}
/name = ResearchAndDevelopment/ {
    capture = 1
    depth = 1
}
capture {
    if (/\{/) {
        depth++
    }
    if (/\}/) {
        depth--
    }
    if (depth == 0) {
        capture = 0
        if (!replacement_printed) {
            print new_content
            replacement_printed = 1
        }
    }
}
!capture {
    print
}
' "${SAVENAME}/persistent.sfs" > updated.sfs
mv -f updated.sfs "${SAVENAME}/persistent.sfs"
SCI=$(grep -m 1 -Po 'sci =\s*\K\d+' "${USERNAME}.sci") # Get science preview number
echo "Extracted ${SCI} science from ${USERNAME}.sci." # Updating persistent.loadmeta"
#sed -i "/science/c\science = ${SCI}" "${SAVENAME}/persistent.loadmeta" #insert science preview number

# create lockfile and push changes
echo "Savegame in use by ${USERNAME}" > locked.txt 
git add *
git commit -m "${USERNAME} Started session" && git push
 retVal=$?
if [ $retVal -ne 0 ]; then
    echo ""
    echo "+===========================================+"
	echo "| Error detected while pushing lock commit. |"
    echo "+===========================================+"
    exit $retVal
fi

# move save into game
until mv "./${SAVENAME}" "${GAMEDIR}"
do 
    read -p "File move failed! press enter to retry." 
done

# inform user and wait for end of session
echo ""
echo "Save locked and loaded! You may now load the game."
echo "When you've saved quit the game, write a short log of what you did and press enter."
read -rp "> " LOG
read -p "Confirm game is closed and press enter to push to git and unlock for the next player"

# move save back
until mv "${GAMEDIR}/${SAVENAME}" "./"
do 
    read -p "File move failed! press enter to retry." 
done

# Update USERNAME.sci
awk '
/name = ResearchAndDevelopment/ { 
    capture = 1
    depth = 1
}
capture {
    if (/\{/) {
        depth++
    }
    if (/\}/) {
        depth--
    }
    if (depth == 0) {
        capture = 0
    }
    else
    {
        print
    }
}
' "${SAVENAME}/persistent.sfs" > "${USERNAME}.sci"

# unlock
git rm ./locked.txt
# rm ./locked.txt

# commit changes
git add -A *
git commit -m "${USERNAME} Finished session - ${LOG}" && git push
retVal=$?
if [ $retVal -ne 0 ]; then
    echo ""
    echo "+=============================================+"
	echo "| Error detected while pushing unlock commit! |"
    echo "| If you can't fix it now, please inform the  |"
    echo "| repo owner, or it will be stuck locked.     |"
    echo "+=============================================+"
    exit $retVal
fi

echo ""
echo "Session Complete!"