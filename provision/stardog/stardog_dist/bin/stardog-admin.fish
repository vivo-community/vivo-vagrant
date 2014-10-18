#
# Fish completion scripts go in your ~/.config/fish/completions directory.
# Alternatively, they can be located in /etc/fish/completions or /usr/share/fish/completions, both of which
# are subject to the configuration used for the fish shell installation.
#

function __fish_stardog_admin_using_command
  set cmd (commandline -opc)
  set subcommands $argv
  if [ (count $cmd) = (math (count $subcommands) + 1) ]
    for i in (seq (count $subcommands))
      if not test $subcommands[$i] = $cmd[(math $i + 1)]
        return 1
      end
    end
    return 0
  end
  return 1
end

function __fish_stardog_admin_needs_command
  set cmd (commandline -opc)
  set foo (echo "$cmd[1]" | grep  -E 'stardog-admin$')
  if [ (count $cmd) -eq 1 -a $cmd[1] = $foo ]
    return 0
  end
  return 1
end

function __bind_user_pw_options
  __bind_option $argv u username 		"Specify the user for running the command"
  __bind_option $argv p passwd 			"Specify the user's password for running the command"
  __bind_option $argv P ask-password 	"Prompt for the user's password"
end

function __bind_option
  complete --no-files -c stardog-admin -s $argv[2] -l $argv[3] -n "__fish_stardog_admin_using_command $argv[1]" -d $argv[4]
end

function __bind_server_option
  complete --no-files -c stardog-admin -l server -n "__fish_stardog_admin_using_command $argv" -d "Specify the URL of the server"
end

function __bind_sub_cmd_help
  complete --no-files -c stardog-admin -a $argv[2] -n "__fish_stardog_admin_using_command help $argv[1]" -d $argv[3]
end

function __bind_cmd_help
  complete --no-files -c stardog-admin -a $argv[1] -n "__fish_stardog_admin_using_command help" -d $argv[2]
end

function __bind_cmd
  complete --no-files -c stardog-admin -a $argv[1] -n "__fish_stardog_admin_needs_command" -d $argv[2]
end

function __bind_sub_cmd
  complete --no-files -c stardog-admin -a $argv[2] -n "__fish_stardog_admin_using_command $argv[1]" -d $argv[3]
end

function __bind_sub_cmd_long_option
  complete --no-files -c stardog-admin -l $argv[2] -n "__fish_stardog_admin_using_command $argv[1]" -d $argv[3]
end

#function __bind_global_long_option
#  complete --no-files -c stardog-admin -l $argv[1] -n "" -d $argv[2]
#end

########################################################

# db commands
__bind_cmd db "Commands for working with databases"

# copy
__bind_sub_cmd db copy "Copy an existing database"
__bind_user_pw_options	"db copy"
__bind_server_option   	"db copy"
__bind_option "db copy" c copy-to "The name of the new database"

# create
__bind_sub_cmd db create "Create a new database"
__bind_user_pw_options	"db create"
__bind_server_option   	"db create"

__bind_option "db create" c config 				"Database Configuration file"
__bind_option "db create" d durable 			"Enable durable transactions"
__bind_option "db create" i index-triples-only 	"Enable triples-only indexes"
__bind_option "db create" n name 				"Specify the name of the new database"
__bind_option "db create" o options				"Specify database configuration options"
__bind_option "db create" s searchable 			"Enable full-text indexing"
__bind_option "db create" c config 				"Database Configuration file"
__bind_option "db create" t type 				"Specify the type of the database"

# drop
__bind_sub_cmd db drop "Drop an existing database"
__bind_user_pw_options	"db drop"
__bind_server_option   	"db drop"

# list
__bind_sub_cmd db list "List the existing databases"
__bind_user_pw_options	"db list"
__bind_server_option   	"db list"

# migrate
__bind_sub_cmd db migrate "Migrate an existing database"
__bind_user_pw_options	"db migrate"
__bind_server_option   	"db migrate"

# optimize
__bind_sub_cmd db optimize "Optimize an existing database"
__bind_user_pw_options	"db optimize"
__bind_server_option   	"db optimize"

# online
__bind_sub_cmd db online "Bring a database online"
__bind_user_pw_options	"db online"
__bind_server_option   	"db online"

# offline
__bind_sub_cmd db offline "Take a database offline"
__bind_user_pw_options	"db offline"
__bind_server_option   	"db offline"
__bind_option "db offline" t timeout 	"Specify the timeout for the offline"

# backup
__bind_sub_cmd db backup "Create a backup of an existing database"
__bind_user_pw_options	"db backup"
__bind_server_option   	"db backup"
#__bind_option "db copy" c copy-to "The name of the new database"

# restore
__bind_sub_cmd db restore "Restore a database from a backup"
__bind_user_pw_options	"db restore"
__bind_server_option   	"db restore"
#__bind_option "db copy" c copy-to "The name of the new database"

########################################################

# server commands
__bind_cmd server "Manage a Stardog server"

# server start
__bind_sub_cmd server start "Start the Stardog server"

