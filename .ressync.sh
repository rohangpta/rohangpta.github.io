local=~/Documents/Rohan_Gupta_Resume.pdf
remote=~/Desktop/Developer/rohan-site/static/resume.pdf
repo=~/Desktop/Developer/rohan-site/
logfile=~/Desktop/.ressync.txt
now=$(TZ=America/New_York date)

cd $repo
git pull -q
if [[ $? -ne 0 ]]
then
cd ~/Desktop
echo "$now: Life is not good" >> $logfile
exit 1
fi

if [[ $(diff $local $remote) ]]
then
    cd ~
    rsync -aE $local $remote
    cd $repo
    git add static/resume.pdf
    git commit -m "Automatically updated resume as of $now"
    git push --quiet -u origin main
    echo "$now: Updates made" >> $logfile
    exit 0
else
    echo "$now: No updates made" >> $logfile
    exit 0
fi