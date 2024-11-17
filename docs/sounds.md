# Terminal Sound Effects

---

My zsh configuration has several aliases and wrapper functions that essentially wrap commands such that they play a sound effect when
invoked. The sound effects are from Earthbound, and are stored in `assets/sound`. Notable examples include `ls` and `cd` which
both play a sound when invoked, among some of the other common utilities, for both GNU and NixOS. If you wish to disable these sound
effects, you can do so by changing the `SOUNDS_ENABLED` environment variable defined in `modules/home/environment/zsh/env.nix` from `true` to `false`.

---

The aliases and commands which use sound effects are:

- `grimblast`
	- Uses: `assets/sound/screenshot.wav`

- `ls`
	- Uses: `assets/sound/ls.wav`

- `cd`
	- Uses: `assets/sound/cd.wav`

- `gcomm (alias for 'git commit')`
	- Uses: `assets/sound/gitcommit.wav`

- `gpush (alias for 'git push')`
	- Uses: `assets/sound/`

- `gpull (alias for 'git pull')`
	- Uses: `assets/sound/gitpull.wav`

- `greb (alias for 'git rebase')`
	- Uses: `assets/sound/gitrebase.wav`

- `ga (alias for 'git add')`
	- Uses: `assets/sound/gitadd.wav`

- `gtp (alias for 'gtrash put')`
	- Uses:  `assets/sound/rm.wav`

- `rebuild`
	- Uses: `assets/sound/update.wav` or `assets/sound/error.wav`
