# Personal Website

My personal website

- Built using [Hugo](https://gohugo.io/), using the `lines` theme as a base.
- Deployed using Github Pages and Github Actions.
- Aliased to [grohan.co](https://grohan.co).

## Syncing

`resume.pdf` is periodically synced between my local filesystem and remote repository using `rsync` and `launchd`.

Use the shell script in `ressync.sh` to run these syncs. `cronjob` is deprecated for MacOS, so use `launchd`. If the system is asleep during the scheduled interval, `launchd` also has the added benefit of running a script on next wake. This is particularly useful since I run this on my personal laptop.

Setting up launchd was an unfortunate experience. For posterity, here are the steps I went through:

- Make the desired script executable using `chmod 744 ressync.sh`. It is important to use absolute paths, since the script is executed from the root directory.
- Write a `.plist` file in user space `~/Library/LaunchAgents/`. This is copied over to `./com.rohangupta.ressync.plist`; the format should work in general (again, use absolute paths). The Label field must match the `.plist` file's name.
- Run `csrutil status`. If SIP is enabled, reboot Mac into recovery mode, launch a terminal and run `csrutil disable; reboot`. This is required to allow the agent to launch your "unauthorized" script using your shell stored in `/bin/`, without complaining.
- Now, run the following

```shell

pname=<YOUR PLIST FILE NAME>
f=~/Library/LaunchAgents/$pname.plist
launchctl load -w $f
launchctl start $pname
launchctl list | grep $pname
```

If the process has code 0, then everything is good. Otherwise, try the following debugging steps:

- Install the GUI software LaunchControl
- Open Console on Mac and grep `$pname` logs in `launchd.log`

When you make changes, run

`launchctl unload -w $f launchctl load -w $f`
