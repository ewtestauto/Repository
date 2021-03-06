1*** Settings ***
1*** Settings ***
Documentation  Includes keywords defined within _*BFI-700.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\Adriano*_

Library     py3270lib    visible=${TRUE}
Library     user_password
Library     DateTime
Library     String
Library     calendar
Library     excelLibrary
#Test Setup       Open Application
Test Teardown    Close Application


#notes
#   ${newaccount}=  Remove String  ${newaccount}  -  *



*** Variables ***
${CompanyNumber}    20000
${DB2pool}          03
${TSO}              S5TSO
${CICS}             CK23A

# Request variable fields
${RequestID_head}   ID100000001
${FirstName}        NAMETSTAUTO01${SPACE*7}
${Surname}          SURNAMETSTAUTO01${SPACE*9}
${ProductKey}       473PRISTDBAS
${LoyaltyNBR}       9876543210
${DOB}              19841115


#TEST VARIABLES
${surrID_CR}        40104317AABW2558
#${RequestID}=       ID10000000120200317145845

*** Test Cases ***
BFI-700 VISA Combo Primary setup

   Connect to mainframe
   Select TSO/CICS     ${CICS}
   Select UDFL pool    ${CompanyNumber}   ${DB2pool}
   ${OnlineDT_HGN}  ${DYYMMDD}  ${today_yymmddhhmmss}  ${today_yymmdd}  ${today_HHMMSS}  ${BatchDT}  ${OnlineDT}  ${NextDT}=      Read IICF dates
   Close session       ${CICS}

   Select TSO/CICS     ${TSO}
   Logon TSTAUTO

   # cambiare con ICPS.ITST.TESTAUTO*
   Copy dataset        TSTAUTO.SETUP.COMBO.PRI.TEMPLATE      TSTAUTO.SETUP.CMB.PRI.D${today_yymmdd}.T${today_HHMMSS}
   Edit dataset        TSTAUTO.SETUP.CMB.PRI.D${today_yymmdd}.T${today_HHMMSS}
   ${RequestID}=        Set Variable    ${RequestID_head}${today_yymmddhhmmss}
   ${today_HHMM}=       get substring   ${today_HHMMSS}  0  4
   ${PersonalID}=       Set Variable    ${today_yymmdd}-${today_HHMM}
   Edit fields          ${RequestID}    ${PersonalID}
   Load table 158T     TSTAUTO.SETUP.CMB.PRI.D${today_yymmdd}.T${today_HHMMSS}

   Select TSO/CICS     ${CICS}

   ${surrID_CR}     ${surrID_DR}=   Run XOBK and retrieve new plastic id    ${RequestID}
   ${expDT_ddmmyyyy}=   Calc expiry date     ${OnlineDT}
   ${pl_id_CR}  ${pl_id_DR}  ${ac_cd_CR}  ${ac_cd_DR}=     Check CUPR   ${PersonalID}

   Check XDVL   ${surrID_CR}    ${expDT_ddmmyyyy}
   Check XDVD   ${surrID_CR}    ${expDT_ddmmyyyy}   ${OnlineDT}  ${FirstName}    ${Surname}  ${LoyaltyNBR}
   Check CASP   ${surrID_CR}    ${pl_id_CR}     ${ac_cd_CR}     ${FirstName}    ${Surname}      ${OnlineDT}     ${DOB}  ${PersonalID}

*** Keywords ***

Check CASP
    [Arguments]     ${surrID_CR}    ${pl_id_CR}     ${ac_cd_CR}     ${FirstName}    ${Surname}      ${OnlineDT}     ${DOB}  ${PersonalID}

    send clear
    send string         XCSR
    send enter
    send string         CASP
    execute command     NewLine
    send string         ${surrID_CR}
    send enter

    String found        4    2     ${ac_cd_CR}
    String found        5    2     ${pl_id_CR}
    String found        6    47    ${PersonalID}
#    String found        9    52    ${DOB}
    String found        12   65    ${OnlineDT}
    string found        17   21    1.500


Check CUPR
    [Arguments]     ${HETU}

    send clear
    send string         XCSR
    send enter
    send string         CUPR
    execute command     NewLine
    send tab
    send string         ${HETU}
    send enter

    #Credit side
    ${ac_cd_CR}=    string get  16  17
    ${pl_id_CR}=    string get  17  17

    #Debit side
    ${ac_cd_DR}=    string get  15  17
    ${pl_id_DR}=    string get  18  17

    [Return]    ${pl_id_CR}  ${pl_id_DR}  ${ac_cd_CR}  ${ac_cd_DR}


Calc expiry date

    [Arguments]     ${OnlineDT}
    # Calculate expiry date startinmg from the online date
    #TODO read pcd 906006 to retrieve issue term
    #for now add 3 years
    ${d} =    Add Time To Date    ${OnlineDT}    1095 days    date_format=%d/%m/%Y
    log     ${d}
    ${exp_yy}=  Get Substring  ${d}  2   4
    log     ${exp_yy}
    ${exp_mm}=  Get Substring  ${d}  5   7
    log     ${exp_mm}
    ${exp_dd}=  Get Substring  ${d}  8   10
    log     ${exp_dd}

    ${HoganDT}=     Set Variable    1${exp_yy}${exp_mm}${exp_dd}
    log     ${HoganDT}

    send clear
    send string   UMBR
    send enter
    send string   DTS
    send enter
    send string     00150
