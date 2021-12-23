﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Заголовок = НСтр("ru = 'Выбор обработчиков для перезапуска отложенного обновления'");
	
	УстановитьУсловноеОформление();
	ЗаполнитьСписокОбработчиков(Параметры.ВыбранныеОбработчики.ВыгрузитьЗначения());
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокОбработчиков

&НаКлиенте
Процедура СписокОбработчиковВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Элемент.ТекущиеДанные.Выбран = Не Элемент.ТекущиеДанные.Выбран;
КонецПроцедуры

&НаКлиенте
Процедура СписокОбработчиковПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура СписокОбработчиковПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура СписокОбработчиковПередНачаломИзменения(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Готово(Команда)
	Закрыть(ВыбранныеОбработчики());
КонецПроцедуры

&НаКлиенте
Процедура Выбрать(Команда)
	
	Для Каждого ИдентификаторСтроки Из Элементы.СписокОбработчиков.ВыделенныеСтроки Цикл
		ВыделеннаяСтрока = СписокОбработчиков.НайтиПоИдентификатору(ИдентификаторСтроки);
		ВыделеннаяСтрока.Выбран = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьВыбор(Команда)
	Для Каждого ИдентификаторСтроки Из Элементы.СписокОбработчиков.ВыделенныеСтроки Цикл
		ВыделеннаяСтрока = СписокОбработчиков.НайтиПоИдентификатору(ИдентификаторСтроки);
		ВыделеннаяСтрока.Выбран = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьВыборВсех(Команда)
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("Выбран", Истина);
	НайденныеСтроки = СписокОбработчиков.НайтиСтроки(ПараметрыПоиска);
	Для Каждого Строка Из НайденныеСтроки Цикл
		Строка.Выбран = Ложь;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ИмяОбработчика.Имя);
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Статус.Имя);
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Версия.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("СписокОбработчиков.Выбран");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветФона", WebЦвета.Роса);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокОбработчиков(ВыбранныеОбработчики)
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыОбработчиковОбновления.Выполнен);
	Запрос.УстановитьПараметр("РежимВыполненияОтложенногоОбработчика", Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	РегистрСведенийОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика,
		|	РегистрСведенийОбработчикиОбновления.Статус КАК Статус,
		|	РегистрСведенийОбработчикиОбновления.Версия КАК Версия
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК РегистрСведенийОбработчикиОбновления
		|ГДЕ
		|	РегистрСведенийОбработчикиОбновления.Статус = &Статус
		|	И РегистрСведенийОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика = &РежимВыполненияОтложенногоОбработчика";
	Обработчики = Запрос.Выполнить().Выгрузить();
	Обработчики.Колонки.Добавить("Выбран", Новый ОписаниеТипов("Булево"));
	
	Для Каждого ВыбранныйОбработчик Из ВыбранныеОбработчики Цикл
		НайденныйОбработчик = Обработчики.Найти(ВыбранныйОбработчик, "ИмяОбработчика");
		НайденныйОбработчик.Выбран = Истина;
	КонецЦикла;
	
	ЗначениеВРеквизитФормы(Обработчики, "СписокОбработчиков");
КонецПроцедуры

&НаСервере
Функция ВыбранныеОбработчики()
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("Выбран", Истина);
	ВыбранныеОбработчики = СписокОбработчиков.Выгрузить(ПараметрыОтбора, "ИмяОбработчика");
	
	Возврат ВыбранныеОбработчики.ВыгрузитьКолонку("ИмяОбработчика");
	
КонецФункции

#КонецОбласти


