*** Settings ***
Documentation  Includes keywords used in Manual Reissure REG defined within _*Manual_Rei_Keywords.robot*_ file.
...
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    .../CsvSaveAndRetrievePlastic1.py
Library    ../AddMonthsToDate.py

Resource   SharedKeywordsSAN.robot
*** Variables ***


*** Keywords ***

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

Change card status to 50 via XDVL
    [Arguments]  ${plasticNumber}    ${statusCode}
    [Documentation]  Opens XDVL, saves sequence number of the card, checks current card status (usually 30) and changes it to 50.
    ...
    ...  Usage:
    ...
    ...    - ``Change card status to 50 via XDVL ${plasticNumber}  ${statusCode} where ${statusCode} is expected current card status``
    ...
    ...  An example:
    ...    - ``Open XDVL ${myplastic}  30``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | `Fill XDVL for rei`, available in *this* file |
    ...
    fill field by label     FUNCTION    XDVL
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
    ${sequence}=   String get   12   16
    Set test variable  ${sequence}
    String found    14  14  ${statusCode}
    String found    14  43  00
    sleep           1
    Fill field     12  2    STMO
    Fill field     14  22   50
    send enter
    sleep           1
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
    fill field by label  Command            f ${plastic1}
    send enter
    Run keyword and continue on failure     string found  3  63   ${plastic}
    log screen
    send pf3
    send pf3


get plastic data for manual reissue test
    [Arguments]  ${test_case_name}  ${environment_name}
    @{plastic_data_from_file}=    retrieve plastic data for manual reissue  ${test_case_name}  ${environment_name}
    ${plastic_from_file}=         Set variable                              @{plastic_data_from_file}[2]
    ${online_date_from_file}=     Set variable                              @{plastic_data_from_file}[3]
    ${alternative_id_from_file}=  Set variable                              @{plastic_data_from_file}[5]
    ${account_id_from_file}=  Set variable                              @{plastic_data_from_file}[6]

    Set test variable             ${plastic_from_file}
    Set test variable             ${online_date_from_file}
    Set test variable             ${alternative_id_from_file}
    Set test variable             ${account_id_from_file}




from ISPF search for debit plastic in JSON file
    [Arguments]  ${account_id_from_file}  ${ReplaceAccount}  ${replaceCard}  ${ReplaceCreditCheckOverride}  ${ReplaceVelocityCheckOverride}
    [Documentation]  Saves in test file 'EQTAUT5.ROBOT.REISSUE.REG' all data about the account and checks if JSON file for credit card plastic is complete: so it has fields: ReplaceAccount, ReplaceCard,  ReplaceCreditCheckOverride, ReplaceVelocityCheckOverride, then clears the test file.
    ...
    ...
    ...  An example:
    ...    - ``from ISPF search for debit plastic in JSON file  ${account_id_from_file}  2  1  1  3 , where numbers means how many times each field occurs in the filecd``
    ...
    ...  Usage:
    ...
    ...    - ``from ISPF search for credit plastic in JSON file    ${account_id_from_file}  2 1 1``.
    ...
    ...
    ...
    ...  | Pre-requisite  | available in *SAANA\\SharedKeywordsSAN.robot * file |
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
    log screen
    String found   3  57   9 CHARS '${account_id_from_file}'
    fill field by label  Command             cut
    fill field   7  2  cc
    fill field   13  2  cc
    send enter
    Sleep           1
    log screen
    send pf3
    send pf3
    String found   3   29   ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    Sleep         1
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
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    fill field by label  Command   F ALL 'ReplaceAccount'
    send enter
    Run keyword and continue on failure    String found   3  56   ${replaceAccount} CHARS 'REPLACEACCOUNT'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCard'
    send enter
    Run keyword and continue on failure    String found   3  59    ${replaceCard} CHARS 'REPLACECARD'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCreditCheckOverride'
    send enter
    Run keyword and continue on failure    String found   3   56   ${ReplaceCreditCheckOverride} CHARS 'REPLACECREDITC
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceVelocityCheckOverride'
    send enter
    Run keyword and continue on failure      String found   3   56   ${ReplaceVelocityCheckOverride} CHARS 'REPLACEVELOCITY
    log screen
    send pf3
    send pf3
    log screen
    String found    3   29  ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    fill field   8  2  d99
    send enter
    String found   8  38   Bottom of Data
    log screen
    send pf3
    send pf3




