#This contains keywords that can be used in all tests

*** Settings ***
Documentation  Includes common keywords defined within _*SharedKeywordsSAN.robot*_ file but it's the same as nexi
...
...  Path to the file: _*\\PyCharm\\NEXI*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    String


*** Variables ***



*** Keywords ***

Select menu Option
    [Arguments]    ${Option}
    [Documentation]  Selects given *${Option}* from main menu screen.
    ...
    ...  Usage:
    ...
    ...    - ``Select menu Option  <OPTION>``, where <OPTION> is `Sessid`
    ...
    ...  An example:
    ...    - ``Select menu Option  CK35``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    # the following four lines are for people who have more menus, and options are not on first screen
    # send pf  24 is the same as pf7 on Adriano's mainframe
    send pf         24
    send pf7
    fill field by label  Comando ===>  FIND ${Option}
    Send enter
    Find Field     ${Option}    RIGHT
    Send string    S
    Send enter
    Sleep          2 seconds
    Log screen

Log out of TSO session
    [Documentation]  Logs out of TSO session using *S5TSO* `Sessid`
    ...
    ...  Usage:
    ...
    ...  - ``Log out of TSO session``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    # the following three lines are for people who have more menus, and options are not on first screen
    send pf         24
    send pf7
    fill field by label  Comando ===>  FIND S5TSO
    Send enter
    Find field      S5TSO   RIGHT
    Send string     i
    Send enter
    Sleep           1

Log out of CICSK session
    # the following three lines are for people who have more menus, and options are not on first screen
    send pf         24
    send pf7
    fill field by label  Comando ===>  FIND &{environment}[cicsk]
    Send enter
    Find field      &{environment}[cicsk]   RIGHT
    Send string     i
    Send enter
    Sleep           1

Connect to mainframe
    connect    Y:192.168.14.6:2399
    Sleep      2 seconds
    ${Cams user}    Credential getter    Cams user
    Fill field by label    Userid:      ${Cams user.user}
    Set log level    None
    Fill field by label    Password:    ${Cams user.password}
    Set log level    Info
    String found     12    25    P A Y M E N T \ \ S E R V I C E S \ \ F O R \ \ E U R O P E
    Send enter
    Wait for field
    log screen


Log in to TSO
    Select menu option    S5TSO
    ${Cams user}    Credential getter    Cams user
    Send String     ${Cams user.user}
    Send enter
    Set log level   None
    Send String     ${Cams user.password}
    Set log level   Info
    Send enter
    Send string     ispf
    Send enter
    String found    3   29  ISPF Primary Option Menu

Send query
    [Arguments]    @{Input query}
    FOR    ${line}    IN    @{Input query}
        Send string    ${line}
        Send tab
    END

Get out of TSO/CICSK/SAREGKT
    send pf19
    sleep           1

Go to CICSK
    Select menu Option  &{environment}[cicsk]
    send clear
    XCSR
    string found    3   1   MAIN MENU

XCSR
    send clear
    send string     xcsr
    send enter



Set UDFL
#This keyword sets CICSK parameters in UDFL
#It should probably be part of setup suite
    Go to CICSK updated
    send clear
    send string          UDFL
    send enter
    fill field by label  Company Number =====>  &{environment}[companynumber]
    fill field by label  DB2 Test Pool ID ===>  &{environment}[pool]
    send pf4
    string found         2  2  User defaults updated, new copy performed
    get out of tso/cicsk/saregkt
    log out of cicsk session

Subtract one year
#takes a date like this: dd.mm.yyyy and returns it minus one year
    [Arguments]  ${date}
    ${yy}=  Get Substring  ${date}  8
    ${yy-1}=  Set variable  ${${yy}-1}
    ${dd.mm.}=  Get Substring  ${date}  0  8
    ${returnthis}=  Convert To String  ${dd.mm.}${yy-1}
    [Return]  ${returnthis}

Backup dataset
    # THIS ONLY MAKES A BACKUP IF BACKUP WITH TODAY'S DATE DOES NOT EXIST
    # if target dataset does not exist, there is a popup Allocate Target Data Set
    # the code cannot read this popup, so this cannot be conditional
    # so we have to do this: check if backup exists, make backup if it does not, and assume that popup will appear
    [Arguments]  ${dataset name}

    ${actual date affix}=  Get current date  result_format=%y%m%d
    set test variable    ${actual date affix}

    fill field by label  Option  3.4
    send enter
    fill field by label  Dsname Level  ${dataset name}.d${actual date affix}


    log screen
    send enter
    log screen
    ${DSLIST}=  string get  3  2  6
    send pf3
    send pf3
    Return from keyword if  '${DSLIST}'=='DSLIST'
        # exit keyword if backup dataset found

    send string  ispf
    send enter
    fill field by label  Option         3.3
    send enter
    fill field by label  Option ===>    c
    fill field by label  Name           '${dataset name}
    send enter
    fill field by label  Name           '${dataset name}.d${actual date affix}
    send enter
    send string  1
    send enter
    sleep  1
    string found  3  65  Data set copied
    send pf3
    string found  3  29  ISPF Primary Option Menu

