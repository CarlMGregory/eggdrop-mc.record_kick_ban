##
# Record Kicks and Bans v3.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug or script not working correctly?
#   http://mc.purehype.net/bugzilla/
# Have a question?
#   http://forum.purehype.net/viewforum.php?f=5
##

##
# Description
##
# This script will keep tally on who kicks/ bans then e-mail's the stats to a
# set able e-mail's address.  This script is more to monitor who's abusing ops
# privileges rather than some kind of "channel stat's" script.
#
# This script also requires you have access to an smtp server to send e-mail.
# Usually your shell account includes this.
##

##
# Commands (DCC)
##
# rkb.email [email@address1 [email@address2 [email@addressN]]]
#   This will set your e-mail address's.  If no email@address' are used, it will
#   erase what you have set.  Use 'whois' or 'match' to see what you have set
#   currently.
#
# rkb.chemail <handle> [email@address1 [email@address2 [email@addressN]]]
#   This will set handle's e-mail address's.  If no email@address' are used, it
#   will erase what handle has set.  Use 'whois' or 'match' to see what handle
#   has set currently.
#
# chanset <channel> <+/->mc.recordkb
#   This will enable (+) or disable (-) this scripts for the specified channel.
##

##
# Configuration
##
#

# What flagged users should receive the an e-mail of the kick/ban log(s)?  Flag
# format, <global>|<channel>.  The user must also have at least one e-mail set
# via dcc command `e-mail`.  Set this to "-|-" to state send e-mail to anyone
# that has an e-mail address defined.
set mc_rkb(:config:email_flag) "nm|nm"

# What flagged users do you want to exempt from being recorded by this script?
# Flag format, <global>|<channel>.  Set this to "-|-" to exempt no one.
set mc_rkb(exempt) "-|-"

# When do you want to e-mail out the log(s)?  Set this to the hour in which you
# want.  Separate each hour with a space.  Time is in 0-23 format, military.
# examples:
#  set mc_rkb(:config:time) "0"           ;# This is at Midnight
#  set mc_rkb(:config:time) "5"           ;# This is at 5am
#  set mc_rkb(:config:time) "13"          ;# This is at 1pm
#  set mc_rkb(:config:time) "23"          ;# This is at 11pm
#  set mc_rkb(:config:time) "7 19"        ;# This is at 7am and 7pm
#  set mc_rkb(:config:time) "3 10 18 23"  ;# This is at 3am, 10am, 6pm and 11pm
set mc_rkb(:config:time) "0"

# What SMTP server do you want to use to send the e-mail?  Specify the host or
# ip here.
set mc_rkb(:config:smtp_server) localhost

# What SMTP server do you want to use to send the e-mail?  Specify the port
# here.
set mc_rkb(:config:smtp_port) 25

# What file do you want to log the raw kick/ban information to?
set mc_rkb(:config:log) "./.rkb.log"

# In addition to emailing the log, you can also have it save to a file (after
# being parsed with the templet, of course). Set this to "" to disable file
# saving.
# Ex: set mc_rkb(file) "/usr/barnie/www/kb_logs/%channel.html"
#  %channel will be automatically replaced with the channel the log pertains to.
set mc_rkb(:config:file) ""

## SVS Client (Script Version Service) v4.1.2 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_rkb(:config:svs:enable) 1

#
##

##
# Templet
##
#

# Valid replacement characters are:
#   %channel       - Channel this e-mailed log pertains to.
#   %report_handle - Handle of the user the log is reporting on.
#   %report_kicks  - Total number of kicks the current reported user made.
#   %report_bans   - Total number of bans the current reported user made.
#   %report_access - Access the current reported user has in the bot.
#   %report_nick   - The irc nickname of the person that performed the kick/ban.
#   %report_victim - The irc nickname of the person that was kick/ banned.
#   %report_reason - The reason for the kick/ban.
#   %report_time   - The time, in unix time format, the kick/ban was preformed.
#   %total_bans    - Total number of bans for the specific channel.
#   %total_kicks   - Total number of kicks for the specific channel.

# Double replacement variables (a bit more advanced):
#   %%Start_handle_report%%
#   %%Stop_handle_report%%
#     Everything in between this will be winded as the log is generated into an
#     e-mail.
#   %%Start_log_entries%%
#   %%Start_log_entries%%
#     Everything in between this will be winded as the log is generated into an
#     e-mail.
#     This should be within the %%Start_handle_report%% and
#     %%Stop_handle_report%%, this is a wind of each individual kick/ban entry
#     from the log.
#   %%tcl <tcl command(s)>%%
#     This will be replaced with what the tcl returns.  A few things you should
#     be aware of is the 'if' statement and the 'clock format' statement.  I put
#     some examples in the default templet, but more information on tcl commands
#     can be found here:
#       If statement: http://tcl.activestate.com/man/tcl8.3/TclCmd/if.htm
#       Clock statement:
#         http://tcl.activestate.com/man/tcl8.3/TclCmd/clock.htm#M6
#       Overall TCL: http://tcl.activestate.com/man/tcl8.3/Keywords/contents.htm
#     I'll show you some examples,
#       %%tcl if {$kickorban == "ban"} {return "ban!"} else {return "kick!"}%%
#       -- This would be replaced with either 'ban!' or 'kick!".
#       %%tcl return [clock format %report_time -format \
#         "$char(percent)I:$char(percent)M $char(percent)p"]%%
#       -- This will format unixtime to whatever string you decide it should be
#          in.
#     If you would like to use a percent sign (%) within any of the tcl command,
#     use the variable of: $char(percent)
#       Example:
#         %%tcl if {$kickorban == "ban"} {return "98$char(percent)?"}%%
#         -- This would return:  98%?
# Tcl statement variables to utilize:
#   $kickorban     - Will either be 'kick' or 'ban'.
#   $nick_matches  - A list of matching nicks that the ban covers.
#   $char(percent) - Will be a % sign.
# from_name, from_addy, subject and headers are only used for email.