# server start options
__bind_sub_cmd_long_option 	"server start" port 			"Specify the port for the server"
__bind_sub_cmd_long_option 	"server start" disable-security "Allow anon access to HTTP SPARQL endpoint"
__bind_sub_cmd_long_option 	"server start" home 			"Specify the name of the Stardog log file"
__bind_sub_cmd_long_option 	"server start" log-file 		"Allow anon access to HTTP SPARQL endpoint"
__bind_sub_cmd_long_option 	"server start" no-http 			"Disable the HTTP server"
__bind_sub_cmd_long_option 	"server start" no-snarl 		"Disable the SNARL server"
__bind_sub_cmd_long_option 	"server start" bind 		    "Specify the network interface the server should bind to"
__bind_sub_cmd_long_option 	"server start" no-web-console   "Disable the web console"
__bind_sub_cmd_long_option 	"server start" enable-ssl 		"Enable support for SSL connections"
__bind_sub_cmd_long_option 	"server start" require-ssl 		"Require clients to use SSL to connect to the server"

# server stop
__bind_sub_cmd server stop "Stop the Stardog server"

# server stop options
__bind_server_option   	"server stop"
__bind_user_pw_options	"server stop"

# server status
__bind_sub_cmd server stop "Display the status of the Stardog server"

# server status options
__bind_server_option   	"server status"
__bind_user_pw_options	"server status"

########################################################

# metadata commands
__bind_cmd metadata "Manage database metadata"

# get
__bind_sub_cmd metadata get "Get metadata from a database"
__bind_user_pw_options	"metadata get"
__bind_server_option   	"metadata get"
__bind_option "metadata get" o option "Metadata options to get"

# set
__bind_sub_cmd metadata set "Set database metadata"
__bind_user_pw_options	"metadata set"
__bind_server_option   	"metadata set"
__bind_option "metadata set" o option "Metadata options to set"

########################################################

# version commands

__bind_cmd version "Display Stardog version information"

########################################################
# icv commands

__bind_cmd icv "Manage database Integrity Constraints"

# add
__bind_sub_cmd icv add 	"Add a constraint(s) to a database"
__bind_user_pw_options	"icv add"
__bind_option 			"icv add" f format "Specify the RDF format of the constraints"

# drop
__bind_sub_cmd icv drop "Remove all constraints to a database"
__bind_user_pw_options	"icv drop"

# remove
__bind_sub_cmd icv add 	"Remove a constraint(s) from a database"
__bind_user_pw_options	"icv remove"
__bind_option 			"icv remove" f format "Specify the RDF format of the constraints"

########################################################
# user commands

# add addrole disable enable grant list passwd permission remove removerole revoke

__bind_cmd user "User management"

__bind_sub_cmd 				user add "Add a new user"
__bind_user_pw_options		"user add"
__bind_server_option   		"user add"
__bind_option 				"user add" s superuser "Create an admin account"
__bind_option 				"user add" N new-password "Password for new user"

__bind_sub_cmd 				user addrole "Assign a role to a user"
__bind_user_pw_options		"user addrole"
__bind_server_option   		"user addrole"
__bind_option 				"user addrole" R role "Role to assign to user"

__bind_sub_cmd 				user disable "Disable a user account"
__bind_user_pw_options		"user disable"
__bind_server_option   		"user disable"

__bind_sub_cmd 				user enable "Enable a user account"
__bind_user_pw_options		"user enable"
__bind_server_option   		"user enable"

__bind_sub_cmd 				user grant "Assign a role to a uesr"
__bind_user_pw_options		"user grant"
__bind_server_option   		"user grant"
__bind_option 				"user grant" a action "Action the user can perform"
__bind_option 				"user grant" o object "Resource the user can act upon"

__bind_sub_cmd 				user list "List all users"
__bind_user_pw_options		"user list"
__bind_server_option   		"user list"
__bind_option 				"user list" f format "Specify the output format"
__bind_sub_cmd_long_option 	"user list" verbose "Enable verbose output"

__bind_sub_cmd 				user passwd "Change a user's password"
__bind_user_pw_options		"user passwd"
__bind_server_option   		"user passwd"
__bind_option 				"user passwd" N new-password "New password for the user"

__bind_sub_cmd 				user permission "List a user's permissions"
__bind_user_pw_options		"user permission"
__bind_server_option   		"user permission"
__bind_option 				"user permission" f format "Specify the output format"

__bind_sub_cmd 				user remove "Delete an existing user"
__bind_user_pw_options		"user remove"
__bind_server_option   		"user remove"

__bind_sub_cmd 				user removerole "Unassign a role from a user"
__bind_user_pw_options		"user removerole"
__bind_server_option   		"user removerole"
__bind_option 				"user removerole" R role "Role to unassign"

__bind_sub_cmd 				user revoke "Revoke a permission from a user"
__bind_user_pw_options		"user revoke"
__bind_server_option   		"user revoke"
__bind_option 				"user revoke" a action "Action the user can not perform"
__bind_option 				"user revoke" o object "Resource the user can not act upon"

########################################################
# role commands

__bind_cmd role "Role management"

__bind_sub_cmd role add "Add a new role"
__bind_user_pw_options	"role add"
__bind_server_option   	"role add"

