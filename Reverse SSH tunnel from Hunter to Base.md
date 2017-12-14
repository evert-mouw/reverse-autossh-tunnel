# Reverse SSH tunnel from Hunter to Base

This is my method to keep connected with a remote Raspberry Pi that has a static external IP address and lives behind a NAT, where I don't have control over the router (so no port forwarding). For your use case, you might want to choose another method (there are plenty on the world wide web, I'm sure you can find them), but the simple method below works for me.

## on Base

Create a new user with `adduser tunnel`

	user tunnel
	pass SomeComplicatedPass

You need a modification to `sshd_config`. At the end of the file, add a Match block to prevent password-based logins (only allow keybased logins for user tunnel) so the password above is of little use to the outside world ;-)

	# Match blocks must be at the and of this config file, see:
	# http://unix.stackexchange.com/questions/67334/openssh-how-to-end-a-match-block
	Match User tunnel
		PasswordAuthentication no

## on Hunter

Login to Hunter. I assume *evert* as your username on Hunter :)

Create the reverse tunnel using:

	ssh -N -R 2222:localhost:22 tunnel@Base

Or, more sophisticated:

	autossh -M 0 -q -f -N \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o "ServerAliveInterval 60" \
	-o "ServerAliveCountMax 3" \
	-R 2222:localhost:22 \
	tunnel@Base

This can be done best by doing it from cron and with a script.

	crontab -e
	@reboot /home/evert/tunnel.sh 60

My script is named `tunnel.sh` and has a few more tricks you might like ;)  so *I suggest you have a look at the complete script*.

## Usage

First login to Base, then connect to Hunter using:

	ssh evert@Base
	ssh localhost -p 2222

And from there, you can play with Hunter.

Have fun!

Evert, 2015-12-27, updated 2017-12-14
