# string_primitives_macros_project

## What is this?
It's an x86 MASM program.
This is the final project I completed for my Computer Architecture and Assembly class.
Its purpose is to demonstrate our ability to design and implement low-level I/O procedures and macros.

## What does it do?
It prompts the user to enter signed integers until the program has read 10 signed integers.
It validates the user's input. Any input that won't fit in a 32-bit register or is non-numeric will be discarded.
It converts the input strings into integers, then it does some basic arithmetic operations with the numbers.
Finally, it returns the sum and truncated average of the 10 signed integers.

## Demonstration
    Please enter 10 signed decimal integers.
    Once that is done, this program will display some summary statistics
    Please enter a signed number:
    abcdef
    Error. Please enter a signed number that will fit in a 32 bit register
    Please enter a signed number:
    10
    Please enter a signed number:
    20
    Please enter a signed number:
    30
    Please enter a signed number:
    40
    Please enter a signed number:
    50
    Please enter a signed number:
    123456789000000
    Error. Please enter a signed number that will fit in a 32 bit register
    Please enter a signed number:
    -60
    Please enter a signed number:
    -70
    Please enter a signed number:
    -80
    Please enter a signed number:
    -90
    Please enter a signed number:
    -100
    You entered the following numbers:
    +10
    +20
    +30
    +40
    +50
    -60
    -70
    -80
    -90
    -100
    The sum of these numbers is:
    -250
    The truncated average is:
    -25

  