__bind_sub_cmd role grant "Grant a permission to a role"
__bind_user_pw_options	"role grant"
__bind_server_option   	"role grant"
__bind_option 			"role grant" a action "Specify the action the role can perform"
__bind_option 			"role grant" o object "Specify the resource the role can act upon"

__bind_sub_cmd 				role list "Display a list of roles"
__bind_user_pw_options		"role list"
__bind_server_option   		"role list"
__bind_option 				"role list" f format "Specify the output format"
__bind_sub_cmd_long_option 	"role list" verbose "Enable verbose output"

__bind_sub_cmd 				role permission "List a role's permissions"
__bind_user_pw_options		"role permission"
__bind_server_option   		"role permission"
__bind_option 				"role permission" f format "Specify the output format"

__bind_sub_cmd 				role remove "Remove an existing role"
__bind_user_pw_options		"role remove"
__bind_server_option   		"role remove"
__bind_option 				"role remove" f force "Force the removal of the role"

__bind_sub_cmd role revoke 	"Revoke a permission from a role"
__bind_user_pw_options		"role revoke"
__bind_server_option   		"role revoke"
__bind_option 				"role revoke" a action "Action the role can no longer perform"
__bind_option 				"role revoke" o object "Resource the role can no longer act upon"
########################################################

# query commands

# kill list status

__bind_cmd query "Manage running queries"

__bind_sub_cmd query kill "Kill a running query"
__bind_user_pw_options	"query kill"
__bind_server_option   	"query kill"
__bind_option 			"query kill" a all "Kill all running queries"

__bind_sub_cmd query list "List running queries"
__bind_user_pw_options	"query list"
__bind_server_option   	"query list"
__bind_option 			"query list" v verbose "Enable verbose output"

__bind_sub_cmd query status "Display the status of a query"
__bind_user_pw_options	"query status"
__bind_server_option   	"query status"

########################################################

#__bind_global_long_option "server" "Specify the URL for the server"

# help commands
__bind_cmd help 			"Display help for a command"

__bind_cmd_help server 		"Display help for the server commands"
__bind_cmd_help db 			"Display help for the database commands"
__bind_cmd_help version 	"Display help for the version commands"
__bind_cmd_help metadata 	"Display help for the metadata commands"
__bind_cmd_help icv 		"Display help for the icv commands"
__bind_cmd_help role 		"Display help for the role commands"
__bind_cmd_help metadata 	"Display help for the user commands"
__bind_cmd_help query 		"Display help for the query management commands"

# help db commands
__bind_sub_cmd_help db copy 	"Display help for the copy command"
__bind_sub_cmd_help db create	"Display help for the create command"
__bind_sub_cmd_help db drop 	"Display help for the drop command"
__bind_sub_cmd_help db list		"Display help for the list command"
__bind_sub_cmd_help db migrate 	"Display help for the migrate command"
__bind_sub_cmd_help db optimize	"Display help for the optimize command"
__bind_sub_cmd_help db online 	"Display help for the online command"
__bind_sub_cmd_help db offline	"Display help for the offline command"

# help server commands
__bind_sub_cmd_help server start 	"Display help for the server start command"
__bind_sub_cmd_help server stop  	"Display help for the server stop command"

# help metadata commands
__bind_sub_cmd_help metadata get 	"Display help for the metadata get command"
__bind_sub_cmd_help metadata set 	"Display help for the metadata set command"

# help icv commands
__bind_sub_cmd_help icv add 	"Display help for the icv add command"
__bind_sub_cmd_help icv drop  	"Display help for the icv drop command"
__bind_sub_cmd_help icv remove  "Display help for the icv remove command"

# help query commands
__bind_sub_cmd_help query kill 		"Display help for the query kill command"
__bind_sub_cmd_help query list  	"Display help for the query list command"
__bind_sub_cmd_help query status 	"Display help for the query status command"

# help user commands
__bind_sub_cmd_help user add 			"Display help for the user add command"
__bind_sub_cmd_help user addrole		"Display help for the user addrole command"
__bind_sub_cmd_help user disable 		"Display help for the user disable command"
__bind_sub_cmd_help user enable			"Display help for the user enable command"
__bind_sub_cmd_help user grant 			"Display help for the user grant command"
__bind_sub_cmd_help user list			"Display help for the user list command"
__bind_sub_cmd_help user passwd 		"Display help for the user passwd command"
__bind_sub_cmd_help user permission		"Display help for the user permission command"
__bind_sub_cmd_help user remove			"Display help for the user remove command"
__bind_sub_cmd_help user removerole		"Display help for the user removerole command"
__bind_sub_cmd_help user revoke			"Display help for the user revoke command"

# help role commands
__bind_sub_cmd_help role add 			"Display help for the role add command"
__bind_sub_cmd_help role grant			"Display help for the role grant command"
__bind_sub_cmd_help role list 			"Display help for the role list command"
__bind_sub_cmd_help role permission		"Display help for the role permission command"
__bind_sub_cmd_help role remove 		"Display help for the role remove command"
__bind_sub_cmd_help role revoke			"Display help for the role revoke command"