set mc_rkb(from_name) "Abuse Monitor Bot"
set mc_rkb(from_addy) "user@somehost.com"
set mc_rkb(subject) "Kick and ban log(s) for %channel."
set mc_rkb(headers) {
  Content-type: text/html
}

set mc_rkb(body) {
  <html>
    <head></head>
    <body bgcolor='white' text='black' link='white' alink='white' vlink='white'>
      <center>
        <font size='+2'>Kicks and bans log for</font>
        <font size='+2' color='red'>%channel</font>
      </center>
      <hr>
      <dd>Total kicks for the channel:  %total_kicks<br>
      <dd>Total bans for the channel:   %total_bans<br>
      <table border='0' cellpading='0' cellspacing='0' width='100%'>
        <tr>
          <td bgcolor='black' width='1%'>&nbsp;</td>
          <td bgcolor='black' width='50%'>
            <font color='white'>
              <b>Handle</b>
            </font>
          </td>
          <td bgcolor='black' width='24%'>
            <font color='white'>
              <b>Total Kicks</b>
            </font>
          </td>
          <td bgcolor='black' width='24%'>
            <font color='white'>
              <b>Total Bans</b>
            </font>
          </td>
          <td bgcolor='black' width='1%'>&nbsp;</td>
        </tr>
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td bgcolor='black' colspan='3'>
            <font color='white'>
              <dd>Important bot access.
            </font>
          </td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td bgcolor='white' colspan='3'>
            <li>IRC-Nick kick'd whomever<br>
            <dd>Reason<br><dd>Time</td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td bgcolor='#E1E1E1' colspan='3'>
            <li>IRC-Nick ban'd whomever<br>
            <dd>Reason<br>
            <dd>Time</td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
%%Start_handle_report%%
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td bgcolor='black'>
            <font color='white'>
              <b>%report_handle</b>
              %%tcl if {"%report_handle" == "MC_8"} {
                return " -- That's the coder!"
              }%%
            </font>
          </td>
          <td bgcolor='black'>
            <font color='white'><b>%report_kicks</b></font>
          </td>
          <td bgcolor='black'>
            <font color='white'><b>%report_bans</b></font>
          </td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td bgcolor='black' colspan='3'>
            <font color='white'>
              <dd>%report_access
            </font>
          </td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
%%Start_log_entries%%
        <tr>
          <td bgcolor='black'>&nbsp;</td>
          <td
           bgcolor='%%tcl if {$kickorban == "kick"} {
              return "white"} else {return "#E1E1E1"}%%'
           colspan='3'
          >
            <li>
            %report_nick
        %%tcl if {$kickorban == "kick"} {return "kick"} else {return "bann"}%%ed
            %report_victim
            %%tcl if {$kickorban == "ban"} {
              return "([join $nick_matches ", "])"
            }%%<br>
            <dd>Reason:  %report_reason<br>
            <dd>Time:
              %%tcl return [clock format %report_time -format \
           "$char(percent)I:$char(percent)M:$char(percent)S $char(percent)p"]%%
          </td>
          <td bgcolor='black'>&nbsp;</td>
        </tr>
%%Stop_log_entries%%
%%Stop_handle_report%%
        <tr>
          <td bgcolor='black' colspan='5' align='right'>
            <font color='white'>
              <a
            href='http://mc.purehype.net/script_info.tcl?script=record_kick-ban'
              >http://mc.purehype.net/script_info.tcl?script=record_kick-ban</a>
            </font>
          </td>
        </tr>
      </table>
    </body>
  </html>
}

#
##


##
# Edit no further, tcl coding below.
##
#

## SVS insert (pre code)
#Script:mc_rkb
catch {unset temp}

foreach temp(bind) [binds mc:rkb:*] {
  foreach {temp(1) temp(2) temp(3) temp(4) temp(5)} $temp(bind) break
  catch {unbind $temp(1) $temp(2) $temp(3) $temp(5)}
}

set mc_rkb(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_rkb :config:*] {
  lappend mc_rkb(info:vars) [list $temp(name) $temp(value)]
}
set mc_rkb(info:loc) [info script]
array set mc_rkb [list \
  script                 "Record Kick and Bans" \
  version                "v3.1" \
  svs:script             "record_kick-ban" \
  svs:version            "003001000000" \
  svs:client_version     "v4.1.2" \
  svs:client_svs_version "004001002000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "80" \
  svs:get                "/index.tcl"]
set mc_rkb(svs:query)    "svs=$mc_rkb(svs:script)&"
append mc_rkb(svs:query) "version=$mc_rkb(svs:version)&"
append mc_rkb(svs:query) \
  "svs_version=$mc_rkb(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_rkb(script) $mc_rkb(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  uplevel #0 {
    if {[info exists temp] && ![array exists temp]} {unset temp}
    set temp(svs_return) [list 0 "Need to upgrade eggdrop."]
  }; return 1
}
## ^

