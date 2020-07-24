*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime


Resource   ../SharedKeywordsSAN.robot
Resource   ../Environments1.robot
Resource   Setup_Keywords.robot
Resource   ../Set_Teardown.robot

#Test Setup     Test setup   ${environment name}
#Test Teardown  Test teardown

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
${jsonfile}     IFO04.JSON.D200423.T0919
${accountid2}   0843943941000
${accountid1}   0843943940000
${plastic1}   4010432000031984
${plastic2}   4010462000276883
${filename}   ODSO1.X91ODSRO.ALLBUT50.D200423

#todo in prebatch add account id and save it
#todo take plastic from file and determine which one is credit/ debit
*** Keywords ***
Simulate connection to EVRY
#starts in tso
    Send string     r
    Send enter
    Send string     4
    Send enter
    Send string     5
    Send enter
    Send string     1
    Send enter
    Sleep           1
    log screen
    String found  1  22  ADDING APPLICATIONS TO THE CURRENT PLAN
    fill field by label   APPLICATION ID    JOBESTEMPOR1
    log screen



*** Test Cases ***
step 8
    ${date}=  Get current date  result_format=%Y%m%d
    set variable    ${date}
    ${dateDD}=  get substring       ${date}   -2
    ${dateMM}=  get substring       ${date}   4  6
    ${dateYYYY}=  get substring       ${date}   0   4