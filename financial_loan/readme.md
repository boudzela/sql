# financial_loan
## Source:  
https://drive.google.com/drive/folders/1wjjTBUg2SHXJQwVNjI5vHLk6DjI2W7y7

## Files:  
[financial_loan.csv](https://github.com/boudzela/sql/blob/ea22ea97aa76d97af782f0702f68c24defe3851f/financial_loan/financial_loan.csv) - row data
- sql script containing the complete code for all data queries with comments
- database resulting from the data cleaning and transformation process

## Objective:  
This project focuses on data analysis with my sql. The metrics obtained:
![image](https://github.com/user-attachments/assets/51b8257f-feca-4f84-a7fd-83d30132a8f3)  
![image](https://github.com/user-attachments/assets/319f3b73-8a4e-406f-bbb4-26217627f0ea)



## Skills gained: 
recursive CTE   
views   
temporary table  
CASE  

## Projects I followed:  
https://www.youtube.com/watch?v=3I8wd1AShXs&list=PLO9LeSU_vHCVbT81nMD2S_YMRJ1OpnXZi&index=13 

## Some steps of the project and snippets: 

### 1. Data preparation andd examination (null values, dublicates, inappropriate values) 
### 2. Metrics from Slide 1 (Dashboard 1: summary)  

I calculated total number of applications, 
             number of applications from the beginning of the year, 
             monhtly change, 
             rate of change compared to the previous month: 
  
![image](https://github.com/user-attachments/assets/a3e50207-795b-414f-b103-a3748393dec0)  
  
Further, based on the query, I created a view to facilitate the access to the information in the future:  
![image](https://github.com/user-attachments/assets/1aa9e4ef-181e-4bdd-8c94-c0509253790a)  

in a similar way the queries returning data and creating view for ttotal funded amount, average intrest rate and debt-to-income ration have been created 

As for factual total amount received, it is a dynamic variable and it is possible to calculate it only for the end of the specified period.
Though, we can monitor the amount of money returned to the bank by their issue month ( this metodology is applied in the video by the author)  

![image](https://github.com/user-attachments/assets/56be1130-a31d-47c1-8f70-dcbb2aed9603)  

Additionally, it is wise to look into an estimated amount of monthly money which the bank planned to receive from the debtors (installment)  
![image](https://github.com/user-attachments/assets/1b57c0f7-ed02-40fc-8602-5bdcc4f730b6)

In order to look into monhtly change and rate of growth I wraped it up in a tem table to simplify the reading of the query:   
![image](https://github.com/user-attachments/assets/70804bfe-b72b-45e0-ac64-8e1097598fcc)  
  
Unfortunately, a temporary table cant be the source of views, and to create one, I needed to orewrite the queries above into. 
  
As a result, the database consists of a number of views:  
![image](https://github.com/user-attachments/assets/fcbd3214-e31f-4d6d-af56-b2052810ee92)












### 3. Metrics from Slide 2 (Dashboard 1: summary) 


![image](https://github.com/user-attachments/assets/12520659-6973-4d46-a779-3c4c9e0a0e10)

