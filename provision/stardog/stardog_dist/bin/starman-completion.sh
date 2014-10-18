#!/bin/sh

# Copyright (c) 2013 - 2014 -- Clark & Parsia, LLC. <http://www.clarkparsia.com>
# For more information about licensing and copyright of this software, please contact
# inquiries@clarkparsia.com or visit http://stardog.com

# Installing Bash Auto Complete
#
# First you'll need to make sure you have bash-completion installed:
#
# Homebrew:
# $ brew install bash-completion
# Then add to your .bash_profile:
# if [ -f `brew --prefix`/etc/bash_completion ]; then
#. `brew --prefix`/etc/bash_completion
# fi
#
# MacPorts:
# $ sudo port install bash-completion
# Then add to your .bash_profile:
# if [ -f /opt/local/etc/bash_completion ]; then
#    . /opt/local/etc/bash_completion
# fi
#
# Ubuntu:
# $ sudo apt-get install bash-completion
# Fedora:
# $ sudo yum install bash-completion
#
# Then, place the script in your bash_completion.d folder, usually something like /etc/bash_completion.d,
# /usr/local/etc/bash_completion.d or ~/bash_completion.d. Or, copy it somewhere (e.g. ~/.stardog-completion.sh)
# and put the following in your .bash_profile:
#   source ~/.starman-completion.sh

_starman() {
        word="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # grab values for these from help directly
        cmds="help svm cluster version"
        cmds_no_help="svm cluster"
        cluster_cmds="deploy undeploy start stop addnodes removenodes copyfile list"
        svm_cmds="bootstrap remove install uninstall list"

        if [[ $prev == "svm" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$svm_cmds" -- "$word"))
        elif [[ $prev == "cluster" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cluster_cmds" -- "$word"))
        elif [[ $prev == "help" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds_no_help" -- "$word"))
        elif [[ $prev == *starman* ]] ;
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds" -- "$word"))
        fi
}

complete -o default -F _starman starman
