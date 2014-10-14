function __stardog_using_command
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

function __stardog_needs_command
  set cmd (commandline -opc)
  set foo (echo "$cmd[1]" | grep  -E 'stardog$')
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
  complete --no-files -c stardog -s $argv[2] -l $argv[3] -n "__stardog_using_command $argv[1]" -d $argv[4]
end

function __bind_server_option
  complete --no-files -c stardog -l server -n "__stardog_using_command $argv" -d "Specify the URL of the server"
end

function __bind_sub_cmd_help
  complete --no-files -c stardog -a $argv[2] -n "__stardog_using_command help $argv[1]" -d $argv[3]
end

function __bind_cmd_help
  complete --no-files -c stardog -a $argv[1] -n "__stardog_using_command help" -d $argv[2]
end

function __bind_cmd
  complete --no-files -c stardog -a $argv[1] -n "__stardog_needs_command" -d $argv[2]
end

function __bind_sub_cmd
  complete --no-files -c stardog -a $argv[2] -n "__stardog_using_command $argv[1]" -d $argv[3]
end

function __bind_sub_cmd_long_option
  complete --no-files -c stardog -l $argv[2] -n "__stardog_using_command $argv[1]" -d $argv[3]
end

########################################################

# data

__bind_cmd data "Modify database contents"

__bind_sub_cmd data add     "Add data to a database"
__bind_sub_cmd data remove  "Remove data from a database"
__bind_sub_cmd data size    "Get the size of a database"
__bind_sub_cmd data export  "Export database contents"

__bind_user_pw_options  "data add"
__bind_option           "data add" f format           "Specify RDF format the data"
__bind_option           "data add" g named-graph      "The target named graph for the data"
__bind_sub_cmd_long_option "data add" strict-parsing  "Sets strict parsing for the RDF"

__bind_user_pw_options  "data remove"
__bind_option           "data remove" f format            "Specify RDF format the data"
__bind_option           "data remove" g named-graph       "The target named graph for the data"
__bind_option           "data remove" a all               "Remove all data in database"
__bind_sub_cmd_long_option "data remove" strict-parsing   "Sets strict parsing for the RDF"

__bind_user_pw_options  "data size"

__bind_user_pw_options  "data export"
__bind_option           "data export" f format            "Specify RDF format the export"
__bind_option           "data export" g named-graph       "The named graph to export"
########################################################

# icv

__bind_cmd icv "Validate or Convert Integrity Constraints"

__bind_sub_cmd icv convert    "Convert an IC"
__bind_sub_cmd icv validate   "Validate contents of the database"
__bind_sub_cmd icv export     "Export ICs from a database"

__bind_user_pw_options  "icv convert"
__bind_option           "icv convert" f format            "Specify the format of the constraints"
__bind_option           "icv convert" C constraints       "(deprecated) The file containing the constraints"
__bind_sub_cmd_long_option "icv convert" contexts   "Contexts containing ICs to convert"

__bind_user_pw_options  "icv validate"
__bind_option           "icv validate" f format            "Specify the format of the constraints"
__bind_option           "icv validate" C constraints       "(deprecated) The file containing the constraints"
__bind_sub_cmd_long_option "icv validate" contexts   "Contexts containing ICs to validate"

__bind_user_pw_options  "icv export"
__bind_option           "icv export" f format            "Specify the format of the constraints"
########################################################

# namespace

__bind_cmd namespace "Edit stored namespaces"

__bind_sub_cmd namespace add      "Add a new namespace"
__bind_sub_cmd namespace list     "List stored namespaces"
__bind_sub_cmd namespace remove   "Remove existing namespace"

__bind_user_pw_options  "namespace add"
__bind_sub_cmd_long_option "namespace add" prefix   "Prefix to store for the namespace"
__bind_sub_cmd_long_option "namespace add" uri      "Namespace URI to store"

__bind_user_pw_options  "namespace remove"
__bind_sub_cmd_long_option "namespace remove" prefix   "Namespace prefix to remove"

__bind_user_pw_options  "namespace list"

########################################################

# query

__bind_cmd query "Query execution & Explanation"

__bind_sub_cmd query execute  "Execute a SPARQL query"
__bind_sub_cmd query explain  "Get a query execution plan"
__bind_sub_cmd query search   "Perform a full-text search"

__bind_user_pw_options      "query execute"
__bind_option               "query execute" b bind    "Var bindings to apply before execution"
__bind_option               "query execute" f format  "Specify the result format"
__bind_sub_cmd_long_option  "query execute" verbose   "Enable verbose output"

__bind_user_pw_options  "query explain"

__bind_user_pw_options  "query search"
__bind_option           "query search" l limit      "Max number of search results"
__bind_option           "query search" o offset     "Search result offset"
__bind_option           "query search" q query      "Specify search query to execute"
__bind_option           "query search" t threshold  "Minimum score threshold for results"

########################################################

# reasoning

__bind_cmd reasoning "Check Consistency & Explanations"

__bind_sub_cmd reasoning explain      "Explain an inference"
__bind_sub_cmd reasoning consistency  "Get the consistency of the database"

__bind_user_pw_options  "reasoning explain"
__bind_option           "reasoning explain" f format        "Specify the input format"
__bind_option           "reasoning explain" i inconsistency "Explain inconsistency of the database"
__bind_option           "reasoning explain" o output-format "Output format for the explanation"
__bind_option           "reasoning explain" r reasoning     "Reasoning level to use for explanation"
__bind_sub_cmd_long_option  "reasoning explain" verbose     "Enable verbose output"

__bind_user_pw_options  "reasoning consistency"
__bind_option           "reasoning consistency" r reasoning     "Reasoning level to use for consistency check"
__bind_sub_cmd_long_option "reasoning consistency" named-graphs     "Named graphs to check the consistency of"
########################################################

# version

__bind_cmd version "Print version information"

########################################################

# help

__bind_cmd help       "Display help for a command"

__bind_cmd_help data        "Display help for the data commands"
__bind_cmd_help icv         "Display help for the icv commands"
__bind_cmd_help namespace   "Display help for the namespace commands"
__bind_cmd_help query       "Display help for the query commands"
__bind_cmd_help reasoning   "Display help for the reasoning commands"
__bind_cmd_help version     "Display help for the version commands"

__bind_sub_cmd_help data add      "Display help for adding data"
__bind_sub_cmd_help data remove   "Display help for removing data"
__bind_sub_cmd_help data size     "Display help for retrieving database size"
__bind_sub_cmd_help data export   "Display help for exporting a database"

__bind_sub_cmd_help icv convert   "Display help for IC conversion"
__bind_sub_cmd_help icv validate  "Display help for IC validation"

__bind_sub_cmd_help namespace add     "Display help for adding a namespace"
__bind_sub_cmd_help namespace list    "Display help for listing namespaces"
__bind_sub_cmd_help namespace remove  "Display help for removing a namespace"

__bind_sub_cmd_help query execute "Display help for executing a query"
__bind_sub_cmd_help query explain "Display help for explaining a query plan"
__bind_sub_cmd_help query search  "Display help for full-text search"

__bind_sub_cmd_help reasoning explain      "Display help for inference explanation"
__bind_sub_cmd_help reasoning consistency  "Display help for consistency checking"
