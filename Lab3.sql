ALTER FUNCTION PaymentClient
(
@clientid int, @month int, @year int
)
RETURNS money
AS
BEGIN
-- Declare the return variable here
DECLARE @PaymentFromClient money, @Sum_Shopping int, @Discount money
SET @Sum_Shopping =(
SELECT SUM(DetailingReceipt.ClientPrice * DetailingReceipt.Guantity) AS
Sum_Shopping
FROM DetailingReceipt INNER JOIN Receipt ON
Receipt.Id=DetailingReceipt.IdReceipt
WHERE @month=MONTH(Receipt.[Data]) AND @year=YEAR(Receipt.[Data]) AND
Receipt.Client=@clientid
)
IF (SELECT Client.Discount FROM Client WHERE Client.IdClient=@clientid ) > 0
SET @Discount =( @Sum_Shopping *0.01 * (SELECT Client.Discount FROM

Client WHERE Client.IdClient=@clientid) )
ELSE
SET @Discount = 0
SET @PaymentFromClient= @Sum_Shopping-@Discount
-- Return the result of the function
RETURN ISNULL(@PaymentFromClient, 0)
END
GO

ALTER PROCEDURE PaymentAllClient
@month int, @year int
AS
BEGIN
WITH T AS (
SELECT C.IdClient, C.[Name], dbo.PaymentClient(C.IdClient, @month, @year) AS
PaymentClient
FROM Client AS C
)
SELECT *
FROM T
WHERE PaymentClient !=0
END
GO
EXECUTE PaymentAllClient 10, 2020
GO