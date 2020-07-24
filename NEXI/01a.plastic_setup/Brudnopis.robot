*** Settings ***
Library        py3270lib    visible=${TRUE}
Library        user_password
Library        BuiltIn
Library        DateTime                            #necessary to make a backup of a dataset with date at the end

Resource       ../SharedKeywords.robot             #contains keywords that can be used in all tests
Resource       ../Environments.robot               # contains handling for environments
                                                   # environment is set up in test setup
Resource       PlasticSetupKeywords.robot          #contains keywords that are specific to plastic setup

Test Setup     Test setup for Plastic Setup     ${environment_name}   #This set up has to take variable for environment
Test Teardown  Test teardown for Plastic Setup

*** Keywords ***

Log plastic
    log  ${plastic}[plastic number]

Can you return from this
    Run keyword unless  '${variable1}'=='${variable2}'  return from keyword
    Log                 this should not be logged

Find additional plastic on CAST and change status to AA
    [Arguments]  ${plastic_number}
    fill field by label  FUNCTION  CAST
    fill field by label  ACCOUNT   ${plastic_number}

    ${pl_num_1}=  get substring  ${plastic_number}  0   4
    ${pl_num_2}=  get substring  ${plastic_number}  4   8
    ${pl_num_3}=  get substring  ${plastic_number}  8   12
    ${pl_num_4}=  get substring  ${plastic_number}  12

    ${plastic_number}=  catenate  ${pl_num_1}  -  ${pl_num_2}  -  ${pl_num_3}  -  ${pl_num_4}

    ${y}=  12


*** Variables ***
${environmentdate}  01.04.2020
${my date}
${my second date}
${variable1}        1
${variable2}        1

${environment_name}  RLSEI

*** Test Cases ***
Test title
    Go to CICSK
    Find additional plastic on CAST and change status to AA




