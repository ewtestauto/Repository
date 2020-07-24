*** Settings ***
Documentation  Includes keywords used in Manual Reissure REG defined within _*Manual_Rei_Keywords.robot*_ file.
...
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    ../CsvSaveAndRetrievePlastic1.py
Library    ../AddMonthsToDate.py

Resource   SharedKeywordsSAN.robot
*** Variables ***


*** Keywords ***

Find plastic card M2 Manual reissue REG
    [Arguments]     ${dv_exp_date}
    [Documentation]  Chooses plastic credit card for test M2 Manual reissue REG and sets variables:  myplastic, accountID, PL_EMB_LN1_NM, AC_BR_NR, PL_CRD_STK_CD, DV_CLESS_IN, LYL_NBR_PRNTD, MEMB_PRNTD_IN, DELVRD_BR_NR, ISS_BR_NR
    ...
    ...  Usage:
    ...
    ...    - ``Finds plastic for test M2 Manual reissue REG   ${dv_exp_date}, where ${dv_exp_date} is a manually set date of card expiration, close to current date``
    ...
    ...  An example:
    ...    - ``Find plastic for test Card M2 Manual reissue REG  01.01.2021``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | `Send query`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Post-requisite | |
    ...
    Send string     r
    Send enter
    Send string     8
    Send enter
    Run Keyword if   '${environment name}' == 'CK0A'  Fill field   16   68   DB25
    ...   ELSE
    ...   Fill field  16  68  db3
    send enter
    Send string     4
    Send enter
    Send string     3
    Send enter
    Sleep           1
    String found    3   25  Enter, Execute and Explain SQL
    Send query    SELECT distinct PL_ID, AC_INTRL_ID,
          ...     PL_EMB_LN1_NM, AC_BR_NR, PL_CRD_STK_CD,
          ...     DV_CLESS_IN, LYL_NBR_PRNTD, MEMB_PRNTD_IN,
          ...     DELVRD_BR_NR, ISS_BR_NR, LYL_TYP
          ...     FROM &{environment}[owner].IC161T
          ...     WHERE 1=1
          ...     AND DV_STAT_CD = '50'
          ...     AND DV_WARN_CD = '00'
          ...     AND DELVRD_MTHD = 'REG'
          ...     AND PL_ID LIKE ('401043%')
          ...     AND DV_EXP_DT < ('${dv_exp_date}')
          ...     and pl_id not in
          ...     (select pl_id from &{environment}[owner].ic161t
          ...     where not dv_stat_cd='50')
          ...     WITH UR;
    Sleep           1
    Send enter
    Sleep           1
    String found    3   29  Select Statement Browse
    ${myplastic}=   String get  15  2
    Set test variable  ${myplastic}
    ${accountID}=  String get  15   27   13
    Set test variable   ${accountID}
    ${PL_EMB_LN1_NM}=  String get   15   41
    Set test variable   ${PL_EMB_LN1_NM}
    ${AC_BR_NR}=  String get   15   71   5
    Set test variable   ${AC_BR_NR}
    Log screen
    send pf  11
    ${PL_CRD_STK_CD}=  String get   15   2
    Set test variable   ${PL_CRD_STK_CD}
    ${DV_CLESS_IN}=  String get   15   16
    Set test variable   ${DV_CLESS_IN}
    ${LYL_NBR_PRNTD}=  String get   15   28
    Set test variable   ${LYL_NBR_PRNTD}
    ${MEMB_PRNTD_IN}=  String get   15   52
    Set test variable   ${MEMB_PRNTD_IN}
    ${DELVRD_BR_NR}=  String get   15   73
    Set test variable   ${DELVRD_BR_NR}
    log screen
    send pf  11
    ${ISS_BR_NR}=  String get   15   6   5
    Set test variable   ${ISS_BR_NR}
    ${LYL_TYP}=  String get   15   12
    Set test variable    ${LYL_TYP}
    log screen
    Sleep           1
    log   ${myplastic}
    log   ${accountID}
    log   ${PL_EMB_LN1_NM}
    log   ${AC_BR_NR}
    log   ${PL_CRD_STK_CD}
    log   ${DV_CLESS_IN}
    log   ${LYL_NBR_PRNTD}
    log   ${MEMB_PRNTD_IN}
    log   ${DELVRD_BR_NR}
    log   ${ISS_BR_NR}
    log   ${LYL_TYP}


