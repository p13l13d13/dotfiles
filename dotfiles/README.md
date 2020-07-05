### Way to setup 

    '''
    git init --bare $HOME/.dotfiles
    alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    config config status.showUntrackedFiles no
    '''

### Update workflow

'''
    config status
    config add .vimrc
    config commit -m "Add vimrc"
    config add .config/redshift.conf
    config commit -m "Add redshift config"
    config push
'''

### Load on a new machine

'''
    git clone --separate-git-dir=$HOME/.dotfiles /path/to/repo $HOME/dotfilestmp
    cp ~/dotfilestmp ~  
    rm -r ~/dotfilestmp/
    alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
'''
