use Flower_shop
------------------------------------------------------СЛОЖНЫЕ ЗАПРОСЫ

-------------------------Запрос с использованием автономных подзапросов

--Автономный(некоррелированный) подзапрос может вычисляться как независимый запрос. 
--Иначе говоря, результаты подзапроса подставляются в основной оператор (или внешний запрос)

--Вывод ID и фамилии сотрудника с максимальной зарплатой
SELECT ID_employee, Surname_of_empl, Name_of_empl FROM Employees WHERE ID_employee = 
 ANY ( SELECT EmployeeID FROM Salary WHERE Salary_amount = 
  (SELECT MAX(Salary_amount) FROM Salary) )

--Вывести поставщика поставляющего товар с ID = 9 с помощью некоррелированного подзапроса
  SELECT ID_supplier, Surname, Name_of_supplier FROM Suppliers WHERE ID_supplier = 
 ANY (SELECT SupplierID FROM Supply WHERE GoodIDSup = 9)

-------------------------Создание запроса с использованием коррелированных подзапросов в предложении SELECT и WHERE
--В коррелированном подзапросе внутренний подзапрос не может быть отработан раз и 
--навсегда, прежде чем будет отработан внешний запрос, поскольку этот внутренний подзапрос 
--зависит от переменной, значение которой изменяется по мере того, 
--как система проверяет различные строки таблицы, участвующие во внешнем запросе

--Коррелированный подзапрос с предложением WHERE
--Вывести поставщика поставляющего товар с ID = 9 с помощью коррелированного подзапроса
SELECT ID_supplier, Surname, Name_of_supplier FROM Suppliers WHERE 9 in 
(SELECT GoodIDSup FROM Supply WHERE SupplierID = Suppliers.ID_supplier)

--Коррелированный подзапрос с предложением SELECT
--Вывести всех клиентов и их заказы
SELECT (SELECT Surname FROM Clients WHERE ID_client = Orders.ClientID), ID_order
FROM Orders

-------------------------Запрос с использованием временных таблиц

--Временная таблица принадлежит создавшему ее сеансу, и видима только этому сеансу. 
--Временная таблица удаляется по завершению создавшего ее сеанса

--Создать временную таблицу с клиентами и их бонусами
--Создание временной таблицы можно осуществить с помощью инструкции CREATE TABLE:
CREATE TABLE #cl1(
	ID_client INT not null,
	Surname nvarchar(15) not null,
	Bonus int
)
SELECT * FROM #cl1

--но при таком способе таблица остается пустой, 
--а если же осуществить создание таблицы через подзапрос, то она сразу заполняется данными:
SELECT ID_client, Surname, Bonus AS Bonus
INTO #cl2
FROM Clients
SELECT * FROM #cl2

-------------------------Запрос с использованием обобщенных табличных выражений (CTE)

--Common Table Expression (CTE) или обобщенное табличное выражение – 
--это временные результирующие наборы (т.е. результаты выполнения SQL запроса), 
--которые не сохраняются в базе данных в виде объектов, но к ним можно обращаться

--Вывести  сотрудников у которых заработная плата меньше средней заработной платы среди всех сотруников или равна ей 
;WITH T (ID) AS
(SELECT EmployeeID 
 FROM Salary 
 WHERE Salary_amount > (SELECT AVG(Salary_amount) FROM Salary))

 SELECT * FROM T

 -------------------------Слияние данных (INSERT, UPDATE) c помощью инструкции MERGE

--MERGE – операция, при которой происходит обновление, 
--вставка или удаление данных в таблице на основе результатов 
--соединения с данными другой таблицы или SQL запроса

--Синхронизировать данные таблиц Сотрудники и Зарплаты. 
--При добавлении нового сотрудника-стажера ему выставляется фиксированная зарплата 17000,
--а если сотрудник уже находится в базе, то ему к зарплате прибавляется процент 
--от продаж (каждый заказ оценивается в 400р)
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

-------------------------Запрос с использованием оператора PIVOT

--PIVOT – это оператор, который поворачивает результирующий набор данных, 
--т.е. происходит транспонирование таблицы.
--Другими словами, значения, которые расположены по вертикали выстраиваются по горизонтали

--Вывод графика выплат зарплат
SELECT EmployeeID, [2022], [2023]
FROM (SELECT EmployeeID, Salary_amount AS Sum, YEAR(Date_salary) AS year from Salary) AS My
PIVOT( SUM(sum) for year in ([2022], [2023]))
AS otchet

SELECT YEAR(Date_salary) from Salary
-------------------------Запрос с использованием оператора UNPIVOT

--UNPIVOT – это оператор, который выполняет действия, обратные PIVOT. 
--Значения, которые расположены по горизонтали выстраиваются по вертикали

--Вывод зарплаты каждого сотрудника
SELECT EmployeeID, column_name, number
FROM Salary
UNPIVOT( number for column_name in (Salary_amount))
AS otchet

-------------------------Запрос с использованием GROUP BY с операторами ROLLUP, CUBE и GROUPING SETS

--Вывести по каждому сотруднику на какую сумму он продал заказов

--ROLLUP – оператор, который формирует промежуточные итоги для каждого указанного элемента и общий итог
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY ROLLUP (Surname_of_empl, Post)

--CUBE — оператор, который формирует результаты для всех возможных перекрестных вычислений
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY CUBE (Surname_of_empl, Post)

--GROUPING SETS – оператор, который формирует результаты нескольких группировок в один набор данных
SELECT Employees.Surname_of_empl, Employees.Post, SUM(Orders.Cost) AS itog
FROM Employees
FULL JOIN Executer_of_the_order ON Employees.ID_employee = Executer_of_the_order.EmployeeID
FULL JOIN Orders ON Orders.ID_order = Executer_of_the_order.OrderID
GROUP BY GROUPING SETS (Surname_of_empl, Post)

