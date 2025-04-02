import subprocess
from clingo import Control
import matplotlib.pyplot as plt
import random

def main():
    # Initialize the control object
    ctl = Control()

    # Load the .lp files
    ctl.load('C:\\clingo\\argbel\\argbel_chatbot.lp')
  
    # Ground the base program
    ctl.ground([("base", [])])
    
    models = []
    with ctl.solve(yield_=True) as handle:
        for model in handle:
            models.append(model.symbols(shown=True))

    # Queries
    
    # All fluents by time point
    #query_fluents(models)

    # Active fluents by time point
    #query_active_fluents(models)

    # Inactive fluents by time toint
    #query_inactive_fluents(models)

    #  Print the original clingo output
    query_full_output(models)

  
def query_full_output(models):
    """
    Query 4: Get the full Clingo output for each model without filtering
    """
    
    print("\nFull Output")
    
    for i, model in enumerate(models, start=1):
        print(f"Model {i}:")
        for atom in model:
            print(atom)
        print("\n" + "-"*40 + "\n")  # Separator between models for readability

def query_fluents(models, time_step=None):
    """
    Query 1: Get all fluents (holds and occurs) by state, capturing any number of arguments.
    """
    
    print("\nQuery 1 - All Fluents")
    
    for model in models:
        # Organize all fluents (holds and occurs) in the model by time step
        fluents_by_time = {}
        for atom in model:
            # Match atoms with predicate names "holds" or "occurs" without specifying the number of arguments
            if atom.name == "holds" or atom.name == "occurs":
                # Extract the time step from the last argument of the atom, assuming it is always the time step
                t = atom.arguments[-1].number  # Use the last argument as the time step
                if t not in fluents_by_time:
                    fluents_by_time[t] = []
                fluents_by_time[t].append(atom)
        
        # Iterate through time steps in order and sort fluents alphabetically within each time step
        for t in sorted(fluents_by_time):
            if time_step is None or time_step == t:
                sorted_fluents = sorted(fluents_by_time[t], key=lambda x: str(x))
                if sorted_fluents:
                    for fluent in sorted_fluents:
                        print(f"{fluent}")
                    print()  # For better readability

def query_active_fluents(models, time_step=None):
    """
    Query 2: Get all active fluents (holds and occurs) by state, capturing any number of arguments.
    """
    
    print("\nQuery 2 - Active Fluents")
    
    for model in models:
        # Organize all active fluents and occurs in the model by time step
        fluents_by_time = {}
        for atom in model:
            # Match atoms with "holds" for active fluents or "occurs" without specifying argument count
            if (atom.name == "holds" and len(atom.arguments) > 1 and atom.arguments[1].arguments[1].name == "active") or atom.name == "occurs":
                # Extract the time step from the last argument of the atom
                t = atom.arguments[-1].number
                if t not in fluents_by_time:
                    fluents_by_time[t] = []
                fluents_by_time[t].append(atom)
        
        # Iterate through time steps in order and sort fluents alphabetically within each time step
        for t in sorted(fluents_by_time):
            if time_step is None or time_step == t:
                sorted_fluents = sorted(fluents_by_time[t], key=lambda x: str(x))
                if sorted_fluents:
                    for fluent in sorted_fluents:
                        print(f"{fluent}")
                    print()  # For better readability

def query_inactive_fluents(models, time_step=None):
    """
    Query 3: Get all inactive fluents (holds and occurs) by state, capturing any number of arguments.
    """
    
    print("\nQuery 3 - Inactive Fluents")
    
    for model in models:
        # Organize all inactive fluents and occurs in the model by time step
        fluents_by_time = {}
        for atom in model:
            # Match atoms with "holds" for inactive fluents or "occurs" without specifying argument count
            if (atom.name == "holds" and len(atom.arguments) > 1 and atom.arguments[1].arguments[1].name == "inactive") or atom.name == "occurs":
                # Extract the time step from the last argument of the atom
                t = atom.arguments[-1].number
                if t not in fluents_by_time:
                    fluents_by_time[t] = []
                fluents_by_time[t].append(atom)
        
        # Iterate through time steps in order and sort fluents alphabetically within each time step
        for t in sorted(fluents_by_time):
            if time_step is None or time_step == t:
                sorted_fluents = sorted(fluents_by_time[t], key=lambda x: str(x))
                if sorted_fluents:
                    for fluent in sorted_fluents:
                        print(f"{fluent}")
                    print()  # For better readability



def process_and_analyze(models):
    # Create dictionaries to hold the active and inactive fluents by time
    active_fluents_by_time = {}
    inactive_fluents_by_time = {}
    
    # Redirect output of query_active_fluents to active_fluents_by_time
    for model in models:
        for atom in model:
            if (atom.name == "holds" and len(atom.arguments) > 1 and atom.arguments[1].arguments[1].name == "active") or atom.name == "occurs":
                t = atom.arguments[-1].number
                if t not in active_fluents_by_time:
                    active_fluents_by_time[t] = []
                active_fluents_by_time[t].append(atom)

    # Redirect output of query_inactive_fluents to inactive_fluents_by_time
    for model in models:
        for atom in model:
            if (atom.name == "holds" and len(atom.arguments) > 1 and atom.arguments[1].arguments[1].name == "inactive") or atom.name == "occurs":
                t = atom.arguments[-1].number
                if t not in inactive_fluents_by_time:
                    inactive_fluents_by_time[t] = []
                inactive_fluents_by_time[t].append(atom)

    # Prepare data for plotting
    active_counts = [len(active_fluents_by_time.get(t, [])) for t in sorted(active_fluents_by_time)]
    inactive_counts = [len(inactive_fluents_by_time.get(t, [])) for t in sorted(inactive_fluents_by_time)]
    time_steps = sorted(set(active_fluents_by_time.keys()).union(inactive_fluents_by_time.keys()))

    # Plotting
    plt.plot(time_steps, active_counts, label="Active Fluents")
    plt.plot(time_steps, inactive_counts, label="Inactive Fluents")
    plt.xlabel("Time Step")
    plt.ylabel("Count")
    plt.title("Active and Inactive Fluents Over Time")
    plt.legend()
    plt.show()




if __name__ == "__main__":
    main()
