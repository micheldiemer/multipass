multipass transfer "%~dp0.bash_aliases" dev:/home/ubuntu/.bash_aliases
multipass transfer "%~dp0.bash_functions" dev:/home/ubuntu/.bash_functions
multipass exec dev sudo chmod 770 /home/ubuntu/.bash_aliases /home/ubuntu/.bash_functions

@REM multipass exec dev sudo mkdir /etc/skel

@REM multipass exec dev sudo chown root:root /etc/skel
@REM multipass exec dev sudo chmod 644 root:root /etc/skel

@REM multipass exec dev sudo chown root:root /etc/skel/.bash_aliases /etc/skel/.bash_functions
@REM multipass exec dev sudo chmod 644 /etc/skel/.bash_aliases /etc/skel/.bash_functions
@REM multipass exec dev cp /etc/skel/.bash_functions /home/ubuntu/.bash_functions
@REM multipass exec dev cp /etc/skel/.bash_aliases /home/ubuntu/.bash_aliases
@REM multipass exec dev sudo chown ubuntu:ubuntu /home/ubuntu/.bash_*
@REM multipass exec dev sudo chmod 644 /home/ubuntu/.bash_*
