##
# Record Kicks and Bans v2.0 by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#  For eggdrop 1.5.0 and above only.
#
# If you have any questions/comments/ideas/suggestions/bug reports, please email me.
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script will keep tally on who kicks/bans and e`mails the stats to
# a setable e`mail address.  This script is more to monitor who's abusing
# ops privlidges than some kinda "channel stat's" script that so many
# lamers like.
#.
# This script requires that sendmail is installed on the shell.  The script
# will automatically search for sendmail on it's own, if it doesn't find it
# then it will not load.  If you want to see if your shell has sendmail
# before loading this script, at the shell prompt type:  which sendmail
##

##
# History
##
# v2.0 (03.16.01)
#  MC_8 - Fixed, `Tcl error [mc:rkb:dcc:email]: can't read "userinfo": no such
#         variable'.
#  MC_8 - This script was built with, and tested on a postfix sendmail version.
#         I didn't know that it wasn't standard sendmail, made it compatable
#         with postfix and the regular sendmail version.
#  MC_8 - Added irc nicks (if avilable) of who it is the ban is pertaning to.
#  MC_8 - Added major bot access to email'd output.
#  MC_8 - Added servers name for recording ban's, insted of it showing "", now
#         shows the irc.server.com.
#  MC_8 - Re`did the from veriable, you can now specify it with a little more
#         detail, such as having a reply to address.
#  MC_8 - Added ability to set a subject on the email's.
#  MC_8 - Added option to send email in plain text or html.
#  MC_8 - Added exemption options, who do you NOT want to record?
#  MC_8 - Changed way of setting when to send email'd logs.  It's now
#         more user friendly to setup.
#  MC_8 - Recoded how it sends email, doesn't use the exec's, uses tcl's
#         open |... this is cleaner and more effecent.
#  MC_8 - Made the e`mail's channel specific, so you can log more than 1
#         channel and have seperate info for each channel.
#  MC_8 - Made it able to change email address on the fly, each user keeps
#         track of there own email's via the DCC email command.
#  MC_8 - Made it able to turn channels on or off for this script on the fly
#         via the DCC chanset command (read the setting for more info).
#  MC_8 - Added `email` dcc command, to change email address of individual
#         on the fly (simular to userinfo, if you use userinfo, don't 
#         worry.. it's compatable)
#  MC_8 - Added SVS
#  MC_8 - TallMic - Added option to specify where sendmail is.
#  MC_8 - TallMic - IF Else problem fixed.
#
# v1.0 (11.15.00)
#  MC_8 - First release
##

##
# Commands (DCC)
##
# email [<email@address [email@address ..]>|none]
# chemail <handle> [<email@address [email@adderss ..]>|none]
##

##
# Settings
##
#
# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   <+/->mc.recordkb  Setting this to +mc.recordkb will enable the
#                     script for the particular channel.
#
#  Example from dcc chat with the bot:
#   .chanset #channel +mc.recordkb

# What flaged users should recieve the email'd kick/ban logs?
# Flag format: <global>|<channel>
# The user must also have at least one email set via dcc command
# `email`.  Set this to "-|-" to state send e`mail to anyone that
# has an email address defined.
set mc_rkb(email_flag) "nm|nm"

# What flaged users do you want to exempt from being recorded by
# this script?  Flag format:  <global>|<channel>
# Set this to "-|-" to exempt no one.
set mc_rkb(exempt) "-|-"

# Who do you want to say it's from?
# Format: <reply-to-address> <"("Display Name")">
# In email, especially outlook express... it will show the email
# has come from "Display Name".  But when you reply to it, it uses
# the "reply-to-address".
# Replacment veriables are:   %chan and %botnick
set mc_rkb(from) "gregory@worldinter.net (%chan's Abuse Monitor Bot (%botnick))"

# What do you want the subject to say?
# Replacment veriables are:  %chan and %botnick
set mc_rkb(subject) "Kick and Ban logs for %chan"

# Do you want email in an HTML format or plain text?
# HTML format looks cleaner, but some people use email programs
# that doesn't support it.
#   0 = Plain Text Format
#   1 = HTML Format
set mc_rkb(format) 1

