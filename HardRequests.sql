use Flower_shop
------------------------------------------------------������� �������

-------------------------������ � �������������� ���������� �����������

--����������(�����������������) ��������� ����� ����������� ��� ����������� ������. 
--����� ������, ���������� ���������� ������������� � �������� �������� (��� ������� ������)

--����� ID � ������� ���������� � ������������ ���������
SELECT ID_employee, Surname_of_empl, Name_of_empl FROM Employees WHERE ID_employee = 
 ANY ( SELECT EmployeeID FROM Salary WHERE Salary_amount = 
  (SELECT MAX(Salary_amount) FROM Salary) )

--������� ���������� ������������� ����� � ID = 9 � ������� ������������������ ����������
  SELECT ID_supplier, Surname, Name_of_supplier FROM Suppliers WHERE ID_supplier = 
 ANY (SELECT SupplierID FROM Supply WHERE GoodIDSup = 9)

-------------------------�������� ������� � �������������� ��������������� ����������� � ����������� SELECT � WHERE
--� ��������������� ���������� ���������� ��������� �� ����� ���� ��������� ��� � 
--��������, ������ ��� ����� ��������� ������� ������, ��������� ���� ���������� ��������� 
--������� �� ����������, �������� ������� ���������� �� ���� ����, 
--��� ������� ��������� ��������� ������ �������, ����������� �� ������� �������

--��������������� ��������� � ������������ WHERE
--������� ���������� ������������� ����� � ID = 9 � ������� ���������������� ����������
SELECT ID_supplier, Surname, Name_of_supplier FROM Suppliers WHERE 9 in 
(SELECT GoodIDSup FROM Supply WHERE SupplierID = Suppliers.ID_supplier)

--��������������� ��������� � ������������ SELECT
--������� ���� �������� � �� ������
SELECT (SELECT Surname FROM Clients WHERE ID_client = Orders.ClientID), ID_order
FROM Orders

-------------------------������ � �������������� ��������� ������

--��������� ������� ����������� ���������� �� ������, � ������ ������ ����� ������. 
--��������� ������� ��������� �� ���������� ���������� �� ������

--������� ��������� ������� � ��������� � �� ��������
--�������� ��������� ������� ����� ����������� � ������� ���������� CREATE TABLE:
CREATE TABLE #cl1(
	ID_client INT not null,
	Surname nvarchar(15) not null,
	Bonus int
)
SELECT * FROM #cl1

--�� ��� ����� ������� ������� �������� ������, 
--� ���� �� ����������� �������� ������� ����� ���������, �� ��� ����� ����������� �������:
SELECT ID_client, Surname, Bonus AS Bonus
INTO #cl2
FROM Clients
SELECT * FROM #cl2

-------------------------������ � �������������� ���������� ��������� ��������� (CTE)

--Common Table Expression (CTE) ��� ���������� ��������� ��������� � 
--��� ��������� �������������� ������ (�.�. ���������� ���������� SQL �������), 
--������� �� ����������� � ���� ������ � ���� ��������, �� � ��� ����� ����������

--�������  ����������� � ������� ���������� ����� ������ ������� ���������� ����� ����� ���� ���������� ��� ����� �� 
;WITH T (ID) AS
(SELECT EmployeeID 
 FROM Salary 
 WHERE Salary_amount > (SELECT AVG(Salary_amount) FROM Salary))

 SELECT * FROM T

 -------------------------������� ������ (INSERT, UPDATE) c ������� ���������� MERGE

--MERGE � ��������, ��� ������� ���������� ����������, 
--������� ��� �������� ������ � ������� �� ������ ����������� 
--���������� � ������� ������ ������� ��� SQL �������

