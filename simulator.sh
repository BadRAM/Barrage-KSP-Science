# This script generates a non locking copy of the save in your game folder. Useful for planning missions, or checking world progress without participating.

if [ ! -f "./local-settings.cfg" ]; then
	echo "local-settings.cfg missing! Please run barrage.sh and complete first time setup."
	exit 1
fi

source ./local-settings.cfg
cd data
source ./game-settings.cfg

git pull

# =========
# MAIN BODY
# =========

# Create USERNAME.sci if it doesn't exist yet
if [ ! -f "./${USERNAME}.sci" ]; then
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
echo "Extracted ${SCI} science from ${USERNAME}.sci. Updating persistent.loadmeta"
sed -i "/science/c\science = ${SCI}" "${SAVENAME}/persistent.loadmeta" #insert science preview number

# copy save into game
BAKNUM=1
until [ ! -f "${GAMEDIR}/${SAVENAME}-Simulator-${BAKNUM}/persistent.sfs" ]; do 
    let "BAKNUM++"
done
cp -Rr "./${SAVENAME}" "${GAMEDIR}/${SAVENAME}-Simulator-${BAKNUM}"

# Undo changes we made to persistent.sfs so pull goes cleanly next time.
git reset --hard 

echo ""
echo "Simulator Save Created!"