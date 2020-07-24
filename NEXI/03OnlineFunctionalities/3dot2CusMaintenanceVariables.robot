*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin


*** Variables ***
# Here put new address for test - street, ZIP, city, prov, country
# TODO from Customer file variable (random on Kacper's customer CSV)
${myNewStreet}=  01TA20200707
${myNewZip}=  20142
${myNewCity}=  MILANO
${myNewProv}=  MI
${myNewCountry}=  ITA