--���������������� ������ ������ ���������� � ��������. 
--��� ���������� ������ ����������-������� ��� ������������ ������������� �������� 17000,
--� ���� ��������� ��� ��������� � ����, �� ��� � �������� ������������ ������� 
--�� ������ (������ ����� ����������� � 400�)
MERGE INTO Salary S
USING Employees E
ON(S.EmployeeID = E.ID_employee)
WHEN MATCHED THEN UPDATE SET S.Salary_amount = S.Salary_amount + 400 * 
                 ( SELECT COUNT(OrderID) FROM Executer_of_the_order 
				   WHERE S.EmployeeID = Executer_of_the_order.EmployeeID ),
                            S.Date_salary = (SELECT DATEADD(month, 1, S.Date_salary))
WHEN NOT MATCHED THEN INSERT (EmployeeID, PositionID, Salary_amount, Date_salary) 
                      VALUES (E.ID_Employee, 4, 17000, DATEADD(month, 1, SYSDATETIMEOFFSET()));

SELECT * FROM Employees
SELECT * FROM Salary

-------------------------������ � �������������� ��������� PIVOT

--PIVOT � ��� ��������, ������� ������������ �������������� ����� ������, 
--�.�. ���������� ���������������� �������.
--������� �������, ��������, ������� ����������� �� ��������� ������������� �� �����������

--����� ������� ������ �������
SELECT EmployeeID, [2022], [2023]
FROM (SELECT EmployeeID, Salary_amount AS Sum, YEAR(Date_salary) AS year from Salary) AS My
PIVOT( SUM(sum) for year in ([2022], [2023]))
AS otchet

SELECT YEAR(Date_salary) from Salary
-------------------------������ � �������������� ��������� UNPIVOT

--UNPIVOT � ��� ��������, ������� ��������� ��������, �������� PIVOT. 
--��������, ������� ����������� �� ����������� ������������� �� ���������

--����� �������� ������� ����������
SELECT EmployeeID, column_name, number
FROM Salary
UNPIVOT( number for column_name in (Salary_amount))
AS otchet

-------------------------������ � �������������� GROUP BY � ����������� ROLLUP, CUBE � GROUPING SETS

--������� �� ������� ���������� �� ����� ����� �� ������ �������

--ROLLUP � ��������, ������� ��������� ������������� ����� ��� ������� ���������� �������� � ����� ����
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY ROLLUP (Surname_of_empl, Post)

--CUBE � ��������, ������� ��������� ���������� ��� ���� ��������� ������������ ����������
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY CUBE (Surname_of_empl, Post)

--GROUPING SETS � ��������, ������� ��������� ���������� ���������� ����������� � ���� ����� ������
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY GROUPING SETS (Surname_of_empl, Post)

SELECT * FROM Employees
SELECT * FROM Executer_of_the_order
SELECT * FROM Orders

-------------------------��������������� � �������������� OFFSET FETCH

--OFFSET-FETCH � ��� ����������� �����, ������� �������� ������ ORDER BY, 
--� ��������� ��������� ������ � ���������������, ��� ����������������, ������ ������

--OFFSET - ������� ������ n �����
SELECT * FROM Flowers
ORDER BY Price
OFFSET 2 ROW

--FETCH ��� ��������� ���������� ������������ ����� ����� �������� ������� ����� �� ��������� OFFSET
SELECT * FROM Flowers
ORDER BY Price
OFFSET 2 ROW
FETCH NEXT 2 ROWS ONLY

-------------------------������� � �������������� ����������� ������� �������. 
--ROW_NUMBER() ��������� �����. ������������ ��� ��������� ������ �����. RANK(), DENSE_RANK(), NTILE().

--����������� ������� � ��� �������, 
--������� ���������� �������� ��� ������ ������ ������ � �������������� ������ ������

--ROW_NUMBER() - ������� ���������, ������� ���������� ����� ������

--����� �������� �� ������������ ���� � ������ �� ��������� ����������� ������� 
SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   ROW_NUMBER() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Top]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type

--RANK() - ����������� �������, ������� ���������� ���� ������ ������. 
--� ������ ������, � ������� �� ROW_NUMBER(), ���� ��� ������ �������� � 
--� ������ ���������� ����������, ������� ���������� ���������� ���� � ��������� ����������

