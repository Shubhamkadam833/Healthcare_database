use Healthcare_DB;
--How many cpt codes are there in each CPTgrouping?--
SELECT CptGrouping, COUNT(DISTINCT(CptCode)) AS Countofcptcodes
FROM dimCptCode
GROUP BY CptGrouping
ORDER BY 2 DESC;
--HOW MANY UNIQUE PATIENTS EXISTS IN THE HEALTHCARE DB? PatientNumber,
SELECT COUNT(DISTINCT(PatientNumber))
FROM  dimPatient;
--HOW MANY PROVIDERS HAVE SUBMITTED A MEDICARE INSURANCE CLAIM?
SELECT PayerName
FROM dimPayer
WHERE PayerName = 'MEDICARE';

select COUNT(DISTINCT(providername)) as Number_of_providers
from dimphysician
join  facttable on facttable.dimphysicianpk = dimphysician.dimphysicianpk
JOIN  dimPayer ON  dimPayer.dimPayerPK =  facttable.dimPayerPK
WHERE PayerName = 'MEDICARE';


--calculate the gross collection rate for each locationname 
-- GCR = payments divided grosscharge
--which location has highest GCR

select LocationName, format(-sum(Payment)/ sum(GrossCharge), 'P1') as GCR 
from FactTable
join dimLocation on FactTable.dimLocationPK = dimLocation.dimLocationPK
group by LocationName
order by LocationName desc;
----
----how many CPTCodes have more than 100 units---
select count(*) as 'Countofcpt>100Units'
from(
	select CptCode, sum(CPTUnits) as Units
	from FactTable
	join dimCPTCode on FactTable.dimCPTCodePK = dimCPTCode.dimCPTCodePK
	group by CptCode, CPTUnits
	having sum(CPTUnits) > 100) a ;

---find the physician specialty that has received the highest amount of payments. 
---then show the payments by month for this group of physicians.
select ProviderSpecialty as Physician_specialty, Payment, Month
from FactTable
join dimPhysician on FactTable.dimPhysicianPK = dimPhysician.dimPhysicianPK
join dimDate on FactTable.dimDatePostPK = dimDate.dimDatePostPK
group by ProviderSpecialty, Payment, Month
order by  Payment desc 

--how many CPT units by DagnosiscodeGroup are assogned to J code Diagnosis ( these are diagnosis codes with the letter J in the code)
select count(*)
from (
	select dimDiagnosisCode.DiagnosisCode, dimDiagnosisCode.DiagnosisCodeGroup, sum(CPTUnits) as 'Units' 
	from FactTable
	join dimDiagnosisCode on FactTable.dimDiagnosisCodePK = dimDiagnosisCode.dimDiagnosisCodePK
	where dimDiagnosisCode.DiagnosisCode like 'J%'
	group by DiagnosisCode, DiagnosisCodeGroup) a;


---the report should group patients into three buckets  under 18n, between 18-65, and over 65 please include the following columns 
---- first and last name in the same column
--- email
---patient age
--city and state in th same column
  
select CONCAT(FirstName,LastName) as PatientNames,
		Email, 
		PatientAge,
		case when PatientAge < 18 then 'Under 18'
			when PatientAge between 18 and 65 then 'Between 18-65'
			when PatientAge > 65 then 'Above 65'
			else Null End as 'PatientAgeBucket', CONCAT(City,',', State) as CityState
from dimPatient


--How many dollars hae been written off(adjustments) due to credentialing (adjustmentreason)?
--which location has highest number of credentialing adjustents?
-- how many physicians at this location have nbeen impacted by credentialing adjustments?
--what does this mean? -sum(Adjustment) as Adjustment

select LocationName, -sum(Adjustment) as Adjustment, count(distinct(dimPhysician.ProviderNpi)) as physicians
from FactTable
join dimTransaction on FactTable.dimTransactionPK = dimTransaction.dimTransactionPK
join dimLocation on FactTable.dimLocationPK = dimLocation.dimLocationPK
join dimPhysician on FactTable.dimPhysicianPK = dimPhysician.dimPhysicianPK
where AdjustmentReason = 'Credentialing' 
group by LocationName
order by Adjustment desc


--------------------
select distinct dimPhysician.ProviderNpi, dimPhysician.ProviderName, -sum(Adjustment) as Adjustment
from FactTable
join dimTransaction on FactTable.dimTransactionPK = dimTransaction.dimTransactionPK
join dimLocation on FactTable.dimLocationPK = dimLocation.dimLocationPK
join dimPhysician on FactTable.dimPhysicianPK = dimPhysician.dimPhysicianPK
where AdjustmentReason = 'Credentialing' and LocationName = 'Angelstone Community Hospital'
group by dimPhysician.ProviderNpi, dimPhysician.ProviderName
order by Adjustment desc


