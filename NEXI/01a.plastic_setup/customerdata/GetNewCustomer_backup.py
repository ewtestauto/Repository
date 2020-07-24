import csv


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

        for customer in my_file_content:
            print(customer)
            if owner not in customer:
                customer.append(owner)
                print(customer)
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
                                "phone_prefix":           customer[11].split('-')[0],
                                "phone_number":           customer[11].split('-')[1],
                                "sex":                    customer[12]
                                }
                break

        with open(filename, mode='w') as customer_file:
            my_writer = csv.writer(customer_file)
            my_writer.writerows(my_file_content)
        print(new_customer)
        return new_customer