from ISPF search for credit plastic in JSON file
    [Arguments]  ${account_id_from_file}  ${ReplaceAccount}  ${replaceCard}  ${ReplaceCreditCheckOverride}  ${ReplaceVelocityCheckOverride}
    [Documentation]  Saves in test file 'EQTAUT5.ROBOT.REISSUE.REG' all data about the account and checks if JSON file for credit card plastic is complete: so it has fields: ReplaceAccount, ReplaceCard,  ReplaceCreditCheckOverride, ReplaceVelocityCheckOverride, then clears the test file.
    ...
    ...
    ...  An example:
    ...    - ``from ISPF search for debit plastic in JSON file  ${account_id_from_file}  2  1  1  3 , where numbers means how many times each field occurs in the filecd``
    ...
    ...  Usage:
    ...
    ...    - ``from ISPF search for credit plastic in JSON file    ${account_id_from_file}  2 1 1``.
    ...
    ...
    ...
    ...  | Pre-requisite  | available in *SAANA\\SharedKeywordsSAN.robot * file |
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
    log screen
    String found   3  56   11 CHARS '${account_id_from_file}'
    fill field by label  Command             cut
    fill field   7  2  cc
    fill field   13  2  cc
    send enter
    Sleep           1
    log screen
    send pf3
    send pf3
    String found   3   29   ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    Sleep         1
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
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    fill field by label  Command   F ALL 'ReplaceAccount'
    send enter
    Run keyword and continue on failure    String found   3  56   ${replaceAccount} CHARS 'REPLACEACCOUNT'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCard'
    send enter
    Run keyword and continue on failure    String found   3  59    ${replaceCard} CHARS 'REPLACECARD'
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceCreditCheckOverride'
    send enter
    Run keyword and continue on failure    String found   3   56   ${ReplaceCreditCheckOverride} CHARS 'REPLACECREDITC
    Sleep         1
    log screen
    fill field by label  Command   F ALL 'ReplaceVelocityCheckOverride'
    send enter
    Run keyword and continue on failure      String found   3   56   ${ReplaceVelocityCheckOverride} CHARS 'REPLACEVELOCITY
    log screen
    send pf3
    send pf3
    log screen
    String found    3   29  ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   'EQTAUT5.ROBOT.REISSUE.REG'
    send enter
    fill field   8  2  d99
    send enter
    String found   8  38   Bottom of Data
    log screen
    send pf3
    send pf3




from ISPF search for combo cards in file
    [Arguments]    ${plastic1}  ${plastic2}   ${filename}
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
    Sleep  1
    Run Keyword if  '${fileName}' == 'AURBB.D91CCXO'  fill field by label  Command  source ascii
    send enter
    fill field by label  Command            f ${plastic1}
    send enter
    Run keyword and continue on failure     string found  3  63   ${plastic1}
    log screen
    fill field by label  Command            f ${plastic2}
    send enter
    Run keyword and continue on failure     string found  3  63   ${plastic2}
    log screen
    send pf3
    send pf3


Send option
    [Arguments]     ${Option}
    Fill field by label      Option ===>     ${Option}
    send enter

Send command
    [Arguments]     ${Command}
    Fill field by label      Command ===>     ${Command}
    send enter



Edit dataset
    [Arguments]     ${DSname}
    Send option    3.4
    execute command     EraseEOF
    Fill field by label     Dsname  ${DSname}
    send enter
    send tab
    send tab
    Send string    E
    Send enter
    send enter
    ${date}=  Get current date  result_format=%Y%m%d
    set variable    ${date}
    ${dateDD}=  get substring       ${date}   -2
    ${dateMM}=  get substring       ${date}   4  6
    ${dateYYYY}=  get substring       ${date}   0   4
    send command     zexpand
    send enter
    send string      c 'ID10001YYYYMMDDXXXXXXXXXX'
    send tab
    send string      '${requestid}' ALL
    send pf3
    send enter
    log screen
    string found   3  56  CHARS
    Sleep  1
    ${Cams user}    Credential getter    Cams user
    fill field by label  Command  c 'USER000' '${Cams user.user}' ALL
    send enter
    log screen
    string found   3  57  CHAR
    Sleep  1
    fill field by label  Command  c 'DD' '${dateDD}' ALL
    send enter
    log screen
    string found   3  62  CHARS
    Sleep  1
    fill field by label  Command  c 'MM' '${dateMM}' ALL
    send enter
    log screen
    string found   3  62  CHARS
    Sleep  1
    fill field by label  Command  c 'YYYY' '${dateYYYY}' ALL
    send enter
    log screen
    string found   3  60  CHARS
    Sleep  1
    fill field by label  Command  c 'PRDKEYXXXX01' '473PRISTDBAS' ALL
    send enter
    string found   3  56  CHARS
    Sleep  1
    fill field by label  Command  c 'PERSONALIDX' '${date}-01' ALL
    send enter
    string found   3  56  CHARS

    Sleep  1
    send command     zexpand
    send enter
    send string      c 'FIRSTNAMEXXXXXXXXXXX'
    send tab
    send string      '${FirstName} ' ALL
    send pf3
    send enter
    log screen
    string found   3  56  CHARS
    Sleep  1
    send command     zexpand
    send enter
    send string      c 'SURNAMEXXXXXXXXXXXXXXXXXX'
    send tab
    send string      '${Surname}' ALL
    send pf3
    send enter
    log screen
    string found   3  56  CHARS
    Sleep  1
    fill field by label  Command  c 'NAMESURNAME' '${TESTNAME}' ALL
    send enter
    log screen
    string found   3  56  CHARS
    fill field by label  Command    c '19780101' '${DOB}'
    send enter
    log screen
    string found   3  56  CHARS
    fill field by label  Command    c 'LOYALTYNBR' '${LoyaltyNBR}'
    send enter
    log screen
    string found   3  56  CHARS

    fill field by label  Command   save
    send pf3
    send pf3
    send PF3
    string found  3  29  ISPF Primary Option Menu

