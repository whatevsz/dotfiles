echo "update" >> ~/test.log
kill -SIGUSR1 $(cat $LOGDIR/i3/conky.pid)