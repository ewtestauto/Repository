#This contains keywords that can be used in all tests

*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    String

asdasdasdasd
*** Variables ***
TA1

TESTAUTO2
*** Keywords ***

Select menu Option
    [Arguments]    ${Option}
    # the following four lines are for people who have more menus, and options are not on first screen
    # send pf  24 is the same as pf7 on Adriano's mainframe
    send pf         24
    send pf7
    fill field by label  Comando ===>  FIND ${Option}
    Send enter
    Find Field     ${Option}    RIGHT
    Send string    S
    Send enterasdasdasd
    Sleep          2 seconds
    Log screen

Log out of TSO session
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
    ${yy}=  Get Substring  ${date}  8
    ${yy-1}=  Set variable  ${${yy}-1}
    ${dd.mm.}=  Get Substring  ${date}  0  8
    ${returnthis}=  Convert To String  ${dd.mm.}${yy-1}
    [Return]  ${returnthis}


