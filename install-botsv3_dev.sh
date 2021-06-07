#! /usr/bin/env bash

# Enter your default Splunk administrative credentials below
printf "\nTo proceed with the install please provide your Splunk admin username and password\n"
read -p "Splunk admin Username: " splunk_user
read -sp "Splunk admin Password: " splunk_password
splunk_home=/opt/splunk

# Install all the associated BOTS Apps

$splunk_home/bin/splunk install app botsapps/SA-cim_vladiator-master.zip -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/add-on-for-microsoft-sysmon_800.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/amazon-guardduty-add-on-for-splunk_104.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/cisco-anyconnect-network-visibility-module-nvm-app-for-splunk_218.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/code42-for-splunk_3012.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/decrypt_20.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/lookup-file-editor_331.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/microsoft-365-app-for-splunk_301.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/microsoft-azure-add-on-for-splunk_202.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/microsoft-office-365-reporting-add-on-for-splunk_124.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/osquery-app-for-splunk_060.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/parallel-coordinates-custom-visualization_140.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/simple-timeseries-custom-visualization_10.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-amazon-web-services_500.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-cisco-asa_340.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-microsoft-cloud-services_401.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-microsoft-office-365_201.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-microsoft-windows_700.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-symantec-endpoint-protection_301.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-tenable_514.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-add-on-for-unix-and-linux_701.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-common-information-model-cim_4150.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-es-content-update_1052.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-timeline-custom-visualization_140.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/ta-for-code42-app-for-splunk_3012.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/url-toolbox_18.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/virustotal-workflow-actions-for-splunk_020.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-security-essentials_306.tgz -auth "$splunk_user:$splunk_password"
$splunk_home/bin/splunk install app botsapps/splunk-stream_720.tgz -auth "$splunk_user:$splunk_password"

# Install the CTF Scoreboard

cd $splunk_home/etc/apps
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

printf "\nCreate a new Answers Service Account for BOTS\n"
read -p "CTF Answers Service username: " ctf_answers_username
read -sp "CTF Answers password: " ctf_answers_password

$splunk_home/bin/splunk add user $ctf_answers_username -password $ctf_answers_password -role ctf_answers_service -auth "$splunk_user:$splunk_password"

# Echo the credentials for the Splunk Answers Service account in the Scoreboard Controller conf file
cp $splunk_home/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config.example /opt/splunk/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config

printf "[ScoreboardController]\nUSER = $ctf_answers_username\nPASS = $ctf_answers_password\nVKEY = Gl9uy4HXxt3Ym2z558XS\n" > $splunk_home/etc/apps/SA-ctf_scoreboard/appserver/controllers/scoreboard_controller.config

# Create the CTF Admin account
printf "\nCreate new Admin Account for BOTS\n"
read -p "CTF Admin username: " ctf_admin_username
read -sp "CTF Admin password: " ctf_admin_password

$splunk_home/bin/splunk add user $ctf_admin_username -password $ctf_admin_password -role ctf_admin -role can_delete -auth "$splunk_user:$splunk_password"

# Create the CTF Competitor Account
printf "\nCreate competitor account for BOTS\n"
read -p "CTF Competitor username: " ctf_competitor_username
read -sp "CTF Competitor password: " ctf_competitor_password

$splunk_home/bin/splunk add user $ctf_competitor_username -password $ctf_competitor_password -role ctf_competitor -auth "$splunk_user:$splunk_password"

echo "BOTSv3 Installation complete!"
echo "New BOTS admin account: ctf_admin_username"
echo "New competitor account: $ctf_competitor_username"
