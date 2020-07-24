#This contains keywords that are specific to plastic setup tests

*** Settings ***
Documentation  Includes keywords using in plasctic setup process defined within _*PlasticSetupKeywords.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\01a.plastic_setup*_
Library   Collections        #necessary for using dictionaries
Library   String             #used to format date
Library   CsvSaveAndRetrievePlastic.py  # used in keywords 'get plastic data to verify'

Resource  ../SharedKeywords.robot
Resource  customerdata/GetNewCustomer.robot

*** Keywords ***

#I think these keywords will work in all plastc setup test cases
#This remains to be seen

Test setup for Plastic Setup
    [Arguments]  &{environment}
    [Documentation]  Test Setup for all tests for Plastic Setup process using in part `Settings`.
    ...
    ...  Usage:
    ...
    ...  - ``Test Setup  Test setup for Plastic Setup  &{environment}``, where &{environment} is environment for executing tests.
    ...
    ...  An example:
    ...    - ``Test Setup     Test setup for Plastic Setup  &{RLSEI}``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Set environment`, available in *\\PyCharm\\NEXI\\Environments.robot* file; |
    ...  | | `Connect to mainframe`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Log out of TSO session`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Log out of CICSK session`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Set UDFL`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Post-requisite | |
    ...
    Set environment  &{environment}
    Connect to mainframe
    Log out of TSO session
    Log out of CICSK session
    Set UDFL

