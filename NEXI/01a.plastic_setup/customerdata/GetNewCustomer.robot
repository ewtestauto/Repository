*** Settings ***
Resource       ../../SharedKeywords.robot             #contains keywords that can be used in all tests

Library        GetNewCustomer.py

*** Keywords ***

Get new customer
    # this keyword takes a new customer from file, and checks if he exists in this environment
    # if he does, it takes another one and check again
    # it fills the &{customer} dict with data
    # on table customer_tb
    # CUST_NAME_LINE_1 -> &{customer}[name]${SPACE}*&{customer}[surname]
    # BIRTH_DATE -> &{customer}[date_of_birth]
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
    FOR  ${index}  IN RANGE  1  999
        String found    3   25  Enter, Execute and Explain SQL

        ${customer data file}=  Set variable if  '${variable_customer}' == 'Y'
        ...                                             NEXI/01a.plastic_setup/customerdata/variable_customer.txt
        ...                                             NEXI/01a.plastic_setup/customerdata/customer_data_parsed.txt
        # this sets the first file if variable=Y, second file (default) if it is anything else

        &{customer}=  get new customer from file  &{environment}[owner]  ${customer data file}
        Set test variable  &{customer}
        Send query    SELECT CUST_NAME_LINE_1, BIRTH_DATE
              ...     FROM &{environment}[owner].CUSTOMER_TB
              ...     WHERE CUST_NAME_LINE_1 = '&{customer}[name]${SPACE}*&{customer}[surname]'
              ...     WITH UR;
        Sleep           1
        log screen
        Sleep           1
        Send enter
        Sleep           1
        ${name *surname}=  string get  11  2
        log  &{customer}[name]${SPACE}*&{customer}[surname]
        log  ${name *surname}
        Run Keyword Unless  '${name *surname}' == '&{customer}[name]${SPACE}*&{customer}[surname]'  Exit For Loop
        send pf3
        send pf3
        Send string     3
        Send enter
    END
    Log  &{customer}[name]${SPACE}&{customer}[surname]
    Log  &{customer}[name]${SPACE}*&{customer}[surname]
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
