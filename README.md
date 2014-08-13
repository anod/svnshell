# SVN Shell

svnshell - addon for BASH which improves CLI with relveant subversion information and shortcuts for common comands.

Based on https://gist.github.com/shpoont/4055511

### Example
```bash
alex@Alexs-Air:~/dev/svnshell$ svnshell

[alexs-air:~/dev/svnshell] alex trunk 9 $

# create a branch 
[alexs-air:~/dev/svnshell] alex trunk 9 $ branch TestBranch "Branch for tests"
Adding copy of        .

Committed revision 11.
[alexs-air:~/dev/svnshell] alex trunk 9 $

# Switch to a branch
[alexs-air:~/dev/svnshell] alex trunk 9 $ sw TestBranch
U    README.md
U    svnshell.sh
Updated to revision 11.
[alexs-air:~/dev/svnshell] alex TestBranch 11 $

# Switch to a previous branch
[alexs-air:~/dev/svnshell] alex TestBranch 11 $ sw -
U    README.md
U    svnshell.sh
Updated to revision 11.
[alexs-air:~/dev/svnshell] alex trunk 11 $

 # List branches
[alexs-air:~/dev/svnshell] alex trunk 11 $ branch
     11 alex.gav              Jul 24 14:32 ./
     11 alex.gav              Jul 24 14:32 TestBranch/
     
# Show log for merge per revision
[alexs-air:~/dev/svnshell] alex TestBranch 11 $ mergelog trunk
------------- alex.gavrishev [2014-07-23 17:24:29] -----------------------------------
merge -c 9 ^/trunk .
commit -m "Merge from trunk:  list branches when executing branch whithout"
------------- alex.gavrishev [2014-07-23 16:41:30] -----------------------------------
merge -c 8 ^/trunk .
commit -m "Merge from trunk:  mergelog receive a branch name as prameter"
#...

#Show colordiff for revision
[alexs-air:~/dev/svnshell] alex TestBranch 11 $ di -c 8
Index: svnshell.sh
===================================================================
--- svnshell.sh	(revision 7)
+++ svnshell.sh	(revision 8)
#....

```
 
### Requirements
   svn 1.7+

### How to use
Way 1 - To enable execute:
```bash
    $ source svnshell.sh
    $ cd /path/to/svn/checkout
```

Way 2 - Add alias to .bash_profile
```bash
    alias svnshell="source svnshell.sh"
```
  Execute:
```bash
    $ svnshell
    $ cd /path/to/svn/checkout
```

### Format
```
   [host:cwd] user svn-branch [svn-status] rev stdprompt
     |    |    |      |            |        |    |        
     |    |    |      |            |        |    `----->  "" for regular user, "$" for root. Green if 
     |    |    |      |            |        |             last command executed without errors, red otherwise.
     |    |    |      |            |        |             
     |    |    |      |            |        `---------->  Current revision (svnversion output)
     |    |    |      |            |                     
     |    |    |      |            `------------------->  Summary of svn status codes
     |    |    |      |                                  
     |    |    |      `--------------------------------->  Current branch.
     |    |    |                                           
     |    |    `---------------------------------------->  Currently logged in user.
     |    |                                                
     |    `--------------------------------------------->  Current working directory.
     |                                                     
     `-------------------------------------------------->  Hostname of current machine.
```
### Command alises
```bash

  # Preform update:
  $ up
  $ update

  # Switch branch:
  $ sw BranchName
  $ sw trunk
  $ switch ^/trunk

  # Commit changes:
  $ ci
  $ commit

  # Create branch:
  $ branch <BranchName> "<Message>"
  
  # List branches
  $ branch
  
  # Show diff (colordiff)
  $ di
  
  # Revert changes
  $ revert
  $ revertall
  
  # Log with merge info
  $ mergelog

  # Merge branch into wokring copy
  $ mb <BranchName>
 
  # Reintegrate branch
  $ reintegrate <BranchName>

  # Other:
  $ add
  $ info
  $ log
  $ status
  $ st
  $ stat
  $ merge
  $ exit
```
### Author
 Alex Gavrishev <alex.gavrishev@gmail.com>