Run XOBK and retrieve new plastic id
    [Arguments]     ${requestID}

    send clear
    sleep   2 seconds
    send string     XOBK ${requestID}
    sleep   5 seconds
    send enter
    sleep   5 seconds
    String found     1    34    REQUEST SUCCESSFUL

    ${surrID_CR}=  string get  6  14
    ${surrID_DR}=  string get  7  57
    sleep       10 seconds
    log screen

    Set test variable  ${surrID_CR}
    Set test variable  ${surrID_DR}

Load table 158T

    [Arguments]     ${DSN}

    send string     TWS
    send enter
    send string     5.1
    send enter
    execute command     EraseEOF
    send string     TESTJOBESTEMPOR
    send enter
    send enter
    send enter
    send enter
    ${a}=           string get  18  26
    send string     ${a}
    log screen
    send command    oper
    execute command     Newline
    execute command     Newline
    send string         J
    send tab
    send tab
    send tab
    send tab
    send string         TSTAUTO1
    log screen
    send enter
    send string         COPY 'TSTAUTO.JOBLIB(LOAD158A)'
    send enter
    fill field by label  Command      C 'XX1' '${DSN}'
    send enter
    log screen
    send pf3
    send pf3
    send pf3
    sleep               60 seconds
    send command        =X


find plastic in ic158t
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
    Send query  select EXTRL_REQ_KEY, REQ_KEY_ID
         ...    from &{environment}[owner].IC158T
         ...    where 1=1
         ...    and EXTRL_REQ_KEY like '%${requestid}%'
         ...    with ur;
    Sleep           1
    Send enter
    Sleep           1
    String found    3   29  Select Statement Browse
    ${creditPL}=   String get  12  39  16
    Set test variable  ${creditPL}
    ${debitPL}=   String get  12  56  16
    Set test variable  ${debitPL}
    Send string     =x
    sleep  1

