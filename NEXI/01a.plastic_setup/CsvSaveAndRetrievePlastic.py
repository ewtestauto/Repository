import csv
from datetime import datetime


class CsvSaveAndRetrievePlastic(object):

    file_name = 'NEXI/01a.plastic_setup/plastic_output.txt'

    # file_name = 'C:/RobotFramework/PyCharm/NEXI/01a.plastic_setup/plastic_output.txt'
    # this is only used for testing, pure Python needs the whole path

    def write_plastic_to_file(self, test_case, plastic, date, embossing_file, environment):
        # this method writes a new plastic to a text file, plastic will be retrieved and verified after NB
        # TODO: format the real date to remove fractions of seconds
        # TODO make a new file with date every time unless one exists
        with open(self.file_name, mode='a+') as output_file:
            output_writer = csv.writer(output_file, delimiter=',')
            output_writer.writerow([datetime.now().isoformat(timespec='seconds').replace('T', ' '),
                                   test_case, plastic, date, embossing_file, environment])

    def retrieve_plastic_from_file(self, test_case, environment_date):
        # this is no longer used
        new_plastic_data = {}
        my_file_content = []
        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        for row in reversed(my_file_content):
            # reversed, so we check the latest plastics first
            # looking for the first row with the right test case, environment date lower than given
            if row[1] == test_case \
                 and datetime.strptime(row[3], '%d.%m.%Y') < datetime.strptime(environment_date, '%d.%m.%Y'):
                new_plastic_data = {'plastic number': row[2], 'embossing file': row[4]}
                break

        return new_plastic_data

    def retrieve_multiple_plastics_from_file(self, test_case, environment_date):
        # this one is no longer used, additional functionality for environment in version 2
        # this method looks for created plastics in the file with the correct test case name
        # it looks for the first date that is lower than environment date
        # then it returns a list of plastics with the same date
        # in dictionaries with plastic number:  and  embossing file:
        new_plastics = []
        my_file_content = []
        my_date = ''
        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        for row in reversed(my_file_content):
            # reversed, so we check the latest plastics first
            # looking for the first row with the right test case, environment date lower than given
            if row[1] == test_case \
                        and datetime.strptime(row[3], '%d.%m.%Y') < datetime.strptime(environment_date, '%d.%m.%Y'):
                my_date = datetime.strptime(row[3], '%d.%m.%Y')
                break

        for row in reversed(my_file_content):
            if row[1] == test_case and datetime.strptime(row[3], '%d.%m.%Y') < my_date:
                break
            if row[1] == test_case and datetime.strptime(row[3], '%d.%m.%Y') == my_date:
                new_plastics.append({'plastic number': row[2], 'embossing file': row[4]})

        return new_plastics

    def retrieve_multiple_plastics_from_file2(self, test_case, environment_date, environment_name):
        # this method looks for created plastics in the file with the correct test case name
        # it looks for the first date that is earlier than environment date
        # then it returns a list of plastics with the same date
        # in dictionaries with plastic number:  and  embossing file:
        new_plastics = []
        my_file_content = []
        my_date = ''
        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        # disregard all lines that do not have the environment in it
        rows_from_my_environment = []
        for row in my_file_content:
            if environment_name in row:
                rows_from_my_environment.append(row)

        for row in reversed(rows_from_my_environment):
            # reversed, so we check the latest plastics first
            # looking for the first row with the right test case, environment date lower than given
            if row[1] == test_case \
                        and datetime.strptime(row[3], '%d.%m.%Y') < datetime.strptime(environment_date, '%d.%m.%Y'):
                my_date = datetime.strptime(row[3], '%d.%m.%Y')
                break

        for row in reversed(rows_from_my_environment):
            if row[1] == test_case and datetime.strptime(row[3], '%d.%m.%Y') < my_date:
                break
            if row[1] == test_case and datetime.strptime(row[3], '%d.%m.%Y') == my_date:
                new_plastics.append({'plastic number': row[2], 'embossing file': row[4]})

        return new_plastics

    def retrieve_primary_plastic_from_file(self, test_case, environment_name):
        # this method is used for setting up additional plastics when entering piedino
        # to link them to the primary plastic
        # it looks for the latest plastic with the given test case
        primary_plastic = ''
        my_file_content = []

        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        for row in reversed(my_file_content):
            if test_case in row and environment_name in row:
                return row[2]

        raise Exception('No plastic was found for test case ' + test_case + ' and environment ' + environment_name)
