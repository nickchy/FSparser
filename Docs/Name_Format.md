#FactSet->Research_DB Parser 

This file is the manual for Div_RD FactSet parser program. The work is organized as follows:

1.	**parsers and their work environment setup**
2.	

###File Name Format[^1]
[^1]: Items are separated by \_ , when define studies, it should 		not contain any other \_ sign 		in the name, otherwise it will mislead the parser.

the file that comes out of FactSet named in a format of:

	Div_RD_GroupID_SutdyName.txt

for example:
	
	Div_RD_1_SummitNegEarning.txt

in the example above:

- **Div_RD**  
	This is the universal title for Diversified team Research Database FactSet Download files. Any file start with `Div_RD` should be parsed and load into database

- **GroupID : 1**  
	This groupid helps categorize a series of studies which belongs 	to the same project. also this grouid will also be used 	search for the correct parser for this file. Currently,
	`all the files have the same groupid shares the same parser`
	
- **SutdyName : SummitNegEarning**  
	In this case the studyname is `SummitNegEarning`. this study is
	a part of summit report project that runs monthly and this	specific study is for NegEarning factor.

- **FactorName : NegEarnings**  
	As introduced above, the FactorName is NegEarnings in this
	case and this is the only factor in this study. However, the 	number of factors in each study can definitely be more than 1.
	
### Parsed Results Format
	
each row of parsed results follows the format:
	
	GroupID_SutdyName_FactorName_Fractile_DataItems,value

for example:
	
	Div_RD_1_SummitNegEarning_NegEarning_1_ret,0.013

in the example above:

 ***GroupID_SutdyName_FactorName_Items*** is the id of this specific record. It maps to a unique `DSID` in research database, where the `Value` part should be stored into. 

- **GroupID : 1**  
	This groupid helps categorize a series of studies which belongs 	to the same project. also this grouid will also be used 	search for the correct parser for this file. Currently,
	`all the files have the same groupid shares the same parser`
	
- **SutdyName : SummitNegEarning**  
	In this case the studyname is `SummitNegEarning`. this study is
	a part of summit report project that runs monthly and this	specific study is for NegEarning factor.

- **FactorName : NegEarnings**  
	As introduced above, the FactorName is NegEarnings in this
	case and this is the only factor in this study. However, the 	number of factors in each study can definitely be more than 1.	
- **Fractile : 1**  
	Fractile tells which fractile(1,2,3,4,5,etc) of this factor is presented in this record. 	In the example, we know that this row stores the data for factors 'Quartile 1' data.[^2]
[^2]:	User will not directly know whether it's quartile data or decile data from the 		numeric numbers (1 for example), This is only used for mapping to DSID, to check 		the fractile property, please go directly to research database UI and view the 		tags there.
	   
- **DataItems : ret**  
	The DataItems stores what kind of calculation was performed on this factor.
	In this example, we know that the `return` was calcualted. Items can also be stat data like `min,median,max,average etc`. 
	
- **Value : 0.013**  
	This is the calculated value of the DataItem introduced above.
 