find plastics in ic161t
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
    Send query     select AC_INTRL_ID,PL_EMB_LN1_NM, PL_EMB_LN2_NM, AC_BR_NR,
         ...       PL_CRD_STK_CD, DV_CLESS_IN, LYL_NBR_PRNTD,
         ...        MEMB_PRNTD_IN, DELVRD_BR_NR, ISS_BR_NR, LYL_TYP
         ...       from &{environment}[owner].IC161T
         ...       where 1 = 1
         ...       and PL_ID = ${creditPL}
         ...       with ur;
    Send enter
    Sleep           1
    send Pf2
    sleep  2
    ${accountID_CRE}=  String get  8  27
    Set test variable   ${accountID_CRE}
 #   String found    9  26     ${FirstName}  #embossing line1= firstname
 #   String found   10  26  ${surname}            #embossing line2 = surname
    ${AC_BR_NR_CRE}=  String get   11  28
    Set test variable   ${AC_BR_NR_CRE}
    ${PL_CRD_STK_CD_CRE}=  String get   12   26
    Set test variable   ${PL_CRD_STK_CD}
    ${DV_CLESS_IN_CRE}=  String get   13  26
    Set test variable   ${DV_CLESS_IN}
    ${LYL_NBR_PRNTD_CRE}=  String get   14  26
    Set test variable   ${LYL_NBR_PRNTD}
    ${MEMB_PRNTD_IN_CRE}=  String get   15   26
    Set test variable   ${MEMB_PRNTD_IN}
    ${DELVRD_BR_NR_CRE}=  String get   16   28
    Set test variable   ${DELVRD_BR_NR}
    ${ISS_BR_NR_CRE}=  String get   17  28
    Set test variable   ${ISS_BR_NR}
    ${LYL_TYP_CRE}=  String get   18   26
    Set test variable    ${LYL_TYP}
    log screen
    sleep   1
    send pf3
    sleep   1
    send pf3
    sleep  1
    String found    3   25  Enter, Execute and Explain SQL
    Send query     select AC_INTRL_ID,PL_EMB_LN1_NM, PL_EMB_LN2_NM, AC_BR_NR,
         ...       PL_CRD_STK_CD, DV_CLESS_IN, LYL_NBR_PRNTD,
         ...        MEMB_PRNTD_IN, DELVRD_BR_NR, ISS_BR_NR, LYL_TYP
         ...       from &{environment}[owner].IC161T
         ...       where 1 = 1
         ...       and PL_ID = ${debitPL}
         ...       with ur;
    Send enter
    Sleep           1
    send Pf2
    sleep  1
    ${accountID_DEB}=  String get  8  27
    Set test variable   ${accountID_DEB}
    String found    9  26     ${FirstName}  #embossing line1= firstname
    String found   10  26  ${surname}            #embossing line2 = surname
    ${AC_BR_NR_DEB}=  String get   11  28
    Set test variable   ${AC_BR_NR_DEB}
    ${PL_CRD_STK_CD_DEB}=  String get   12   26
    Set test variable   ${PL_CRD_STK_CD}
    ${DV_CLESS_IN_DEB}=  String get   13  26
    Set test variable   ${DV_CLESS_IN}
    ${LYL_NBR_PRNTD_DEB}=  String get   14  26
    Set test variable   ${LYL_NBR_PRNTD}
    ${MEMB_PRNTD_IN_DEB}=  String get   15   26
    Set test variable   ${MEMB_PRNTD_IN}
    ${DELVRD_BR_NR_DEB}=  String get   16   28
    Set test variable   ${DELVRD_BR_NR}
    ${ISS_BR_NR_DEB}=  String get   17  28
    Set test variable   ${ISS_BR_NR}
    ${LYL_TYP_DEB}=  String get   18   26
    Set test variable    ${LYL_TYP}
    log screen
    sleep   1
    send pf3





Verify XDVD
	[Arguments]  ${myplastic}  ${newExpDtCRE}   ${statusCode}   ${plasticType}   ${accountType}
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
    String found   7  44  ${newExpDtCRE}
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
    String found    20  17     ${statusCode}
    String found    21   17    00
    String found    22   17    000
    String found    4  64  AA
    String found    5  64   AA
    String found     5  56  ${plasticType}
    String found   4   56   ${accountType}


Check XDVL
    [Arguments]     ${plasticNumber}    ${statusCode}   ${plasticType}   ${accountType}
    fill field by label     FUNCTION    XDVL
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1
    ${expDtCRE}=            add months to date    ${online_Date}    36
    log   ${expDtCRE}
    ${future_expiration_MM.YYYYCRE}=    get substring        ${expDtCRE}           3
    ${newExpDtCRE}=   String get   12  35
    Set test variable  ${newExpDtCRE}
    ${expiration_dtCRE}=  replace string       ${newExpDtCRE}  /  .
    ${expiration_dt_MM.YYYYCRE}=  get substring       ${expiration_dtCRE}   3
    Run keyword and continue on failure
    ...                        Should be equal      ${future_expiration_MM.YYYYCRE}   ${expiration_dt_MM.YYYYCRE}
    sleep           1
    String found    14  14  ${statusCode}
    String found    14  43  00
    String found    14   69    000
    String found    4  64  AA
    String found    5  64   AA
    String found    5   56   ${plasticType}
    String found     4   56  ${accountType}
    log screen


Check CUPR
    [Arguments]   ${plastic}  ${HETU}

    send clear
    send string         XCSR
    send enter
    send string         CUPR
    execute command     NewLine
    send tab
    send string         ${HETU}
    send enter

    String found  8  53  ${DOB}
    log screen
    String found   15  64  BA1
    String found   15  68  AA
    String found   16   64  VCA
    String found    16  68   AA
    String found   17   64  CF1
    String found    17  68   AA
    String found   18   64  DC1
    String found    18  68   AA
     #Credit side
    ${ac_cd_CR}=    string get  16  17
    #Debit side
    ${ac_cd_DR}=    string get  15  17

    set test variable ${ac_cd_CR}
    set test variable   ${ac_cd_DR}
    log   ${ac_cd_CR}
    log   ${ac_cd_DR}

