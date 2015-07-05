### Overview

This is a collection of my global dotfiles which remain same across my different machines. Rather than overriding the existing dotfiles files in the machine, it creates references in the existing dotfiles to these global files.

### Requirements

* [Ansible] is used to to setup the files

### Installation

Clone the repo and run the ansible playbook::

      git clone https://github.com/sharjeel/dotfiles.git
      cd dotfiles
      ansible-playbook -i hosts ansible-dotfiles.yml

Since Ansible is not supported on Windows, included install.py script may be used on Windows

      install.py emacs


  [ansible]: http://www.ansibleworks.com/docs/gettingstarted.html