# Error Catching System (ECS), v4.1.
proc mc:rkb:errchk {command args} {
  
  # Enable (1) or disable (0) auto reporting of bugs to mc8@purehype.net.
  # This setting here for those who want to disable it in fear of privacy
  # violations.
  set enable_auto_reporting 1
  
  if {![info exists ::lastCommand]} {set ::lastCommand [list]}
  set ::lastCommand \
    "[list [list [clock seconds] $command $args]] $::lastCommand"
  set ::lastCommand [lrange $::lastCommand 0 4]
  if {![catch {eval $command $args} return]} {return $return}
  if {$::errorCode == "mc.ecs.done"} {return -errorcode mc.ecs.done -code error}
  
  set temp(lastbind) [expr {[info exists ::lastbind]?$::lastbind:"-NULL-"}]
  set temp(eversion) [expr {[info exists ::version]?$::version:"-NULL-"}]
  set message "
    ************************************
    (ECS 4.1) Error found in TCL script.
    --------------
    Script name   : $::mc_rkb(script)
    Script version: $::mc_rkb(version)
    Egg. Version  : $temp(eversion)
    TCL Version   : [info tclversion] ([info patchlevel])
    --------------
    Last Bind     : $temp(lastbind)
    Last Commands :"
  foreach line $::lastCommand {
    foreach {time command arg} $line break
    append message "\n        ${time}- $command $arg"
  }
  append message "\n    Error stack   :"
  foreach line [split $::errorInfo \n] {
    append message "\n        $line"
  }
  append message "\n    --------------"
  
  set message [lrange [split $message \n] 1 end]
  set offset [string first * [lindex $message 0]]
  set new_message [list]
  foreach line $message {lappend new_message [string range $line $offset end]}
  set message $new_message
  
  if {!$enable_auto_reporting ||
      [catch {socket -async mc.purehype.net 80} sid]} {
    foreach line $message {putloglev o * $line}
    putloglev o * "Submit this bug to http://mc.purehype.net/bugzilla/ . If"
    putloglev o * "you are experiencing problems with bugzilla, contact MC_8"
    putloglev o * "via email at mc8@purehype.net. Please include all"
    putloglev o * "information shown here, in this ECS report."
    putloglev o * "************************************"
    return -errorcode mc.ecs.done -code error
  }
  fconfigure $sid -blocking 0 -buffering line

  set query [list]
  # This info is passed should I need to hunt down the bot's owner for more
  # information.
  lappend query "Admin   : [expr {[info exists ::admin]?$::admin:""}]"
  lappend query "Owner   : [expr {[info exists ::owner]?$::owner:""}]"
  lappend query "Botnick : [expr {[info exists ::botnick]?$::botnick:""}]"
  lappend query "Server  : [expr {[info exists ::server]?$::server:""}]"
  lappend query "Channels: [join [lsort -dictionary [channels]] ", "]"
  lappend query ""
  
  foreach line $message {lappend query $line}
  lappend query "************************************"
  
  set new_query [list]
  foreach line $query {
    regsub -all -- "(\002|\017|\026|\037)" $line "" line
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $line "" line
    regsub -all {\%} $line "%25" line
    set i [string length $line]
    while {[regexp {[^a-zA-Z0-9%]} $line toh] && ($i >= 0)} {
      scan "$toh" %c dec
      regsub -all -- "\\${toh}" $line "%[format %X $dec]" line
      incr i -1
    }; lappend new_query $line
  }; set query $new_query
  
  set query "message=[join $query %0a]"
  puts $sid "POST /report_bug.tcl HTTP/1.0\
           \nHost: mc.purehype.net:80\
           \nContent-type: application/x-www-form-urlencoded\
           \nContent-Length: [expr [string length $query] +2]"
  puts $sid \n$query
  close $sid

  foreach line $message {putloglev o * $line}
  putloglev o * "Automatically sending bug report to MC_8."
  putloglev o * "If you have a firewall setup, it may block the sending of this"
  putloglev o * "report. You can check the status of your bug, as soon as MC_8"
  putloglev o * "adds it, at http://mc.purehype.net/bugzilla/ ."
  putloglev o * "************************************"
  
  return -errorcode mc.ecs.done -code error
}
# ^

setudef flag mc.recordkb

set mc_rkb(whoisfield) "RKB.Email"
if {![info exists whois-fields]} {set whois-fields ""}
if {[lsearch -exact ${whois-fields} $mc_rkb(whoisfield)] == "-1"} {
  lappend whois-fields $mc_rkb(whoisfield)
}

bind dcc - rkb.email mc:rkb:dcc:rkb.email
proc mc:rkb:dcc:rkb.email {handle idx arg} {
  return [mc:rkb:errchk mc:rkb:dcc:rkb.email_ $handle $idx $arg]
}
proc mc:rkb:dcc:rkb.email_ {handle idx arg} {
  global mc_rkb
  if {$arg == ""} {
    if {[getuser $handle XTRA $mc_rkb(whoisfield)] == ""} {
      putdcc $idx "You do not have any e-mail address' set."
      return 0
    }
    set temp(emails) [split [getuser $handle XTRA $mc_rkb(whoisfield)]]
    set temp(llength) [llength $temp(emails)]
    set s [expr {($temp(llength) == "1")?"":"'"}]
    putdcc $idx "Removed $temp(llength) e-mail address$s from your record."
    setuser $handle XTRA $mc_rkb(whoisfield) ""
    return 1
  }
  if {[regexp -- {^-?-?(h(elp)?|\?|syntax|usage)$} $arg]} {
    set temp(syntax) {[email@address1 [email@address2 [email@addressN]]]}
    putdcc $idx "Usage: rkb.email $temp(syntax)"
    return 0
  }
  set s [expr {([llength [split $arg]] == "1")?"":"'"}]
  putdcc $idx "Set your e-mail address$s to: $arg"
  setuser $handle XTRA $mc_rkb(whoisfield) $arg
  return 1
}

