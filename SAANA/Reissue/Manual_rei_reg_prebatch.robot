*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime


Resource   ../SharedKeywordsSAN.robot
Resource   ../Environments1.robot
Resource   Manual_Rei_Keywords.robot
Resource   ../Set_Teardown.robot

Test Setup     Test setup  ${environment name}
Test Teardown  Test teardown

*** Variables ***
${environment name}   RLSES
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=

${prevExpDt}         #  expiration date of a card, before reissue, set in Fill XDVL for rei and get expiration dates, prevExpDt<dv_exp_date
${newExpDt}          #  expiration date of a card, after reissue, set in Fill XDVL for rei and get expiration dates
${online_date}       # set by 'get environment date'
${myplastic}         # plastic number set in Find plastic card M2 Manual reissue REG
${accountID}         # AC_INTRL_ID set in Find Plastic for reissue test, used in JSON search afer batches

${test case name}  Manual Reissue REG
${company id}   20000        # company id for SAANA
${dv_exp_date}  01.01.2021   # card will have expiration date before this variable; used in sql in Find plastic card M2 Manual reissue reg
#TODO change variable dv_exp_dt to be high level - current date + 6 months or something like that but I have to check if we use env date or the real date


*** Keywords ***

*** Test Cases ***
ReissuePreBatch
    Log in to TSO
    Find plastic card M2 Manual reissue REG   ${dv_exp_date}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Go to CICSK updated
    Get environment date     ${company id}
    XCSR
    OPEN CCMB  ${myplastic}
    XCSR
    Open XDVL  ${myplastic}
    Check XDVL card status   50
    Reissue card in XDVL
    Check XDVL fields after reissue    20
    XCSR
    Verify the new expiration date in XDVD   ${myplastic}   ${newExpDt}
    XCSR
    Verify the new expiration date in XDVD   ${secondaryApp}   ${newExpDt}
    XCSR
    Get alternative card number from XPAD  ${myplastic}
    XCSR
    Check CAPI for expiration and reissue dates    ${myplastic}   ${newExpDt}   ${prevExpDt}
    write plastic to file  ${test case name}
    ...                    ${myplastic}
    ...                    ${online_date}
    ...                    &{environment}[owner]
    ...                    ${alternativeID}
    ...                    ${accountID}
    log  ${test case name}
    log  ${myplastic}
    log  &{environment}[owner]
    log  ${alternativeID}
    log  ${accountID}





