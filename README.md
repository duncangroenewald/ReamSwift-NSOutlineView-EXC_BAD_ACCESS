# Realm EXC_BAD_ACCESS Demo

To reproduce the issue, build and run the application. It should launch the
application successfully. Attempt to expand one of the headers in the
`NSOutlineView` and the app should crash with an `EXC_BAD_ACCESS` error.

To "fix" the issue, uncomment the code for `badItemsArray` and
`goodItemsArray`. `MasterViewController.swift` lines: `30`, `31`, `34`, `35`,
`96`, and `100`. Rebuild and launch the application, it should work as expected
now.
