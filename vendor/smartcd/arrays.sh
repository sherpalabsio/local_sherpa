################################################################################
# Basic array functions
#
#   Copyright (c) 2009,2012 Dave Olszewski <cxreg@pobox.com>
#   http://github.com/cxreg/smartcd
#
#   This code is released under GPL v2 and the Artistic License, and
#   may be redistributed under the terms of either.
#
#
#   While bash gives you support for using variables as arrays, which is a
#   great improvement over using a space-delimited list, it still leaves it
#   difficult to make use of this feature.  This library aims to improve
#   the situation.
#
#   The provided functions are as follows:
#
#       smartcd::apush
#         Description: Add an element to the end of your array
#         Usage:       $ smartcd::apush var_name elem1 [elem2...]
#
#       smartcd::apop
#         Description: Remove the last element from the array and print it.
#                      The value is also set to the variable _smartcd::apop_return.
#         Usage:       $ smartcd::apop var_name
#
#       smartcd::ashift
#         Description: Remove the first element from the array and print it
#                      The value is also set to the variable _ashift_return.
#         Usage:       $ smartcd::ashift var_name
#
#       smartcd::aunshift
#         Description: Add an element to the beginning of the array
#         Usage:       $ smartcd::aunshift var_name elem1 [elem2...]
#
#       smartcd::areverse
#         Description: Reverse the order of elements in the array
#         Usage:       $ smartcd::areverse var_name
#
#       smartcd::afirst
#         Description: Like smartcd::ashift, but doesn't remove anything.
#         Usage:       $ smartcd::afirst var_name
#
#       smartcd::alast
#         Description: Like smartcd::apop, but doesn't remove anything.
#         Usage:       $ smartcd::alast var_name
#
#       smartcd::anth
#         Description: Retreive the n-th element of an array.
#         Usage:       $ smartcd::anth var_name n
#
#       smartcd::alen
#         Description: Print the current number of elements in the array
#         Usage:       $ smartcd::alen var_name
#
#       smartcd::acopy
#         Description: Copy the contents of an array into a new variable.
#         Usage:       $ smartcd::alen var_name new_variable
#
#   If the incorrect number of arguments are supplied, all functions exit
#   silently.  This is subject to change in the future.
#
#   This library was inspired largely by having access to this functionality
#   in Perl, and then finding it severely lacking in bash.
################################################################################

function smartcd::is_array() {
    local var=$1

    if [[ -n $ZSH_VERSION ]]; then
        local pattern="^typeset"
    else
        local pattern="^declare"
    fi

    type=$(declare -p $var 2>/dev/null)
    if [[ $type =~ $pattern" -a" ]]; then
        echo 1
    fi
}

# It's not really possible to "echo" an array copy and catch it correctly
# so instead we'll ask for the destination
function smartcd::acopy() {
    local var=$1; shift
    local dest=$1; shift

    if [[ -n $(smartcd::is_array $var) && -n $dest ]]; then
        eval "$dest=(\"\${$var""[@]}\")"
    fi
}

function smartcd::apush() {
    local var=$1; shift

    if [[ -n $var ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            eval "$var=(\${$var[@]} \"\$@\")"
        else
            eval "$var=(\"\${$var[@]}\" \"\$@\")"
        fi
    fi
}

function smartcd::apop() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1

    _apop_return=

    if [[ -n $var ]] && (( $(eval "echo \${#$var""[@]}") >= 1 )); then
        eval "_apop_return=\"\$(echo \"\${$var[\${#$var""[@]} - 1]}\")\""
        if [[ -n $ZSH_VERSION ]]; then
            eval "$var""[-1]=()"
        else
            eval "unset $var""[\$(( \${#$var""[@]} - 1))]"
        fi

        echo "$_apop_return"
    fi
}

function smartcd::ashift() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1

    _ashift_return=

    if [[ -n $var ]] && (( $(eval "echo \${#$var[@]}") >= 1 )); then
        eval "_ashift_return=\"\${$var""[0]}\""
        if [[ -n $ZSH_VERSION ]]; then
            eval "$var""[0]=()"
        else
            eval "unset $var[0]"
            eval "$var=(\"\${$var[@]}\")"
        fi

        echo "$_ashift_return"
    fi
}

# Bash requires the array to be quoted, zsh does not.
function smartcd::aunshift() {
    local var=$1; shift

    if [[ -n $var ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            eval "$var=(\"\$@\" \${$var[@]})"
        else
            eval "$var=(\"\$@\" \"\${$var[@]}\")"
        fi
    fi
}

function smartcd::areverse() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1

    if [[ -n $var ]] && (( $(eval "echo \${#$var""[@]}") >= 2 )); then
        len=$(eval "echo \${#$var""[@]}")
        i=0
        if [[ -n $ZSH_VERSION ]]; then
            local op='<='
        else
            local op='<'
        fi
        while (( $i $op $len/2 )); do
            tmp=$(eval echo "\${$var""[\$i]}")

            eval "$var""[\$i]=\"\${$var""[\$len-\$i-1]}\""
            eval "$var""[\$len-\$i-1]=\"\$tmp\""
            (( i++ ))
        done
    fi
}

function smartcd::afirst() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1

    if [[ -n $var ]] && (( $(eval "echo \${#$var[@]}") >= 1 )); then
        eval "echo \"\${$var""[0]}\""
    fi
}

function smartcd::alast() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1

    if [[ -n $var ]] && (( $(eval "echo \${#$var[@]}") >= 1 )); then
        eval "echo \"\${$var""[\${#$var[@]} - 1]}\""
    fi
}

function smartcd::anth() {
    [[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays
    local var=$1
    local n=$2

    if [[ -n $var ]] && (( $(eval "echo \${#$var[@]}") >= 1 )); then
        eval "echo \"\${$var""[$(($n - 1))]}\""
    fi
}

function smartcd::alen() {
    local var=$1

    if [[ -n $var ]]; then
        eval "echo \${#$var[@]}"
    fi
}

# vim: filetype=sh autoindent expandtab shiftwidth=4 softtabstop=4
