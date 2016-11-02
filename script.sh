#!/bin/sh
#
# Thank you Kevin Vicrey for his orignal work at https://github.com/Anomen/vagrant-selenium
# In order to modify the original Vagrant provisioning script file, we add git & build-essential 
# software package and "Install Node.js and Protractor" section
# 
#=========================================================

#=========================================================
echo "Install the packages..."
#=========================================================
sudo apt-get update
sudo apt-get -y install fluxbox xorg unzip vim default-jre rungetty firefox git build-essential

#=========================================================
echo "Set autologin for the Vagrant user..."
#=========================================================
sudo sed -i '$ d' /etc/init/tty1.conf
sudo echo "exec /sbin/rungetty --autologin vagrant tty1" >> /etc/init/tty1.conf

#=========================================================
echo -n "Start X on login..."
#=========================================================
PROFILE_STRING=$(cat <<EOF
if [ ! -e "/tmp/.X0-lock" ] ; then
    startx
fi
EOF
)
echo "${PROFILE_STRING}" >> .profile
echo "ok"

#=========================================================
echo "Download the latest chrome..."
#=========================================================
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo rm google-chrome-stable_current_amd64.deb
sudo apt-get install -y -f

#=========================================================
echo "Download latest selenium server..."
#=========================================================
SELENIUM_VERSION=$(curl "https://selenium-release.storage.googleapis.com/" | perl -n -e'/.*<Key>([^>]+selenium-server-standalone[^<]+)/ && print $1')
wget "https://selenium-release.storage.googleapis.com/${SELENIUM_VERSION}" -O selenium-server-standalone.jar
chown vagrant:vagrant selenium-server-standalone.jar

#=========================================================
echo "Download latest chrome driver..."
#=========================================================
CHROMEDRIVER_VERSION=$(curl "http://chromedriver.storage.googleapis.com/LATEST_RELEASE")
wget "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
sudo rm chromedriver_linux64.zip
chown vagrant:vagrant chromedriver

#=========================================================
echo -n "Install tmux scripts..."
#=========================================================
TMUX_SCRIPT=$(cat <<EOF
#!/bin/sh
tmux start-server
tmux new-session -d -s selenium
tmux send-keys -t selenium:0 './chromedriver' C-m
tmux new-session -d -s chrome-driver
tmux send-keys -t chrome-driver:0 'java -jar selenium-server-standalone.jar' C-m
EOF
)
echo "${TMUX_SCRIPT}"
echo "${TMUX_SCRIPT}" > startSelenium.sh
chmod +x startSelenium.sh
chown vagrant:vagrant startSelenium.sh
echo "ok"


#=========================================================
echo -n "Install startup scripts..."
#=========================================================
STARTUP_SCRIPT=$(cat <<EOF
#!/bin/sh
~/startSelenium.sh &
xterm &
echo 'Selenium started!'
EOF
)
echo "${STARTUP_SCRIPT}" > /etc/X11/Xsession.d/9999-common_start
chmod +x /etc/X11/Xsession.d/9999-common_start
echo "ok"

#=========================================================
echo -n "Add host alias..."
#=========================================================
echo "192.168.33.1 host" >> /etc/hosts
echo "ok"


#=========================================================
echo "Install Node.js and Protractor"
#=========================================================

NODEJS_VERSION=$(curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -)
sudo apt-get install -y nodejs
sudo npm install -g protractor

#=========================================================
echo "add webdriver-manager to the startup"
#=========================================================
touch /home/vagrant/.fluxbox/startup && cp -r /vagrant/fbstartup /home/vagrant/.fluxbox/startup

#=========================================================
echo "updating sudoers file to remove password prompt"
#=========================================================
cp -r /vagrant/newsudo /etc/sudoers

#=========================================================
echo "Reboot the VM"
#=========================================================

sudo shutdown -r now


