ConvertFrom-StringData @'
    EmptyArray             = Expected to find an array value for property {0} in the current values, but it was either not present or was null. This has caused the test method to return false.
    ArrayNotInDesiredState = Found an array for property {0} in the current values, but this array does not match the desired state. Details of the changes are below.
    ArrayItemIncorrect     = Item {0} - {1}
    ValueInDesiredState    = {0} value for property {1} does not match. Current state is '{2}' and desired state is '{3}'
    UnableToCompare        = Unable to compare property {0} as the type ({1}) is not handled by the Test-SCDscParameterState cmdlet
'@
