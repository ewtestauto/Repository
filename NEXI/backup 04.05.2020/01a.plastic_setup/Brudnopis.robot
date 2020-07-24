*** Settings ***
Library        py3270lib    visible=${TRUE}
Library        user_password
Library        BuiltIn
Library        DateTime                            #necessary to make a backup of a dataset with date at the end

Resource       ../SharedKeywords.robot             #contains keywords that can be used in all tests
Resource       ../Environments.robot               # contains handling for environments
                                                   # environment is set up in test setup
Resource       PlasticSetupKeywords.robot          #contains keywords that are specific to plastic setup

*** Keywords ***

Log plastic
    log  ${plastic}[plastic number]

*** Variables ***
${environmentdate}  01.04.2020

*** Test Cases ***
Test title
    @{my plastics}=  retrieve multiple plastics from file  01a.01  01.03.2020
    FOR  ${plastic}  IN  @{my plastics}
        set test variable  ${plastic}
        Log plastic
    END



