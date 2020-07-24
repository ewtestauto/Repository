*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime
Library     String
Library     calendar
Library     excelLibrary

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


*** Keywords ***
    clean after fake PPRFL.X91EVFBI