# dotfiles

# WSL Setup

Cascadia font install
```
choco install cascadiacodepl -y
```

Update WSL settings (Ctrl+,) for Ubuntu

```
"fontFace": "Cascadia Code PL"
```

## Install dotfiles and vim plugins

Clone the repo then run the symlink script
```
cd ~
git clone https://github.com/CJHarmath/dotfiles
cd dotfiles
chmod +x ./symlink.sh ./vim_setup.sh
./symlink.sh
./vim_setup.sh
```

