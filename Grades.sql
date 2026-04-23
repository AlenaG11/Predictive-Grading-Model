use cb_cdr
select t2.*, grade_brand, grade_catalog, grade_catavg, grade_ship,grade_affiliate,
grade_email,grade_organicsearch, grade_paidbrand, grade_paidnonbrand, grade_shopping, grade_text, grade_social
from cb_cdr..Score_Output_Dec23 t1
left join Model_Data_Prep_20240221 t2
on t2.customerID = t1.household_id
