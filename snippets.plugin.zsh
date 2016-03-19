#!/usr/bin/env zsh
# snippets for expansion anywhere in the command line
# taken from http://zshwiki.org/home/examples/zleiab and expanded somewhat
#
# use: add-snippet <key> <expansion>
# then, with cursor just past <key>, run snippet-expand

typeset -Ag snippets

snippet-add() {
    # snippet-add <key> <expansion>
    snippets[$1]="$2"
}

snippet-exists() {
    [ -n "${snippets[$1]:-}" ];
}

snippet-edit() {
    name="$1"
    filename=$(mktemp)
    finished=$(mktemp --dry-run)
    tmux new-window bash -c "vim $filename; touch $finished"

    # This can't handle a save and edit
    #   to support this we some sort of signal
    while [ ! -e "$finished" ]; do
        sleep 0.1;
    done;
    content=$(cat $filename)
    escaped_content=$(echo "$content" | sed "s/'/\\\\'/g" )
    echo snippet-add "$name" $'$\''"$escaped_content""'" >> ~/.zsh-snippets
}

snippet-expand() {
    emulate -L zsh
    setopt extendedglob
    local MATCH

    LBUFFER=${LBUFFER%%(#m)[.\-+:|_a-zA-Z0-9]#}
    LBUFFER+=${snippets[$MATCH]:-$MATCH}
}
zle -N snippet-expand

snippet-expand-or-edit() {
    emulate -L zsh
    setopt extendedglob
    local MATCH

    LBUFFER=${LBUFFER%%(#m)[.\-+:|_a-zA-Z0-9]#}
    if [ -z "${snippets[$MATCH]:-}" ]; then
        snippet-edit "$MATCH"
    fi;
    source ~/.zsh-snippets
    LBUFFER+=${snippets[$MATCH]:-$MATCH}
}
zle -N snippet-expand-or-edit

snippet-edit-and-expand() {
    emulate -L zsh
    setopt extendedglob
    local MATCH

    LBUFFER=${LBUFFER%%(#m)[.\-+:|_a-zA-Z0-9]#}

    echo $MATCH > /tmp/match
    snippet-edit "$MATCH"
    source ~/.zsh-snippets
    LBUFFER+=${snippets[$MATCH]:-$MATCH}
}
zle -N snippet-edit-and-expand




help-list-snippets(){
    local help="$(print "Add snippet:";
        print "snippet-add <key> <expansion>";
        print "Snippets:";
        print -a -C 2 ${(kv)snippets})"
    if [[ "$1" = "inZLE" ]]; then
        zle -M "$help"
    else
        echo "$help" | ${PAGER:-less}
    fi
}
run-help-list-snippets(){
    help-list-snippets inZLE
}
zle -N run-help-list-snippets


# set up some default snippets
snippet-add l      "less "
snippet-add tl     "| less "
snippet-add g      "grep "
snippet-add tg     "| grep "
snippet-add gl     "grep -l"
snippet-add tgl    "| grep -l"
snippet-add gL     "grep -L"
snippet-add tgL    "| grep -L"
snippet-add gv     "grep -v "
snippet-add tgv    "| grep -v "
snippet-add eg     "egrep "
snippet-add teg    "| egrep "
snippet-add fg     "fgrep "
snippet-add tfg    "| fgrep "
snippet-add fgv    "fgrep -v "
snippet-add tfgv   "| fgrep -v "
snippet-add ag     "agrep "
snippet-add tag    "| agrep "
snippet-add ta     "| ag "
snippet-add p      "${PAGER:-less} "
snippet-add tp     "| ${PAGER:-less} "
snippet-add h      "head "
snippet-add th     "| head "
snippet-add t      "tail "
snippet-add tt     "| tail "
snippet-add s      "sort "
snippet-add ts     "| sort "
snippet-add v      "${VISUAL:-${EDITOR:-nano}} "
snippet-add tv     "| ${VISUAL:-${EDITOR:-nano}} "
snippet-add tc     "| cut "
snippet-add tu     "| uniq "
snippet-add tx     "| xargs "