Log out of mainframe
    [Documentation]  Logs out of mainframe.
    ...
    ...  Usage:
    ...
    ...  - ``Log out of mainframe``
    ...
    ...  | Pre-requisite  | `Connect to mainframe` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label   Comando ===>   logoff
    send enter

from ISPF backup dataset
    # THIS ONLY MAKES A BACKUP IF BACKUP WITH TODAY'S DATE DOES NOT EXIST
    # if target dataset does not exist, there is a popup Allocate Target Data Set
    # the code cannot read this popup, so this cannot be conditional
    # so we have to do this: check if backup exists, make backup if it does not, and assume that popup will appear
    [Arguments]  ${dataset name}
    [Documentation]  Makes a backup of dataset if backup with today's date does not exist.
    ...
    ...  Usage:
    ...
    ...    - ``From ISPF backup dataset  ${dataset name}``
    ...
    ...  | Pre-requisite  | `Log in to TSO` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    ${actual date affix}=  Get current date  result_format=%y%m%d

    fill field by label  Option  3.4
    send enter
    fill field by label  Dsname Level  ${dataset name}.d${actual date affix}

    log screen
    send enter
    log screen
    ${DSLIST}=  string get  3  2  6
    send pf3
    send pf3
    Return from keyword if  '${DSLIST}'=='DSLIST'
        # exit keyword if backup dataset found
    send string  ispf
    send enter
    fill field by label  Option         3.3
    send enter
    fill field by label  Option ===>    c
    fill field by label  Name           '${dataset name}
    send enter
    fill field by label  Name           '${dataset name}.d${actual date affix}
    send enter
    send string  1
    send enter
    sleep  1
    string found  3  65  Data set copied
    send pf3
    string found  3  29  ISPF Primary Option Menu


Log into CICKS
    [Documentation]  Handles logging into CICKS when it's necessary, used in Go to CICKS updated keyword
    ...
    ...  Usage:
    ...
    ...    - ``Log into CICKS``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Go to CICSK updated` |
    ...  | Post-requisite | |
    ...
    ${Cams user}    Credential getter    Cams user
    Fill field by label  Userid  ${Cams user.user}
    Set log level    None
    Fill field by label    Password    ${Cams user.password}
    Set log level    Info
    send enter
    send clear

Go to CICSK updated
    [Documentation]  Goes into cicks, handles logging in, uses keyword 'Log into CICKS'
    ...
    ...  Usage:
    ...
    ...    - ``Go to CICSK updated``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | 'Log into CICKS' |
    ...  | Post-requisite | |
    ...
    Select menu Option   &{environment}[cicsk]
    ${Cams user}    Credential getter    Cams user
    Sleep    1
    ${SingON}=  String get   1   31   12
    Set test variable   ${SingON}
    Run Keyword if   '${SingON}' != 'CICS Sign On'  send clear
    ...      ELSE
    ...      Log into CICKS
    XCSR
    string found    3   1   MAIN MENU


Get environment date
#requires  the company id as argument
#sets the ${online_date} variable
    [Arguments]  ${company id}
    [Documentation]  Sets the ${online_date} variable.
    ...
    ...  Usage:
    ...
    ...  - ``Get environment date  ${company id}``
    ...
    ...  An example:
    ...    - ``Get environment date  03104``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send clear
    send string  ucsc
    send enter
    send string  iicf
    send enter
    Fill field by label  COID  ${company id}
    send pf6
    ${online_date_og}=     string get      8  47
    ${online_date}=     Replace string  ${online_date_og}  /  .
    Set test variable   ${online_date_og}  #online date og is in format  15/01/2000, this format is used in checking XDVD after reissue
    Set test variable   ${online_date}   #online date is in format 15.01.2000, this format is used to calculate new expiration date
    ${batch_date}=      string get      8  32
    ${batch_date}=      Replace string   ${batch_date}  /  .
    Set test variable   ${batch_date}