bind dcc m rkb.chemail mc:rkb:dcc:rkb.chemail
proc mc:rkb:dcc:rkb.chemail {handle idx arg} {
  return [mc:rkb:errchk mc:rkb:dcc:rkb.chemail_ $handle $idx $arg]
}
proc mc:rkb:dcc:rkb.chemail_ {handle idx arg} {
  global mc_rkb
  if {[regexp -- {^-?-?(h(elp)?|\?|syntax|usage)$} $arg]} {
    set temp(syntax) \
      {<handle> [email@address1 [email@address2 [email@addressN]]]}
    putdcc $idx "Usage: rkb.chemail $temp(syntax)"
    return 0
  }
  set who [lindex [split $arg] 0]
  if {![validuser $who]} {
    putdcc $idx "$who is not a valid user."
    return 0
  }
  set arg [join [lrange [split $arg] 1 end]]
  if {$arg == ""} {
    if {[getuser $who XTRA $mc_rkb(whoisfield)] == ""} {
      putdcc $idx "$who does not have any e-mail address' set."
      return 0
    }
    set temp(emails) [split [getuser $handle XTRA $mc_rkb(whoisfield)]]
    set temp(llength) [llength $temp(emails)]
    set s [expr {($temp(llength) == "1")?"":"'"}]
    putdcc $idx "Removed $temp(llength) e-mail address$s from $who's record."
    setuser $who XTRA $mc_rkb(whoisfield) ""
    return 1
  }
  set s [expr {([llength [split $arg]] == "1")?"":"'"}]
  putdcc $idx "Set $who's e-mail address$s to: $arg"
  setuser $who XTRA $mc_rkb(whoisfield) $arg
  return 1
}

bind kick - * mc:rkb:kick
proc mc:rkb:kick {nick uhost handle channel victim reason} {
  mc:rkb:list log [list kick $nick $handle $channel $victim $reason]
}

bind mode - "* +b" mc:rkb:ban
proc mc:rkb:ban {nick uhost handle channel mc victim} {
  mc:rkb:list log [list ban $nick $handle $channel $victim $uhost]
}

set temp(time) ""
foreach temp(time_) [split $mc_rkb(:config:time)] {
  if {($temp(time_) > "23") || ($temp(time_) < "0")} {
    lappend temp(time) 00
  } elseif {[string length $temp(time_)] == "1"} {
    lappend temp(time) 0$temp(time_)
  } else {
    lappend temp(time) $temp(time_)
  }
}
foreach temp(bind) [binds time] {
  if {[lindex $temp(bind) 4] != "mc:rkb:tts"} {continue}
  unbind time [lindex $temp(bind) 1] [lindex $temp(bind) 2] mc:rkb:tts
}
foreach temp(time_) $temp(time) {
  bind time - "00 $temp(time_) * * *" mc:rkb:tts
}

