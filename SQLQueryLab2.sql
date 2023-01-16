--1 ������, ������� ���� >5, � ����<50
SELECT Goods.[Name], Category, Goods.Guantity, ProviderPrice
FROM Goods
WHERE Guantity > 5 AND ProviderPrice < 50
ORDER BY Category
GO
--�볺���, � ���� ���� ������ ��� ������ ��'�����
SELECT [Name], Discount, Balance
FROM Client
WHERE Discount = 0 OR Balance < 0
GO
--2 ��������
SELECT Cl.[Name], Cl.[Address], Category AS Disc
FROM Client AS Cl
GO
--3 ������, �� ���� ������
SELECT Goods.IdGoods, Goods.[Name], Goods.SuitableFor
FROM Goods INNER JOIN WriteOff ON WriteOff.Goods = IdGoods
GO
--4 ������ �� ���������� Dove �� �����
SELECT Goods.[Name], Goods.Category, Goods.ProviderPrice, ClientPrice
FROM Goods INNER JOIN DetailingInvoice ON DetailingInvoice.Googs=IdGoods
INNER JOIN Invoice ON Invoice.Id=DetailingInvoice.IdInvoice
INNER JOIN Provider ON Provider.IdProvider= Invoice.Provider
WHERE IdProvider = 1 OR IdProvider = 6
GO
--5 ���������� ��� ��� 곺��� �� �� �������
SELECT *
FROM Receipt RIGHT JOIN Client ON Receipt.Client = IdClient
GO
--���������� ��� �� ������� �� ��� ��������, �� �������� �������
SELECT *
FROM Receipt LEFT JOIN Client ON Receipt.Client = IdClient
GO
--6 ������ ������, �� ��������� ���� � ����� �� 20 �� 60
SELECT *
FROM Goods
WHERE Goods.ProviderPrice BETWEEN 20 AND 60
--7 ���������� ��� ����������� ��� �������� �����
SELECT *
FROM Goods
WHERE Goods.ClientPrice = (SELECT MAX(Goods.ClientPrice) FROM Goods)
GO
--8 ���� ������� ��������, ��'������ ����� ����� ������
SELECT Client.Discount, SUM(Client.Balance)
FROM Client
GROUP BY Client.Discount
GO
--9 �� ���������, �� ������ � ��� ���� �� ���� �����
SELECT DetailingInvoice.IdInvoice, SUM(DetailingInvoice.IdInvoice) AS
SumNumberIdInvoic
FROM DetailingInvoice
GROUP BY DetailingInvoice.IdInvoice
HAVING COUNT(*)>1
GO
--10 ������� ����������� ������ �� ���� ���
SELECT Goods.[Name],Goods.ProviderPrice,
(SELECT Sum(DetailingInvoice.Guantity)
FROM DetailingInvoice
WHERE Goods.IdGoods= DetailingInvoice.Googs) AS AllGuantity
FROM Goods
GO
--11 ���������� ����� �������, �� �������� ��� �����
SELECT Provaidered.[Name], Provaidered.Category
FROM
(SELECT [Provider].[Name], [Provider].Category
FROM [Provider] INNER JOIN Invoice ON Invoice.[Provider]=IdProvider
GROUP BY [Provider].[Name], [Provider].Category
) AS Provaidered
WHERE Category='Confectionery'
GO
--12 ������, ���� ���� �������� � ������� ����� 7
SELECT G.[Name], Category, ProviderPrice, ClientPrice
FROM Goods AS G
WHERE G.IdGoods IN (SELECT DetailingInvoice.Googs FROM DetailingInvoice WHERE
DetailingInvoice.Guantity >7 )

GO
--13 ����� ��������, ��� �� > ���� ����������, � ������ ���� �������� �������
SELECT DetailingInvoice.IdInvoice, COUNT(DetailingInvoice.IdInvoice) AS
SumNumberIdInvoic
FROM DetailingInvoice
GROUP BY DetailingInvoice.IdInvoice
HAVING COUNT(DetailingInvoice.IdInvoice)>1 AND DetailingInvoice.IdInvoice IN (
SELECT Invoice.Id
FROM Invoice INNER JOIN [Provider] ON [Provider].IdProvider=Invoice.[Provider]
WHERE [Provider].Balance>0)
GO
--14 �� �� �볺�� ������
SELECT Client.[Name],Client.Category,
CASE
WHEN Discount >= 3 THEN 'has a discount'
ELSE 'no discount'
END AS Discount
FROM Client
GO
--15 �� �볺���, �� �������� �������
SELECT Client.IdClient
FROM Client
INTERSECT
SELECT Receipt.Client
FROM Receipt
GO
--16 �� ������, �� �� ���� ������
SELECT Goods.IdGoods
FROM Goods
EXCEPT
SELECT DetailingReceipt.Goods
FROM DetailingReceipt
GO
--17 �� ���������� �� �볺���, �� ������
SELECT Client.[Name], Client.Balance
FROM Client
UNION
SELECT[Provider].[Name], [Provider].Balance
FROM [Provider]
ORDER BY Balance DESC
GO
--18 ����� ������� �� ����
INSERT INTO Receipt ([Data], [Client])
VALUES ('2020-11-11', 2)
--19 ��������� ������� � ��������� ��������, �� �� ������� ��������
CREATE TABLE AllWriteOffGoods (Id int, GoodsName nvarchar(50), DataWriteof date,
Category nvarchar(50))
GO
INSERT INTO AllWriteOffGoods(Id,GoodsName, DataWriteof, Category)
SELECT G.IdGoods, G.[Name], G.SuitableFor, G.Category
FROM Goods AS G
WHERE G.IdGoods IN (SELECT WriteOff.Goods FROM WriteOff )
GO
--20 ���� �������, �� ��������� ����� �������
SELECT * INTO ProviderConfectionery
FROM [Provider]
WHERE [Provider].Category = 'Confectionery'
GO

