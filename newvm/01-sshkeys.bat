multipass transfer c:\Users\Michel\.ssh\id_ed25519_dev.pub dev:/tmp/x
multipass exec dev -- sh -c "cat /tmp/x >> ~/.ssh/authorized_keys && rm /tmp/x"
