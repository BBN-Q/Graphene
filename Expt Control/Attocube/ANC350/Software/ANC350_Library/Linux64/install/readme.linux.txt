Installation of Daisy and its libraries under Linux
========================================================================

1. The software is built for x86 systems; builds for 32 bit and 64 bit
   (AMD architecture) systems are available. It is linked against libc 2.19;
   binary compatibility  has been verified with different distributions
   / distribution families. There should be good chances to run the programs
   on distributions released not before 2015.

2. Besides the standard installation, the following software is required:
   - Qt4 Core, GUI, and OpenGL libraries
     (Ubuntu: packets libqtcore4, libqtgui4 libqt4-op)
   - libusb 1.0 (don't confuse with libusb 0.1) (Ubuntu: libusb-1.0-0)

3. Extract the directory tree to a place of your choice.
   E.g. /home/me/daisy .

4. Add nhands.rules from /home/me/daisy/install to the udev rules.
   (Ubuntu: copy to /etc/udev/rules.d, requires root privileges).
   The file installs a rule that grants access to nhands USB devices
   to every user.

5. Daisy et al. require a couple of shared libraries that reside in the
   program folder. The program loader must be enabled to find those libs.
   Using the start scripts "rundaisy" and "runflasher" instead of "daisy"
   and "nhflash" will do the job.

   To call the programs (or userlib applications) directly, the library
   path has to be published. This may be achieved

   a) temporarily: add the extra search path to your shell:
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/me/daisy
      Daisy only can be started by command from that shell window:
      /home/me/daisy/daisy &

   b) permanently: add the extra search path to the loader config.
      Ubuntu: create a file "daisy.conf" that contains just one line
      /home/me/daisy .
      Copy that file to /etc/ld.so.conf.d and call ldconfig for
      cache generation. Root privileges required.
      Daisy now can be started by command or file manager click.
      Note that daisy versions can't be installed in parallel this way
      because daisy's shared libs don't have real version management.

6. What has been said for Daisy also holds for programs developed
   on top of the libraries. Examples for such programs can be
   found under userlib/src or daisybase in the installation directory.

7. On some systems, Daisy is using a very large font leading to
   inappropriate screen space consumption. The program "qtconfig"
   (Ubuntu: packet qt4-qtconfig) can be used to customize the
   font size and other look-and-feel parameters.
