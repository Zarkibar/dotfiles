# Setting Up Gitub and SSH Authentication
First set username and email
```bash
git config --global user.email <email>
git config --global user.name <username>
```

Then generate an ssh key. (Make sure to add this new ssh key into github ssh)
```bash
mkdir "$HOME/.ssh"
ssh-keygen -t ed25519 -C "<email>"
```

Make a ~/.ssh/config directory and write the following code there
```bash
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/github_key
```

Now add this bit of commands in ~/.bashrc
```bash
eval "$(ssh-agent -s)" &>/dev/null
ssh-add ~/.ssh/github_key &>/dev/null
```

now restart your terminal and do a ```ssh -T git@github.com``` to test if it's working

# Potential issues
### If you cloned a repository and is now having trouble pushing it even if your ssh key is working...

Try ```git remote -v``` and if you see `https://github.com/USER/REPO.git` instead of `git@github.com:USER/REPO.git` that means you simply need to convert the https link into an shh link. Do it by the command below.

```git remote set-url origin git@github.com:USER/REPO.git```
