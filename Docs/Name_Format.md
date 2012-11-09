##File Name Foramt
the file that come out of FactSet named in the format of
	
	Name:Div_RD_GroupID_SutdyName.txt

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
	
## Parsed Results Format
	
each row of parsed results follows the format:
	
	GroupID_SutdyName_FactorName_Fractile_Items,value

for example:
	
	Div_RD_1_SummitNegEarning_NegEarning_Q1_ret,0.013

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
- **Fractile : Q1**  
	Here `Item` really means what kind of Fractile of this factor is presented in this record. In the example, we know that this row stores the data for factors 'Quartile 1' data.
- **Items : ret**  
	The Items stores what kind of calculation was performed on this factor.
	In this example, we know that the `return` was calcualted. Items can also be stat data like `min,median,max,average` etc. 
- **Value : 0.013"  
	This is the value of the ID

Items are sepeareted by \_ , when define studies, it should not contain any other \_ sign in the name, otherwise it will mislead the parser.  