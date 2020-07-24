from datetime import datetime
from dateutil.relativedelta import relativedelta


class AddMonthsToDate():

    def add_months_to_date(self, date_given, add_this_many_months):
        # takes date as string in format dd.mm.yyyy, adds months to it
        my_date = datetime.strptime(date_given, '%d.%m.%Y')
        my_date = my_date + relativedelta(months=+int(add_this_many_months))
        my_date = datetime.strftime(my_date, '%d.%m.%Y')
        return my_date