proc mc:rkb:tts {{args ""}} {
  return [mc:rkb:errchk mc:rkb:tts_ $args]
}
proc mc:rkb:tts_ {{args ""}} {
  global mc_rkb botnick
  putlog "emailing kick/ban log(s) ..."
  foreach channel [channels] {
    if {![mc:rkb:chanflag $channel mc.recordkb]} {
      mc:rkb:list reset $channel
      continue
    }
    set temp(::subject) [mc:rkb:replace -- $mc_rkb(subject) [list \
      %channel $channel]]
    set temp(::headers) ""
    foreach temp() [split $mc_rkb(headers) \n] {
      set temp() [string trim $temp()]
      if {$temp() == ""} {continue}
      lappend temp(::headers) $temp()
    }

    catch {unset cache}
    set cache(total_bans) 0
    set cache(total_kicks) 0
    set cache(!list) ""

    foreach entry [lsort -index 1 -dictionary [mc:rkb:list list $channel]] {
      set orig_handle [lindex $entry 1]
      set handle [string tolower $orig_handle]
      if {[lsearch -exact [string tolower $cache(!list)] $handle] == "-1"} {
        lappend cache(!list) $orig_handle
      }
      set bans [list $handle bans]
      set kicks [list $handle kicks]
      set access [list $handle access]
      if {![info exists cache($bans)]} {set cache($bans) 0}
      if {![info exists cache($kicks)]} {set cache($kicks) 0}

      lappend cache(::$handle) $entry

      set kickorban [lindex $entry 7]

      if {$kickorban == "ban"} {
        incr cache($bans) 1
        incr cache(total_bans) 1
      } elseif {$kickorban == "kick"} {
        incr cache($kicks) 1
        incr cache(total_kicks) 1
      }

      if {![info exists cache($access)]} {
        set cache($access) ""
        if {[matchattr $handle +b]} {lappend cache($access) "Bot"}
        if {[matchattr $handle +n]} {lappend cache($access) "Global Owner"} \
        elseif {[matchattr $handle +m]} {
          lappend cache($access) "Global Master"
        } elseif {[matchattr $handle +t]} {
          lappend cache($access) "Botnet Master"
        } elseif {[matchattr $handle +o]} {lappend cache($access) "Global Op"} \
        elseif {[matchattr $handle +v]} {
          lappend cache($access) "Global Voice"
        } elseif {[matchattr $handle +f]} {
          lappend cache($access) "Global Friend"
        }
        if {[matchattr $handle |+n $channel]} {
          lappend cache($access) "Channel Owner"
        } elseif {[matchattr $handle |+m $channel]} {
          lappend cache($access) "Channel Master"
        } elseif {[matchattr $handle |+o $channel]} {
          lappend cache($access) "Channel Op"
        } elseif {[matchattr $handle |+v $channel]} {
          lappend cache($access) "Channel Voice"
        } elseif {[matchattr $handle |+f $channel]} {
          lappend cache($access) "Channel Friend"
        }
        set cache($access) [join $cache($access) ", "]
      }
    }

    regsub -- {^\n} $mc_rkb(body) "" temp(body)

    set temp(body) [mc:rkb:replace -- $temp(body) [list %channel $channel]]

      set regex {^(.*[^%])%%Start_handle_report%%}
    append regex {(.*[^%])%%Start_log_entries%%}
    append regex {(.*[^%])%%Stop_log_entries%%}
    append regex {(.*[^%])%%Stop_handle_report%%}
    append regex {(.*)$}
    regexp -- $regex $temp(body) -> temp(!a) temp(!b) temp(!c) temp(!d) temp(!e)

    set tcl_regex {^(.*)%%tcl(?: |\t)*([^%]*)%%(.*)$}

    set char(percent) %

    set temp(::body) [mc:rkb:replace -- $temp(!a) [list \
      %total_bans  $cache(total_bans) \
      %total_kicks $cache(total_kicks)]]
    while {[regexp -- $tcl_regex $temp(::body) -> a b c]} {
      catch {eval $b} b
      set temp(::body) $a$b$c
    }
    foreach handle $cache(!list) {
      set orig_handle $handle
      set handle [string tolower $handle]
      set bans [list $handle bans]
      set kicks [list $handle kicks]
      set access [list $handle access]
      append temp(::body) [mc:rkb:replace -- $temp(!b) [list \
        %total_bans    $cache(total_bans) \
        %total_kicks   $cache(total_kicks) \
        %report_handle $orig_handle \
        %report_kicks  $cache($kicks) \
        %report_bans   $cache($bans) \
        %report_access $cache($access)]]
      while {[regexp -- $tcl_regex $temp(::body) -> a b c]} {
        catch {eval $b} b
        set temp(::body) $a$b$c
      }
      foreach entry $cache(::$handle) {
        set entry_nick [lindex $entry 2]
        set entry_victim [lindex $entry 3]
        set entry_reason [lindex $entry 4]
        set entry_unixtime [lindex $entry 5]
        set nick_matches [lindex $entry 6]
        set kickorban [lindex $entry 7]
        append temp(::body) [mc:rkb:replace -- $temp(!c) [list \
          %total_bans    $cache(total_bans) \
          %total_kicks   $cache(total_kicks) \
          %report_handle $orig_handle \
          %report_kicks  $cache($kicks) \
          %report_bans   $cache($bans) \
          %report_access $cache($access) \
          %report_nick   $entry_nick \
          %report_victim $entry_victim \
          %report_reason $entry_reason \
          %report_time   $entry_unixtime]]
        while {[regexp -- $tcl_regex $temp(::body) -> a b c]} {
          catch {eval $b} b
          set temp(::body) $a$b$c
        }
      }
      append temp(::body) [mc:rkb:replace -- $temp(!d) [list \
        %total_bans    $cache(total_bans) \
        %total_kicks   $cache(total_kicks) \
        %report_handle $orig_handle \
        %report_kicks  $cache($kicks) \
        %report_bans   $cache($bans) \
        %report_access $cache($access)]]
      while {[regexp -- $tcl_regex $temp(::body) -> a b c]} {
        catch {eval $b} b
        set temp(::body) $a$b$c
      }
    }
    append temp(::body) [mc:rkb:replace -- $temp(!e) [list \
      %total_bans  $cache(total_bans) \
      %total_kicks $cache(total_kicks)]]
    while {[regexp -- $tcl_regex $temp(::body) -> a b c]} {
      catch {eval $b} b
      set temp(::body) $a$b$c
    }

    foreach handle [userlist $mc_rkb(:config:email_flag) $channel] {
      set temp(getuser) [getuser $handle XTRA $mc_rkb(whoisfield)]
      foreach addy [split $temp(getuser) " ,;"] {
        if {![regexp {^.*[^@]@.*\.[a-zA-Z][a-zA-Z][a-zA-Z]?[a-zA-Z]?$} $addy]} {
          putloglev d * \
            "$mc_rkb(script): $handle has an invalid e-mail address; $addy"
          continue
        }
        if {[catch {
          mc:rkb:sendemail \
            [list $mc_rkb(from_name) $mc_rkb(from_addy)] \
            [list $handle $addy] \
            $temp(::subject) $temp(::body) $temp(::headers)} error]} {
  putloglev d * "$mc_rkb(script): Email NOT sent to \"$handle\" <$addy>: $error"
          continue
        }
        putloglev d * "$mc_rkb(script): Email sent to \"$handle\" <$addy>"
      }
    }

    if {$mc_rkb(:config:file) != ""} {
      set temp(::file) [mc:rkb:replace -- $mc_rkb(:config:file) \
        [list %channel [string tolower $channel]]]
      if {![catch {open $temp(::file) w} id]} {
        putloglev d * "$mc_rkb(script): Error opening $temp(::file): $id"
      } else {
        puts $id $temp(::body)
        close $id
        putloglev d * "$mc_rkb(script): Wrote $temp(::file)."
      }
    }

    mc:rkb:list reset $channel
  }
}

proc mc:rkb:list {command {arg ""}} {
  return [mc:rkb:errchk mc:rkb:list_ $command $arg]
}
proc mc:rkb:list_ {command {arg ""}} {
  # Format:
  # <channel> <hand> <nick> <victim> <reason> <unixtime> <victim_matches> \
  # <kick/ban>
  global mc_rkb
  if {![file exists $mc_rkb(:config:log)]} {close [open $mc_rkb(:config:log) w]}
  switch -- $command {
    reset {
      # in: <channel>
      # out:
      set channel [string tolower $arg]
      set list ""
      foreach entry [mc:rkb:list list] {
        if {[lindex $entry 0] == $channel} {continue}
        lappend list $entry
      }
      mc:rkb:list save_list $list
    }
    list {
      # in: <channel>
      # out: <list>
      set channel [string tolower $arg]
      set list ""
      set io [open $mc_rkb(:config:log) r]
      if {![eof $io]} {gets $io entry}
      while {![eof $io]} {
        gets $io entry
        if {[join $entry] == ""} {continue}
        if {($channel == "") || ([lindex $entry 0] == $channel)} {
          lappend list $entry
        }
      }
      close $io
      return $list
    }
    save_list {
      # in: <list>
      # out:
      set list $arg
      set io [open $mc_rkb(:config:log) w]
      puts $io "#v2.0:$mc_rkb(script):$mc_rkb(version):[clock seconds]"
      foreach entry $list {
        puts $io $entry
      }
      close $io
    }
    log {
      # in: 'kick' <nick> <handle> <channel> <victim> <reason>
      # in: 'ban' <nick> <handle> <channel> <victim> <uhost>
      # out:
      set kickorban [lindex $arg 0]
      set nick [lindex $arg 1]
      set handle [lindex $arg 2]
      set channel [string tolower [lindex $arg 3]]
      set victim [lindex $arg 4]
      set reason [lindex $arg 5]

      if {![mc:rkb:chanflag $channel mc.recordkb]} {return 0}

      if {$kickorban == "kick"} {set victim_matches ""} \
      else {
        if {$nick == ""} {set nick $reason}
        if {[set reason [mc:rkb:banreason $victim $channel]] == "0"} {
          set reason "Not a ban within the bot, reason unknown."
        }
        set victim_matches [mc:rkb:findnicks $victim $channel]
      }
      set io [open $mc_rkb(:config:log) a]
      puts $io [list $channel $handle $nick $victim $reason [clock seconds] \
        $victim_matches $kickorban]
      close $io
    }
  }
}

