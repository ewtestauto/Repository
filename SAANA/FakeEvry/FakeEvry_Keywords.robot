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

# for now it is only desing to work for manual reissue
*** Keywords ***

fake PPRFL.X91EVFBI
    [Arguments]   ${alternative_id_from_file}
    [Documentation]  Puts card's data into PPRFL.X91EVFBI file to simulate incoming file from Evry. Used for environments not connected to evry, e.g. RLSE
    ...
    ...
    ...  Usage:
    ...
    ...    - ``fake PPRFL.X91EVFBI   ${alternative_id_from_file}``.
    ...
    ...
    ...
    ...  | Pre-requisite  | Log in to TSO in *SAANA\\SharedKeywordsSAN.robot * file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    ${date}=  Get current date  result_format=%Y%m%d
    log  ${date}
    ${date2}=  Get current date  result_format=%Y-%m-%d
    log  ${date2}
    fill field by label  Option  1
    send enter
    fill field by label  ${SPACE * 2}Name   'ICPS.ITST.TESTAUTO.FAKEEVRY'
    send enter
    Sleep   1
    fill field by label  Command             cut
    fill field   8  2  cc
    fill field   9  2  cc
    send enter
    Sleep           1
    log screen
    send pf3
    send pf3
    String found   3   29   ISPF Primary Option Menu
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   '&{environment}[datasetprefix]PPRFL.X91EVFBI'
    send enter
    Sleep         1
    fill field by label  Command     paste
    fill field   7  3   a
    send enter
    Sleep     3
    fill field by label  Command   c 'SURMANUALREISSUE' '${alternative_id_from_file}' all
    send enter
    Sleep     1
    fill field by label  Command   c 'YYYYMMDD' '${date}' all
    send enter
    Sleep     1
    fill field by label  Command   c 'YYYY-MM-DD' '${date2}' all
    send enter
    fill field by label  Command     save
    Sleep     1
    send pf3
    send pf3

clean after fake PPRFL.X91EVFBI
    [Arguments]
    [Documentation]  After second batch the fake Evry input file is no longer used, so it should be cleared out of data
    ...
    ...
    ...
    ...
    ...
    ...
    ...  | Pre-requisite  | ``fake PPRFL.X91EVFBI`` found in *this* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  Option  2
    send enter
    fill field by label  ${SPACE * 2}Name   '&{environment}[datasetprefix]PPRFL.X91EVFBI'
    send enter
    Sleep         1
    fill field   8  2  d99
    send enter
    String found   8  38   Bottom of Data
    log screen
    send pf3
    send pf3