# How often do you want to report?
# Set the hour in which you want to send the logs via email.
# Seperate each hour with a space.  Time is in military!
# examples:
#  set mc_rkb(time) "0"           ;#This is at Midnight
#  set mc_rkb(time) "5"           ;#This is at 5am
#  set mc_rkb(time) "13"          ;#This is at 1pm
#  set mc_rkb(time) "23"          ;#This is at 11pm
#  set mc_rkb(time) "7 19"        ;#This is at 7am and 7pm
#  set mc_rkb(time) "3 10 18 23"  ;#This is at 3am, 10am, 6pm and 11pm
set mc_rkb(time) "0"

# If you know where sendmail is then specify it here.
# If you don't then just leave this at "", the script will try
# and search for it it's self.
# ie. /usr/sbin
set mc_rkb(sendmail) "/usr/local/sbin"

## MC SVS (Script Version Service) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_rkb(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_rkb(svs:check) 0  ;#This is at Midnight
#  set mc_rkb(svs:check) 5  ;#This is at 5am
#  set mc_rkb(svs:check) 13  ;#This is at 1pm
#  set mc_rkb(svs:check) 23  ;#This is at 11pm
set mc_rkb(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_rkb(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_rkb(svs:stableonly) 0




##
# Coding

# Logfile apend.
set mc_rkb(log) ".wnrkb.log"

set mc_rkb(version) v2.0
set mc_rkb(svs:script) "record_kick-ban 002000000000"
set mc_rkb(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Record Kicks and Bans $mc_rkb(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Record Kicks and Bans $mc_rkb(version) will not work with eggdrop $version."
 putlog "Record Kicks and Bans $mc_rkb(version) not loaded."
 return 1
}

set exists 0
if {$mc_rkb(sendmail) == ""} {
 foreach path [split $env(PATH) :] {
  if {[file exists $path/sendmail]} {set exists 1;break}
 }
} {
 switch -- [string range $mc_rkb(sendmail) [expr [string last / $mc_rkb(sendmail)]+1] e] {
  sendmail {set path [string range $mc_rkb(sendmail) 0 [expr [string last / $mc_rkb(sendmail)]-1]]}
  ""  {set path [string range $mc_rkb(sendmail) 0 [expr [string last / $mc_rkb(sendmail) ]-1]]}
  default {set path $mc_rkb(sendmail)}
 };if {[file exists $path/sendmail]} {set exists 1}
}
if {!$exists} {
 putlog "Record Kicks and Bans $mc_rkb(version) by MC_8, could not find sendmail installed on the system."
 putlog "Record Kicks and Bans $mc_rkb(version), please contact the admin, or set mc_rkb(sendmail) correctly."
 putlog "Record Kicks and Bans $mc_rkb(version) not loaded."
 return 1
};set mc_rkb(sendmail:path) $path/sendmail;setudef flag mc.recordkb

bind kick - * mc:rkb:kick
proc mc:rkb:kick {nick uhost hand chan target reason} {
 mc:rkb:log $nick $hand $chan kick $target $reason
}

bind mode - "* +b" mc:rkb:ban
proc mc:rkb:ban {nick uhost hand chan mc vic} {
 global mc_rkb;set chan [string tolower $chan]
 if {[set reason [mc:rkb:inter:banreason $vic $chan]] == "0"} {
  set reason "Not a ban in bot, reason unknown"
 }
 if {$nick == ""} {set nick $uhost}
 set vicn [join [split [mc:rkb:inter:findchanuser $vic $chan]] ", "]
 if {$vicn != ""} {set vicn "($vicn)"}
 set vic "$vic $vicn"
 mc:rkb:log $nick $hand $chan ban $vic $reason
}

proc mc:rkb:log {nick hand chan method target reason} {
 global mc_rkb
 set chan [string tolower $chan]
 if {(![mc:rkb:inter:chanon $chan mc.recordkb]) ||
     (([matchattr $hand $mc_rkb(exempt) $chan]) && ($mc_rkb(exempt) != "-|-"))} {return 0}
 if {![file exists $chan$mc_rkb(log)]} {set io [open $chan$mc_rkb(log) w];close $io}
 set io [open $chan$mc_rkb(log) r];set log ""
 while {![eof $io]} {set log "$log {[gets $io]}"}
 close $io;set temp ""
 foreach line $log {if {[join $line] != ""} {set temp "$temp {$line}"}}
 set log [string trim $temp " "]
 if {$log == ""} {if {$method == "kick"} {set totals "1 0"} {set totals "0 1"}} {
  if {$method == "kick"} {
   set totals "[expr [lindex [lindex $log 0] 0]+1] [lindex [lindex $log 0] 1]"
  } {
   set totals "[lindex [lindex $log 0] 0] [expr [lindex [lindex $log 0] 1]+1]"
  }
 }
 set temp "{$totals}";set found 0
 foreach user [lrange $log 1 e] {
  if {[lindex $user 0] == $hand} {
   if {$method == "kick"} {
    set totals "[expr [lindex $user 1]+1] [lindex $user 2]"
   } {set totals "[lindex $user 1] [expr [lindex $user 2]+1]"}
   set temp "$temp {{$hand} $totals [lrange $user 3 e] {{$nick} {$method} {$target} {$reason} {[unixtime]}}}"
   set found 1
  } {set temp "$temp {$user}"}
 }
 if {!$found} {
  if {$method == "kick"} {set totals "1 0"} {set totals "0 1"}
  set temp "$temp {{$hand} $totals {{$nick} {$method} {$target} {$reason} {[unixtime]}}}"
 }
 set io [open $chan$mc_rkb(log) w]
 foreach line "{[lindex $temp 0]} [lsort -index 0 [lrange $temp 1 e]]" {
  puts $io $line
 };close $io
}

proc mc:rkb:sendmail {a b c d e} {
 global mc_rkb botnick
 putloglev c * "Email'n kick/ban logs..."
 foreach chan [string tolower [channels]] {
  if {![mc:rkb:inter:chanon $chan mc.recordkb]} {
   if {[file exists $chan$mc_rkb(log)]} {file delete $chan$mc_rkb(log)}
   continue
  }
  if {$mc_rkb(format)} {
   set log "{<table border=0 cellpading=0 cellspacing=0 width=100%>}"
   set log "$log {<tr>}"
   set log "$log {<td bgcolor=black width=1%>&nbsp\;</td>}"
   set log "$log {<td bgcolor=black width=50%><font color=white><b>Handle (username in bot)</b></font></td>}"
   set log "$log {<td bgcolor=black width=24%><font color=white><b>Total Kicks</b></font></td>}"
   set log "$log {<td bgcolor=black width=24%><font color=white><b>Total Bans</b></font></td>}"
   set log "$log {<td bgcolor=black width=1%>&nbsp\;</td>}"
   set log "$log {</tr>}"
   set log "$log {<tr>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {<td bgcolor=black colspan=3><font color=white><dd>Important bot access.</font></td>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {</tr>}"
   set log "$log {<tr>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {<td bgcolor=white colspan=3><li>IRC-Nick kick'd whomever}"
   set log "$log {<br><dd>Reason<br><dd>Time</td>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {</tr>}"
   set log "$log {<tr>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {<td bgcolor=#E1E1E1 colspan=3><li>IRC-Nick ban'd whomever}"
   set log "$log {<br><dd>Reason<br><dd>Time</td>}"
   set log "$log {<td bgcolor=black>&nbsp\;</td>}"
   set log "$log {</tr>}"
  } {
   set log "{Handle (username in bot)     Total Kicks   Total Bans}"
   set log "$log {o   IRC-Nick kick/ban'd whoever} {        Reason} {        Time}"
   set log "$log {      Important bot access.}"
   set log "$log {__________________________________________________}"
  }
  if {![file exists $chan$mc_rkb(log)]} {set totals "0 0"} {
   set io [open $chan$mc_rkb(log) r];set line ""
   while {![eof $io]} {set line "$line {[gets $io]}"};close $io
   set totals "[lindex [lindex $line 0] 0] [lindex [lindex $line 0] 1]"
   foreach entry [lrange $line 1 e] {
    if {$entry == ""} {continue}
    set access ""
    if {[matchattr [lindex $entry 0] +b]} {
     if {$access == ""} {set access Bot} {set access "$access, Bot"}
    }
    if {[matchattr [lindex $entry 0] +n]} {
     if {$access == ""} {set access "Global Owner"} {set access "$access, Global Owner"}
    } {
     if {[matchattr [lindex $entry 0] +m]} {
      if {$access == ""} {set access "Global Master"} {set access "$access, Global Master"}
     } {
      if {[matchattr [lindex $entry 0] +t]} {
       if {$access == ""} {set access "Botnet Master"} {set access "$access, Botnet Master"}
      }
      if {[matchattr [lindex $entry 0] +o]} {
       if {$access == ""} {set access "Global Op"} {set access "$access, Global Op"}
      } {
       if {[matchattr [lindex $entry 0] +v]} {
        if {$access == ""} {set access "Global Voice"} {set access "$access, Global Voice"}
       }
       if {[matchattr [lindex $entry 0] +f]} {
        if {$access == ""} {set access "Global Friend"} {set access "$access, Global Friend"}
       }
      }
     }
    }
    if {[matchattr [lindex $entry 0] |+n $chan]} {
     if {$access == ""} {set access "Channel Owner"} {set access "$access, Channel Owner"}
    } {
     if {[matchattr [lindex $entry 0] |+m $chan]} {
      if {$access == ""} {set access "Channel Master"} {set access "$access, Channel Master"}
     } {
      if {[matchattr [lindex $entry 0] |+o $chan]} {
       if {$access == ""} {set access "Channel Op"} {set access "$access, Channel Op"}
      } {
       if {[matchattr [lindex $entry 0] |+v $chan]} {
        if {$access == ""} {set access "Channel Voice"} {set access "$access, Channel Voice"}
       }
       if {[matchattr [lindex $entry 0] |+f $chan]} {
        if {$access == ""} {set access "Channel Friend"} {set access "$access, Channel Friend"}
       }
      }
     }
    };if {$access == ""} {set access "User has no important bot access."}
    if {$mc_rkb(format)} {
     set log "$log {<tr>}"
     set log "$log {<td bgcolor=black>&nbsp\;</td>}"
     set log "$log {<td bgcolor=black><font color=white><b>[lindex $entry 0]</b></font></td>}"
     set log "$log {<td bgcolor=black><font color=white><b>[lindex $entry 1]</b></font></td>}"
     set log "$log {<td bgcolor=black><font color=white><b>[lindex $entry 2]</b></font></td>}"
     set log "$log {<td bgcolor=black>&nbsp\;</td></tr>}"
     set log "$log {<tr>}"
     set log "$log {<td bgcolor=black>&nbsp\;</td>}"
     set log "$log {<td bgcolor=black colspan=3><font color=white><dd>$access</font></td>}"
     set log "$log {<td bgcolor=black>&nbsp\;</td>}"
     set log "$log {</tr>}"
    } {
     set log "$log {[lindex $entry 0]      [lindex $entry 1]   [lindex $entry 2]}"
     set log "$log {   $access}"
    }
    foreach kb [lrange $entry 3 e] {
     if {$mc_rkb(format)} {
      if {[lindex $kb 1] == "kick"} {set temp "bgcolor=white"} {set temp "bgcolor=#E1E1E1"}
      set log "$log {<tr>}"
      set log "$log {<td bgcolor=black>&nbsp\;</td>}"
      set log "$log {<td $temp colspan=3><li>[lindex $kb 0] [lindex $kb 1]'d [lindex $kb 2]}"
      set log "$log {<br><dd>Reason:  [lindex $kb 3]}"
      set log "$log {<br><dd>[ctime [lindex $kb 4]]</td>}"
      set log "$log {<td bgcolor=black>&nbsp\;</td>}"
      set log "$log {</tr>}"
     } {
      set log "$log {o   [lindex $kb 0] [lindex $kb 1]'d [lindex $kb 2]}"
      set log "$log {        Reason:  [lindex $kb 3]}"
      set log "$log {        [ctime [lindex $kb 4]]}"
     }
    }; if {!$mc_rkb(format)} {set log "$log {}"}
   }
  }
  if {$mc_rkb(format)} {
   set log "$log {<tr><td bgcolor=black colspan=5 align=right><font color=white>}"
   set log "$log {Record Kicks and Bans $mc_rkb(version) by <a href=mailto:gregory@worldinter.net>Carl M. Gregory, MC_8</a>.}"
   set log "$log {</font></td></tr></table>}"
  } {set log "$log {} {} {Record Kicks and Bans $mc_rkb(version) by Carl M. Gregory, MC_8.}"}
  foreach user [userlist $mc_rkb(email_flag) $chan] {
   foreach addy [split [getuser $user XTRA email] " ,;"] {
    if {$addy == ""} {continue}
    set io [open "|$mc_rkb(sendmail:path) $addy" w]
    puts $io "To: $addy ($user)"
    puts $io "From: [mc:rkb:svs:replace $mc_rkb(from) "%chan $chan %botnick $botnick"]"
    puts $io "Subject: [mc:rkb:svs:replace $mc_rkb(subject) "%chan $chan %botnick $botnick"]"
    if {$mc_rkb(format)} {
     puts $io "Content-Type: text/html\; charset=\"iso-8859-1\""
     puts $io ""
     puts $io "<html><center><font size=+2>Record Kicks and Bans log for</font> <font size=+2 color=red>$chan</font>"
     puts $io "</center><hr><dd> Total kicks for the channel:  [lindex $totals 0]<br>"
     puts $io "<dd> Total bans for the channel:  [lindex $totals 1]<br>"
     foreach post $log {puts $io "$post"}
     puts $io "</html>"
    } {
     puts $io "Record Kicks and Bans log for $chan"
     puts $io "__________________________________________________"
     puts $io ""
     puts $io "Total kicks for the channel: [lindex $totals 0]"
     puts $io "Total bans for the channel:  [lindex $totals 1]"
     puts $io ""
     foreach post $log {puts $io "$post"}
    };close $io
   }
  };if {[file exists $chan$mc_rkb(log)]} {file delete $chan$mc_rkb(log)}
 }
}

proc mc:rkb:inter:banreason {ban chan} {
 if {![isban $ban $chan] && ![isban $ban]} {return 0}
 set reason ""
 foreach line [banlist] {
  if {[lindex [string tolower $line] 0] == [string tolower $ban]} {
   set reason "[lindex $line 5]: [lindex $line 1]" ; break
  }
 }
 if {$reason == ""} {
  foreach line [banlist $chan] {
   if {[lindex [string tolower $line] 0] == [string tolower $ban]} {
    set reason "[lindex $line 5]: [lindex $line 1]" ; break
   }
  }
 } ; if {$reason == ""} {return 0} {return $reason}
}

proc mc:rkb:inter:chanon {chan flag} {
 set chan [string tolower $chan]
 foreach info [channel info $chan] {
  if {[string tolower [string range $info 1 e]] == [string tolower $flag]} {
   if {[string index $info 0] == "+"} {return 1} elseif {[string index $info 0] == "-"} {return 0}
  }
 };return 0
}

bind dcc - email mc:rkb:dcc:email
proc mc:rkb:dcc:email {hand idx args} {
 set args [join $args]
 if {$args == ""} {
  if {[getuser $hand XTRA email] == ""} {
   putdcc $idx "You do not have any email address' set."
  } {
   if {[llength [getuser $hand XTRA email]] == "1"} {set s " is"} {set s "' are"}
   putdcc $idx "Your current email address$s: [getuser $hand XTRA email]"
  }
 } {
  if {[string tolower $args] == "none"} {
   if {[getuser $hand XTRA email] == ""} {
    putdcc $idx "You do not have any email address' set."
    set args ""
   } {
    if {[llength [getuser $hand XTRA email]] == "1"} {set s ""} {set s "'"}
    putdcc $idx "Removed your email address$s."
    setuser $hand XTRA email ""
   }
  } elseif {([string tolower $args] == "help") || ($args == "?")} {
   putdcc $idx "syntax: .email \[<email@address \[email@address ..\]>|none\]"
  } else {
   if {[llength $args] == "1"} {set s ""} {set s "'"}
   putdcc $idx "Set your email address$s to: [string range $args 0 159]"
   setuser $hand XTRA email "[string range $args 0 159]"
  }
 }
 putcmdlog "#$hand# email [string range $args 0 159]"
 return 0
}

bind dcc m chemail mc:rkb:dcc:chemail
proc mc:rkb:dcc:chemail {hand idx args} {
 set args [join $args]
 if {($args == "") || ($args == "?") || ($args == "help")} {
  putdcc $idx "syntax: .chemail <handle> \[<email@address \[email@adderss ..\]>|none\]"
  return 0
 }
 set who [lindex [split $args] 0]
 if {![validuser $who]} {
  putdcc $idx "$who is not a valid user."
  return 0
 }
 set args [lrange [split $args] 1 e]
 if {$args == ""} {
  if {[getuser $who XTRA email] == ""} {
   putdcc $idx "$who does not have any email address' set."
  } {
   if {[llength [getuser $who XTRA email]] == "1"} {set s " is"} {set s "' are"}
   putdcc $idx "$who's current email address$s: [getuser $who XTRA email]"
  }
 } {
  if {[string tolower $args] == "none"} {
   if {[getuser $who XTRA email] == ""} {
    putdcc $idx "$who does not have any email address' set."
   } {
    if {[llength [getuser $who XTRA email]] == "1"} {set s ""} {set s "'"}
    putdcc $idx "Removed $who's email address$s."
    setuser $who XTRA email ""
    putcmdlog "email for $who removed by $hand"
   }
  } {
   if {[llength $args] == "1"} {set s ""} {set s "'"}
   putdcc $idx "Set $who's email address$s to: [string range $args 0 159]"
   setuser $who XTRA email "[string range $args 0 159]"
   putcmdlog "email address$s for $who set to \"[string range $args 0 159]\" by $hand"
  }
 };return 0
}

# Time Procedure
set time ""
foreach time_ $mc_rkb(time) {
 if {($time_ > "23") || ($time_ < "0")} {set time_ 00}
 if {[string length $time_] == "1"} {set time "$time 0$time_"} {set time "$time $time_"}
};set time [string trim $time]
if {[info exists mc_rkb(old:time)]} {
 foreach time_ $mc_rkb(old:time) {
  catch {unbind time - "00 $time_ * * *" mc:rkb:sendmail}
 }
}
foreach time_ $time {
 bind time - "00 $time_ * * *" mc:rkb:sendmail
};set mc_rkb(old:time) $time
# ^

proc mc:rkb:inter:findchanuser {hostmask channel} {
 set hostmask [string tolower $hostmask]
 if {![validchan $channel]} {return -code error "no such channel record"} ; set buffer ""
 foreach user [chanlist $channel] {
  if {[string match $hostmask [string tolower $user![getchanhost $user $channel]]]} {
   set buffer "$buffer $user"
  }
 } ; return [string trim [join [split $buffer] " "]]
}

if {$mc_rkb(svs:enabled)} {
 if {($mc_rkb(svs:check) > "23") || ($mc_rkb(svs:check) < "0")} {set mc_rkb(svs:check) 00}
 if {[string length $mc_rkb(svs:check)] == "1"} {set mc_rkb(svs:check) 0$mc_rkb(svs:check)}
 if {$mc_rkb(svs:stableonly)} {
  set mc_rkb(svs:script) [string range $mc_rkb(svs:script) 0 [expr [string length $mc_rkb(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_rkb(svs:oldcheck) * * *" mc:rkb:svs:time}
 set mc_rkb(svs:oldcheck) $mc_rkb(svs:check)
 bind time - "00 $mc_rkb(svs:check) * * *" mc:rkb:svs:time
 proc mc:rkb:svs:time {min hour day month year} {
  global mc_rkb
  catch {control [connect [lindex $mc_rkb(svs:server) 0] [lindex $mc_rkb(svs:server) 1]] mc:rkb:svs:interface}
 }
}
proc mc:rkb:svs:interface {idx args} {
 global mc_rkb;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_rkb(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_rkb(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_rkb(svs:script) 1]} {
    set note [mc:rkb:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:rkb:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:rkb:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_rkb(version)}"]
    set note [mc:rkb:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:rkb:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:rkb:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:rkb:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_rkb(svs:notify) ",;"]] {
     set outnote [mc:rkb:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_rkb(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_rkb(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:rkb:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Record Kicks and Bans $mc_rkb(version) by MC_8 loaded."

#####[ DB Format ]####%%=-.,
#{Total Kicks} {Total Bans}
#{hand} {Total Kicks} {Total Bans} {{nick} {kick|ban} {target} {reason} {[unixtime]}} {{nick} {kick|ban} {target} {reason} {[unixtime]}} ..
#{hand} {Total Kicks} {Total Bans} {{nick} {kick|ban} {target} {reason} {[unixtime]}} {{nick} {kick|ban} {target} {reason} {[unixtime]}} ..
#..
######################%%=-.,