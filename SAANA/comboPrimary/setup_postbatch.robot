*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime


Resource   ../SharedKeywordsSAN.robot
Resource   ../Environments1.robot
Resource   Setup_Keywords.robot
Resource   ../Set_Teardown.robot

Test Setup     Test setup   ${environment name}
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


${company id}   20000
${plastic1}  4010432000081385
${accountid1}   1573761700000
${alternative_plastic1}   40104392AAT31385
${plastic2}  4010462000108813
${accountid2}   1573761701000
${alternative_plastic2}   40104693AAT38813
${jsonfile}   IFO04.JSON

*** Keywords ***


*** Test Cases ***
PostbatchSetup
    Go to CICSK updated
    Get environment date     ${company id}
    XCSR
    Open XDVL   ${plastic1}
    Check XDVL card status   40
    XCSR
    Open XDVL   ${plastic2}
    Check XDVL card status   40
    Get out of TSO/CICSK/SAREGKT
    Log in to TSO
    from ISPF search for combo cards in file   ${plastic1}  ${plastic2}    ODSO1.X91ODSRO.ALLBUT50
    from ISPF search for debit plastic in JSON file  ${accountid2}  2  1  No  4
    from ISPF search for credit plastic in JSON file  ${accountid1}  2  1  1  3

