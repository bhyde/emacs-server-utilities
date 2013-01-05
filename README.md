emacs-server-utilities
======================

Using a emac-server via multiple X11 heads is a pain.  Scripts to make
it easier, and a hack for display tracking.

Some people, me included, like to run emacs as a daemon.  Then when
we want to edit a file we connect to that daemon.  It's nice to be
able to quickly get a fully fleshed out emacs.  It's nice to be able
to close all your emacs windows, and not lose that state.

Three Scripts
=============
So we have three scripts here.
 frame-on-emacs-server
 assure-we-have-an-emacs-server  -- rarely called directly
 bless-emacs-server-with-xauthority -- even more rarely called directly

Bless-emacs-server-with-xauthority is the only clever bit.  It is used
(internally) to change the xauthority of the emacs server so it will
be able to open x windows on the current display.  This is necessary
if you trying to get a window on the emacs server from an ssh session
(one that has includes X11Forarding).  Generally you don't need to
call this, the other scripts will see to it.

Assure-we-have-an-emacs-server does what it says on the tin.  You
might call in when your machine starts up; or when you login.  But the
only it's probably not worth the bother.  You can wait and let the
next routine to if for you later.  It does nothing if you already have
a running emacs server.  Otherwise it starts one under nohup and puts
any output it generates into ~/.emacs-server.log.  That's were you
will find reports of what went wrong in your init file, and other
complaints that emacs may have.  At least initially you should have a
look at that.

Frame-on-emacs-server is the primary entry point.  Called with no args
it will return immediately and a new frame should appear on your
$DISPLAY.  If called with <args> it behaves as emacsclient -c <args>.
that makes it suitable for using as your EDITOR enviroment setting.
Frame-on-emacs-server calls assure-we-have-an-emacs-server and
bless-emacs-server-with-xauthority as needed.

I have ~/bin at the front of my PATH, and I have ~/bin/emacs symbolically
linked to frame-on-emacs-server.

Display Tracking
================

Note that your emacs server does not have any idea what DISPLAY your
on.  In fact DISPLAY is unset to start.  Which is a pain if you want
to launch an application (xterm or gnuplot for example) from inside
Emacs.  Two things make fixing this painful.

Frames know what display they are on, see (frame-parameter nil 'display).
But buffers can be displayed on multiple frames.  In theory you might
be able to force the DISPLAY environment setting in the dynamic extent
of individual interactive commands and this is what the code in 
display-tracking.el does; by placing advise around the three functions
that create subprocesses.  You'll want to byte compile and then load
that in your init file.

Even if you manage to juggle the emacs' enviroment so DISPLAY follows
the interaction that won'd help with process buffers and their
associated modes such as shell, R, etc. etc.  If you create a shell
while on one machine it's DISPLAY won't change when you access it
from another machine.

Dynamically modifying thier environments would require case by case 
schemes.  See the command synch-display in display-tracking.el for
a lame shell-mode example.

If display-tracking.el frightens you, and that might be approrpate
the global default for DISPLAY from time to time.
  (setenv "DISPLAY" (frame-parameter nil 'display))



