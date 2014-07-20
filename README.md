# SVN Shell

improved bash with subversion information
Based on https://gist.github.com/shpoont/4055511

### Example
```bash
   [blackbox:~/work] john trunk [M] 34673 $
```
 
### Requirements
   svn 1.7+

### How to use
Way 1:
 To enable execute:
```bash
    $ source svnshell.sh
    $ cd /path/to/svn/checkout
```

Way 2:
  Add alias to .bash_profile
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


