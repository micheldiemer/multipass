multipass transfer "%USERPROFILE%\.gitignore_global" dev:/home/ubuntu/.gitignore_global
multipass exec dev sudo chmod 664 /home/ubuntu/.gitignore_global

multipass transfer "%~dp0.vimrc" dev:/home/ubuntu/.vimrc
multipass exec dev sudo chmod 664 dev:/home/ubuntu/.vimrc

multipass transfer "%~dp008-git.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 777 /tmp/x.sh
multipass exec dev /tmp/x.sh
multipass exec dev sudo rm /tmp/x.sh