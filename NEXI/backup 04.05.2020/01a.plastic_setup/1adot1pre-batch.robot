*** Settings ***
Library        py3270lib    visible=${TRUE}
Library        user_password
Library        BuiltIn

Resource       ../SharedKeywords.robot             #contains keywords that can be used in all tests
Resource       ../Environments.robot               #contains handling for environments
                                                   # environment is set up in test setup
Resource       PlasticSetupKeywords.robot          #contains keywords that are specific to plastic setup

Test Setup     Test setup for Plastic Setup  &{RLSEI}   #This set up has to take variable for environment
Test Teardown  Test teardown for Plastic Setup



*** Variables ***
${test case name}  01a.01

@{piedino}   1       #centro
...          7       #punzonatura
...          10      #tipo titolare
...          06      #iniziativa
...          0591    #azione
...          03104   #abi
...          01600   #cab

&{customer}  name=
...          surname=
...          sex=
...          fiscalcode=
...          dateofbirth=
...          provinceofbirth=
...          placeofbirth=
#The strings have to be capitalized for comparing fields in CAMS


${externalReferenceNumber}  dc615hb
#This is used on EXTERNAL RELATIONSHIPS screen, it is specific to this test

${iban}  IT12V0310401600001234567890deutsche bank
#TODO do this in lines

${environmentdate}
#the format has to be like this: dd.mm.yyyy for purposes of verification in tables, this is the environment date

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
    fill field by label     FUNCTION    APSU
    send enter

    enter piedino
    CUSTOMER LOCATE screen
    GENERAL DATA screen
    RESIDENCE ADDRESS screen
    ADDITIONAL INFORMATION screen
    APPLICATION INITIATION screen
    CURRENT EMPLOYER MAINTENANCE screen
    INCOME/REFERENCE MAINTENANCE screen

#EXTERNAL RELATIONSHIPS screen
    send string          ${externalReferenceNumber}
    send enter
    log screen
    string found         5  33              RELATED ACCOUNT
    #TODO make this a universal keyword with conditions

    RELATED ACCOUNT screen
    CAPS - STATEMENT ADR SETUP screen

#CAPS - EVALUATION RESULTS screen
    log screen
    #get the plastic without dashes -
    ${newplastic}=  string get  10  13
    ${newplastic}=  Remove String  ${newplastic}  -
    Set test variable  ${newplastic}
    log  ${newplastic}
    ${newaccount}=  string get  11  13
    ${newaccount}=  Remove String  ${newaccount}  -  *
    Set test variable  ${newaccount}
    log  ${newaccount}
    ${approved?}=   string get  21  18
    #TODO if ${approved?} is anything other than APV, approve the plastic
        #in other words, make this a universal keyword

    Check on CAPI screen

    get out of tso/cicsk/saregkt
    log out of cicsk session
    log out of tso session

    Verify plastic on table

    get out of tso/cicsk/saregkt
    go to cicsk

#Change plastic status to AA
    fill field by label  FUNCTION  CAST
    fill field by label  ACCOUNT   ${newplastic}
    send enter
    fill field           12  2     CHG
    fill field           12  61    AA AA
    send enter
    string found         2   49    3 CHANGE SUCCESSFUL
    string found         12  53    AA${SPACE * 2}AA
    #TODO make this a universal keyword
        #there can be more than one plastic
        #sometimes you have to also approve the account

    write plastic to file  ${test case name}  ${newplastic}  ${environmentdate}  ${PCD906073}[embossing file]
    #TODO add this as logs


    #TEARDOWN occurs here



#TODO make keyword "go to SQL search"









