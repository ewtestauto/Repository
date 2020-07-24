import csv
from datetime import datetime


class CsvSaveAndRetrievePlastic1(object):

    file_name = '/PyCharm/SAANA/Reissue/plastic.txt'

        # file_name = 'C:/RobotFramework/PyCharm/NEXI/01a.plastic_setup/plastic_output.txt'
        # this is only used for testing, pure Python needs the whole path

    def write_plastic_to_file(self, test_case, plastic, date, environment, accountID, alternativeID):
        # this method writes a new plastic to a text file, plastic will be retrieved and verified after NB
        # TODO: format the real date to remove fractions of seconds
        # TODO make a new file with date every time unless one exists
        with open(self.file_name, mode='a+') as output_file:
            output_writer = csv.writer(output_file, delimiter=',')
            output_writer.writerow([datetime.now().isoformat(timespec='seconds').replace('T', ' '),
                                    test_case, plastic, date, environment, accountID, alternativeID])

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
                new_plastics.append({'plastic number': row[2]})

        return new_plastics

    def retrieve_plastic_for_manual_reissue2(self, test_case_name, environment_name):
        # this method takes the file from path defined in this class,
        # turns the file content into a list, reverses list order
        # then it looks for the first row with the given test case name and environment name
        # then it returns the plastic number found in the row
        # TODO maybe add some kind of verification for date?
        plastic_from_file = ''
        my_file_content = []
        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        for row in reversed(my_file_content):
            # reversed, so we check the latest plastics first
            # looking for the first row with the right test case, right environment
            if row[1] == test_case_name and row[4] == environment_name:
                plastic_from_file = row[2]
                break

        return plastic_from_file

    def retrieve_plastic_data_for_manual_reissue(self, test_case_name, environment_name):
        # this method takes the file from path defined in this class,
        # turns the file content into a list, reverses list order
        # then it looks for the first row with the given test case name and environment name
        # then it returns the plastic number found in the row
        # TODO maybe add some kind of verification for date?
        my_file_content = []
        my_plastic_data = []
        with open(self.file_name, mode='r') as customer_file:
            for row in csv.reader(customer_file):
                if row:
                    # csv reader makes blank lines when reading the file, so this has to be here to get rid of them
                    my_file_content.append(row)

        for row in reversed(my_file_content):
            # reversed, so we check the latest plastics first
            # looking for the first row with the right test case, right environment
            if row[1] == test_case_name and row[4] == environment_name:
                my_plastic_data = row
                break

        return my_plastic_data



