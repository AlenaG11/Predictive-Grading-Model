# Customer Channel Scoring and Predictive Grading Model

## Goal

Using an SAS system, a client developed a channel score (A-F) for each channel giving them the ability to score each of their customers, and thus predictions/grades for each channel. For example, this enables the ability to look at shipping vs. catalog grades or shipping vs. email grades. The goal is to migrate the SAS code to Python, and make it runnable at any time using the latest available data.

## Structure of the Scoring Equations

There are three pieces to a catalog scoring equation.
1.	Probability of a Customer Purchasing, Next Year (30%).
2.	Amount a Customer Will Spend if Customer Purchases, Next Year ($100.00).
3.	Percentage of Next Year’s Spend That is Organic (Non-Catalog) (60%).

The catalog score is derived as follows:
-	(Probability of Purchase) * (Predicted Spend) * (1 – Predicted Organic Percentage).

In the example above, the catalog score is 0.30 * 100 * (1 – 0.60) = $12.00.

Based on the Optimal Grade, this customer would be classified as a “D” catalog shopper.

A series of variables comprise the scoring models:
-	ROOT_REC = Square root of months since last purchase.
-	HST_FREQ = Number of life-to-date purchases.
-	HST_DEMD = Life-to-Date Demand spent.
-	HST_AOV = (HST_DEMD / HST_FREQ).
-	HST_AOV000 = HST_AOV / 1000.
-	Merchandise Indicators … 1 = Ever Bought, 0 = Never Bought. Derived from the High Level Category Variable sent.
    - MR00 = All Other Merchandise
    - MR01 = Adjustments
    - 	MR02 = Bibles
    - 	MR03 = Books
    - 	MR04 = Church Supplies
    - 	MR05 = Closeouts
    - 	MR06 = Damaged
    - 	MR07 = Downloads
    - 	MR08 = Exclusives
    - 	MR09 = Gifts
    - 	MR10 = HomeSchool
    - 	MR11 = Music
    - 	MR12 = Videos
-	Channel Indicators … 1 = Ever Bought, 0 = Never Bought. Derived from each Attributed Channel sent.
    - 	HST_AFFI (affiliates)
    - 	HST_CATG (catalog)
    - 	HST_CATI (catalog insert)
    - 	HST_EMAI (email)
    - 	HST_SRCO (organic search)
    - 	HST_OTHR (all other)
    - 	HST_PBRN (paid search brand)
    - 	HST_PNON (paid search non-branded)
    - 	HST_SHOP (shopping / PLA).
    - 	HST_TEXT (sms)
    - 	HST_SOCI (social)
-	HST_SHIP (sum all paid shipping, then divide by historical demand spent).
-	HST_ORGN (sum all demand spent except for catalog attribution and catalog insert attribution, divide by sum of all demand spent).
-	HST_CLCK = Sum of all email clicks, past year.
-	HST_VISI = Sum of all website visits, past year.
-	ROOT_ECL = Square Root of HST_CLCK.
-	ROOT_VIS = Square Root of HST_VISI.

## Scores for other Channel Explanation:
For shipping, customers are broken down into 20%(ish) groups, from most likely to pay for shipping (“A”) to most likely to need free shipping (“F”). To build this model, predict the percentage of demand that would be spent by the customer on shipping in the next year. For instance, if a customer is predicted to spend $100 next year and will also spend $12 on shipping, the customer is predicted to have a shipping value of 12/100 = 0.12. In this case, the customer would be graded as an “F” … a customer more likely than most to need free shipping. If a customer has a shipping prediction of 0.25, the customer is graded as an “A” … a customer more likely than most to pay the most for shipping.

Channel-Based variables are segmented as follows (all models assume the customer will purchase next year … e.g., determining “how” the customer will purchase … to add customer value, overlay the segments for the channel-based segment by GRADE_BRAND.
-	“A” = Top 5% for prediction to buy from this channel if customer purchases.
-	“B” = Top 6% - 15% for prediction to buy from this channel.
-	“C” = Top 16% - 30% for prediction to buy from this channel.
-	“D” = Top 31% - 50% for prediction to buy from this channel.
-	“F” = Bottom 50% for prediction to buy from this channel.

This results in predictions (predv for brand value, pred_ship, pred_affi, pred_emai, pred_srco, pred_prbn, pred_pnon, pred_shop, pred_text, pred_soci) for each channel (and for shipping expense) … the predictions are converted into grades (grade_brand, grade_catalog, grade_catavg, grade_catkev, grade_ship, grade_affiliate, grade_email, grade_organicsearch, grade_paidbrand, grade_paidnonbrand, grade_shopping, grade_text, grade_social).

“Pred Brand” represents the grading for overall brand responsiveness. What are the data points farthest away from “Pred Brand” (meaning that these channels are essentially opposite from high value customers)?
-	Shopping/PLA.
-	Paid Non-Brand.
-	Organic Search.
-	Paying for Shipping/Handling.
-	Social.

## Grade Key

Each customer has a score (called “predc”), that predicts how much the customer will spend via catalog marketing next year. The scores can be converted to grades, as illustrated here.

### Catalog
- compute                  	grade_catalog = 'F'.
- if (predc ge 09.0000)    	grade_catalog = 'D'.
- if (predc ge 16.0000)    	grade_catalog = 'C'.
- if (predc ge 25.0000)    	grade_catalog = 'B'.
- if (predc ge 31.0000)    	grade_catalog = 'A'.

### Catavg
- compute                  	grade_catavg  = 'F'.
- if (predc ge 00.9000)    	grade_catavg  = 'D'.
- if (predc ge 05.0000)    	grade_catavg  = 'C'.
- if (predc ge 20.0000)    	grade_catavg  = 'B'.
- if (predc ge 31.0000)    	grade_catavg  = 'A'.

### Catkey
- compute                   	grade_catkev  = 'F'.
- if (predc  ge 07.0000)    	grade_catkev  = 'D'.
- if (predc  ge 13.9000)    	grade_catkev  = 'C'.
- if (predc  ge 25.0000)    	grade_catkev  = 'B'.
- if (predc  ge 31.0000)    	grade_catkev  = 'A'.

## Environment
Project uses the UV Package Manager

## Jupyter Notebooks:
Grades.ipynb  - original manual grade calculation. Input file is local, Table_100K.csv

Model.ipynb - wraps models, builds them in a single function and ‘pickles’ them

Prediction_TEST – retrieves ‘pickled’ models, makes predictions on file with existing output, checks accuracy.  Connects with pyodbc to CB_CDR..Model_Data_Prep20240201 and, for testing accuracy, CB_CDR..Score_Output_Dec23 

Prediction.ipynb  - retrieves ‘pickled’ models and makes predictions for new data with input file CB_CDM..F_Customer_Model. Output is written out either to local drive, or to server 78 CDR.. Score_Output table.

Prediction.py – script used in executable automated version on server 78 (replica of Prediction.ipynb). 
__________________________________________________________________________________________
Test.ipynb – this is just an additional, testing file. Allows to create and remove tables  from SQL server ---  REMOVE after the project is done
Outputs for predictions produces on weekly (or monthly) bases: Grades_(date).csv