--21 ������� ����� ������
UPDATE Goods
SET [Name] = 'Napoleon cake'
WHERE IdGoods = 38
SELECT *
FROM Goods
--22 ������ ���� ������� ������ ��� �볺����, �� �������� �������
SELECT * INTO ClientCopy
FROM Client
GO
UPDATE ClientCopy
SET ClientCopy.Discount = ClientCopy.Discount +1
WHERE ClientCopy.IdClient IN (SELECT Receipt.Client FROM Receipt )
GO
--23 ��������� ��� ����� �� ������� � �������
DELETE FROM ClientCopy
WHERE ClientCopy.Discount =5
GO
DROP TABLE AllWriteOffGoods
--24 ��������� ����������, �� ���� ���������
DELETE FROM ProviderConfectionery
WHERE ProviderConfectionery.IdProvider IN (SELECT Invoice.Provider FROM [Invoice] )
GO
--I ������ ������ ����� ������� (��������) � ��������� ��������������� ����,
�����, ��� �� ������ ������� �� ������� ������ ����
SELECT *
FROM Goods AS G
WHERE G.Category='Confectionery' AND G.SuitableFor > GETDATE()
GO
--II.������ ���� ������ �� ������ ����� ���� �������� �� ������� ������,
������� ��������� ������ �� �����, ������� ������� �� �������� ������ ��
�����, ������� ������, �������� �� ����� ������;
SELECT G.IdGoods, G.[Name], G.Guantity AS StartGuantity,
(SELECT Sum(DI.Guantity)
FROM DetailingInvoice AS DI
WHERE G.IdGoods= DI.Googs AND DI.IdInvoice IN (

SELECT I.Id
FROM Invoice AS I
WHERE I.[Data] > '2020-10-15' )

) AS ProvideredGuantity,
(SELECT Sum(DR.Guantity)
FROM DetailingReceipt AS DR
WHERE G.IdGoods= DR.Goods AND DR.IdReceipt IN (
SELECT R.Id
FROM Receipt AS R
WHERE R.[Data] > '2020-10-15' )
) AS ReceiptedGuantity,
(SELECT Sum(WriteOff.Guantity)
FROM WriteOff
WHERE G.IdGoods= WriteOff.Goods AND WriteOff.DataSuitableFor > '2020-10-15' )
AS WriteOffGuantity
INTO Guantity
FROM Goods AS G
WHERE SuitableFor > '2020-10-15'
GO
UPDATE Guantity
SET ProvideredGuantity = 0
WHERE ProvideredGuantity IS NULL
UPDATE Guantity
SET ReceiptedGuantity = 0
WHERE ReceiptedGuantity IS NULL
UPDATE Guantity
SET WriteOffGuantity = 0
WHERE WriteOffGuantity IS NULL
SELECT G.IdGoods, G.[Name], StartGuantity, ProvideredGuantity, ReceiptedGuantity,
WriteOffGuantity,
(StartGuantity + ProvideredGuantity - ReceiptedGuantity - WriteOffGuantity) AS
FinishGuantity
FROM Guantity AS G
GO
--III ������ ������������� � ��������� ��� ����� ��������� ��� ������ ������ ��
���;
SELECT *
FROM [Provider] AS PR INNER JOIN Invoice ON Invoice.Provider=PR.IdProvider
INNER JOIN DetailingInvoice ON DetailingInvoice.IdInvoice=Invoice.Id
GO
--IV ������ �������� �� ���� ����� �� ������� ������ ���� � ������� �������� ����
�����
SELECT C.IdClient, C.[Name], C.Balance
FROM Client AS C
WHERE C.IdClient IN (SELECT Receipt.Client FROM Receipt WHERE (Receipt.[Data]) >
'2020-11-01' )
ORDER BY C.Balance DESC
GO
