#!/bin/sh

# Installing Bash Auto Complete
#
# First you'll need to make sure you have bash-completion installed:
#
# Homebrew:
#	$ brew install bash-completion
#	Then add to your .bash_profile:
#	if [ -f `brew --prefix`/etc/bash_completion ]; then
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
#	$ sudo apt-get install bash-completion
# Fedora:
#	$ sudo yum install bash-completion
#
# Then, place the script in your bash_completion.d folder, usually something like /etc/bash_completion.d, /usr/local/etc/bash_completion.d or ~/bash_completion.d.
# Or, copy it somewhere (e.g. ~/.stardog-completion.sh) and put the following in your .bash_profile::
#
# source ~/.stardog-completion.sh

_stardog() {
        word="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

		# grab values for these from help directly
        cmds="data help namespace query reasoning version icv"
        cmds_no_help="data namespace query reasoning version icv"
        ns_cmds="add list remove"
        icv_cmds="convert validate export"
        inf_cmds="consistent explain"
        data_cmds="add remove size export obfuscate"
        query_cmds="execute search status explain obfuscate"
        
        if [[ $prev == "namespace" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$ns_cmds" -- "$word"))
        elif [[ $prev == "reasoning" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$inf_cmds" -- "$word"))
        elif [[ $prev == "help" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds_no_help" -- "$word"))
        elif [[ $prev == "data" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$data_cmds" -- "$word"))
        elif [[ $prev == "query" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$query_cmds" -- "$word"))
        elif [[ $prev == "icv" ]]
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$icv_cmds" -- "$word"))
        elif [[ $prev == *stardog* ]] ;
        then
                COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds" -- "$word"))
        fi
}

_stardog_admin() {
        word="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        isUser=0
        isRole=0
        c=1
        while [ $c -lt $COMP_CWORD ]; do
        	curr="${COMP_WORDS[c]}"
            case "$curr" in
				user) isUser=1 ;;
            esac
            c=$((++c))
        done

		# grab values for these from help directly
        cmds="db help metadata role server user version icv query cluster"
        cmds_no_help="db metadata role server user version icv query cluster"
        user_cmds="add addrole disable enable grant list passwd permission remove removerole revoke"
        role_cmds="add grant list permission remove revoke"
        server_cmds="start status stop"
        server_cmds="start stop status"
        meta_cmds="get set"
        icv_cmds="add remove drop"
        db_cmds="backup copy create drop list migrate optimize online offline restore status"
        query_cmds="kill list status"
        cluster_cmds="info proxystart zkstart"

        if [[ $prev == "user" ]]
        then
        	COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$user_cmds" -- "$word"))
        elif [[ $prev == "help" ]]
        then
            COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds_no_help" -- "$word"))
		elif [[ $prev == "role" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$role_cmds" -- "$word"))
		elif [[ $prev == "db" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$db_cmds" -- "$word"))
		elif [[ $prev == "server" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$server_cmds" -- "$word"))
		elif [[ $prev == "metadata" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$meta_cmds" -- "$word"))
        elif [[ $prev == "query" ]]
        then
            COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$query_cmds" -- "$word"))
		elif [[ $prev == "icv" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$icv_cmds" -- "$word"))
		elif [[ $prev == "cluster" ]]
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cluster_cmds" -- "$word"))
		elif [[ $prev == *stardog-admin* ]] ;
		then
			COMPREPLY=(${COMPREPLY[@]:-} $(compgen -W "$cmds" -- "$word"))
		fi
}

complete -o default -F _stardog stardog
complete -o default -F _stardog_admin stardog-admin