---------------------------------------------------------------------
---what is the average patientage by the gender for patients seen 
---at big heart community hospital with a diagnosis that include type 2 diabetes ? 
---and how many patients are included in that average? dimpatient dimLocationPK, dimDiagnosisCode
--where LocationName = 'Big Hart Community Hospital' and  DiagnosisCode 

select PatientGender, AVG(PatientAge) as AVGPatientAge, count(distinct PatientNumber) as CountofPatients
from 
(select distinct  facttable.PatientNumber , PatientGender, PatientAge
from FactTable
join dimPatient on FactTable.dimPatientPK = dimPatient.dimPatientPK
join dimLocation on FactTable.dimLocationPK = dimLocation.dimLocationPK
join dimDiagnosisCode on FactTable.dimDiagnosisCodePK = dimDiagnosisCode.dimDiagnosisCodePK 
where LocationName = 'Big Heart Community Hospital' and  DiagnosisCodeDescription like '%Type 2%' ) a
group by PatientGender 


----There are two types of visits that you have been asked to compare(use CPTdes).
---Office/outpatient visit est
-----Office/outpatient visit new  dimCptCode dimTransaction  FactTable
--show each CPTcode, CPTDesc and associted CPTUnits
---what is the charge per CPTUnits?
---what does this mean?

select CptCode , CptDesc, format(sum(CPTUnits),'#') as CPTUnits, format(sum(GrossCharge)/sum(CPTUnits), '$#') as ChargeperUnit
from FactTable
join dimCptCode on FactTable.dimCPTCodePK = dimCptCode.dimCPTCodePK
WHERE CptDesc = 'Office/outpatient visit est' OR CptDesc = 'Office/outpatient visit new'
group by CptCode , CptDesc
order by CptCode , CptDesc desc

----Do the analysis the paymentperUnit (not chargeunit). You have been tasked with finding the PaymentperUnit by payer.name
----Do this analysis on the following visit Type (CPTDesc)
---initial Hospital care
---Show each CPTCode, CPTdesc and associated CPTunits.(use NUllIF) Payment per unit CPTUnits, PayerName, CPTDesc, dimPayer, dimCPTCode

select CptCode , CptDesc, format(sum(CPTUnits),'#') as CPTUnits, format(-sum(Payment)/NUllif(sum(CPTUnits), 0), '$#') as PaymentperUnit
		, PayerName
from FactTable
join dimCptCode on FactTable.dimCPTCodePK = dimCptCode.dimCPTCodePK
join dimPayer on FactTable.dimPayerPK = dimPayer.dimPayerPK
WHERE CptDesc = 'Initial Hospital care'
group by CptCode , CptDesc, PayerName
order by  PaymentperUnit desc

------Within the Facttable we are able to see Grosscharge. Find the Netcharge , which means conrtractualadjustments need to besubtracted from 
------Grosscharge (GrossCharges - contractual adjustements ). After found the netcharge then calculate the Net collection Rate (Payment/Netcharge)
----for each physician speciality . which physician specialty has worst net collection rate with a netcharge greater than $25000?
----what is happening here? Where are the other dollars and why arent they being collected ? what does that mean?

SELECT ProviderSpecialty,
		GrossCharge, ContractualAdj, Netcharge, Payments, Adjustments, 
		FORMAT(-(Payments/ Netcharge), 'P0') as Net_Collection_Rate,
		FORMAT(AR, '$#, #') as AR,
		FORMAT(AR/ Netcharge, 'P0') as 'PercentinAR', 
		FORMAT(-(Adjustments-ContractualAdj)/Netcharge, 'P0') AS 'Writeoffpercent'
from 
(select ProviderSpecialty, sum(GrossCharge) as 'GrossCharge', 
	sum(case when AdjustmentReason  = 'Contractual' 
		 then Adjustment
		 else Null
		 End) as 'ContractualAdj',
	sum(GrossCharge) + sum(case when AdjustmentReason  = 'Contractual' 
		 then Adjustment
		 else Null
		 End) as 'Netcharge' ,
	sum(Payment) as 'Payments',
	sum(Adjustment) as 'Adjustments',
	sum(AR) as 'AR'
from FactTable
join dimPhysician on FactTable.dimPhysicianPK = dimPhysician.dimPhysicianPK
join dimTransaction on FactTable.dimTransactionPK = dimTransaction.dimTransactionPK
group by ProviderSpecialty) a
where Netcharge > 25000
order by Net_Collection_Rate asc







