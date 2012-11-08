##File Name Foramt
the file that come out of FactSet named in the format of
	
	Name:Div_RD_GroupID_SutdyName.txt

for example:
	
	Div_RD_1_SummitNegEarning.txt
in the example above:
- **Div_RD** is hte

- **GroupID : 1**  
	This groupid helps categorize a series of studies which belongs 	to the same project. also this grouid will also be used 	search for the correct parser for this file. Currently,
	`all the files have the same groupid shares the same parser`
	
- **SutdyName : SummitNegEarning**  
	In this case the studyname is `SummitNegEarning`. this study is
	a part of summit report project that runs monthly and this	specific study is for NegEarning factor.

- **FactorName : NegEarnings**  
	As introduced above, the FactorName is NegEarnings in this
	case and this is the only factor in this study. However, the 	number of factors in each study can definitely be more than 1.
	
## Parsed Results Format
	
each row of parsed results follows the format:
	
	GroupID_SutdyName_FactorName_Items,value

for example:
	
	Div_RD_1_SummitNegEarning_NegEarning_NA,0.013
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
- **Items : NA**  
	Here `Item` really means what kind of characteristic or	information of this factor is presented in this record