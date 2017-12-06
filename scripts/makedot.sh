#!/bin/bash

# all fucntions  (func)#(file)
# cscope -f cscope.out -RL2 ".*" | awk -F ' ' '{print $2 "#" $1}' | sort | uniq

#AUTHOR John Warnes johnwarnes@mail.weber.edu copywrite 2017

#usage makedot.sh [GRAPH TITLE] [primary function to highlight in green] [another primary]...

#EXAMPLE: makedot.sh "Atmosniffer\ CallGraph\ 12/02/17" main
#EXAMPLE: makedot.sh "Atmosniffer\ CallGraph\ 12/01/17" SYSTEM_Initialize main

FILTERNAMES="$DOTFILES/scripts/filter_names.txt"
FILTERFILES="$DOTFILES/scripts/filter_files.txt"


graph_end()
{
    printf "\n}\n"
}


graph_start()
{
    printf "strict digraph iftree {\n"
    printf "\tgraph [rankdir=\"LR\", truecolor=true, concentrate=false];\n"
    #printf "\tgraph [dpi=300];\n"  # Default 96
    #printf "\tgraph [packmode=clust];\n"
    printf "\tgraph [label=\"$CAP\", labelloc=top, labeljust=left, fontsize=25];\n"
    printf "\tnode [shape=box, style=\"filled\", fillcolor=lightgrey, color=black];\n"
    printf "\tedge [color=\"#00000055\", arrowsize=\"0.5\", weight=\"2\"];\n\n"
    printf "\n"
}


cluster_start()
{
    printf "subgraph cluster_$1 {\n"
    #printf "\tnode [style=filled, color=\"grey\"];\n"
    printf "\tgraph [fontcolor=blue, fontsize=\"16\", label=\"$1\", color=blue, style=\"rounded\"];\n"
    printf "\tgraph [margin=10];\n"
    printf "\n"
}


basepath()
{
    local cline
    while read -a cline; do
        printf "$(basename ${cline[0]}) ${cline[1]}\n"
    done
}


__all_called()
{
    cscope -RL2 '.*' | awk -F ' ' '{print $2}'
    cscope -RL2 'main' | awk -F ' ' '{print $2}'
    printf "main\n"
}


all_called()
{
    __all_called | sort | uniq
    #sed '/ __/ d' | sed '/ _/ d'
}

add_location()
{
    local line
    while read line; do
        cscope -RL1 $line | awk -F ' ' '{print $1" "$2}'
    done
}


filter_names()
{
    local line
    while read line; do

        #don't draw edges FROM a function with double underscore
        if [[ $line =~ __.* ]]; then
            continue
        fi

        if grep -Fxq "$line" $FILTERNAMES ; then
            continue
        fi

        printf "$line\n"

    done
}


filter_files()
{
    local line
    while read -a line; do

        #don't draw edges FROM a function with double underscore
        if [[ ${line[0]} =~ __.* ]]; then
            continue
        fi

        #don't draw edges TO a function with double underscore
        if [[ ${line[0]} =~ __.* ]]; then
            continue
        fi

        if grep -Fxq "${line[0]}" $FILTERFILES ; then
            continue
        fi

        printf "${line[*]}\n"

    done
}


filter_edges()
{
    local line
    while read -a line; do

        #don't draw edges FROM a function with double underscore
        if [[ ${line[0]} =~ __.* || ${line[2]} =~ __.* ]]; then
            continue
        fi

        if ( grep -Fxq "${line[0]}" $FILTERNAMES || grep -Fxq "${line[2]}" $FILTERNAMES ); then
            continue
        fi

        printf "\t${line[*]}\n"
    done
}


all_called_by()
{
    cscope -f cscope.out -RL2 "$1" | awk -F ' ' -v header="$2" -v tailer="$3" '{print header $2 tailer}'
}


get_edges()
{
	local OPT=$(opt_add_edge_decorcation $1)
    all_called_by $1 "$1 -> " "$OPT" | filter_edges
}


create_clusters()
{
    local current_cluster="1!Z"

    local word
    while read -a word; do

        cluster=${word[0]}
        cluster=${cluster//\./_}

        if [[ $cluster != $current_cluster ]]; then
            #if current cluster has changed
            if [[ $current_cluster != "1!Z" ]]; then
                #and it's not the first cluster
                printf "}\n\n" #close old cluster
            fi
            current_cluster=$cluster
            cluster_start $current_cluster
        fi

        printf "\t${word[1]}" #add node
        opt_add_node_decorcation ${word[1]} #add optional decorations
        printf "\n"           #end node
    done

    printf "}\n\n" #close the last cluster
}


create_edges()
{
    local word
    while read word; do
        get_edges $word #add all edges for this node
    done
}

opt_add_node_decorcation()
{
    if [[ $PRIMARY =~ $1 ]]; then
        printf " [fillcolor=green, style=\"filled,rounded\", root=true];"
        return
	fi
    if [[ $SECONDARY =~ $1 ]]; then
        printf " [fillcolor=lightblue, style=\"filled,rounded\"];"
        return
    fi
	printf ""
}

opt_add_edge_decorcation()
{
    if [[ $PRIMARY =~ $1 ]]; then
        printf " [color=green, arrowsize=\"1.5\"];\n"
        return
    fi
    if [[ $SECONDARY =~ $1 ]]; then
        printf " [color=blue, arrowsize=\"1.5\"];\n"
        return
    fi
	printf ""
}

get_sec()
{
	local RET=""
	local TEMP
	for word in $*; do
		TEMP=$(all_called_by $word | sort | uniq | filter_names )
		TEMP=${TEMP//$'\n'/ }
		RET+="$TEMP "
	done
	printf "$RET"
}
###################### MAIN BELOW ###################

if [[ $# > 0 ]]; then
    CAP=$1
else
    CAP="Unnamed Call Graph"
fi

if [[ $# > 1 ]]; then
    shift 1
	PRIMARY=$*
else
    PRIMARY="main"
fi

SECONDARY=$(get_sec $PRIMARY)

echo "PRIMARY= $PRIMARY"
echo "SECONDARY= $SECONDARY"
#all_called | filter_names | sort | uniq | create_edges

echo "[rm] old files"
rm cscope.out graph.dot graph.svg

echo "[Building] cscope.out"
cscope -bkRu -f cscope.out

echo "[Generating] graph"
graph_start > graph.dot
echo "[Generating] clusters"
all_called | filter_names | add_location | basepath | filter_files | sort | uniq | create_clusters >> graph.dot
echo "[Generating] edges"
all_called | filter_names | sort | uniq | create_edges >> graph.dot
echo "[Generating] completing graph"
graph_end >> graph.dot

echo "[Converting] graph.dot -> graph.svg"
dot -Tsvg graph.dot -o graph.svg;

printf "\n[Opening] graph.svg\n"
xdg-open graph.svg

exit 0

#mv graph.dot flat.dot
#unflatten -l1 -c5 -o graph.dot flat.dot

#dot -Tps graph.dot -o graph.ps;
#dot -Tpng graph.dot -o graph.png;
#dot -Tsvg graph.dot -o graph.svg;


#gsettings set org.gnome.Evince page-cache-size 200
#tfile=/tmp/makedot.temp.$RANDOM