OPEN CCMB
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens CCMB and sets secondary application as variable, used in 'fill xdvl for reissue' to make reisuee is correctly propagated.
    ...
    ...  Usage:
    ...
    ...    - ``Open CCMB  ${plasticNumber}, where ${plasticNumber} primary application.``
    ...
    ...  An example:
    ...    - ``Open CCMB ${myplastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label     FUNCTION    CCMB
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1
    ${secondaryApp}=   String get   10   36
    ${secondaryApp}=  Remove String  ${secondaryApp}  -
    Set test variable  ${secondaryApp}


Open XDVL
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens XDVL screen for plastic card.
    ...
    ...  Usage:
    ...
    ...    - ``Open XDVL  ${plasticNumber}, where ${plasticNumber} is plastic number to open in XDVL.``
    ...
    ...  An example:
    ...    - ``Open XDVL ${myplastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | `Fill XDVL for rei`, available in *this* file |
    ...
    fill field by label     FUNCTION    XDVL
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1
    log screen



Reissue card in XDVL
    [Arguments]
    [Documentation]  Fills out XDVL for Reissure REG and sets Previous and New expiration date as variables. Checks the new card status code.
    ...
    ...  Usage:
    ...
    ...    - ``Fill XDVL fields for reissure ``
    ...
    ...
    ...  | Pre-requisite  |  'Open XDVL', available in *SAANA\\SharedKeywordsSAN.robot * file  |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label     ACTION  REI
    fill field by label     REQUESTED BY    B
    send enter
    string found    2   51   ACTION SUCCESSFUL
    log screen

Check XDVL fields after reissue
    [Arguments]     ${statusCode}
    [Documentation]  Sets Previous and New expiration date as variables (and checks if they are properly calculated). Checks the new card status code and if reissue is propagated to correct PAN
    ...
    ...  Usage:
    ...
    ...    - ``Check XDVL fields after reissue   20 ``
    ...
    ...
    ...  | Pre-requisite  |  'Reissue card in XDVL', available in *this* file  |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    ${prevExpDt}=   String get  16  35
    Set test variable  ${prevExpDt}
    ${expDt}=            add months to date    ${online_Date}    36
    log   ${expDt}
    ${future_expiration_MM.YYYY}=    get substring        ${expDt}           3
    ${newExpDt}=   String get   12  35
    Set test variable  ${newExpDt}
    ${expiration_dt}=  replace string       ${newExpDt}  /  .
    ${expiration_dt_MM.YYYY}=  get substring       ${expiration_dt}   3
    Run keyword and continue on failure
    ...                        Should be equal      ${future_expiration_MM.YYYY}   ${expiration_dt_MM.YYYY}
    sleep           1
    String found    14  14  ${statusCode}
    String found    14  43  00
    String found   23  47   ${secondaryApp}
    log screen



Check XDVL card status
	[Arguments]  ${statusCode}
    [Documentation]  Checks status code of a card. Warning code should be 00.
    ...
    ...  Usage:
    ...
    ...    - ``Check XDVL card status  ${statusCode}``, where ${statusCode} is current expected status of the card.``
    ...
    ...  An example:
    ...    - ``Check XDVL card status 	20``
    ...
    ...  | Pre-requisite  | `Open XDVL`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    String found    14  14  ${statusCode}
    String found    14  43  00
    log screen


Get alternative card number from XPAD
	[Arguments]  ${myplastic}
    [Documentation]  Gets alternative number of a card from XPAD and sets it as variables. The variable are later used in searching for card in files.
    ...
    ...  Usage:
    ...
    ...    - ``Check XPAD screen for alternative card number for ${myplastic}``.
    ...
    ...  An example:
    ...    - ``Get alternative card number from XPAD   ${myplastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *SAANA\\SharedKeywordsSAN.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label     FUNCTION    XPAD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
    ${alternativeID}=   String get  7   37
    Set test variable   ${alternativeID}



Verify the new expiration date in XDVD
	[Arguments]  ${myplastic}   ${newExpDt}
    [Documentation]  Verify the new  expiration date after manual reissue and checks additional fields.
    ...
    ...  Usage:
    ...
    ...    - ``Verify the new expiration date ${myplastic}``.
    ...
    ...
    ...
    ...  | Pre-requisite  | `Fill XDVL for rei`; 'Open CICSK` available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
    String found   7  44  ${newExpDt}
    Run Keyword And Continue On Failure  String found    7  70  ${online_date_og}
    Run Keyword And Continue On Failure   String found    8  14   ${PL_EMB_LN1_NM}
    Run Keyword And Continue On Failure  String found    9  13   ${PL_CRD_STK_CD}
    Run Keyword And Continue On Failure  String found    9  27    ${DV_CLESS_IN}
    Run Keyword And Continue On Failure  String found    9  76   ${ISS_BR_NR}
    Run Keyword And Continue On Failure  String found    10  76    ${AC_BR_NR}
    Run Keyword And Continue On Failure  String found    13  11     ${LYL_NBR_PRNTD}
    Run Keyword And Continue On Failure  String found    13  45    ${LYL_TYP}
    Run Keyword And Continue On Failure  String found    13  63     ${MEMB_PRNTD_IN}
    Run Keyword And Continue On Failure  String found    16  36     ${DELVRD_BR_NR}
    String found    20  17     20
    String found    21   17    00
    String found    22   17    000




Check CAPI for expiration and reissue dates
	[Arguments]  ${myplastic}   ${newExpDt}    ${prevExpDt}
    [Documentation]  Verifies CAPI fields for manual reissue reg test: new expiration date, previous expiration date and next reissue date
    ...
    ...  Usage:
    ...
    ...    - ``Open CAPI for rei  ${myplastic}   ${newExpDt}    ${prevExpDt}``.
    ...
    ...
    ...
    ...  | Pre-requisite  | `Fill XDVL for rei`; 'Open CICSK` available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | `Send query`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Post-requisite | |
    ...
    fill field by label     FUNCTION    CAPI
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
    String found    8   51   REI
    String found    9   22   ${newExpDt}
    String found    10  22   ${prevExpDt}
    ${nextrei}=   String get  10   51
    ${checkDate} =  Subtract Time From Date    ${newExpDt}    105d    result_format=%d/%m/%Y   exclude_millis=True     date_format=%d/%m/%Y
    Should be equal  ${checkDate}   ${nextrei}






from ISPF search for plastic in file
    [Arguments]    ${plastic}     ${filename}
    [Documentation]  Checks if plastic is in file after Nightly Batch
    ...
    ...  Usage:
    ...
    ...    - ``Verify that plastic is in X91XEVRO.DAILY ``.
    ...
    ...  An example:
    ...    - ``from ISPF search for plastic file   ${myplastic}    X91XEVRO.DAILY``
    ...
    ...  | Pre-requisite  | `Open TSO`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  Option  1
    send enter
    fill field by label  ${SPACE * 2}Name   '&{environment}[datasetprefix]${fileName}'
    send enter
    fill field by label  Command            f ${plastic}
    send enter
    Run keyword and continue on failure     string found  3  63   ${plastic}
    log screen
    send pf3
    Sleep           1
    send pf3
    Sleep           1



from ISPF search for reissued credit plastic in JSON file
    [Arguments]  ${account_id_from_file}    ${jsonfile}
    [Documentation]  Saves in 'ICPS.ITST.TESTAUTO.REISSUE.REG' all data about the account and checks if JSON file for credit plastic used for reissue is complete: so it has fields: 2x ReplaceAccount, 2x ReplaceCard,  ReplaceCreditCheckOverride, 3x ReplaceVelocityCheckOverride, then clears the test file.
    ...
    ...
    ...  Usage:
    ...
    ...    - ``from ISPF search for credit plastic in JSON file   ${account_id_from_file}    ${jsonfile}``.
    ...
    ...
    ...
    ...  | Pre-requisite  | ``Log in to TSO`` available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  Option  1
    send enter
    fill field by label  ${SPACE * 2}Name   '&{environment}[datasetprefix]${jsonfile}'
    send enter
    fill field by label  Command            X ALL;F ALL '${account_id_from_file}'
    send enter
    Sleep           1
    String found   3  56   12 CHARS '${account_id_from_file}'  #number of chars are very specific for this test, as it uses only credit card and json file for reissued card is longer than for setuped card
    fill field by label  Command             cut
    fill field   7  2  cc
    fill field   14  2  cc
    send enter
    Sleep           1
    log screen
    send pf3
    send pf3
    String found   3   29   ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'ICPS.ITST.TESTAUTO.REISSUE.REG'
    send enter
    fill field by label  Command     paste
    fill field   7  3   a
    send enter
    Sleep     3
    fill field by label  Command     save
    Sleep     1
    send pf3
    send pf3
    String found   3   29   ISPF Primary Option Menu
    fill field by label  Option  1
    send enter
    fill field by label  ${SPACE * 2}Name   'ICPS.ITST.TESTAUTO.REISSUE.REG'
    send enter
    fill field by label  Command   F ALL 'ReplaceAccount'
    send enter
    Run keyword and continue on failure    String found   3  56   2 CHARS 'REPLACEACCOUNT'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCard'
    send enter
    Run keyword and continue on failure    String found   3  59   2 CHARS 'REPLACECARD'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCreditCheckOverride'
    send enter
    Run keyword and continue on failure    String found   3   56   1 CHARS 'REPLACECREDITCH
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceVelocityCheckOverride'
    send enter
    Run keyword and continue on failure      String found   3   56   3 CHARS 'REPLACEVELOCITY
    log screen
    send pf3
    send pf3
    log screen
    String found    3   29  ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'ICPS.ITST.TESTAUTO.REISSUE.REG'
    send enter
    fill field   8  2  d99
    send enter
    String found   8  38   Bottom of Data
    log screen
    send pf3
    send pf3


get plastic data for manual reissue test
    [Arguments]  ${test_case_name}  ${environment_name}
    [Documentation]  Takes plastic data from file and set it as variable
    @{plastic_data_from_file}=    retrieve plastic data for manual reissue  ${test_case_name}  ${environment_name}
    ${plastic_from_file}=         Set variable                              @{plastic_data_from_file}[2]
    ${online_date_from_file}=     Set variable                              @{plastic_data_from_file}[3]
    ${alternative_id_from_file}=  Set variable                              @{plastic_data_from_file}[5]
    ${account_id_from_file}=  Set variable                              @{plastic_data_from_file}[6]

    Set test variable             ${plastic_from_file}
    Set test variable             ${online_date_from_file}
    Set test variable             ${alternative_id_from_file}
    Set test variable             ${account_id_from_file}


