#This contains keywords that can be used in all tests

*** Settings ***
Documentation  Includes common keywords defined within _*SharedKeywords.robot*_ file.
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
    [Documentation]  Selects given *${Option}* from Menu Tubes screen.
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
    [Documentation]  Logs out of TSO session using *S5TSO* `Sessid`.
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
    [Documentation]  Logs out of CICSK session using name of CICSK (e.g. CK35) that is set in `Set environment` Keyword.
    ...
    ...  Usage:
    ...
    ...  - ``Log out of CICSK session``
    ...
    ...  | Pre-requisite  | `Set environment`, available in *\\PyCharm\\NEXI\\Environments.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    # the following three lines are for people who have more menus, and options are not on first screen
    send pf         24
    send pf7
    fill field by label  Comando ===>  FIND &{environment}[cicsk]
    Send enter
    Find field      &{environment}[cicsk]   RIGHT
    Send string     i
    Send enter
    Sleep           1

Connect To Mainframe
    [Documentation]  Connects to Mainframe using the following properties:
    ...
    ...  - *Connection String*: Y:192.168.14.6:2399
    ...
    ...  - *Credentials*: _User ID_ and _Password_ from `Cams User`
    ...
    ...  Usage:
    ...
    ...  - ``Connect to mainframe``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
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
    [Documentation]  Logs into TSO using *S5TSO*.
    ...
    ...  Usage:
    ...
    ...  - ``Log in to TSO``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Select menu Option` |
    ...  | Post-requisite | |
    ...
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
    [Documentation]  Sends given sql query *${Input query}*.
    ...
    ...  Usage:
    ...
    ...    - ``Send query  ${Input query}``, where ${Input query} is sql query
    ...
    ...  An example:
    ...    - ``Send query SELECT PL_ID ...``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    FOR    ${line}    IN    @{Input query}
        Send string    ${line}
        Send tab
    END

Get out of TSO/CICSK/SAREGKT
    [Documentation]  Gets out of TSO/CICSK/SAREGKT screen and goes to Menu Tubes with all the sessions.
    ...
    ...  Usage:
    ...
    ...  - ``Gets out of TSO/CICSK/SAREGKT session``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send pf19
    sleep           1

Go to CICSK
    [Documentation]  Opens CICSK session using name of CICSK (e.g. CK35) that is set in `Set environment` Keyword.
    ...
    ...  Usage:
    ...
    ...    - ``Go to CICSK``
    ...
    ...  | Pre-requisite  | `Set environment`, available in *\\PyCharm\\NEXI\\Environments.robot* file |
    ...  | Co-requisite   | `Select menu Option`, `XCSR` |
    ...  | Post-requisite | |
    ...
    Select menu Option  &{environment}[cicsk]
    send clear
    XCSR
    string found    3   1   MAIN MENU

XCSR
    [Documentation]  Opens refreshed screen of CICSK.
    ...
    ...  Usage:
    ...
    ...    - ``XCSR``
    ...
    ...  | Pre-requisite  | `Set environment`, available in *\\PyCharm\\NEXI\\Environments.robot* file; `Go to CICSK` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send clear
    send string     xcsr
    send enter

Set UDFL
    [Documentation]  Sets CICSK parameters in UDFL using company number and pool that are set in `Set environment` Keyword.
    ...
    ...  Usage:
    ...
    ...    - ``Set UDFL``
    ...
    ...  | Pre-requisite  | `Set environment`, available in *\\PyCharm\\NEXI\\Environments.robot* file |
    ...  | Co-requisite   | `Go to CICSK`; `Get out of TSO/CICSK/SAREGKT`; `Log out of CICSK session` |
    ...  | Post-requisite | |
    ...
#This keyword sets CICSK parameters in UDFL
#It should probably be part of setup suite
    Go to CICSK
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
    [Documentation]  Takes a date in format dd.mm.yyyy and returns it minus one year.
    ...
    ...  Usage:
    ...
    ...    - ``Subtract one year  ${date}``
    ...
    ...  An example:
    ...    - ``Subtract one year  ${environmentdate}``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    ${yy}=  Get Substring  ${date}  8
    ${yy-1}=  Set variable  ${${yy}-1}
    ${dd.mm.}=  Get Substring  ${date}  0  8
    ${returnthis}=  Convert To String  ${dd.mm.}${yy-1}
    [Return]  ${returnthis}

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
