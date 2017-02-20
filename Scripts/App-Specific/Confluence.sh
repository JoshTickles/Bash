#!/bin/bash
# Confluence Linux service controller script - An easy to use companion for your confluence server. 

# JA -2016
# Usage - sudo sh /home/confluence/confluence.sh 'command"
# Example - sudo sh ./confluence.sh restart

# Install location
cd "/opt/atlassian/confluence/bin"
# add case
case "$1" in
    start)
        ./start-confluence.sh ;;
    stop)
        ./stop-confluence.sh ;;
    restart)
        ./stop-confluence.sh
        sleep 10
        ./start-confluence.sh ;;
    status)
        PID=`ps aux | grep java | grep confluence | awk '{print $2}'`
        if test -z $PID
        then
        echo "Confluence is down..."
        else
        echo "Confluence is running... PID $PID"
        fi ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
