CREATE TABLE NewForTrigg
(
id int IDENTITY PRIMARY KEY,
nameNewWorker nvarchar(50),
UCD nvarchar(50),
DCR datetime,
ULC nvarchar(50),
DLC datetime
);
GO
CREATE OR ALTER TRIGGER NewForTriggInsert ON dbo.NewForTrigg
AFTER INSERT
AS
UPDATE dbo.NewForTrigg
SET UCD ='ADMIN', DCR=GETDATE()
WHERE Id=(SELECT Id FROM inserted)
GO
CREATE OR ALTER TRIGGER NewForTriggUpdate ON dbo.NewForTrigg
AFTER UPDATE
AS
UPDATE dbo.NewForTrigg
SET ULC ='ADMIN' , DLC=GETDATE()
WHERE Id=(SELECT Id FROM inserted)
GO

CREATE TRIGGER InvoicetGoods ON dbo.DetailingInvoice
AFTER INSERT
AS
BEGIN
DECLARE @InvoicetGuantity int =(SELECT Guantity FROM inserted), @InvoicetGoods int
=(SELECT Googs FROM inserted),
@InvoicetData date =(SELECT SuitableFor FROM inserted)
INSERT INTO Storage(IdGoods, Guantity, SuitableFor)
VALUES (@InvoicetGoods, @InvoicetGuantity, @InvoicetData )
END

ALTER TRIGGER ReceiptGoods ON dbo.DetailingReceipt
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @ReceiptGuantity int =(SELECT Guantity FROM inserted), @ReceiptGoods
int =(SELECT Goods FROM inserted),
@ALLGuantity int
-------
DECLARE @CurIdStorageGoods int, @CurDataSuitableFor date,@CurGuantity int,
@CurIdGoods int
DECLARE CursGoodsStorange CURSOR FOR
SELECT ST.Id, ST.SuitableFor, ST.Guantity, ST.IdGoods
FROM Storage AS ST
WHERE ST.SuitableFor > GETDATE() AND IdGoods =@ReceiptGoods
ORDER BY ST.SuitableFor
-------
SET @ALLGuantity = (
SELECT SUM(ST.Guantity)
FROM Storage AS ST
WHERE ST.IdGoods = @ReceiptGoods)
IF @ALLGuantity < @ReceiptGuantity
ROLLBACK
ELSE
OPEN CursGoodsStorange
FETCH CursGoodsStorange INTO @CurIdStorageGoods,

@CurDataSuitableFor,@CurGuantity, @CurIdGoods
WHILE @@FETCH_STATUS = 0
BEGIN
IF @ReceiptGuantity <= @CurGuantity
BEGIN
UPDATE Storage SET Guantity=Guantity-@ReceiptGuantity

WHERE Id =@CurIdStorageGoods

SET @ReceiptGuantity = 0

BREAK
END
ELSE
BEGIN
UPDATE Storage SET Guantity=0 WHERE Id =@CurIdStorageGoods
SET @ReceiptGuantity= @ReceiptGuantity-@CurGuantity
FETCH CursGoodsStorange INTO @CurIdStorageGoods,

@CurDataSuitableFor,@CurGuantity, @CurIdGoods

END

END
CLOSE CursGoodsStorange
DEALLOCATE CursGoodsStorange
END


CREATE OR ALTER PROCEDURE WriteOffG
AS
BEGIN
DECLARE @IdStorageGoods int, @DataSuitableFor date,@Guantity int, @IdGoods int
DECLARE CursDataGoods CURSOR FOR
SELECT ST.Id, ST.SuitableFor, ST.Guantity, ST.IdGoods
FROM Storage AS ST
WHERE ST.SuitableFor < GETDATE()
OPEN CursDataGoods
FETCH CursDataGoods INTO @IdStorageGoods, @DataSuitableFor,@Guantity, @IdGoods
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO WriteOff(IdStorageGoods, DataSuitableFor, Guantity,

IdGoods)

VALUES (@IdStorageGoods, @DataSuitableFor ,@Guantity, @IdGoods )
UPDATE Storage SET Guantity=0 WHERE Id =@IdStorageGoods
FETCH CursDataGoods INTO @IdStorageGoods,

@DataSuitableFor,@Guantity, @IdGoods

END
CLOSE CursDataGoods;
DEALLOCATE CursDataGoods;
END
GO