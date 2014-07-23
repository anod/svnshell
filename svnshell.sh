#!/bin/bash
#
# SVN shell : improved bash with svn information
#
# Alex Gavrishev <alex.gavrishev@gmail.com>
#

_update_prompt () {
    ## Save $? early, we'll need it later
    local exit="$?"

    ## define some colors
    local red="31";
    local green="32";
    local yellow="33";
    local purple="35";
    local cyan="36";
    local white="37";

    local pre="\[\e[";
    local suf="\]";

    local e_green="${pre}0;${green}m$suf";
    local e_purple="${pre}0;${purple}m$suf";
    local e_cyan="${pre}0;${cyan}m$suf";
    local e_white="${pre}0;${white}m$suf";
    local e_bred="$pre$red;1m$suf";
    local e_byellow="$pre$yellow;1m$suf";

    local e_normal="\[\e[0;0m\]"

    local arrow_up=`echo -e "\xe2\x86\x91"`
    local arrow_down=`echo -e "\xe2\x86\x93"`

    ## Initial prompt
    _prompt="[$e_green\h$e_normal:$e_cyan\w$e_normal]";

    ## Color current user
    local u;
    local p;
    if [ "$UID" = "0" ]; then
        u="$e_bred\u$e_normal ";
        p="#"; 
    else
        u="$e_purple\u$e_normal ";
        p="\$";
    fi

    ## Color based on exit code
    if [ "$exit" = "0" ]; then 
        p="$e_green$p$e_normal";
    else
        p="$e_bred$p$e_normal";
    fi

    ## Color git status if any
    branch=`svn info 2>/dev/null | grep "Relative URL"`
    if [ -n "$branch" ] ; then 
		# strip beginning
		prefix='Relative URL: ^/' 
		branch=${branch#$prefix}

		if  [ "$branch" != "$SVNSHELL_BRANCH_CURRENT" ] ;
		then
			export SVNSHELL_BRANCH_PREV=$SVNSHELL_BRANCH_CURRENT
			export SVNSHELL_BRANCH_CURRENT=$branch
		fi

		if  [[ $branch == branches* ]] ;
		then
		    branch=${branch#'branches/'}
		fi
		if  [[ $branch == tags* ]] ;
		then
		    branch=${branch#'tags/'}
		fi
		
		svn_version=`svnversion`
        branch_revision=$svn_version
		branch_status=`svn status -q | cut -c 1-7 | grep -ve '^---' | grep --color=never -o . | sort -u | tr -d " \n"`
		if [[ "$svn_version" =~ ([0-9:]+)([MSP]+)? ]] ;
		then
		    branch_revision=${BASH_REMATCH[1]}
		fi
		
        if [ "$branch_status" ] ; then
            status_formatted="[$e_bred$branch_status$e_normal$e_normal]"
            branch="$e_bred$branch$e_normal $status_formatted $branch_revision "
        else
            branch="$e_green$branch$e_normal $branch_revision "
        fi

	    full_prompt="$_prompt $u$branch$p"
	    export PS1="\[\e]0;\u@\h:\w\\a\]$full_prompt "
	else
		export SVNSHELL_BRANCH_CURRENT=
		export SVNSHELL_BRANCH_PREV=
	    export PS1=$PS1_ORIGINAL
    fi

}

function _extract_branch_name() {
	local branch=$1
	if  [[ $branch == branches* ]] ;
	then
	    branch=${branch#'branches/'}
	fi
	if  [[ $branch == tags* ]] ;
	then
	    branch=${branch#'tags/'}
	fi
	echo "$branch"
}

function _switch() {
	local branch=$1
    if [ -n "$branch" ] ; then 
		if [ "$branch" == "-" ]; then
			if  ["$SVNSHELL_BRANCH_PREV" != ""] && [ "$SVNSHELL_BRANCH_CURRENT" != "$SVNSHELL_BRANCH_PREV" ] ;
			then
				svn switch ^/$SVNSHELL_BRANCH_PREV "${*:2}"
			fi
		elif [ "$branch" == "trunk" ]; then
			svn switch ^/trunk "${*:2}"
		elif [[ "$branch" == *\/* ]]; then
			svn switch ^/"$branch" "${*:2}"
		else
			svn switch ^/branches/"$branch" "${*:2}"
		fi
	else
		svn switch "$@"
	fi
}

function _branch() {
	local branch=$1
	local message=$2
    if [ -n "$message" ] ; then 
		svn copy . ^/branches/"$branch" -m "$message"
	else
		svn copy . ^/branches/"$branch"
	fi
}

function _commit() {
	svn commit "$@"
	local RETVAL=$?
	[ $RETVAL -eq 0 ] && svn update
}

function _mergelog() {
	local shortbransh=$(_extract_branch_name $SVNSHELL_BRANCH_CURRENT)
	local message=
	local author=
	local rev=
	local date=
	local state=0
	
	#echo "Branch: $SVNSHELL_BRANCH_CURRENT"
	
	svn log --limit 10 "$@" | while read line
	do
		if [[ "$line" == ---* ]]; then
			
			if [ "$state" -eq 3 ]; then
				echo "------------- $author [$date] -----------------------------------"
				echo "merge -c $rev ^/$SVNSHELL_BRANCH_CURRENT ."
				echo "commit -m \"Merge from $shortbransh: $message\"" 
			fi
			
			state=1
		elif [ "$state" -eq 1 ]; then
			# r6733 | alex | 2014-07-07 16:09:21 +0300 (Mon, 07 Jul 2014) | 1 line
			state=2
			local OLD_IFS="$IFS"
			IFS=' | '
			local data=( $line )
			IFS="$OLD_IFS"

			rev=${data[0]#r}
			author=${data[1]}
			date="${data[2]} ${data[3]}"
			message=

		elif [ "$state" -eq 2 ]; then
			#empty line
			state=3
		elif [ "$state" -eq 3 ]; then
			#empty line
			if [ -n "$line" ]; then
			    message="$message $line"
			fi
		fi
	done
	# show last
	if [ "$state" -eq 3 ]; then
		echo "------------- $author [$date] -----------------------------------"
		echo "merge -c $rev ^/$SVNSHELL_BRANCH_CURRENT ."
		echo 'commit -m "Merge from $shortbransh: $message"' 
	fi
}

function _exit() {
	export PROMPT_COMMAND=
	export PS1=$PS1_ORIGINAL
	unset SVNSHELL_BRANCH_CURRENT
	unset SVNSHELL_BRANCH_PREV
	unalias add
	unalias up
	unalias update
	unalias sw
	unalias switch
	unalias ci
	unalias commit
	unalias info
	unalias log
	unalias mergelog
	unalias status
	unalias st
	unalias stat
	unalias merge
	unalias branch
	unalias revert
	unalias revertall
	unalias di
	unalias exit
}

PROMPT_COMMAND='_update_prompt'
export PROMPT_COMMAND
export PS1_ORIGINAL=$PS1
export SVNSHELL_BRANCH_CURRENT=
export SVNSHELL_BRANCH_PREV=

# Define shortcuts

alias add="svn add "
alias up="svn update "
alias update="svn update "
alias sw="_switch "
alias switch="svn switch "
alias ci="_commit "
alias commit="_commit "
alias info="svn info "
alias log="svn log --limit 10 "
alias mergelog="_mergelog "
alias status="svn status "
alias stat="svn status "
alias st="svn status "
alias merge="svn merge "
alias branch="_branch "
alias revert="svn revert "
alias revertall="svn revert --depth=infinity ."
alias di="svn diff "
alias exit="_exit "
