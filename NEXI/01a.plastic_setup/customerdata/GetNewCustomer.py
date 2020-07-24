import csv
from random import randint


class GetNewCustomer(object):

    def get_new_customer_from_file(self, owner, filename):
        # this method takes as arguments the table owner from environment and path to the file with client data as CSV
        # it finds the first client in that file that does not have the environment name added
        # then it adds that environment name to the client
        # then it returns client data as dictionary
        #TODO make a backup of the file with real date
        new_customer = {}
        # this variable holds a dictionary with customer data to return
        my_file_content = []
        # this variable holds the whole content of the csv file as a table of tables
        with open(filename, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        # make a copy of the file content
        my_file_content_copy = []
        for row in my_file_content:
            my_file_content_copy.append(row)

        # remove already used rows from copy
        remove_this_from_copy = []
        for row in my_file_content_copy:
            if owner in row:
                remove_this_from_copy.append(row)
        for row in remove_this_from_copy:
            my_file_content_copy.remove(row)

        # take random customer from copy
        # take new one until you get one that is 13 elements long
        take_this_codice_fiscale = []
        while len(take_this_codice_fiscale) < 13:
            take_this_codice_fiscale = my_file_content_copy[randint(0, len(my_file_content_copy)-1)][5]

        # take the customer from original file content and add owner name
        for customer in my_file_content:
            if take_this_codice_fiscale in customer:
                customer.append(owner)
                new_customer = {"name":                   customer[1].upper(),
                                "surname":
                                                customer[0].replace('ï', '').replace('»', '').replace('¿', '').upper(),
                                # these are formatting bytes from the text file, only in the first line
                                "fiscal_code":            customer[5].upper(),
                                "date_of_birth":          customer[4].upper(),
                                "province_of_birth":      customer[3].upper(),
                                "place_of_birth":         customer[2].upper(),
                                "address_street":         customer[6].upper(),
                                "address_street_number":  customer[7].upper(),
                                "address_zip":            customer[8].upper(),
                                "address_city":           customer[9].upper(),
                                "address_province":       customer[10].upper(),
                                "phone_prefix":           '333',
                                "phone_number":           '7777777',
                                "sex":                    customer[12]
                                }
                if not customer[11] == '':
                    new_customer['phone_prefix'] = customer[11].split('-')[0]
                    new_customer['phone_number'] = customer[11].split('-')[1]
                break

        with open(filename, mode='w') as customer_file:
            my_writer = csv.writer(customer_file)
            my_writer.writerows(my_file_content)
        return new_customer

