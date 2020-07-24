*** Settings ***
Documentation    Verify plastic embossed and present in file

Library        py3270lib    visible=${TRUE}
Library        user_password
Library        BuiltIn
Library        DateTime                            #necessary to make a backup of a dataset with date at the end

Resource       ../SharedKeywords.robot             #contains keywords that can be used in all tests
Resource       ../Environments.robot               # contains handling for environments
                                                   # environment is set up in test setup
Resource       PlasticSetupKeywords.robot          #contains keywords that are specific to plastic setup

Test Setup     Test setup for Plastic Setup  ${environment_name}   #This set up has to take variable for environment
                                                                   # sets the &{environment} dict used by keywords
Test Teardown  Test teardown for Plastic Setup


*** Variables ***
${test_case_name}  01a.02       # required to fetch the correct plastic from text file

@{plastic list}
# set by get plastic data to verify
# list of plastics to be checked, stored in dictionaries
&{plastic data}     plastic number=
...                 embossing file=
# this variable stores the plastic number to be checked, set by the keyword retrieving the variable from file
# and also the embossing file where the plastic must be found

${online_date}      # set by 'get environment date'

${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot  -v environment_name:SITITA04 NEXI/01a.plastic_setup/1adot1post-batch.robot

# this has to be here, or the environment won't be set
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=
...             examplecompanyid=

*** Keywords ***


*** Test Cases ***
1adot1post-batch
    # setup occurs here
    go to cicsk
    get environment date  &{environment}[examplecompanyid]
    get out of tso/cicsk/saregkt
    log out of cicsk session

    get plastic data to verify  ${test_case_name}  ${online_date}  &{environment}[owner]

    FOR  ${plastic data}  IN  @{plastic list}
        go to cicsk
        verify plastic embossed on CAPI  ${plastic data}[plastic number]
        get out of tso/cicsk/saregkt
        log out of cicsk session

        log in to tso
        from ISPF backup dataset  &{environment}[datasetprefix]PPR14.${plastic data}[embossing file]
        Run keyword and continue on failure
        ...     from ISPF search for plastic in embossing file
        ...                       ${plastic data}[plastic number]  ${plastic data}[embossing file]
        get out of tso/cicsk/saregkt
        log out of tso session
        Run keyword and continue on failure
        ...     Verify plastic on table post-batch
        ...                       ${plastic data}[plastic number]  ${environment}[owner]  ${batch_date}
        get out of tso/cicsk/saregkt
        log out of tso session
    END

    log  &{plastic data}[plastic number] has been verified
    # teardown occurs here


#TODO think if keywords should have arguments
#TODO maybe move file names from python to keyword? or to argument?
