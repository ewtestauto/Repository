*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin


*** Variables ***
# Here put new description for test
${transactionDescription}=  TATEST 05 20200707
# Don't change variables below:
${transactionCode}=  5935
${transactionReasonCode}=  PU
${transactionCurrencyCode}=  978
${transactionAmount}=  20.00                # In format xx.xx less than 100,00
