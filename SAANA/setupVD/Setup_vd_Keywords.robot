*** Settings ***
Documentation  Includes keywords used in Manual Reissure REG defined within _*Manual_Rei_Keywords.robot*_ file.
...
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    CsvSaveAndRetrievePlastic1.py
Library    AddMonthsToDate.py

Resource   .../SharedKeywordsSAN.robot
*** Variables ***


*** Keywords ***
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
    ${online_date}=     string get      8  47
    ${online_date}=     Replace string  ${online_date}  /  .
    Set test variable   ${online_date}
    ${batch_date}=      string get      8  32
    ${batch_date}=      Replace string   ${batch_date}  /  .
    Set test variable   ${batch_date}

verify ic158t
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
    Send query      SELECT EXTRL_REQ_KEY, PROC_RESULT,PROC_ERROR_TYPE
    ...             FROM  &{environment}[owner].IC158T WHERE
    ...             EXTRL_REQ_KEY='${RequestID}'
    send enter
    sleep   3
    String found  3  72   Top of 1
    String found  11  39  S
    String found  11  51  P
    log screen
    send pf3
    Sleep    1
    send pf3
    Sleep    1
    send pf3
    sleep  1
    send pf3
    sleep  1
    send pf3
    Log screen
    String found    3   29  ISPF Primary Option Menu




verify ic159t
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
    Send query      SELECT REQ_KEY_ID, RESP_STATUS, RESP_GEN_STATUS
    ...             FROM  &{environment}[owner].IC159T WHERE
    ...             EXTRL_REQ_KEY='${RequestID}'
    send enter
    sleep   3
    String found  3  72   Top of 2
    ${plastic}=  String get  11    2
    Set test variable    ${plastic}
    String found   11   53   S
    String found   12   53    S
    String found    11    65    S
    String found    12    65    R


Check XDVL
    [Arguments]  ${statuscode}  ${warningcode}
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
    String found    14  43  ${warningcode}
    log screen


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
 #   Run Keyword And Continue On Failure   String found    8  14   ${PL_EMB_LN1_NM}
    String found    20  17     20
    String found    21   17    00
    String found    22   17    000

Check CUPR
    fill field by label     FUNCTION    CUPR
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CASP
    fill field by label     FUNCTION    CASP
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen


Check CAPF
    fill field by label     FUNCTION    capf
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CAMN
    fill field by label     FUNCTION    camn
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CAPI
    fill field by label     FUNCTION    capi
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CPPR
    fill field by label     FUNCTION    CPPR
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CPPM
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check XPAD
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CPRA
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen

Check CPSL
    fill field by label     FUNCTION    XDVD
    fill field by label     ACCOUNT     ${myplastic}
    send enter
    sleep           1
    log screen
