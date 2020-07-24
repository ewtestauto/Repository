*** Settings ***
Documentation  Includes environment keywords defined within _*Environments.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI*_
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


*** Keywords ***
Set environment
#TODO maybe do this as Set to dictionary?
#Creates an &{environment} variable that stores info to use in the test case
    [Arguments]  &{setthis}
    [Documentation]  Creates an &{environment} variable that stores info to use in the test case.
    ...
    ...  Usage:
    ...
    ...    - ``Set environment   &{setthis}``, where &{setthis} is chosen variable\
    ...  from available in section `Variables` in *\\PyCharm\\NEXI\\Environments.robot* file
    ...
    ...  An example:
    ...    - ``Set environment   &{RLSEI}``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    &{environment}=  Create dictionary  owner=&{setthis}[owner]
    ...                                 appprefix=&{setthis}[appprefix]
    ...                                 jobprefix=&{setthis}[jobprefix]
    ...                                 datasetprefix=&{setthis}[datasetprefix]
    ...                                 cicsk=&{setthis}[cicsk]
    ...                                 companynumber=&{setthis}[companynumber]
    ...                                 pool=&{setthis}[pool]
    Set test variable  &{environment}
