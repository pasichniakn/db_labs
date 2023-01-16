--1 товари, кількість яких >5, а ціна<50
SELECT Goods.[Name], Category, Goods.Guantity, ProviderPrice
FROM Goods
WHERE Guantity > 5 AND ProviderPrice < 50
ORDER BY Category
GO
--клієнти, в яких немає знижки або баланс від'ємний
SELECT [Name], Discount, Balance
FROM Client
WHERE Discount = 0 OR Balance < 0
GO
--2 псевдонім
SELECT Cl.[Name], Cl.[Address], Category AS Disc
FROM Client AS Cl
GO
--3 товари, що були списані
SELECT Goods.IdGoods, Goods.[Name], Goods.SuitableFor
FROM Goods INNER JOIN WriteOff ON WriteOff.Goods = IdGoods
GO
--4 товари від провайдерів Dove та Світоч
SELECT Goods.[Name], Goods.Category, Goods.ProviderPrice, ClientPrice
FROM Goods INNER JOIN DetailingInvoice ON DetailingInvoice.Googs=IdGoods
INNER JOIN Invoice ON Invoice.Id=DetailingInvoice.IdInvoice
INNER JOIN Provider ON Provider.IdProvider= Invoice.Provider
WHERE IdProvider = 1 OR IdProvider = 6
GO
--5 інформація про всіх кієнтів та їх покупки
SELECT *
FROM Receipt RIGHT JOIN Client ON Receipt.Client = IdClient
GO
--інформація про всі покупки та тих покупців, які здійснили покупку
SELECT *
FROM Receipt LEFT JOIN Client ON Receipt.Client = IdClient
GO
--6 список товарів, де закупочна ціна в межах від 20 до 60
SELECT *
FROM Goods
WHERE Goods.ProviderPrice BETWEEN 20 AND 60
--7 інформація про найдорожчий для покупців товар
SELECT *
FROM Goods
WHERE Goods.ClientPrice = (SELECT MAX(Goods.ClientPrice) FROM Goods)
GO
--8 сума балансу покупців, об'єднних одним видом знижки
SELECT Client.Discount, SUM(Client.Balance)
FROM Client
GROUP BY Client.Discount
GO
--9 ід накладних, які містять в собі більш ніж один товар
SELECT DetailingInvoice.IdInvoice, SUM(DetailingInvoice.IdInvoice) AS
SumNumberIdInvoic
FROM DetailingInvoice
GROUP BY DetailingInvoice.IdInvoice
HAVING COUNT(*)>1
GO
--10 кількість замовленого товару за весь час
SELECT Goods.[Name],Goods.ProviderPrice,
(SELECT Sum(DetailingInvoice.Guantity)
FROM DetailingInvoice
WHERE Goods.IdGoods= DetailingInvoice.Googs) AS AllGuantity
FROM Goods
GO
--11 провайдери певної категорії, які привезли свій товар
SELECT Provaidered.[Name], Provaidered.Category
FROM
(SELECT [Provider].[Name], [Provider].Category
FROM [Provider] INNER JOIN Invoice ON Invoice.[Provider]=IdProvider
GROUP BY [Provider].[Name], [Provider].Category
) AS Provaidered
WHERE Category='Confectionery'
GO
--12 товари, яких було завезено в кількості більше 7
SELECT G.[Name], Category, ProviderPrice, ClientPrice
FROM Goods AS G
WHERE G.IdGoods IN (SELECT DetailingInvoice.Googs FROM DetailingInvoice WHERE
DetailingInvoice.Guantity >7 )

