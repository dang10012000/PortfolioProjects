class Library:

    def __init__(self, available_books):
        self.available_books = available_books
        self.rental_history = dict()

    def inventory(self):
        print(f"Number of available book(s): {self.available_books}\n\n")

    def rental_book(self):

        customer_name = input('To start your rental, please enter your name: ')
        if customer_name in self.rental_history:
            print(f"Sorry {customer_name},"
                  f" we cannot process your request because you are currently having a rental in process\n\n")
            return

        print(f"Welcome {customer_name}!")

        rental_period = input('Please enter your rental period, it has to be hour, day, or week: ')

        while rental_period not in ['hour', 'day', 'week']:
            rental_period = input('Invalid input. Please enter your rental period (hour, day, or week): ')

        while True:
            try:
                num_rented_books = int(input('Please enter number of book(s) you want to rent today: '))
                break
            except:
                print('Sorry, please enter a number')

        if num_rented_books == 0:
            print('Invalid input. Number of book(s) cannot be 0\n\n')
            return
        if num_rented_books > self.available_books:
            print(f"Sorry {customer_name}, we don't have enough book(s) available at this time!\n\n")
            return

        # set case for renting by hour
        if rental_period == 'hour':
            while True:
                try:
                    hour = int(input('Please enter how many hour(s) you want to rent: '))
                    break
                except:
                    print('Sorry, please enter a number')
            rental_price = num_rented_books * hour * 1
            time_rented = f"{hour} hour(s)"

        # set case for renting by day
        elif rental_period == 'day':
            while True:
                try:
                    day = int(input('Please enter how many day(s) you want to rent: '))
                    break
                except:
                    print('Sorry, please enter a number')
            rental_price = num_rented_books * day * 2
            time_rented = f"{day} day(s)"

        # set case for renting by week
        elif rental_period == 'week':
            while True:
                try:
                    week = int(input('Please enter how many week(s) you want to rent: '))
                    break
                except:
                    print('Sorry, please enter a number')
            rental_price = num_rented_books * week * 5
            time_rented = f"{week} week(s)"

        # case when the customer type wrong rental period
        else:
            print(f"Sorry {customer_name}, please enter rental period again. It has to be hour, day, or week\n\n")
            return


        self.available_books -= num_rented_books

        self.rental_history[customer_name] = {'num_rented_books': num_rented_books, 'time_rented': time_rented,
                                              'rental_period': rental_period,
                                              'rental_price': rental_price}

        print(f"{customer_name} is renting {num_rented_books} book(s) for {time_rented}")
        print(f"Your total price is ${rental_price}\n\n")

    def rental_return(self):

        customer_name = input("\nWelcome back!\nTo return your rental, please type your name: ")

        if customer_name not in self.rental_history:
            print('Sorry, you currently do not have any rental.')
            return

        rental_record = self.rental_history[customer_name]
        num_rented_books = rental_record['num_rented_books']
        time_rented = rental_record['time_rented']
        rental_period = rental_record['rental_period']

        # update inventory
        self.available_books += num_rented_books

        total_price = rental_record['rental_price']

        # delete the record out of history
        del self.rental_history[customer_name]

        print(f"Hi {customer_name}! Thank you for coming back.")
        print(f"You have successfully returned {num_rented_books} book(s)")
        print(f"Your total time rented {time_rented}.Your total price due is ${total_price}.\n\n")

        print('========================================')
        print('               RECEIPT                  ')
        print('========================================')
        print(f"Customer name: {customer_name}")
        print(f"Number of kayaks rented: {num_rented_books}")
        print(f"Rental period: {rental_period}")
        print(f"Time rented: {time_rented}")
        print(f"Rental price per {rental_period}: ${total_price / num_rented_books}")
        print(f"Total rental price: ${total_price}")
        print("========================================\n\n\n")

    # emergency stop function
    def emergency_stop(self):
        print(f"EMERGENCY STOP: All rentals are stopped until further notice.\nWe are sorry for the inconvenience.\n\n")
        self.available_books = 0
        self.rental_history.clear()

# unit test
if __name__ == "__main__":

    # create a new KayakRentalShop instance with 10 kayaks
    HappyReading = Library(200)

    # rent kayaks
    HappyReading.rental_book()  # this to check code work on renting by hour
    HappyReading.rental_book()  # rent by day
    HappyReading.rental_book()  # rent by week
    HappyReading.rental_book()  # check when renting kayaks are more than available kayaks

    # check inventory
    HappyReading.inventory()

    # ask the customer to return their kayaks and print the invoice
    HappyReading.rental_return() # test when a customer is not on the rental_history
    HappyReading.rental_return() # start a return to get invoice

    # check inventory again after return
    HappyReading.inventory()

    # emergency stop
    HappyReading.emergency_stop()

    # check inventory again after emergency stop
    HappyReading.inventory()