SELECT * FROM Employees
SELECT * FROM Executer_of_the_order
SELECT * FROM Orders

-------------------------Секционирование с использованием OFFSET FETCH

--OFFSET-FETCH – это конструкция языка, которая является частью ORDER BY, 
--и позволяет применять фильтр к результирующему, уже отсортированному, набору данных

--OFFSET - пропуск первых n строк
SELECT * FROM Flowers
ORDER BY Price
OFFSET 2 ROW

--FETCH для уточнения количества возвращаемых строк после пропуска массива строк по выражению OFFSET
SELECT * FROM Flowers
ORDER BY Price
OFFSET 2 ROW
FETCH NEXT 2 ROWS ONLY

-------------------------Запросы с использованием ранжирующих оконных функций. 
--ROW_NUMBER() нумерация строк. Использовать для нумерации внутри групп. RANK(), DENSE_RANK(), NTILE().

--Ранжирующие функции — это функции, 
--которые возвращают значение для каждой строки группы в результирующем наборе данных

--ROW_NUMBER() - функция нумерации, которая возвращает номер строки

--Вывод рейтинга по максимальной цене в каждой из категорий продаваемых товаров 
SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   ROW_NUMBER() OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Top]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type

--RANK() - ранжирующая функция, которая возвращает ранг каждой строки. 
--В данном случае, в отличие от ROW_NUMBER(), идет уже анализ значений и 
--в случае нахождения одинаковых, функция возвращает одинаковый ранг с пропуском следующего

--Вывод рангов по максимальной цене в каждой из категорий продаваемых товаров
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

--DENSE_RANK() - ранжирующая функция, которая возвращает ранг каждой строки, но в отличие от rank, 
--в случае нахождения одинаковых значений, возвращает ранг без пропуска следующего(различие в разделе упаковки)

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

--NTILE(n) - функция, которая делит результирующий набор на n групп по определенному столбцу.
--В случае если в группах получается разное количество строк, то в первой группе будет наибольшее количество

SELECT Goods.ID_good, Type_of_goods.Type_of, Flowers.Name_flower, Flowers.Color, Flowers.Price,  
       Bouquets.Name_bouquet, Bouquets.Price, Accessories.Name_accessory, Accessories.Color_accessory, Accessories.Price,
	   NTILE(3) OVER (PARTITION BY Type_of 
	   ORDER BY Flowers.Price DESC, Bouquets.Price DESC,  Accessories.Price DESC) AS [Groups]
FROM Goods
FULL JOIN Flowers ON Goods.ID_good = Flowers.FlowerID
FULL JOIN Bouquets ON Goods.ID_good = Bouquets.BouquetID
FULL JOIN Accessories ON Goods.ID_good = Accessories.AccessoryID
FULL JOIN Type_of_goods ON Goods.Type_good = Type_of_goods.ID_type


-------------------------Перенаправление ошибки в TRY/CATCH
--TRY CATCH – это конструкция для обработки ошибок

--Поймать ошибочную попытку вставить явное значение в столбец с ID, где IDENTITY_INSERT установлен в OFF
BEGIN TRY
   INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, 'Иванов', 'Иван', '89001232012', 0)
END TRY
BEGIN CATCH
	PRINT 'Ошибка! Нельзя вставить значение ID явно!'
END CATCH

-------------------------Создание процедуры обработки ошибок в блоке CATCH с использованием функций ERROR

--Поймать ошибочную попытку вставить явное значение в столбец с ID, где IDENTITY_INSERT установлен в OFF
BEGIN TRY
    INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, 'Иванов', 'Иван', '89001232012', 0)
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS error_num, ERROR_MESSAGE() AS error_mes
END CATCH

-------------------------Использование THROW, чтобы передать сообщение об ошибке клиенту

--THROW нужен для вызова исключения
--Поймать ошибочную попытки вставить явное значение в столбец с ID, где IDENTITY_INSERT установлен в OFF
BEGIN TRY
    INSERT Clients(ID_client, Surname, Name, Phone_number, Bonus) 
	VALUES (1, 'Иванов', 'Иван', '89001232012', 0)
END TRY
BEGIN CATCH
	THROW 51000, 'Ошибка! Нельзя вставить значение ID явно!', 1
END CATCH

-------------------------Контроль транзакций с BEGIN и COMMIT

--BEGIN TRANSACTION – команда служит для определения начала транзакции
--COMMIT TRANSACTION – с помощью данной команды SQL серверу  сообщается об успешном завершении транзакции,
--и о том, что все изменения, которые были выполнены, необходимо сохранить на постоянной основе

--Выполнить два изменения в одной транзакции
BEGIN TRANSACTION
	UPDATE Flowers SET Price = 700
	WHERE FlowerID = 1;

	UPDATE Bouquets SET Price = 50000
	WHERE BouquetID = 11;
COMMIT TRANSACTION

SELECT * FROM Flowers
SELECT * FROM Bouquets

-------------------------Использование XACT_ABORT

--XACT_ABORT – это параметр, который указывает SQL Server, 
--выполнять ли откат всей транзакции
--в случае возникновения ошибки в инструкциях этой транзакции

SET XACT_ABORT ON
BEGIN TRANSACTION
	UPDATE Flowers SET Price = 100
	WHERE FlowerID = 1;

	UPDATE Bouquets SET Price = null
	WHERE BouquetID = 11
COMMIT TRANSACTION

-------------------------Добавление логики обработки транзакций в блоке CATCH

--Выполнить два изменения в одной транзакции с явной ошибкой
--(поймать исключение, при котором все изменения откатятся назад)
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