GO
--13 номер накладної, яка має > однієї деталізації, а баланс того продавця додатній
SELECT DetailingInvoice.IdInvoice, COUNT(DetailingInvoice.IdInvoice) AS
SumNumberIdInvoic
FROM DetailingInvoice
GROUP BY DetailingInvoice.IdInvoice
HAVING COUNT(DetailingInvoice.IdInvoice)>1 AND DetailingInvoice.IdInvoice IN (
SELECT Invoice.Id
FROM Invoice INNER JOIN [Provider] ON [Provider].IdProvider=Invoice.[Provider]
WHERE [Provider].Balance>0)
GO
--14 чи має клієнт знижку
SELECT Client.[Name],Client.Category,
CASE
WHEN Discount >= 3 THEN 'has a discount'
ELSE 'no discount'
END AS Discount
FROM Client
GO
--15 ід клієнтів, які здійснили покупку
SELECT Client.IdClient
FROM Client
INTERSECT
SELECT Receipt.Client
FROM Receipt
GO
--16 ід товарів, які не були продані
SELECT Goods.IdGoods
FROM Goods
EXCEPT
SELECT DetailingReceipt.Goods
FROM DetailingReceipt
GO
--17 всі провайдери та клієнти, їх баланс
SELECT Client.[Name], Client.Balance
FROM Client
UNION
SELECT[Provider].[Name], [Provider].Balance
FROM [Provider]
ORDER BY Balance DESC
GO
--18 Додаєм покупця до чеку
INSERT INTO Receipt ([Data], [Client])
VALUES ('2020-11-11', 2)
--19 Створюємо таблицю з списаними товарами, де ще вказуємо категорію
CREATE TABLE AllWriteOffGoods (Id int, GoodsName nvarchar(50), DataWriteof date,
Category nvarchar(50))
GO
INSERT INTO AllWriteOffGoods(Id,GoodsName, DataWriteof, Category)
SELECT G.IdGoods, G.[Name], G.SuitableFor, G.Category
FROM Goods AS G
WHERE G.IdGoods IN (SELECT WriteOff.Goods FROM WriteOff )
GO
--20 нова табциця, де провайдер певної категорії
SELECT * INTO ProviderConfectionery
FROM [Provider]
WHERE [Provider].Category = 'Confectionery'
GO

--21 змінюємо назву товару
UPDATE Goods
SET [Name] = 'Napoleon cake'
WHERE IdGoods = 38
SELECT *
FROM Goods
--22 додаємо один відсоток знижки тим клієнтам, які здійснили покупку
SELECT * INTO ClientCopy
FROM Client
GO
UPDATE ClientCopy
SET ClientCopy.Discount = ClientCopy.Discount +1
WHERE ClientCopy.IdClient IN (SELECT Receipt.Client FROM Receipt )
GO
--23 видалення всіх даних із таблиці і таблиці
DELETE FROM ClientCopy
WHERE ClientCopy.Discount =5
GO
DROP TABLE AllWriteOffGoods
--24 видаляємо провайдерів, які щось постачали
DELETE FROM ProviderConfectionery
WHERE ProviderConfectionery.IdProvider IN (SELECT Invoice.Provider FROM [Invoice] )
GO
--I список товарів певної категорії (параметр) з вказанням номенклатурного коду,
назви, цін та наявної кількості на заданий момент часу
SELECT *
FROM Goods AS G
WHERE G.Category='Confectionery' AND G.SuitableFor > GETDATE()
GO
--II.список обігу товарів за певний період часу наявного на початок періоду,
кількості придбання товару за період, кількості продажу та списання товару за
період, кількості товару, наявного на кінець періоду;
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
--III список постачальників з вказанням всіх даних документів про прихід товару від
них;
SELECT *
FROM [Provider] AS PR INNER JOIN Invoice ON Invoice.Provider=PR.IdProvider
INNER JOIN DetailingInvoice ON DetailingInvoice.IdInvoice=Invoice.Id
GO
--IV список покупців та суми боргу на заданий момент часу в порядку спадання суми
боргу
SELECT C.IdClient, C.[Name], C.Balance
FROM Client AS C
WHERE C.IdClient IN (SELECT Receipt.Client FROM Receipt WHERE (Receipt.[Data]) >
'2020-11-01' )
ORDER BY C.Balance DESC
GO
