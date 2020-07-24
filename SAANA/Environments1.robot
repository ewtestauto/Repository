*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin


*** Variables ***
#Just add new environments here like this
#Then in the test you must set the environment using the keyword Set environment with dictionary as argument
#You will have the &{environment} variable

&{RLSEI}        owner=RLSEI
...             appprefix=ICP
...             jobprefix=DBI
...             datasetprefix=icps.rlse.icr
...             cicsk=CK35
...             companynumber=30000
...             pool=${SPACE * 2}

&{SITITA04}     owner=SITITA04
...             appprefix=DBD
...             jobprefix=DBD
...             datasetprefix=icps.itst.icd
...             cicsk=CK23A
...             companynumber=30000
...             pool=04

&{RLSES}        owner=RLSES
...             appprefix=SAN
...             jobprefix=SAN
...             datasetprefix=OPBK.rlse.icr
...             cicsk=CK35
...             companynumber=20000
...             pool=01

*** Keywords ***
Set environment
#TODO maybe do this as Set to dictionary?
#Creates an &{environment} variable that stores info to use in the test case
    [Arguments]  &{setthis}
    &{environment}=  Create dictionary  owner=&{setthis}[owner]
    ...                                 appprefix=&{setthis}[appprefix]
    ...                                 jobprefix=&{setthis}[jobprefix]
    ...                                 datasetprefix=&{setthis}[datasetprefix]
    ...                                 cicsk=&{setthis}[cicsk]
    ...                                 companynumber=&{setthis}[companynumber]
    ...                                 pool=&{setthis}[pool]
    Set test variable  &{environment}


Set environment2
    # requires argument with environment owner name as text
    [Arguments]  ${environment name}
    Create dictionary  &{environment}  owner=
    ...                                appprefix=
    ...                                jobprefix=
    ...                                datasetprefix=
    ...                                cicsk=
    ...                                companynumber=
    ...                                pool=

    Run keyword if  '${environment name}'=='RLSES'      Set RLSES
    Run keyword if  '${environment name}'=='CK0A'       Set CK0A



Set RLSES
    Set to dictionary   ${environment}  owner=RLSES
    Set to dictionary   ${environment}  appprefix=SAN
    Set to dictionary   ${environment}  jobprefix=SAN
    Set to dictionary   ${environment}  datasetprefix=OPBK.rlse.icr
    Set to dictionary   ${environment}  cicsk=CK35
    Set to dictionary   ${environment}  companynumber=20000
    Set to dictionary   ${environment}  pool=01


Set CK0A
    Set to dictionary   ${environment}  owner=QASAN01
    Set to dictionary   ${environment}  appprefix=SAO
    Set to dictionary   ${environment}  jobprefix=SAO
    Set to dictionary   ${environment}  datasetprefix=OPBK.PRON.ICN
    Set to dictionary   ${environment}  cicsk=CK0A
    Set to dictionary   ${environment}  companynumber=20000
    Set to dictionary   ${environment}  pool=01
