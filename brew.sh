#!/usr/bin/env bash


################################################
bot "Setting up >Homebrew<"
################################################
promptSudo
running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  action "installing homebrew"
  xcode-select --install
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  if [[ $? != 0 ]]; then
    error "unable to install homebrew, script $0 abort!"
    exit -1
  fi
else
  echo -n "already installed "
fi
ok

# Make sure we’re using the latest Homebrew
running "updating homebrew"
brew update
ok

question "Upgrade any existing outdated packages? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    # Upgrade any already-installed formulae
    action "upgrade brew packages"
    brew upgrade
fi
ok
botdone


################################################
bot "Setting up >Git<"
################################################

running "Replacing personal info in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"
# test if gnu-sed or osx sed
sed -i 's/João Loff/'$firstname' '$lastname'/' .gitconfig > /dev/null 2>&1 | true
if [[ ${PIPESTATUS[0]} != 0 ]]; then
  sed -i '' 's/João Loff/'$firstname' '$lastname'/' .gitconfig;
  sed -i '' 's/jfloff@gmail.com/'$email'/' .gitconfig;
  sed -i '' 's/jfloff/'$githubuser'/' .gitconfig;
  sed -i '' 's/jfloff/'$(whoami)'/g' .zshrc;ok
else
  sed -i 's/jfloff@gmail.com/'$email'/' .gitconfig;
  sed -i 's/jfloff/'$githubuser'/' .gitconfig;
  sed -i 's/jfloff/'$(whoami)'/g' .zshrc;ok
fi

# ask sensible information
question "Please input your github command line token: " githubtoken

# build file
running "Creating your .gitconfig.local file with sensible information"
cat > .gitconfig.local <<EOL
[github]
  token = ${githubtoken}
EOL
ok

running "symlinking git dotfiles"; filler
pushd ~ > /dev/null 2>&1
symlinkifne .gitconfig
symlinkifne .gitignore
popd > /dev/null 2>&1
ok

running "installing git brews"; fille
# skip those GUI clients, git command-line all the way
require_brew git
# yes, yes, use git-flow, please :)
require_brew git-flow
# hub command line tools
require_brew hub
botdone

################################################
bot "Installing >homebrew command-line tools<"
################################################

# Install GNU core utilities (those that come with OS X are outdated)
require_brew coreutils --default-names
# Install some other useful utilities like `sponge`
require_brew moreutils --default-names
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
require_brew findutils --default-names
# Install GNU `sed`, overwriting the built-in `sed`
# so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
require_brew gnu-sed --default-names

# other tools per: http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
require_brew gnu-indent --with-default-names
require_brew gnutls --with-default-names
require_brew grep --with-default-names
require_brew gnu-tar --with-default-names
require_brew gnu-getopt --with-default-names
require_brew gawk

# was missing --default-name it might fix the points below
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# sudo rm /usr/local/bin/sha256sum
# sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install Bash 4
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
#install bash
#install bash-completion

# Install other useful binaries
require_brew ack
# dos2unix converts windows newlines to unix newlines
require_brew dos2unix
# better, more recent grep
require_brew homebrew/dupes/grep
# fortune command--I source this as a better motd :)
require_brew fortune
# jq is a JSON grep
require_brew jq
# better/more recent version of screen
require_brew tree
# better, more recent vim
require_brew vim --override-system-vi
require_brew watch
# Install wget with IRI support
require_brew wget --with-iri
require_brew rename
# Record terminal to share: https://asciinema.org/
require_brew asciinema

botdone
