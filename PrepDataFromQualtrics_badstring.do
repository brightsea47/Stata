
version 17
//Meryl Motika, updated Dec 5 2023

/*
//MACROS - DEFINE in your file
//dataset name, and location if not current working directory
global dataname = "[ADDRESS]/[FILENAME].csv"
//Name for saving it, with location if not current working directory
global savename = "[NAME]"
do "/Users/mimotika/Library/CloudStorage/GoogleDrive-mimotika@berkeley.edu/My Drive/Resources/Utility/PrepDataFromQualtrics.do"
*/

display "$dataname"

local dataname = "$dataname"
local savename = "$savename"

display "`dataname'"

//import the data as string variables
clear all
import delimited using "`dataname'", /// 
	rowrange(2:) bindquotes(strict) stringcols(_all) varnames(1) case(preserve)

//drop unnecessary variables
capture drop  StartDate 
capture drop  EndDate 
capture drop  IPAddress  //drop unnecessary potential identifiers
drop if _n==2 //drop the ImportID row 

//export variable names for the codebook (created using a different do-file)
preserve
	keep if _n==1
	export delimited * using "codebook.csv", replace
restore

//loop through each variable, saving the long name as the label and creating a short name that Stata accepts
foreach var of varlist * {
	local labname=`var'[1]
	display "first record of `var' is "`"`labname'"'" "
	if strlen(`"`labname'"')>80 & strpos(`"`labname'"'," - ")>1 {		//for long labels, take the part to the right of the hyphen
		local start=strpos(`"`labname'"'," - ")+2 // start after the hyphen
		display "start is `start'"
		local labname=trim(substr(`"`labname'"',`start',strlen(`"`labname'"')))
		display "label is "`"`labname'"'" "
	}
	if substr(`"`labname'"',1,17)=="Selected Choice -" {
		local labname=trim(substr(`"`labname'"',18,strlen(`"`labname'"'))) 
	}
	capture lab var `var' `"`labname'"'
}


drop if _n==1	//drop the row of labels

//destring the variable if it's numeric, otherwise leave as string
foreach var of varlist * {
	capture destring `var', replace
}

save `savename', replace
