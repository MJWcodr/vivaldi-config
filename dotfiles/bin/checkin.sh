#!/usr/bin/env nix-shell
#! nix-shell -p gum -i bash

# Style
GUM_INPUT_WIDTH=110
GUM_INPUT_HEIGHT=2

TIMEDATE=$(date +"%Y-%m-%d-%H-%M")
TIME=$(date +"%H:%M")
STIMMUNG_FOLDER="/home/matthias/Documents/Diary/10. Einträge/Stimmung/"
FILENAME="$STIMMUNG_FOLDER$TIMEDATE.md"

TEMPFILE=$(mktemp)

# Remove the first line of the file
trap "rm -f $TEMPFILE" EXIT

PROMPT="Wie geht es dir(0-10)"
HAPPINESS=$(gum input --placeholder "$PROMPT")

PROMPT="Wie viel Angst hast du(0-10)"
ANXIETY=$(gum input --placeholder "$PROMPT")

PROMPT="Wie viel Energie hast du (0-10)"
ENERGY=$(gum input --placeholder "$PROMPT")

PROMPT="Wie viel schlaf (in Stunden?)"
SLEEP_HOURS=$(gum input --placeholder "$PROMPT")

# PROMPT="Hattest du heute eine Panikattacke? (false/true)"
# PANIC=$(gum choose --header "$PROMPT" false true)

# PROMPT="Hast du dir gewünscht du wärst Tod?"
# WISH_OF_DEATH=$(gum choose --header "$PROMPT" false true)

PROMPT="Mögliche Tags"
TAGS=$(gum choose --no-limit "#Psyche/Panikattacke" "#Psyche/Todeswunsch" "#Drogen/Methylphenidat" "#Drogen/Alkohol")

PROMPT="Möchtest du noch etwas schreiben?"
TEXT=$(gum write --placeholder "$PROMPT")

# write file
echo "---" > $TEMPFILE
printf "\n" >> $TEMPFILE
echo "creation_date: $TIMEDATE" >> $TEMPFILE
echo "anxiety: $ANXIETY" >> $TEMPFILE
echo "happiness: $HAPPINESS" >> $TEMPFILE
echo "energy: $ENERGY" >> $TEMPFILE
echo "hours_of_sleep: $SLEEP_HOURS" >> $TEMPFILE

# Add Tags
TAGS=$(echo $TAGS | sed s/" "/"\", \""/g)
TAGS="\"$TAGS\""
echo "tags: [$TAGS]" >> $TEMPFILE

printf "\n" >> $TEMPFILE
echo "---" >> $TEMPFILE
printf "\n" >> $TEMPFILE
echo "# $TIME" >> $TEMPFILE
echo $TEXT >> $TEMPFILE

cat $TEMPFILE | gum format

YESNO="$(gum confirm && echo 'yes')"
echo $YESNO

# If yes then save the file to the diary
if [ "$YESNO" == "yes" ]; then
	touch "$FILENAME"
	gum format "Creating file $FILENAME"
	cp "$TEMPFILE" "$FILENAME"
fi

if [ "$YESNO" != "yes" ]; then
	 gum format "Abgebrochen"
fi
