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
${environment name}  RLSES

&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=

${alternative_id_from_file}  40104360AATA1293

*** Keywords ***

check data
    Send string     r
    Send enter
    Send string     8
    Send enter
    Sleep   1
    Run Keyword if   '${environment name}' == 'CK0A'  Fill field   16   68   DB25
    ...   ELSE
    ...   Fill field  16  68  db3
    send enter
    Sleep  5

*** Test Cases ***
Midbatch
    Go to CICSK updated