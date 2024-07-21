# duckdns
duckdns IP address updater

## Notes:
### duckdns.config
Will create duckdns.config in the same folder when it is run the first time into which you can enter your system's variables. Script will automatically set permissions to 600 for security. As such, make sure the first time it is run by the user whose cron will be running the task.
### directory
If not run in the home directory, not only the locations of the .log and .response files must be changed in the .config file, the location from which to load the config file must be updated in duckdns.sh
### suggested contab
(from duckdns.org):  */5 * * * * ~/duckdns.sh >/dev/null 2>&1

## Future items to implement
- [ ] add correct format of domain note to config
- [ ] add support for comma delineated list (supported by duckdns, just not this script)
- [ ] validate that domain and token are correct format
- [ ] specific commands to write to log if domain or token are missing or incorrect (send email?)
- [ ] set counter to limit error messages
  - [ ] don't send first error? (avoids temporary interruption)
  - [ ] only send a certain number of errors?
- [ ] clean log file periodically?