Test teardown for Plastic Setup
    [Documentation]  Test Teardown for all tests for Plastic Setup process using in part `Settings`. Logs out of TSO,
    ...  CICSK sessions and mainframe.
    ...
    ...  Usage:
    ...
    ...  - ``Test Teardown  Test teardown for Plastic Setup``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Get out of TSO/CICSK/SAREGKT`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Log out of TSO session`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Log out of CICSK session`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | | `Log out of mainframe` |
    ...  | Post-requisite | |
    ...
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Log out of CICSK session
    send pf         24
    send pf7
    Log out of mainframe

Log out of mainframe
    [Documentation]  Logs out of mainframe.
    ...
    ...  Usage:
    ...
    ...  - ``Log out of mainframe``
    ...
    ...  | Pre-requisite  | `Connect to mainframe`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file; |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label   Comando ===>   logoff
    send enter

Check XCPP piedino validity
#this keyword requires a list variable with piedino in the test case
#it also stores some info for later verification in dictionary &{xcpp}
    [Documentation]  Checks piedino validity using XCPP function.
    ...  This keyword requires a list variable with piedino in the test case. It also stores some info for later verification in dictionary &{xcpp}.
    ...
    ...  Usage:
    ...
    ...  - ``Check XCPP piedino validity``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Post-requisite | |
    ...
    xcsr
    fill field by label  FUNCTION  XCPP
    send enter
    send tab
    FOR  ${item}  IN  @{piedino}
       send string  ${item}
       #this loop will also send the CAB code from the last item of the list
       #but it doesn't matter, because it does not actually put it anywhere on the screen
    END
    send pf6
    log screen
    #string found  2  49  4 INQUIRY SUCCESSFUL
    #TODO this sometimes gives a different message - PCD default something something
        #the problem is that I cannot reproduce this and I do not know how to verify this
        #maybe like this:
    ${not found}=  string get  2  51
    Run keyword if  '${not found}'=='PIEDINO NOT FOUND'  string found  2  49  4 INQUIRY SUCCESSFUL
        #TODO this way it should be stopped if we get 'PIEDINO NOT FOUND'
    string found  8  68  31/12/2799
    #this is the equivalent of indefinite expiry date, we only want piedinos that do not have a set expiry date

    ${company id}=      string get  10  17
    ${cis company id}=  string get  11  43
    ${pls type}=        string get  16  15
    ${pls stock}=       string get  16  33
    ${pgm sol cd}=      string get  10  38  8  #has to be 8 field long, no two spaces at end of field
    ${owner 1}=         string get  11  17

    Set to dictionary   ${xcpp}  company id=${company id}    #this works, name of dictionary starting with $
    Set to dictionary   ${xcpp}  cis company id=${cis company id}
    Set to dictionary   ${xcpp}  pls type=${pls type}
    Set to dictionary   ${xcpp}  pls stock=${pls stock}
    Set to dictionary   ${xcpp}  pgm sol cd=${pgm sol cd}
    Set to dictionary   ${xcpp}  owner 1=${owner 1}

Get environment date
#requires to first run the Check XCPP piedino validity to get company id
#or just the company id as argument
#sets the ${environmentdate} variable
    [Arguments]  ${company id}
    [Documentation]  Sets the ${environmentdate} variable.
    ...
    ...  Usage:
    ...
    ...  - ``Get environment date  ${company id}``
    ...
    ...  An example:
    ...    - ``Get environment date  ${3104}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send clear
    send string  ucsc
    send enter
    send string  iicf
    send enter
    Fill field by label  COID  ${company id}
    send pf6
    ${environmentdate}=  string get  8  47
    ${environmentdate}=  Replace string  ${environmentdate}  /  .
    Set test variable  ${environmentdate}

Get data from PCD906073
#gets data from pcd to verify after plastic setup
#requires XCPP keyword to run first
    [Documentation]  Gets data from PCD906073 and stores in dictionary ${pcd906073} to verify after plastic setup.
    ...
    ...  Usage:
    ...
    ...  - ``Get data from PCD906073``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `Check XCPP piedino validity` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send clear
    send string  u
    send enter
    fill field by label  Select Option ===>  2
    send enter
    fill field by label  Select Option ===>  1
    send enter
    fill field by label  Format ==>          906073
    send enter
    fill field by label  KEY...  ${xcpp}[company id],${xcpp}[owner 1] ,*;*,&{xcpp}[pls type]
    send pf6
    log screen
    #sleep  1
    string found  1  51  Action Successful
    ${plastic status}=            string get  20  29  3
    ${reason code}=               string get  20  35
    ${chip type}=                 string get  8   12  3
    ${interchange service code}=  string get  19  29
    ${embossing file}=            string get  13  47  8

    Set to dictionary  ${pcd906073}  plastic status=${plastic status}
    Set to dictionary  ${pcd906073}  reason code=${reason code}
    Set to dictionary  ${pcd906073}  chip type=${chip type}
    Set to dictionary  ${pcd906073}  interchange service code=${interchange service code}
    Set to dictionary  ${pcd906073}  embossing file=${embossing file}

enter piedino
    #requires @{piedino} as list in test case
    [Documentation]  Enters piedino from @{piedino} list available in Test Case in part `Variables` .
    ...
    ...  Usage:
    ...
    ...  - ``enetr piedino``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    FOR  ${index}  ${item}  IN ENUMERATE  @{piedino}
        send string  ${item}
        Run keyword if  '${index}'=='4'  send enter
        #after entering the first five elements (index 4 on the list) of the piedino, we press enter
        #and the system skips to the next field that has to be filled
    END
    send enter
    log screen
    string found  3  1  CUSTOMER LOCATE

CUSTOMER LOCATE screen
    [Documentation]  Enters Customer data on CUSTOMER LOCATE screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``CUSTOMER LOCATE screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  SURNAME            &{customer}[surname]
    fill field by label  ${SPACE}NAME       &{customer}[name]
    #the space has to be here, otherwise the script will put the name into surname field
    fill field by label  FISCAL CODE-IVA    &{customer}[fiscalcode]
    fill field by label  DOB                &{customer}[dateofbirth]
    fill field by label  PROV               &{customer}[provinceofbirth]
    log screen
    send pf2
    log screen
    string found  5  34  GENERAL DATA

GENERAL DATA screen
    #requires ${environmentdate} in the test case
    [Documentation]  Enters Customer data on GENERAL DATA screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``GENERAL DATA screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  1:                 y
    fill field by label  2:                 y
    fill field by label  3:                 y
    fill field by label  4:                 y
    fill field by label  PLACE              &{customer}[placeofbirth]
    fill field by label  PROV               &{customer}[provinceofbirth]
    fill field by label  SEX                &{customer}[sex]
    fill field by label  TYPE DOC           1
    fill field by label  NBR                AK1234567   #this can probably be whatever
    ${IDdocumentDate}=   Subtract one year  ${environmentdate}
    #maybe do it in the keyword
    fill field           17  71             ${IDdocumentDate}
                                            #this should be environment date -1 year
    #this has to be like this because there is more than one date field
    fill field by label  ISSUED BY          1
    fill field           18  50             MILANO
    #as above, there are two fields named PLACE
    fill field by label  PROVINCE           MI
    send enter
    log screen
    string found         5  8               RESIDENCE ADDRESS OF

RESIDENCE ADDRESS screen
    [Documentation]  Enters Customer data on RESIDENCE ADDRESS screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``RESIDENCE ADDRESS screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  STREET AND NBR     Strada 1
    fill field by label  ZIP CODE           20142
    fill field by label  CITY               Milano
    fill field by label  PROVINCE           MI
    fill field           17  31             333
    fill field           17  38             7777777
    send enter
    log screen
    string found         5  7               ADDITIONAL INFORMATION OF

ADDITIONAL INFORMATION screen
    [Documentation]  Enters Customer data on ADDITIONAL INFORMATION screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``ADDITIONAL INFORMATION screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  ACTIVITY AREA      1
    fill field by label  PROFESSIONAL SECTOR         1
    fill field by label  PROFESSIONAL QUALIFICATION  1
    send enter
    log screen
    string found         5  29              APPLICATION INITIATION

APPLICATION INITIATION screen
    [Documentation]  Enters Customer data on APPLICATION INITIATION screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``APPLICATION INITIATION screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send enter
    string found         5  27              CURRENT EMPLOYER MAINTENANCE

CURRENT EMPLOYER MAINTENANCE screen
    [Documentation]  Enters Customer data on CURRENT EMPLOYER MAINTENANCE screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``CURRENT EMPLOYER MAINTENANCE screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  CURR.EMPL.SENIORITY         0101
    #these are two fields, but it works, also in ZIP - CITY
    fill field by label  CURRENT EMPLOYER   CSC
    fill field by label  STREET AND NBR.    Via Strada 1
    fill field by label  ZIP - CITY         20090${SPACE * 4}Assago
    fill field by label  PROVINCE           MI
    fill field by label  COUNTRY            ITA
    send enter
    string found         5  26              INCOME/REFERENCE MAINTENANCE

INCOME/REFERENCE MAINTENANCE screen
    [Documentation]  Enters Customer data on INCOME/REFERENCE MAINTENANCE screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``INCOME/REFERENCE MAINTENANCE screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  CURR.ADD.SENIOR.   0101
    fill field by label  OWN/RENT/OTH       o
    send enter
    string found         5  27              EXTERNAL RELATIONSHIPS

RELATED ACCOUNT screen
    #requires ${iban} defined in the test case
    [Documentation]  Enters Customer data on RELATED ACCOUNT screen. Requires using setup function, e.g. APSU.
    ...  Uses ${iban} defined in the test case.
    ...
    ...  Usage:
    ...
    ...  - ``RELATED ACCOUNT screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send tab
    send string          ${iban}
    fill field by label  AUTO PAY METHOD    f
    log screen
    send enter
    string found         3  1               CAPS - STATEMENT ADR SETUP

CAPS - STATEMENT ADR SETUP screen
    [Documentation]  Enters Customer data on CAPS - STATEMENT ADR SETUP screen. Requires using setup function, e.g. APSU.
    ...
    ...  Usage:
    ...
    ...  - ``CAPS - STATEMENT ADR SETUP screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `enter piedino` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    send enter
    string found         3  1               CAPS - EVALUATION RESULTS

Check on CAPI screen
    [Documentation]  Checks existing of created plastic on CAPI screen.
    ...
    ...  Usage:
    ...
    ...  - ``Check on CAPI screen``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Post-requisite | |
    ...
    XCSR
    fill field by label  FUNCTION  CAPI
    fill field by label  ACCOUNT   ${newplastic}
    send enter
    log screen
    #string found         2   49    4 INQUIRY SUCCESSFUL
    #TODO restore the above check - sometimes there is a different message
    string found         5   60    PST &{PCD906073}[plastic status]
    #TODO also read the plastic open date, and compare with ac_op_dt
        #but which field is it CAPI? "INITIAL ISSUE DT"?

Verify plastic on table
    [Documentation]  Verifies existing of created plastic on table. Uses ${environmentdate}, ${XCPP}, ${PCD906073},
    ...  ${newplastic}, ${newaccount}, ${customer} defined in the test case.
    ...
    ...  Usage:
    ...
    ...  - ``Verify plastic on table``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Post-requisite | |
    ...
    log in to tso
    Send string     r
    Send enter
    Send string     8
    Send enter
    Send string     4
    Send enter
    Send string     3
    Send enter
    Sleep           1
    String found    3   25  Enter, Execute and Explain SQL
    Send query    SELECT B.PL_ID, A.AC_CD,
          ...     B.PL_ADD_DT, B.PL_EMB_LN1_NM, B.PL_CO_NR, B.CU_CO_ID, B.PY_TYP_CD,
          ...     B.PL_CRD_STK_CD, A.CA_SLTN_PG_CD, A.AC_OWNR1_CD, B.PL_CUR_STAT_CD,
          ...     B.PL_CUR_STAT_RSN_CD, B.PL_CHIP_TYP_CD, B.PL_ICHG_SVC_CD
          ...     FROM &{environment}[owner].DCTAC_ACCOUNT A, &{environment}[owner].DCTPL_PLASTIC B
          ...     WHERE A.AC_INTRL_ID = B.AC_INTRL_ID
          ...     AND B.PL_ID = '${newplastic}'
          ...     WITH UR;
    log screen
    Sleep           1
    Send enter
    Sleep           1
    send pf2
    string found    3   29  Select Statement Browse
    string found    9   31  ${newaccount}
    Run keyword and continue on failure  string found    10  31  ${environmentdate}
    Run keyword and continue on failure  string found    11  31  ${customer}[name] ${customer}[surname]
                            #TODO make sure this is uppercase
                                #it's done in the python lib that takes a new customer
    Run keyword and continue on failure  string found    12  32  ${XCPP}[company id]
    #String " 3104" was not found at position 14,33
    #Found 3104  instead.
    #this is why it is 12  32, and not 31
    #TODO will this work with longer company ID?
    Run keyword and continue on failure  string found    13  32  ${XCPP}[cis company id]
    Run keyword and continue on failure  string found    14  31  ${XCPP}[pls type]
    Run keyword and continue on failure  string found    15  31  ${XCPP}[pls stock]
    Run keyword and continue on failure  string found    16  31  ${XCPP}[pgm sol cd]
    Run keyword and continue on failure  string found    17  31  ${XCPP}[owner 1]
    Run keyword and continue on failure  string found    18  31  ${PCD906073}[plastic status]
    Run keyword and continue on failure  string found    19  31  ${PCD906073}[reason code]
    Run keyword and continue on failure  string found    20  31  ${PCD906073}[chip type]
    Run keyword and continue on failure  string found    21  31  ${PCD906073}[interchange service code]
    #these are all the fields that are requested in the query above, I don't know how to make it more legible
    #TODO verify more fields

verify plastic embossed on CAPI
    # used in post-batch verification, assumes existing  &{plastic data}[plastic number]
    [Arguments]  ${plastic number}
    [Documentation]  Verifies existing of created plastic on CAPI screen.
    ...  Used in post-batch verification, assumes existing  &{plastic data}[plastic number].
    ...
    ...  Usage:
    ...
    ...  - ``verify plastic embossed on CAPI  ${plastic number}``
    ...
    ...  An example:
    ...    - ``verify plastic embossed on CAPI  ${plastic data}[plastic number]``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Post-requisite | |
    ...
    xcsr
    fill field by label  FUNCTION   CAPI
    fill field by label  ACCOUNT    ${plastic number}
    send enter
    log screen
    Run keyword and continue on failure  string found  1   24  CAPI
    Run keyword and continue on failure  string found  11  62  C

from ISPF search for plastic in embossing file
    # used in post-batch verification
    # requires existing variables as seen blow
    [Arguments]  ${plastic number}  ${embossing file}
    [Documentation]  Verifies existing of created plastic in embossing file.
    ...  Used in post-batch verification.
    ...
    ...  Usage:
    ...
    ...  - ``from ISPF search for plastic in embossing file  ${plastic number}  ${embossing file}``
    ...
    ...  An example:
    ...    - ``from ISPF search for plastic in embossing file  ${plastic data}[plastic number]  ${plastic data}[embossing file]``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeyords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    fill field by label  Option  1
    send enter
    fill field by label  ${SPACE * 2}Name   '&{environment}[datasetprefix]PPR14.${embossing file}
    send enter
    fill field by label  Command            f ${plastic number}
    send enter
    Run keyword and continue on failure     string found  3  63  ${plastic number}
    log screen

get plastic data to verify
    # used in post-batch verification, takes plastic data from file
    # requires 'get environment date'
    [Arguments]  ${test case name}
    [Documentation]  Takes plastic data from file. Requires 'get environment date'.
    ...  Used in post-batch verification.
    ...
    ...  Usage:
    ...
    ...  - ``get plastic data to verify ${test case name}``
    ...
    ...  An example:
    ...    - ``get plastic data to verify  ${test case name}``
    ...
    ...  | Pre-requisite  | `Get environment date` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    @{plastic list}=  retrieve multiple plastics from file  ${test case name}  ${environmentdate}
                      # this keyword from python library
    set test variable  @{plastic list}

# from cicsk get company ID for plastic
     # currently notused anywhere
#    xcsr
#    fill field by label  FUNCTION       CAPN
#    fill field by label  ACCOUNT        &{plastic data}[plastic number]
#    send enter
#    string found         1  24          CAPN
#    ${company id}=       string get     7  76  5
#    set test variable    ${company id}




