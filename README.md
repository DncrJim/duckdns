# duckdns
duckdns IP address updater


Notes:
Will create duckdns.config in the same folder when it is run the first time. This is a template which can be filled in with variables, and should be set to 600 so that it is visible only to that user. As such, make sure the first time it is run by the user whose cron will be running the task.
duckdns.sh should be set to 700
If not run in the home directory, the location from which to load the config file must be updated
text for crontab (from duckdns.org):  */5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1


Future items to implement

add correct format of domain note to config
validate that domain and token are correct format
write to log if domain or token are missing or incorrect (send email?)
don't send error message on first error?
only send so many error messages?
clean log file periodically?