--����� ������ �� ������������ ���� � ������ �� ��������� ����������� �������
SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   ROW_NUMBER() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Top],
	   RANK() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Rank]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type

--DENSE_RANK() - ����������� �������, ������� ���������� ���� ������ ������, �� � ������� �� rank, 
--� ������ ���������� ���������� ��������, ���������� ���� ��� �������� ����������(�������� � ������� ��������)

SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   ROW_NUMBER() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Top],
	   RANK() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Rank],
	   DENSE_RANK() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Dense-rank]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type

--NTILE(n) - �������, ������� ����� �������������� ����� �� n ����� �� ������������� �������.
--� ������ ���� � ������� ���������� ������ ���������� �����, �� � ������ ������ ����� ���������� ����������

SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   NTILE(3) OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Groups]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type


-------------------------��������������� ������ � TRY/CATCH
--TRY CATCH � ��� ����������� ��� ��������� ������

--������� ��������� ������� �������� ����� �������� � ������� � ID, ��� IDENTITY_INSERT ���������� � OFF
BEGIN TRY
   INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, '������', '����', '89001232012', 0)
END TRY
BEGIN CATCH
	PRINT '������! ������ �������� �������� ID ����!'
END CATCH

-------------------------�������� ��������� ��������� ������ � ����� CATCH � �������������� ������� ERROR

--������� ��������� ������� �������� ����� �������� � ������� � ID, ��� IDENTITY_INSERT ���������� � OFF
BEGIN TRY
    INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, '������', '����', '89001232012', 0)
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS error_num, ERROR_MESSAGE() AS error_mes
END CATCH

-------------------------������������� THROW, ����� �������� ��������� �� ������ �������

--THROW ����� ��� ������ ����������
--������� ��������� ������� �������� ����� �������� � ������� � ID, ��� IDENTITY_INSERT ���������� � OFF
BEGIN TRY
    INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, '������', '����', '89001232012', 0)
END TRY
BEGIN CATCH
	THROW 51000, '������! ������ �������� �������� ID ����!', 1
END CATCH

-------------------------�������� ���������� � BEGIN � COMMIT

--BEGIN TRANSACTION � ������� ������ ��� ����������� ������ ����������
--COMMIT TRANSACTION � � ������� ������ ������� SQL �������  ���������� �� �������� ���������� ����������,
--� � ���, ��� ��� ���������, ������� ���� ���������, ���������� ��������� �� ���������� ������

--��������� ��� ��������� � ����� ����������
BEGIN TRANSACTION
	UPDATE Flowers SET Price = 700
	WHERE FlowerID = 1;

	UPDATE Bouquets SET Price = 50000
	WHERE BouquetID = 11;
COMMIT TRANSACTION

SELECT * FROM Flowers
SELECT * FROM Bouquets

-------------------------������������� XACT_ABORT

--XACT_ABORT � ��� ��������, ������� ��������� SQL Server, 
--��������� �� ����� ���� ����������
--� ������ ������������� ������ � ����������� ���� ����������

SET XACT_ABORT ON
BEGIN TRANSACTION
	UPDATE Flowers SET Price = 100
	WHERE FlowerID = 1;

	UPDATE Bouquets SET Price = null
	WHERE BouquetID = 11
COMMIT TRANSACTION

-------------------------���������� ������ ��������� ���������� � ����� CATCH

--��������� ��� ��������� � ����� ���������� � ����� �������
--(������� ����������, ��� ������� ��� ��������� ��������� �����)
BEGIN TRY
	BEGIN TRANSACTION
	UPDATE Flowers SET Price = 400
	WHERE FlowerID = 1;

	UPDATE Bouquets SET Price = null
	WHERE BouquetID = 11;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT ERROR_NUMBER() AS error_num,
		   ERROR_MESSAGE() AS error_mes
	RETURN
END CATCH
	COMMIT TRANSACTION









