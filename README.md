# CPLEX - Customer Support System Staff Scheduling 

## Background

The purpose of the mathematical model is to find the optimal workforce assignment for a Customer Support System of a Large Financial Enterprise. 
The objective function minimizes total costs (fixed and variable) while meeting the demand (call and chat requests), Monday through Sunday. 

The detailed description of the model can be found in `Mathematical Model for Customer Support System Staff Scheduling` file.

## Requirements

The model runs on `IBM ILOG CPLEX Optimization Studio V12.9.0`. 
Download instructions are found [here](https://www.ibm.com/support/pages/downloading-ibm-ilog-cplex-optimization-studio-v1290).
 
## Files description

* `CPLEX files`
    - `capstone_test.dat` - input data 
    - `capstone_test.mod` - mathematical model (decision variables, objective function, and constraints)
    - `capstone_test.ops` - run paramaters and model configuration 
    - `demand_capstone_test.xlsx` - demand data in excel file
     
* `Mathematical Model for Customer Support System Staff Scheduling` - detailed description of the model

* `mod-raw-code.txt` - cplex code for the model 

* `README.md` - git repo description
