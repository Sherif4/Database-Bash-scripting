Bash Database Management System (DBMS) Script Documentation
Overview

This Bash script provides a simple database management system (DBMS) through a command-line interface. It allows users to interact with a database by performing various operations such as viewing, inserting, updating, and deleting records.
Usage

To use this script:

    Ensure Bash is installed on your system.
    Run the script by executing ./script_name.sh in your terminal, replacing script_name.sh with the actual name of the script file.

Features

    Show Table Data
        Displays existing data in a table.
    Insert Record
        Adds new records to the table.
    Update Record
        Updates existing records in the table.
    Delete Record
        Deletes records from the table.
    Drop Table
        Deletes an entire table.
    Back to Main Menu
        Returns to the main menu for further actions.

Script Structure

The script is organized into several components:

    tableHandling Function
        Manages the main menu and user selections.
        Utilizes a select loop to present options and execute corresponding actions.

    Options Handling
        Uses a case statement to determine actions based on user input.

    Input Validation
        Validates user input to ensure it meets specific criteria (e.g., data type constraints, primary key uniqueness).

    Database Operations
        Interacts with database files (.metadata_TABLENAME and TABLENAME ) for operations like reading metadata, inserting, updating, and deleting records.
        Uses awk and sed commands for file parsing and manipulation.

    Error Handling
        Provides error messages and prompts users to re-enter input if invalid data is provided or if an operation fails.

Developer Information

    Displays information about the developers responsible for creating the DBMS.
    Includes names, roles, and contact information for the developers.

Exiting the Script

    Users can exit the script, which displays a farewell message before terminating the program.

Conclusion

This Bash script offers basic functionalities for managing a simple database via a command-line interface.

Made by: Sherif Ashraf and Hassan Hosny
