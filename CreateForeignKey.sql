USE Healthcare_DB


IF OBJECT_ID('FK_dimPatientPK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimPatientPK
GO
IF OBJECT_ID('FK_dimPhysicianPK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimPhysicianPK
GO
IF OBJECT_ID('FK_dimTransactionPK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimTransactionPK
GO
IF OBJECT_ID('FK_dimPayerPK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimPayerPK
GO
IF OBJECT_ID('FK_dimLocationPK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimLocationPK
GO
IF OBJECT_ID('FK_dimDiagnosisCodePK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimDiagnosisCodePK
GO
IF OBJECT_ID('FK_dimCptCodePK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimCptCodePK
GO
IF OBJECT_ID('FK_dimDatePK') IS NOT NULL Alter Table FactTable DROP Constraint FK_dimDatePK
GO

Alter Table FactTable
Add  Constraint FK_dimPatientPK Foreign Key (dimPatientPK) References dimPatient(dimPatientPK)
	,Constraint FK_dimPhysicianPK Foreign Key (dimPhysicianPK) References dimPhysician(dimPhysicianPK)
	,Constraint FK_dimTransactionPK Foreign Key (dimTransactionPK) References dimTransaction(dimTransactionPK)
	,Constraint FK_dimPayerPK Foreign Key (dimPayerPK) References dimPayer(dimPayerPK)
	,Constraint FK_dimLocationPK Foreign Key (dimLocationPK) References dimLocation(dimLocationPK)
	,Constraint FK_dimDiagnosisCodePK Foreign Key (dimDiagnosisCodePK) References dimDiagnosisCode(dimDiagnosisCodePK)
	,Constraint FK_dimCptCodePK Foreign Key (dimCptCodePK) References dimCptCode(dimCptCodePK)
	,Constraint FK_dimDatePK Foreign Key (dimDatePostPK) References dimDate(dimDatePostPK)

	--Select * from FactTable 
	--Select * from dimPatient
	--Select * from dimPhysician
	--Select * from dimTransaction
	--Select * from dimPayer
	--Select * from dimLocation
	--Select * from dimDiagnosisCode
	--Select * from dimCptCode
	--Select * from dimDate