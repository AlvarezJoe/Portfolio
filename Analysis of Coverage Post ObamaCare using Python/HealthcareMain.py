import matplotlib.pyplot as plt
import pandas as pd


def intro():
    print("This is a quick overview of a dataset from kaggle that examines the change in healthcare in America, \n"
          "across all 50 states, as a result of the Affordable Care Act and the Health Care and Education \n"
          "Reconciliation Act that went into affect in late 2013.\n"
          "\nDataset: https://www.kaggle.com/datasets/hhs/health-insurance\n\nThe following is a menu where selection "
          "is done by inputting a number that corresponds with the\ninformation you'd like displayed and then "
          "pressing enter.")


def read_and_simplify():
    # This more efficient than keeping it constantly open
    file = pd.read_csv(open("healthinsurance.csv"))

    # Replace harder to work with characters
    file.columns = [c.replace(' ', '_') for c in file.columns]
    file.columns = [c.replace('-', '_') for c in file.columns]
    file.columns = [c.replace('(', '') for c in file.columns]
    file.columns = [c.replace(')', '') for c in file.columns]

    return file


def menu():
    # Menu Listing
    while True:
        print("\n1) Data set preview\n2) Summary statistics on the data set\n3) Change in health insurance coverage "
              "(2010 - 2015)\n4) Percent change in uninsured (2010 - 2015)\n5) Change in medicaid enrollment per state"
              " (2013 - 2016)\n6) Percent of states with medicaid expansion (2016)\n7) Total change when medicaid "
              "expanded (2016)\n9) Quit the program\n")
        # Selection
        try:
            selection = int(input("What information would you like to see? "))
            return selection
        except:
            print("\nPlease enter a number for your selection.")


def summary_statistics(f):
    # Column data
    print(f.describe())


def data_preview(f):
    # Display 15 rows
    print(f.to_string(max_rows=15))


def medicaid_enrollement_change_per_state(f):
    # Sort data
    f = f.sort_values(by=['Medicaid_Enrollment_Change_2013_2016'], ascending=False)

    # Generate and display horizontal bar graph
    plt.figure(figsize=(17, 11))
    plt.style.use("fivethirtyeight")
    plt.barh(f.State[1:], f.Medicaid_Enrollment_Change_2013_2016[1:], color="#008fd5")
    plt.xlabel("Change in Individuals Insured (in millions)")
    plt.title("Change in Medicaid Enrollment per State (2013 - 2016)")
    plt.show()


def coverage_change(f):
    # Sort data
    f = f.sort_values(by=['Health_Insurance_Coverage_Change_2010_2015'], ascending=False)

    # Generate and display horizontal bar graph
    plt.figure(figsize=(17, 11))
    plt.style.use("fivethirtyeight")
    plt.barh(f.State[1:], f.Health_Insurance_Coverage_Change_2010_2015[1:], color="#008fd5")
    plt.xlabel("Change in Individuals Insured (in millions)")
    plt.title("Change in Health Insurance Coverage (2010 - 2015)")
    plt.show()


def percent_medicaid_expand(f):
    # Count
    number_true = 0
    number_false = 0

    # Convert booleans to values
    for line in f.State_Medicaid_Expansion_2016:
        if line:
            number_true += 1
        elif not line:
            number_false += 1

    # Value and label creation
    slices = [number_true, number_false]
    labels = ["Expanded", "Didn't Expand"]

    # Generate and display pie chart
    plt.figure(figsize=(10, 7))
    plt.style.use("fivethirtyeight")
    plt.pie(slices, labels=labels, wedgeprops={'edgecolor': 'black'}, autopct='%1.1f%%', shadow=True, startangle=90)
    plt.title("Percent of States That Expanded Medicade")
    plt.show()


def uninsured_decrease(f):
    # Sort data
    f = f.sort_values(by=['Uninsured_Rate_Change_2010_2015'], ascending=True)

    # Generate and display horizontal bar graph
    plt.figure(figsize=(17, 11))
    plt.style.use("fivethirtyeight")
    plt.barh(f.State[:-1], f.Uninsured_Rate_Change_2010_2015[:-1], color="#008fd5")
    plt.xlabel("Change in uninsured (Negative)")
    plt.title("Change in Health Insurance Coverage (2010 - 2015)")
    plt.show()


def expansion_when_true(f):
    # Create lists
    lst = ["True", "False"]
    sum_lst = [0, 0]

    # Sum in list
    for i in range(len(f.State_Medicaid_Expansion_2016) - 1):
        if f.State_Medicaid_Expansion_2016[i]:
            try:
                sum_lst[0] += int(f.Medicaid_Enrollment_Change_2013_2016[i])
            except:
                pass
        elif not f.State_Medicaid_Expansion_2016[i]:
            try:
                sum_lst[1] += int(f.Medicaid_Enrollment_Change_2013_2016[i])
            except:
                pass

    # Generate and display bar graph
    plt.figure(figsize=(11, 17))
    plt.style.use("fivethirtyeight")
    plt.bar(lst, sum_lst, color="#008fd5")
    plt.title("Total Change When Medicaid Expanded")
    plt.ylabel("in ten million")
    plt.show()


# Intro and csv to dataframe
intro()
file = read_and_simplify()

# Program
while True:
    user_input = menu()

    # Selection w/ verification
    match user_input: #python 3.10 or newer
        case 1:
            data_preview(file)
        case 2:
            summary_statistics(file)
        case 3:
            coverage_change(file)
        case 4:
            uninsured_decrease(file)
        case 5:
            percent_medicaid_expand(file)
        case 6:
            medicaid_enrollement_change_per_state(file)
        case 7:
            expansion_when_true(file)
        case 9:
            # End program
            break
        case _:
            # Loop to top
            print("\nPlease select a valid input.")
            continue

    # Show more w/ verification
    while True:
        again = input("\nWould you like to look at another graph? (Y/N)").lower()

        if again == "y" or again == "n":
            break
        else:
            print("\nPlease use either Y or N.")

    if again.lower() == "n":
        # End program
        break
