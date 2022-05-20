# Personal Website

My personal website


- Built using [Hugo](https://gohugo.io/), using the `hugo-coder` theme, with header inspiration from `hugo-theme-nix`.
- Deployed using Github Pages and Github Actions.
- Aliased to [grohan.co](https://grohan.co).
- `resume.pdf` synced between local fs and remote repository using `rsync` and `crontab`. Every $N$ minutes, the filesystem syncs the latest version of my resume to the local repository, and if different then pushes it to git.
