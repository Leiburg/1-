﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ВариантыОтчетов

// Задать настройки формы отчета.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения
//         - Неопределено
//   КлючВарианта - Строка
//                - Неопределено
//   Настройки - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт

	Настройки.ФормироватьСразу = Истина;
	Настройки.Печать.ПолеСверху = 5;
	Настройки.Печать.ПолеСлева = 5;
	Настройки.Печать.ПолеСнизу = 5;
	Настройки.Печать.ПолеСправа = 5;
	
	Настройки.События.ПриСозданииНаСервере = Истина;
	
КонецПроцедуры

// Вызывается в обработчике одноименного события формы отчета после выполнения кода формы.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения - форма отчета.
//   Отказ - Булево - передается из параметров стандартного обработчика ПриСозданииНаСервере "как есть".
//   СтандартнаяОбработка - Булево - передается из параметров стандартного обработчика ПриСозданииНаСервере "как есть".
//
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда
		Возврат;
	КонецЕсли;
	
	// Добавление команд на командную панель.
	Если Пользователи.ЭтоПолноправныйПользователь() Тогда
		МодульОтчетыСервер = ОбщегоНазначения.ОбщийМодуль("ОтчетыСервер");
		Команда = Форма.Команды.Добавить("ПродлитьДействиеПодписей");
		Команда.Действие  = "Подключаемый_Команда";
		Команда.Заголовок = НСтр("ru = 'Продлить действие подписей'");
		Команда.Подсказка = НСтр("ru = 'Продлить действие подписей'");
		МодульОтчетыСервер.ВывестиКоманду(Форма, Команда, "Настройки");
	КонецЕсли;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ВариантыОтчетов

#КонецОбласти

#КонецОбласти
	
#Область ОбработчикиСобытий

// Параметры:
//  ДокументРезультат - ТабличныйДокумент
//  ДанныеРасшифровки - ДанныеРасшифровкиКомпоновкиДанных
//  СтандартнаяОбработка - Булево
//
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	НастройкиКомпоновщика = КомпоновщикНастроек.ПолучитьНастройки();
	
	Если НастройкиКомпоновщика.ДополнительныеСвойства.КлючВарианта = "Основной" Тогда
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить("ТребуетсяУсовершенствоватьПодписи", Истина);
		ПараметрыЗапроса.Вставить("ТребуетсяДобавитьАрхивныеМетки", Истина);
		ПараметрыЗапроса.Вставить("НеобработанныеПодписи", Истина);
	Иначе
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить(НастройкиКомпоновщика.ДополнительныеСвойства.КлючВарианта, Истина);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	Запрос = ЭлектроннаяПодписьСлужебный.ЗапросДляПродленияДостоверностиПодписей(ПараметрыЗапроса);
	УстановитьПривилегированныйРежим(Ложь);
	
	ЭлектронныеПодписи = Запрос.Выполнить().Выгрузить();
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновщика, ДанныеРасшифровки);
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ЭлектронныеПодписи", ЭлектронныеПодписи);
		
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
КонецПроцедуры

#КонецОбласти
	
#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли