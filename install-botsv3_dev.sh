#! /usr/bin/env bash

# Enter your default Splunk administrative credentials below

username=splunk
password=splunksplunk
splunk_home=/opt/splunk

# Loop through all the Splunk Apps within the present working directory, and install them to Splunk

for f in *.tgz;
do $splunk_home/bin/splunk install app $f  -auth "$username:$password";
done

# Install the CTF Scoreboard

cd /opt/splunk/etc/apps
git clone https://github.com/splunk/SA-ctf_scoreboard
git clone https://github.com/splunk/SA-ctf_scoreboard_admin
mkdir /opt/splunk/var/log/scoreboard

# Downloads the Splunk dataset and extracts it to the appropriate directory

echo "[$(date +%H:%M:%S)]: Downloading Splunk BOTSv3 Attack Only Dataset..."
wget --progress=bar:force -P /opt/ https://botsdataset.s3.amazonaws.com/botsv3/botsv3_data_set.tgz
echo "[$(date +%H:%M:%S)]: Download Complete."
echo "[$(date +%H:%M:%S)]: Extracting to Splunk Apps directory"
tar zxvf /opt/botsv3_data_set.tgz -C /opt/splunk/etc/apps/

echo "[$(date +%H:%M:%S)]: Restarting Splunk..."
/opt/splunk/bin/splunk restart

# Create the Splunk Answers service account, and give it the appropriate role

printf "\nCreate new Answers Service Account\n"
read -p "CTF Answers Service username: " ctf_answers_username
read -sp "CTF Answers password: " ctf_answers_password

$splunk_home/bin/splunk add user $ctf_answers_username -password $ctf_answers_password -role ctf_answers_service -auth "$username:$password"

# Echo the credentials for the Splunk Answers Service account in the Scoreboard Controller conf file
cp /opt/splunk/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config.example /opt/splunk/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config

printf "[ScoreboardController]\nUSER = $ctf_answers_username\nPASS = $ctf_answers_password\nVKEY = Gl9uy4HXxt3Ym2z558XS\n" > $splunk_home/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config

# Create the CTF Admin account
printf "\nCreate new Admin Account for CTF\n"
read -p "CTF Admin username: " ctf_admin_username
read -sp "CTF Admin password: " ctf_admin_password

$splunk_home/bin/splunk add user $ctf_admin_username -password $ctf_admin_password -role ctf_admin -role can_delete -auth "$username:$password"

# Create the CTF Competitor Account
printf "\nCreate competitor account\n"
read -p "CTF Competitor username: " ctf_competitor_username
read -sp "CTF Competitor password: " ctf_competitor_password

$splunk_home/bin/splunk add user $ctf_competitor_username -password $ctf_competitor_password -role ctf_competitor -auth "$username:$password"

echo "BOTSv3 Installation complete!"
