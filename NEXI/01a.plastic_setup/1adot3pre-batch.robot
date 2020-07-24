*** Settings ***
Library        py3270lib    visible=${TRUE}
Library        user_password
Library        BuiltIn

Resource       ../SharedKeywords.robot             #contains keywords that can be used in all tests
Resource       ../Environments.robot               #contains handling for environments
                                                   # environment is set up in test setup
Resource       PlasticSetupKeywords.robot          #contains keywords that are specific to plastic setup

Test Setup     Test setup for Plastic Setup     ${environment_name}   #This set up has to take variable for environment
Test Teardown  Test teardown for Plastic Setup



*** Variables ***
${test case name}  01a.03

${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot  -v environment_name:SITITA04 NEXI/01a.plastic_setup/1adot1pre-batch.robot

# this has to be here, or the environment won't be set
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=
...             examplecompanyid=

@{piedino}   1       #centro
...          6       #punzonatura
...          10      #tipo titolare
...          06      #iniziativa
...          0001    #azione
...          03104   #abi
...          01600   #cab

${setup_function}  APSU
# this is the function in CICS used to set up the plastic

&{customer}  name=
...          surname=
...          sex=
...          fiscal_code=
...          date_of_birth=
...          province_of_birth=
...          place_of_birth=
...          address_street=
...          address_street_number=
...          address_zip=
...          address_city=
...          address_province=
...          phone_prefix=
...          phone_number=
# The strings have to be capitalized for comparing fields in CAMS


${externalReferenceNumber}  ${EMPTY}
# This is used on EXTERNAL RELATIONSHIPS screen, it is specific to this test
# this is old variable from test 01

${iban}  IT12V0310401600001234567890DEUTSCHE BANK
#TODO do this in lines

${batch_date}
${online_date}
# the format has to be like this: dd.mm.yyyy for purposes of verification in tables, this is the environment date

&{XCPP}         company id=
...             cis company id=
...             pls type=
...             pls stock=
...             pgm sol cd=
...             owner 1=
#used to store data read from this screen, later used for verification, set by keyword

&{PCD906073}    plastic status=
...             reason code=
...             chip type=
...             interchange service code=
...             embossing file=
#set by keyword, stores data read from this pcd

&{PCD906006}    initial_issue_term=
# set by keyword, stores data from PCD

&{CAPI}         member_since_dt=
...             plas_emboss_dt=
...             expiration_dt=
# set by CHECK CAPI keyword, used in keyword Verify plastic on table

${variable_customer}  N
# Run this if you want to use customer data from /customerdata/variable_customer.txt:
# robot  -v variable_customer:Y NEXI/01a.plastic_setup/1adot1pre-batch.robot
# Add dots at the end if you have more than one customer in that file:
# robot  -v variable_customer:Y NEXI/01a.plastic_setup/1adot1pre-batch.robot . . .

${primary_plastic}
# This variable is necessary for additional plastics that require a primary plastic number, should be empty
${primary_test_case_name}
# This variable is used when retrieving a primary plastic from plastic_output.txt

*** Keywords ***




*** Test Cases ***
01adot01pre-batch
    #SETUP occurs here

    Get new customer

    Go to CICSK
    Check XCPP piedino validity
    Get environment date    &{xcpp}[company id]
    Get data from PCD906073
    XCSR
    Get data from PCD906006
    XCSR

    fill field by label     FUNCTION    ${setup_function}
    send enter

    enter piedino
    CUSTOMER LOCATE screen
    GENERAL DATA screen
    RESIDENCE ADDRESS screen
    ADDITIONAL INFORMATION screen
    APPLICATION INITIATION screen
    CURRENT EMPLOYER MAINTENANCE screen
    INCOME/REFERENCE MAINTENANCE screen

    EXTERNAL RELATIONSHIPS screen  ${externalReferenceNumber}

    RELATED ACCOUNT screen
    CAPS - STATEMENT ADR SETUP screen

    CAPS - EVALUATION RESULTS screen

    Check on CAPI screen

    get out of tso/cicsk/saregkt
    log out of cicsk session
    log out of tso session

    Verify plastic on table pre-batch

    get out of tso/cicsk/saregkt
    go to cicsk

    set plastic and account status to aa on cast

    write plastic to file  ${test case name}
    ...                    ${newplastic}
    ...                    ${online_date}
    ...                    ${PCD906073}[embossing file]
    ...                    &{environment}[owner]
    log  ${test case name}
    log  ${newplastic}
    log  ${online_date}
    log  ${PCD906073}[embossing file]
    log  &{environment}[owner]


    #TEARDOWN occurs here