#    send tab
    send string     ${HoganDT}
    send enter
    ${expDT}=   string get  7   39
    log     ${expDT}

    ${expDT_yyyy}=  Get Substring  ${expDT}  0   4
    log     ${expDT_yyyy}
    ${expDT_mm}=  Get Substring  ${expDT}  4   6
    log     ${expDT_mm}
    ${expDT_dd}=  Get Substring  ${expDT}  6   8
    log     ${expDT_dd}

    ${expDT_ddmmyyyy}=      Set Variable      ${expDT_dd}/${expDT_mm}/${expDT_yyyy}
    log     ${expDT_ddmmyyyy}

    [Return]    ${expDT_ddmmyyyy}

#    ${exp_dd}=      Run Keyword If     '${exp_mm}'=='1' or '${exp_mm}'=='3' or '${exp_mm}'=='5' or '${exp_mm}'=='7'or '${exp_mm}'=='8'or '${exp_mm}'=='10' or '${exp_mm}'=='12'    Set Variable     31
#                    ...     ELSE    Set variable    30

#    ${exp_dd}=      Run Keyword If      '${exp_mm}'=='2' and 'Is Leap(2020)'=='TRUE'     Set Variable    29
#    ${exp_dd}=      Run Keyword If      '${exp_mm}'=='2' and 'Is Leap(2020)'=='FALSE'     Set Variable    28

#    log     ${exp_dd}


Read IICF dates
    send string         D
    send enter
    send string         IICF
    send enter
    send tab
    send string         ${CompanyNumber}
    send enter
    ${BatchDT}=         string get  8  32
    ${OnlineDT}=        string get  8  47
    ${NextDT}=          string get  8  60
    ${todayDT}=         string get  1  64
    log screen
    Log    Batch ${BatchDT}
    Log    Online ${OnlineDT}
    Log    Next ${NextDT}
    send clear
    log screen

    #Set variables
    ${OnlineDT_yy}=     Get Substring  ${OnlineDT}  8   11
    ${OnlineDT_mm}=     Get Substring  ${OnlineDT}  3   5
    ${OnlineDT_dd}=     Get Substring  ${OnlineDT}  0   2


    ${OnlineDT_HGN}=     Set Variable    1${OnlineDT_yy}${OnlineDT_mm}${OnlineDT_dd}
    ${DYYMMDD}=     Set Variable    D${OnlineDT_yy}${OnlineDT_mm}${OnlineDT_dd}
    ${YYYYMMDD}=    Set Variable    20${OnlineDT_yy}${OnlineDT_mm}${OnlineDT_dd}
    log     ${OnlineDT_HGN}
    log     ${DYYMMDD}

    ${today_yymmddhhmmss}=    Get Current Date    result_format=%Y%m%d%H%M%S
    log     ${today_yymmddhhmmss}

    ${today_yymmdd}=     Get Substring  ${today_yymmddhhmmss}  2   8
    ${today_HHMMSS}=     Get Substring  ${today_yymmddhhmmss}  8   14

    [Return]    ${OnlineDT_HGN}  ${DYYMMDD}  ${today_yymmddhhmmss}  ${today_yymmdd}  ${today_HHMMSS}  ${BatchDT}  ${OnlineDT}  ${NextDT}

Check XDVD

    [Arguments]     ${pl_id}    ${expDT}    ${OnlineDT}  ${FirstName}    ${Surname}  ${LoyaltyNBR}

    send clear
    send string         XCSR
    send enter
    send string         XDVD
    execute command     NewLine
    send string         ${pl_id}
    send enter

    #Account/Plastic status
    String found        4   64  AA
    String found        5   64  AA

    #Account/Plastic Type
    #TODO retrieve from PCD ???
    String found        4   56  VCA
    String found        5   56  CF1

    #Expiry date
    String found        7    44    ${expDT}

    #Open date
    String found        7    70    ${OnlineDT}

    #EMBLINE
    String found        8    14    ${FirstName}
    String found        8    54    ${Surname}

    #Branches
    #TODO retrieve from PCD ???
    String found        9    76    50009
    String found        10   76    50009
    String found        16   36    50009

    #Loyalty number
    String found        13   11    ${LoyaltyNBR}

    #Status/Warning
    String found        20   17    20
    String found        21   17    00
    String found        22   17    000

    send clear

Check XDVL

    [Arguments]     ${pl_id}    ${expDT}

    send clear
    send string         XCSR
    send enter
    send string         XDVL
    execute command     NewLine
    send string         ${pl_id}
    send enter

    #Expiry date
    String found        12    35    ${expDT}

    # Check device status 20 00
    string found        14  14  20
    string found        14  43  00

    send clear






Open CAAD screen with plastic
    [Arguments]     ${PL_ID}
    Send string         XCSR
    Send enter
    Sleep     2 seconds
    String found    3   45   53572 Terminal records RESET
    Fill field by label        FUNCTION :  CAAD
    Fill field by label        ACCOUNT  ${PL_ID}
    send enter
    String found    2   46   4152 END OF LINE ITEMS
    log screen

Close application

 #   Fill field by label      Option ===>     =X
 #   Fill field by label      Command ===>     =X
 #   send enter
    send pf         24
    send string     QUIT
    send enter



File Manager Edit

    [Arguments]     ${DSN}     ${Copybook}
    send command    fm
    send string     2
    send enter
    log screen
    Fill field by label     Data set/path name  ${DSN}
    Fill field by label     Data set name       ${Copybook}
    Find Field     1. Above    RIGHT
    Send string    1
    Send enter

