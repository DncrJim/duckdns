#!/bin/bash


## script to be run as cron job to update duckdns.org DNS server IP addresses in bash
# evolution of https://github.com/DncrJim/GDomains_DDNS (since google domains service ended)

##### load or create duckdns.config

#create config file if it doesn't exist
if [ ! -f "duckdns.config" ] ; then
  echo "Subdomain='subdomain'  #do not include duckdns.org, just the subdomain. can be comma separated (no spaces) list of domains for duckdns command, but script does not fully support" > duckdns.config
  echo "Token=''" >> duckdns.config
  echo "Email=root #will only work if an email server is set up, can be user name or email address" >> duckdns.config
  echo "NewIP=''" >> duckdns.config
  echo "" >> duckdns.config
  echo "EmailonMatches=0  #Email if script finds that current IP and Subdomain IP already match. 0=no 1=yes" >> duckdns.config
  echo "EmailonSuccess=1  #Email if script tries to change IP and API says good. 0=no 1=yes" >> duckdns.config
  echo "EmailonFailure=1  #Email if script tries to change IP and API says anything other than good. 0=no 1=yes" >> duckdns.config
  echo "" >> duckdns.config
  echo "Logfile=~/duckdns.log #no quotes or spaces" >> duckdns.config
  echo "Responsefile=~/duckdns.response #no quotes or spaces" >> duckdns.config
  echo "Failures=0" >> duckdns.config
  echo ""
  echo "duckdns.config created, please open the file, insert the values for all variables and run again."
  echo ""
  #set ownership of created file to chmod 600
  chmod 600 duckdns.config
 exit 0
fi

#load config file variables - if not run in home directory, must update location
   . ~/duckdns.config

#Stop emails from sending if no email has been provided.
if [[ -z $Email ]]; then EmailonMatches=0 ; EmailonSuccess=0 ; EmailonFailure=0 ; fi

#Verify Domain and Username are not blank, if they are exit. Does not check if entry is valid.
if [[ -z $Subdomain ]]; then echo "Subdomain not provided"; exit 1; fi
if [[ -z $Token ]]; then echo "Token not provided"; exit 1; fi


##### Pull local IP

#If a new IP is not provided, Pull WAN IP from the network interface. Should work if appliance is directly connected or through router.
if [[ -z $NewIP ]]; then NewIP=$(wget -qO - icanhazip.com); fi
      #2nd option, seems to have stopped working 2020.08.30
      #if [[ -z $NewIP ]]; then NewIP=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}'); fi


  #exit and email error if new IP is still blank
      if [[ -z $NewIP ]]; then echo "DDNS for $Subomain was not able to automatically resolve the WAN IP and none was provided." | mail -s "DDNS for $Subdomain Update ::ERROR::" "$Email"
              exit; fi


##### Pull duckdns IP
DuckIP=$(host "www.$Subdomain.duckdns.org" | awk '/has address/ { print $4 ; exit ; }')
      #2nd option if first one doesn't work
      #DuckIP=$(nslookup $Subdomain | awk 'FNR ==5 {print$3}')


    #exit and email error if Subdomain IP is still blank
      if [[ -z $DuckIP ]]; then
        echo "$(date "+%Y.%m.%d %H:%M:%S") DDNS for $Subdomain was not able to resolve the current Subdomain IP." >> "$Logfile"
        echo "DDNS for $Subdomain was not able to resolve the current Subdomain IP." | mail -s "DDNS for $Subdomain Update ::ERROR::" "$Email"
        exit
      fi

##### Test if IPs the same, update if not, send emails as necessary


#If WAN IP and Subdomain IP are the same, log, optionally send email, and exit
if [[ "$NewIP" == "$DuckIP" ]]; then
        echo "$(date "+%Y.%m.%d %H:%M:%S") WAN IP ($NewIP) unchanged, not updated" >> "$Logfile"
        if [[ $EmailonMatches == 1 ]]; then
          echo "DDNS for $Subdomain was tested and is up to date at $NewIP" | mail -s "DDNS for $Subdomain Update Unnecessary" "$Email"
        fi
else
        #If WAN IP and Subdomain IP don't match, send request to update, save response as Response

        echo url="https://www.duckdns.org/update?domains=$Subdomain&token=$Token&ip=" | curl -k -o "$Responsefile" -K -
          #save output as variable
          Response=$(<"$Responsefile")
          #delete response file
          rm "$Responsefile"

        #If response includes correct new IP with the 'OK' response, log, optionally send email, exit
      if [[ "$Response" == "OK" ]]; then
          echo "$(date "+%Y.%m.%d %H:%M:%S") DDNS for $Subdomain successfully updated from $DuckIP to $NewIP" >> "$Logfile"
          if [[ $EmailonSuccess == 1 ]]; then
          echo "DDNS for $Subdomain succeessfully from $DuckIP to $NewIP" | mail -s "DDNS for $Subdomain Update Successful" "$Email"
          fi

        #If response is KO (failure response), log, optionally send email, and exit.
      else
          echo "$(date "+%Y.%m.%d %H:%M:%S") DDNS for $Subdomain ERROR ***  - old IP: $DuckIP new IP: $NewIP" >> "$Logfile"
          if [[ $EmailonFailure == 1 ]]; then
          echo "DDNS for $Subdomain failed to update from $DuckIP to $NewIP." | mail -s "DDNS for $Subdomain Update ::ERROR::" "$Email"
          fi
      fi
fi

exit
