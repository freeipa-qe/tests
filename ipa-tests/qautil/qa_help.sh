#/bin/sh

readnotes(){
  NOTEDIR=$IPA_TESTS/qautil/qanotes/
  if [ -d $NOTEDIR ]; then
	NOTE_FILE=$NOTEDIR/`hostname`.notes
	if [ -f $NOTE_FILE ]; then
		echo "Notes about host `hostname` is below"
		echo "===================================="
		echo ""
		cat < $NOTE_FILE
		echo ""
		echo "========== END OF NOTES ============"
		echo ""
	else
		echo "No host specific notes found"
	fi
	NOTE_FORALL=$NOTEDIR/forall.notes
        if [ -f $NOTE_FORALL ]; then
                echo "Global Notes is below"
                echo "===================================="
                cat < $NOTE_FORALL
		echo ""
		echo "========== END OF NOTES ============"
		echo ""
        fi

  else
	echo "No [$NOTEDIR] exist, please check if you have IPA_TESTS setup"
  fi
}

readnotes

