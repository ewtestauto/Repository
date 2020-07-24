*** Settings ***
Documentation  Includes environment keywords defined within _*Environments.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin


*** Variables ***

*** Keywords ***

Set environment2
    # requires argument with environment owner name as text
    # this is named 2 because there was an older version no longer used
    # if you want to add a new keyword "set newevnironment" and add it to this keyword as well
    [Arguments]  ${environment name}
    Create dictionary  &{environment}  owner=
    ...                                appprefix=
    ...                                jobprefix=
    ...                                datasetprefix=
    ...                                cicsk=
    ...                                companynumber=
    ...                                pool=
    ...                                examplecompanyid=

    Run keyword if  '${environment name}'=='RLSEI'      Set RLSEI
    Run keyword if  '${environment name}'=='SITITA04'   Set SITITA04
    Run keyword if  '${environment name}'=='IC6'        Set IC6
    Run keyword if  '${environment name}'=='IC7'        Set IC7

Set RLSEI
    Set to dictionary   ${environment}  owner=RLSEI
    Set to dictionary   ${environment}  appprefix=ICP
    Set to dictionary   ${environment}  jobprefix=DBI
    Set to dictionary   ${environment}  datasetprefix=icps.rlse.icr
    Set to dictionary   ${environment}  cicsk=CK35
    Set to dictionary   ${environment}  companynumber=30000
    Set to dictionary   ${environment}  pool=${SPACE * 2}
    Set to dictionary   ${environment}  examplecompanyid=03104

Set SITITA04
    Set to dictionary   ${environment}  owner=SITITA04
    Set to dictionary   ${environment}  appprefix=DBD
    Set to dictionary   ${environment}  jobprefix=DBD
    Set to dictionary   ${environment}  datasetprefix=icps.itst.icd
    Set to dictionary   ${environment}  cicsk=CK23A
    Set to dictionary   ${environment}  companynumber=30000
    Set to dictionary   ${environment}  pool=04
    Set to dictionary   ${environment}  examplecompanyid=03104

Set IC6
    Set to dictionary   ${environment}  owner=IC6
    Set to dictionary   ${environment}  appprefix=DBL
    Set to dictionary   ${environment}  jobprefix=DBL
    Set to dictionary   ${environment}  datasetprefix=icps.pron.icp
    Set to dictionary   ${environment}  cicsk=CK25
    Set to dictionary   ${environment}  companynumber=30000
    Set to dictionary   ${environment}  pool=${SPACE * 2}
    Set to dictionary   ${environment}  examplecompanyid=03104

Set IC7
    Set to dictionary   ${environment}  owner=IC7
    Set to dictionary   ${environment}  appprefix=DBW
    Set to dictionary   ${environment}  jobprefix=DBW
    Set to dictionary   ${environment}  datasetprefix=icps.itst.icw
    Set to dictionary   ${environment}  cicsk=CK23A
    Set to dictionary   ${environment}  companynumber=30000
    Set to dictionary   ${environment}  pool=${SPACE * 2}
    Set to dictionary   ${environment}  examplecompanyid=03104