proc mc:rkb:banreason {ban channel} {
  if {![isban $ban $channel] && ![isban $ban]} {return 0}
  foreach line "[banlist $channel] [banlist]" {
    if {[lindex [string tolower $line] 0] == [string tolower $ban]} {
      return "[lindex $line 5]: [lindex $line 1]"
    }
  }; return 0
}


## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:rkb:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
  wrong # args: should be "mc:rkb:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) || (($llength != "end") &&
      ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:rkb:unlist {{args ""}} {
  mc:rkb:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# 2list <text>
#     version:
#       v1.0
proc mc:rkb:2list {{args ""}} {
  mc:rkb:badargs $args 1 1 "text"
  mc:rkb:unlist $args text

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# findnicks <nick!ident@host.domain> [channel]
#     version:
#       v2.0
proc mc:rkb:findnicks {{args ""}} {
  mc:rkb:badargs $args 1 2 "nick!ident@host.domain ?channel?"
  mc:rkb:unlist $args hostmask channel

  set hostmask [string tolower $hostmask]

  if {$channel == ""} {set channels [channels]} \
  elseif {![validchan $channel]} {error "no such channel record"} \
  else {set channels [list $channel]}
  set origional_channel $channel

  set list ""
  foreach channel $channels {
    foreach user [chanlist $channel] {
      set nuhost [string tolower $user![getchanhost $user $channel]]
      if {[string match $hostmask $nuhost]} {
        lappend list $user[expr {($origional_channel != "")?"":"@$channel"}]
      }
    }
  }; return $list
}

# chanflag <channel> <flag>
#     version:
#       v3.1
proc mc:rkb:chanflag {{args ""}} {
  mc:rkb:badargs $args 2 2 "channel flag"
  mc:rkb:unlist $args channel flag

  if {![validchan $channel]} {error "no such channel record"}

  # Try the 'channel' commands' 'get' option first, it's faster since it is
  # written in C by the eggdrop development team.
  if {![catch {channel get $channel $flag} output]} {return $output}

  set temp(chaninfo) [string tolower [channel info $channel]]
  if {[lsearch -exact $temp(chaninfo) +[string tolower $flag]] >= "0"} {
    return 1
  }; return 0
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:rkb:replace {{args ""}} {
  mc:rkb:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:rkb:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:rkb:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

# sendemail <from> <to> <subject> <body> [headers] [-wait]
#     version:
#       v1.5

# You can set this to emulate another SMTP client.
set mc_rkb(xmailer) \
  "Send eMail procedure by MC_8 (Carl M. Gregory) - http://mc.p"
append mc_rkb(xmailer) \
  "urehype.net/ - TCL [info tclversion] ([info patchlevel])."

proc mc:rkb:sendemail {{args ""}} {
  mc:rkb:badargs $args 4 6 "from to subject body ?headers? ?-wait?"
  mc:rkb:unlist $args from to subject body headers wait

  global mc_rkb

  if {![info exists headers]} {set headers ""}
  if {![info exists wait]} {set wait ""}
  if {($wait == "") && ($headers == "-wait")} {
    set wait -wait
    set headers ""
  }
  if {$wait == "-wait"} {
    if {
    [catch {socket $mc_rkb(:config:smtp_server) $mc_rkb(:config:smtp_port)} sid]
    } {
      error "cannot create socket: $sid"
    }
    set mc_rkb(:vwait:$sid) 1
  } else {
 set sid [socket -async $mc_rkb(:config:smtp_server) $mc_rkb(:config:smtp_port)]
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:rkb:sendemail_fileevent $sid timeout"]
  fileevent $sid readable \
    [list mc:rkb:sendemail_fileevent $sid $tout $from $to $subject \
    $body $headers]
  if {$wait == "-wait"} {vwait mc_rkb(:vwait:$sid)}
}
proc mc:rkb:sendemail_fileevent {{args ""}} {
  set optional "?from? ?to? ?subject? ?body? ?headers?"
  mc:rkb:badargs $args 2 7 "socket_id timeout_after_id $optional"
  mc:rkb:unlist $args sid tout from to subject body headers

  global mc_rkb

  set last_command_a :temp:$sid:last_command
  if {$tout == "timeout"} {
    catch {unset mc_rkb($last_command_a)}
    catch {unset mc_rkb(:vwait:$sid)}
    close $sid
    error "timeout connecting to SMTP server"
  }
  if {[eof $sid]} {
    catch {unset mc_rkb($last_command_a)}
    catch {unset mc_rkb(:vwait:$sid)}
    close $sid
    return
  }
  after cancel $tout
  if {![info exists mc_rkb($last_command_a)]} {
    set mc_rkb($last_command_a) ""
  }
  set last_command $mc_rkb($last_command_a)
  gets $sid line
  set line [split $line " -"]
  set rfc [lindex $line 0]
  set info [join [lrange $line 1 end]]
  switch -- $rfc {
    221 {
      switch -- $last_command {
        QUIT {
          catch {unset mc_rkb($last_command_a)}
          catch {unset mc_rkb(:vwait:$sid)}
          close $sid
          return
        }
        default {mc:rkb:sendemail_def_error}
      }
    }
    220 {
      switch -- $last_command {
        "" {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    250 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "MAIL From:<[lindex $from 1]>"}
        HELO {mc:rkb:sendemail_puts $sid "MAIL From:<[lindex $from 1]>"}
        MAIL {
          set addy [lindex $to 1]
          set mc_rkb(:temp:$sid:last_to) 1
          mc:rkb:sendemail_puts $sid "RCPT To:<$addy>"
        }
        RCPT {
          set last_to_a :temp:$sid:last_to
          set last_to $mc_rkb($last_to_a)
          if {$last_to >= [expr [llength $to]-1]} {
            catch {unset mc_rkb(:temp:$sid:last_to)}
            mc:rkb:sendemail_puts $sid "DATA "
            return
          }
          incr mc_rkb($last_to_a) 2
          incr last_to 2
          set addy [lindex $to $last_to]
          mc:rkb:sendemail_puts $sid "RCPT To:<$addy>"
        }
        DATA_d {
          mc:rkb:sendemail_puts $sid "QUIT"
        }
        default {mc:rkb:sendemail_def_error}
      }
    }
    354 {
      switch -- $last_command {
        DATA {
          foreach {name addy} $to {
            puts $sid "To: \"$name\" <$addy>"
          }
          puts $sid "From: \"[lindex $from 0]\" <[lindex $from 1]>"
          puts $sid "Subject: $subject"
          foreach header $headers {
            puts $sid $header
          }
          puts $sid "X-Mailer: $mc_rkb(xmailer)"
          puts $sid "X-Originating-Host: [info hostname]"
          puts $sid ""
          foreach line [split $body \n] {
            regsub -- ^\\. $line .. line
            puts $sid $line
          }
          puts $sid .
          flush $sid
          set mc_rkb($last_command_a) DATA_d
        }
        default {mc:rkb:sendemail_def_error}
      }
    }
    421 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    500 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    501 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    502 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    554 {
      switch -- $last_command {
        EHLO {mc:rkb:sendemail_puts $sid "HELO [info hostname]"}
        default {mc:rkb:sendemail_def_error}
      }
    }
    default {mc:rkb:sendemail_def_error}
  }
}
proc mc:rkb:sendemail_puts {sid command} {
  global mc_rkb
  puts $sid $command
  set mc_rkb(:temp:$sid:last_command) [lindex [split $command] 0]
  flush $sid
}
proc mc:rkb:sendemail_def_error {} {
  uplevel 1 {error "unknown reply, '$rfc' to '$last_command'; $info"}
}

## End of More Tools quick procs.


## SVS v3.2.1
set mc_rkb(svs:client_version) "v3.2.1"
if {![info exists mc_rkb(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_rkb(svs:mode)]} {
  set mc_rkb(svs:mode) 0
}
if {![info exists mc_rkb(svs:notify)]} {
  if {![info exists owner]} {set owner ""}
  set mc_rkb(svs:notify) $owner
}

bind time - "00 00 *" mc:rkb:do_svs
proc mc:rkb:do_svs {{args ""}} {
  global mc_rkb
  mc:rkb:do_svs_ $mc_rkb(svs:server) $mc_rkb(svs:port) $mc_rkb(svs:get)
}

proc mc:rkb:do_svs_ {svs_server svs_port svs_get} {
  global mc_rkb
  if {[catch {
          socket -async $svs_server $svs_port
             } sid]} {
    putloglev d * "$mc_rkb(script): SVS socket error: $sid"
    return 1
  }

  fconfigure $sid -blocking 1 -buffering line
  set tout \
    [after 60000 "mc:rkb:svs_talk $sid timeout $svs_server $svs_port"]
  fileevent $sid readable "mc:rkb:svs_talk $sid $tout"
  puts $sid "GET $svs_get?$mc_rkb(svs:query) HTTP/1.0\
           \nHost: $svs_server:$svs_port\n"
  flush $sid
}

proc mc:rkb:svs_talk {sid tout {svs_server ""} {svs_port ""}} {
  global mc_rkb
  set array [list svs temp $sid]
  if {$tout == "timeout"} {
    set temp(1) "$svs_server:$svs_port"
    putloglev d * \
      "$mc_rkb(script): SVS Warning: Timed out connecting to $temp(1)."
    catch {unset mc_rkb($array)}
    close $sid
    return 0
  }
  if {[eof $sid]} {
    catch {unset mc_rkb($array)}
    close $sid
    return 1
  }
  gets $sid get
  after cancel $tout
  if {![info exist mc_rkb($array)]} {
    if {$get == ""} {set mc_rkb($array) 1}
    return -1
  }
  if {($get == "") || [catch {llength $get}]} {
    return -2
  }
  switch -- [lindex $get 0] {
    200 {
      set temp(host) [lindex $get 1]
      set temp(port) [lindex $get 2]
      set temp(get) [lindex $get 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_rkb(script): SVS is being redirected to $temp(cache)."
      mc:rkb:do_svs_ $temp(host) $temp(port) $temp(get)
      close $sid
      return 200
    }
    003 {
      set temp(reply) [lrange $get 1 end]
      for {set number 0} {$number <= 5} {incr number} {
        set temp(reply:$number) [lindex $temp(reply) $number]
      }
      if {$temp(reply:0) != $mc_rkb(svs:script)} {
        set temp(1) "wanted $mc_rkb(svs:script), got $temp(reply:0)"
        putloglev d * "$mc_rkb(script): SVS Error: $temp(1)"
        unset mc_rkb($array)
        close $sid
        return -3
      }
      if {$mc_rkb(svs:mode)} {
        set temp(svs:version) [string range $mc_rkb(svs:version) 0 8]999
      } else {
        set temp(svs:version) [string range $mc_rkb(svs:version) 0 11]
      }
      if {$temp(reply:1) > $temp(svs:version)} {
        set temp(note) $temp(reply:5)
        regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
        regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
        regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
        regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
        regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
        regsub -all -- %version $temp(note) $mc_rkb(version) temp(note)
        foreach temp(to) [split $mc_rkb(svs:notify) ",; "] {
          if {[string trim $temp(to)] == ""} {continue}
          regsub -- %nick $temp(note) $temp(to) temp(note2)
          set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
          if {[string match *$temp(note2)* $temp(lunotes)]} {
            set temp(found_note) 0
            foreach temp(unote) $temp(lunotes) {
              if {$temp(note2) == [lindex $temp(unote) 2]} {
                set temp(found_note) 1
                break
              }
            }
            if {$temp(found_note)} {continue}
          }
          set temp(error) "sending note to $temp(to) -> "
          switch -- [sendnote SVS $temp(to) $temp(note2)] {
            0 {
              if {![validuser $temp(to)]} {
                append temp(error) "invalid user"
              } else {append temp(error) "unknown error"}
              putloglev d * \
                "$mc_rkb(script): SVS sendnote error: $temp(error)"
            }
            3 {
              append temp(error) "notebox too full"
              putloglev d * \
                "$mc_rkb(script): SVS sendnote error: $temp(error)"
            }
          }
        }
      }
      unset mc_rkb($array)
      close $sid
      return 2
    }
  }
}
## ^

putloglev * o "$mc_rkb(script) $mc_rkb(version) by MC_8 loaded."

#
##

##
# History
##
# v3.1 (10.07.03)
#  MC_8 -       - Upgraded SVS Client.  v3.2.1 -> v4.1.2
#  MC_8 -       - Upgraded ECS.  v3.0 -> v4.1
#  MC_8 - heber - Created a catch for sending mail to stop bug reports for
#                 socket issues such as host unreachable or timeout of the smtp
#                 server.  Will dump to console d but not as a debug for a
#                 script problem.
#                 Bugzilla Bug 261 
#
#
# v3.0 (02.12.03)
#  MC_8 - HC - Added `file` variable.
#              Bugzilla Bug 106
#  MC_8 -    - Upgraded SVS Client.  v1.2 -> v3.2.1
#  MC_8 -    - Wasn't saving email address' correctly, would reset on
#              re(start|hash).
#  MC_8 -    - Fixed duplication problem with records due to multi channels.
#  MC_8 -    - Added an ECS system.  none -> v3.0
#  MC_8 -    - Added the `sendemail` tcl command.  none -> v1.5
#  MC_8 -    - Added the `badargs` tcl command.  none -> v1.0
#  MC_8 -    - Added the `unlist` tcl command.  none -> v1.0
#  MC_8 -    - Added the `2list` tcl command.  none -> v1.0
#  MC_8 -    - Added the `replace` tcl command.  none -> v1.3
#  MC_8 -    - Added `findnicks` tcl command, replacing the old
#              `inter:findchanuser` tcl command.  old -> v2.0
#  MC_8 -    - Added `chanflag` tcl command, replacing the old `inter:chanon`
#              tcl command.  old -> v3.1
#  MC_8 -    - Renamed `sendmail` to `tts`, and re coded.
#  MC_8 -    - Recoded how it setups up and removes the time binds.
#  MC_8 -    - Removed now unused `log` tcl command.
#  MC_8 -    - Added `list` tcl command.
#  MC_8 -    - Renamed tcl command `inter:banreason` to `banreason`, and re
#              coded.
#  MC_8 -    - Script no longer required the sendmail program to send it's
#              e-mails.  I will be using a TCL socket connection directly to the
#              mail server.
#  MC_8 -    - Added a templet type system, so the user can better customize
#              what get's sent.  TCL settings added for this, `from_name`,
#              `from_addy`, `headers`, and `body`.
#  MC_8 -    - Removed `from`, `format` tcl settings.
#
# v2.0 (03.16.01)
#  MC_8 - Fixed, `Tcl error [mc:rkb:dcc:email]: can't read "userinfo": no such
#         variable'.
#  MC_8 - This script was built with, and tested on a postfix sendmail version.
#         I didn't know that it wasn't standard sendmail, made it compatible
#         with postfix and the regular sendmail version.
#  MC_8 - Added irc nicks (if available) of who it is the ban is pertaining to.
#  MC_8 - Added major bot access to e-mailed output.
#  MC_8 - Added servers name for recording ban's, instead of it showing "", now
#         shows the irc.server.com.
#  MC_8 - Redid the from variable, you can now specify it with a little more
#         detail, such as having a reply to address.
#  MC_8 - Added ability to set a subject on the e-mail's.
#  MC_8 - Added option to send e-mail in plain text or html.
#  MC_8 - Added exemption options, who do you NOT want to record?
#  MC_8 - Changed way of setting when to send e-mailed logs.  It's now
#         more user friendly to setup.
#  MC_8 - Recoded how it sends e-mail, doesn't use the exec's, uses tcl's
#         open |... this is cleaner and more efficient.
#  MC_8 - Made the e-mail's channel specific, so you can log more than 1
#         channel and have separate info for each channel.
#  MC_8 - Made it able to change e-mail address on the fly, each user keeps
#         track of there own e-mail's via the DCC e-mail command.
#  MC_8 - Made it able to turn channels on or off for this script on the fly
#         via the DCC chanset command (read the setting for more info).
#  MC_8 - Added `e-mail` dcc command, to change e-mail address of individual
#         on the fly (similar to userinfo, if you use userinfo, don't
#         worry.. it's compatible)
#  MC_8 - Added SVS.
#  MC_8 - TallMic - Added option to specify where sendmail is.
#  MC_8 - TallMic - IF Else problem fixed.
#
# v1.0 (11.15.00)
#  MC_8 - First release
##
